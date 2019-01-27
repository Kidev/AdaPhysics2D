with Collisions; use Collisions;
with Interfaces; use Interfaces;
with Circles; use Circles;
with Rectangles; use Rectangles;

package body Worlds is

   -- init world
   procedure Init(This : in out World; dt : in Float)
   is
   begin
      This.Index := 0;
      This.dt := dt;
      This.Entities := (others => null);
      This.InvalidChecker := null;
      This.Env := VACUUM;
   end Init;

   -- Add entity to the world
   procedure Add(This : in out World; Ent : not null access Entity'Class)
   is
   begin
      if This.Index < EntArrIndex'Last then
         This.Index := This.Index + 1;
         This.Entities(This.Index) := Ent;
      end if;
   end Add;

   -- Gives the world a function to check if entities are valid or not
   procedure SetInvalidChecker(This : in out World; Invalider : EChecker)
   is
   begin
      if Invalider /= null then
         This.InvalidChecker := Invalider;
      end if;
   end SetInvalidChecker;

   -- Remove entity from the world
   procedure Remove(This : in out World; Ent : not null access Entity'Class; Destroy : Boolean)
   is
      Ents : constant EArray := This.GetEntities;
   begin
      for I in Ents'Range loop
         if Ents(I) = Ent then
            if Destroy then
               FreeEnt(Ent);
            end if;
            This.Entities(I) := null;
            for J in I + 1 .. Ents'Last loop
               This.Entities(J - 1) := Ents(J);
            end loop;
            This.Index := This.Index - 1;
            exit;
         end if;
      end loop;
   end Remove;

   function GetEntities(This : in out World) return EArray
   is
      Ret : EArray (1 .. This.Index);
   begin
      for I in Ret'Range loop
         Ret(I) := This.Entities(I);
      end loop;
      return Ret;
   end;

   -- This procedure will perform Collision resolution
   -- in a way that doesnt require as much RAM as the Step
   -- one: it will not store all collisions and then resolve
   -- them. Instead, it will resolve them one at a time
   -- The result might be less realistic, but more efficient
   procedure StepLowRAM(This : in out World)
   is
      A, B : access Entity'Class;
      Col : Collision;
   begin

      for I in 1 .. This.Index loop
         This.IntForce(This.Entities(I));
      end loop;

      -- Broad phase
      for I in 1 .. This.Index loop
         A := This.Entities(I);
         for J in I .. This.Index loop
            B := This.Entities(J);
            -- Narrow phase
            if A /= B and then (A.all.Layer and B.all.Layer) /= 2#00000000#
              and then Collide(A, B, Col) then
               Resolve(Col);
               PosCorrection(Col);
            end if;
         end loop;
      end loop;

      for I in 1 .. This.Index loop
         This.IntVelocity(This.Entities(I));
      end loop;

      for I in 1 .. This.Index loop
         ResetForces(This.Entities(I));
      end loop;

      This.CheckEntities;

   end StepLowRAM;

   -- Update the world of dt
   procedure Step(This : in out World)
   is
      -- TODO the 2 lines below crashes the RAM on STM32 when This.Index >= 13
      -- The number of max collisions would be 78, and its too much for the RAM
      subtype ColIndex is Natural range 0 .. ((This.Index * (This.Index - 1)) / 2);
      type ColArray is array (ColIndex) of Collision;
      Cols : ColArray;
      A, B : access Entity'Class;
      Count : ColIndex := 0;
   begin
      -- Broad phase
      for I in 1 .. This.Index loop
         A := This.Entities(I);
         for J in I .. This.Index loop
            B := This.Entities(J);
            -- Narrow phase
            if A /= B and then (A.all.Layer and B.all.Layer) /= 2#00000000#
              and then Collide(A, B, Cols(Count)) then
               Count := Count + 1;
            end if;
         end loop;
      end loop;

      for I in 1 .. This.Index loop
         This.IntForce(This.Entities(I));
      end loop;

      for I in 0 .. Count - 1 loop
         Resolve(Cols(I));
      end loop;

      for I in 1 .. This.Index loop
         This.IntVelocity(This.Entities(I));
      end loop;

      for I in 0 .. Count - 1 loop
         PosCorrection(Cols(I));
      end loop;

      for I in 1 .. This.Index loop
         ResetForces(This.Entities(I));
      end loop;

      This.CheckEntities;

   end Step;

   procedure CheckEntities(This : in out World)
   is
   begin
      if This.InvalidChecker /= null then
         declare
            Edited : Boolean := False;
            LastI : EntArrIndex := 1;
         begin
            loop
               Edited := False;
               for I in LastI .. This.Index loop
                  if This.InvalidChecker.all(This.Entities(I)) then
                     This.Remove(This.Entities(I), True);
                     Edited := True;
                     LastI := I;
                     exit;
                  end if;
               end loop;
               exit when Edited = False;
            end loop;
         end;
      end if;
   end CheckEntities;

   procedure ResetForces(Ent : not null access Entity'Class)
   is
   begin
      Ent.Force := Vec2D'(x => 0.0, y => 0.0);
   end ResetForces;

   -- Sets the env density. 0.0 disables fluid friction
   procedure SetEnvironment(This : in out World; Env : Environment)
   is
   begin
      This.Env := Env;
   end SetEnvironment;

   -- This compute the fluid friction between That and the ambiant air in This
   -- It should depend of the shape and speed of That
   -- It returns a positive force that will oppose the movement in the end
   -- Cx_circle : 0.47 | Cx_rect : 1.05
   -- S_circle : 3.14 * This.Radius | S_rect : (That.Dim.x + That.Dim.y) / 2.0;
   -- k_circle : 6.0 * 3.14 * This.Radius | k_rect : 6.0 * 3.14 * (That.Dim.x + That.Dim.y) / 2.0
   function FluidFriction(This : in out World; That : access Entity'Class) return Vec2D
   is
      QuadraticLimit : constant Float := 5.0;
   begin
      if This.Env.Density = 0.0 or else This.Env.Viscosity = 0.0 then
         return (0.0, 0.0);
      end if;
      if MagSq(That.Velocity) >= QuadraticLimit * QuadraticLimit then
         declare

            function GetCx(Ent : access Entity'Class) return Float is
            begin
               case Ent.EntityType is
                  when EntCircle => return 0.47;
                  when EntRectangle => return 1.05;
               end case;
            end GetCx;

            function GetS(Ent : access Entity'Class) return Float is
            begin
               case Ent.EntityType is
                  when EntCircle =>
                     return 3.14 * CircleAcc(Ent).Radius;
                  when EntRectangle =>
                     return (RectangleAcc(Ent).Dim.x + RectangleAcc(Ent).Dim.y) / 2.0;
               end case;
            end GetS;

            Rho : constant Float := This.Env.Density; -- Density for the env
            S : constant Float := GetS(That); -- "Area" normal to speed
            Cx : constant Float := GetCx(That); -- Drag coeff
         begin
            return 0.5 * Rho * S * Cx * Sq(That.Velocity);
         end;
      end if;
      declare

         function GetK(Ent : access Entity'Class) return Float is
         begin
            case Ent.EntityType is
               when EntCircle =>
                  return 6.0 * 3.14 * CircleAcc(Ent).Radius;
               when EntRectangle =>
                  return 6.0 * 3.14 * (RectangleAcc(Ent).Dim.x + RectangleAcc(Ent).Dim.y) / 2.0;
            end case;
         end GetK;

         Nu : constant Float := This.Env.Viscosity * This.Env.Density; -- viscosity coeff for env
         k : constant Float := GetK(That); -- shape coeff for That
      begin
         return Nu * k * That.Velocity;
      end;
   end FluidFriction;

   -- F: custom force | m: mass | g: grav acc | f(v) >= 0: dynamic friction, function of speed
   -- F = f(v) - mg [Newton's 2nd Law]
   -- F + mg - f(v) = 0
   -- F/m + g - f(v)/m = 0
   -- (F-f(v))/m + g = 0
   -- Let A = ((F-f(v))/m + g), so A = 0
   -- A + v/dt = v/dt [Euler's integration method]
   -- v = v + A*dt
   procedure IntForce(This : in out World; Ent : not null access Entity'Class)
   is
   begin
      if Ent.all.InvMass /= 0.0 then
         declare
            A : constant Vec2D := (((Ent.Force - This.FluidFriction(Ent)) * Ent.InvMass) + Ent.Gravity);
         begin
            Ent.all.Velocity := Ent.all.Velocity + (A * This.dt);
         end;
      else
         Ent.all.Velocity := (0.0, 0.0);
      end if;
   end IntForce;

   procedure IntVelocity(This : in out World; Ent : not null access Entity'Class)
   is
   begin
      if Ent.all.InvMass /= 0.0 then
         Ent.all.Coords := Ent.all.Coords + (Ent.all.Velocity * This.dt);
         This.IntForce(Ent);
      end if;
   end IntVelocity;

end Worlds;
