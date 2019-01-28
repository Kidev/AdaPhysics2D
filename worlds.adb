with Collisions; use Collisions;
with Interfaces; use Interfaces;
with Circles; use Circles;
with Rectangles; use Rectangles;

package body Worlds is

   -- init world
   procedure Init(This : in out World; dt : in Float; MaxEnts : Natural := 32)
   is
   begin
      This.MaxEntities := MaxEnts;
      This.dt := dt;
      This.Entities := new List;
      This.Environments := new List;
      This.InvalidChecker := null;
   end Init;

   -- Add entity to the world
   procedure AddEntity(This : in out World; Ent : not null access Entity'Class)
   is
   begin
      if This.MaxEntities = 0
        or else This.Entities.Length + This.Environments.Length < This.MaxEntities then
         This.Entities.Append(Ent);
      end if;
   end Add;

   -- Add env to the world
   procedure AddEnvironment(This : in out World; Ent : not null access Entity'Class)
   is
   begin
      if This.MaxEntities = 0
        or else This.Entities.Length + This.Environments.Length < This.MaxEntities then
         This.Environments.Append(Ent);
      end if;
   end Add;

   -- clear the world (deep free)
   procedure Free(This : in out World)
   is
      procedure FreeList is new Ada.Unchecked_Deallocation(List, ListAcc);
   begin
      for E of This.Entities loop
         FreeEnt(E);
      end loop;
      for E of This.Environments loop
         FreeEnt(E);
      end loop;
      FreeList(This.Entities);
      FreeList(This.Environments);
   end Free;

   -- Gives the world a function to check if entities are valid or not
   procedure SetInvalidChecker(This : in out World; Invalider : EntCheckerAcc)
   is
   begin
      if Invalider /= null then
         This.InvalidChecker := Invalider;
      end if;
   end SetInvalidChecker;

   -- Remove entity from the world
   procedure Remove(This : in out World; Ent : not null access Entity'Class; Destroy : Boolean)
   is
   begin
      This.Entities.Delete(This.Entities.Find(Ent));
      if Destroy then
         FreeEnt(Ent);
      end if;
   end Remove;

   -- Remove entity from the world
   procedure RemoveEnv(This : in out World; Ent : not null access Entity'Class; Destroy : Boolean)
   is
   begin
      This.Environments.Delete(This.Environments.Find(Ent));
      if Destroy then
         FreeEnt(Ent);
      end if;
   end Remove;

   function GetEntities(This : in out World) return ListAcc
   is
   begin
      return This.Entities;
   end GetEntities;

   function GetEnvironments(This : in out World) return ListAcc
   is
   begin
      return This.Environments;
   end GetEnvironments;

   -- This procedure will perform Collision resolution
   -- in a way that doesnt require as much RAM as the Step
   -- one: it will not store all collisions and then resolve
   -- them. Instead, it will resolve them one at a time
   -- The result might be less realistic, but more efficient
   procedure StepLowRAM(This : in out World)
   is
      A, B : access Entity'Class;
      C1, C2 : Cursor;
      Col : Collision;
   begin

      for E of This.Entities loop
         This.IntForce(E);
      end loop;

      -- Broad phase
      C1 := This.Entities.First;
      while C1 /= No_Element loop
         A := Element(C1);
         C2 := Next(C1);
         while C2 /= No_Element loop
            B := Element(C2);
            -- Narrow phase
            if (A.all.Layer and B.all.Layer) /= 2#00000000#
              and then Collide(A, B, Col) then
               Resolve(Col);
               PosCorrection(Col);
            end if;
            C2 := Next(C2);
         end loop;
         C1 := Next(C1);
      end loop;

      for E of This.Entities loop
         This.IntVelocity(E);
      end loop;

      for E of This.Entities loop
         ResetForces(E);
      end loop;

      This.CheckEntities;

   end StepLowRAM;

   -- Update the world of dt
--     procedure Step(This : in out World)
--     is
--        Cols : List;
--        Col : access Collision;
--        A, B : access Entity'Class;
--        C1, C2 : Cursor;
--        Count : ColIndex := 0;
--     begin
--
--        -- Broad phase
--        C1 := This.Entities.First;
--        while C1 /= No_Element loop
--           A := Element(C1);
--           C2 := Next(C1);
--           while C2 /= No_Element loop
--              B := Element(C2);
--              -- Narrow phase
--              Col := new Collision;
--              if (A.all.Layer and B.all.Layer) /= 2#00000000#
--                and then Collide(A, B, Col) then
--                 Resolve(Col);
--                 PosCorrection(Col);
--              end if;
--              C2 := Next(C2);
--           end loop;
--           C1 := Next(C1);
--        end loop;
--
--        -- Broad phase
--        for I in 1 .. This.Index loop
--           A := This.Entities(I);
--           for J in I .. This.Index loop
--              B := This.Entities(J);
--              -- Narrow phase
--              if A /= B and then (A.all.Layer and B.all.Layer) /= 2#00000000#
--                and then Collide(A, B, Cols(Count)) then
--                 Count := Count + 1;
--              end if;
--           end loop;
--        end loop;
--
--        for I in 1 .. This.Index loop
--           This.IntForce(This.Entities(I));
--        end loop;
--
--        for I in 0 .. Count - 1 loop
--           Resolve(Cols(I));
--        end loop;
--
--        for I in 1 .. This.Index loop
--           This.IntVelocity(This.Entities(I));
--        end loop;
--
--        for I in 0 .. Count - 1 loop
--           PosCorrection(Cols(I));
--        end loop;
--
--        for I in 1 .. This.Index loop
--           ResetForces(This.Entities(I));
--        end loop;
--
--        This.CheckEntities;
--
--     end Step;

   -- TODO editing the list while iterating might lead to weird stuff
   procedure CheckEntities(This : in out World)
   is
   begin
      if This.InvalidChecker /= null then
         for E of This.Entities loop
            if This.InvalidChecker.all(E) then
               This.Remove(E, True);
            end if;
         end loop;
      end if;
   end CheckEntities;

   procedure ResetForces(Ent : not null access Entity'Class)
   is
   begin
      Ent.Force := Vec2D'(x => 0.0, y => 0.0);
   end ResetForces;

   -- TODO
   -- for each env it is in, TotalCoef += Rho_env * Area_overlap_ent_env
   -- approximate circles with rectangles
   -- x_overlap = Math.max(0, Math.min(rect1.right, rect2.right) - Math.max(rect1.left, rect2.left));
   -- y_overlap = Math.max(0, Math.min(rect1.bottom, rect2.bottom) - Math.max(rect1.top, rect2.top));
   -- overlapArea = x_overlap * y_overlap;
   function Archimedes(This : in out World; That : access Entity'Class) return Float
   is
      TotalCoef : Float := 0.0; -- >= 0.0
   begin
      if This.Environments.Length = 0 then
         return 0.0;
      end if;
      return TotalCoef;
   end ArchimedesPrinciple;

   function GetMostDenseMaterial(This : in out World; That : access Entity'Class) return Material
   is
   begin
      return VACUUM;
   end GetMostDenseMaterial;

   -- TODO
   -- This compute the fluid friction between That and the env That is in (in This)
   -- It should depend of the shape and speed of That
   -- It returns a positive force that will oppose the movement in the end
   -- Cx_circle : 0.47 | Cx_rect : 1.05
   -- S_circle : 3.14 * This.Radius | S_rect : (That.Dim.x + That.Dim.y) / 2.0;
   -- k_circle : 6.0 * 3.14 * This.Radius | k_rect : 6.0 * 3.14 * (That.Dim.x + That.Dim.y) / 2.0
   function FluidFriction(This : in out World; That : access Entity'Class) return Vec2D
   is
      QuadraticLimit : constant Float := 5.0;
   begin
      if This.Environments.Length = 0 then
         return (0.0, 0.0);
      end if;

      declare
         MostDenseMat : Material := This.GetMostDenseMaterial(That);
         Density : Float := MostDenseMat.Density;
         Viscosity : Float := MostDenseMat.Viscosity;
      begin
         if Density = 0.0 or else Viscosity = 0.0 then
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

               Rho : constant Float := Density; -- Density for the env
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

            Nu : constant Float := Viscosity * Density; -- viscosity coeff for env
            k : constant Float := GetK(That); -- shape coeff for That
         begin
            return Nu * k * That.Velocity;
         end;
      end;
   end FluidFriction;

   -- F: custom force | m: mass | g: grav acc | f(v) >= 0: dynamic friction | pV: density * volume
   -- m * a = F + mg - f(v) - pVg
   -- m * dv / dt = F + mg - f(v) - pVg
   -- dv = (dt/m) * (F + mg - f(v) - pVg)
   -- dv = (dt/m) * (F + (m - pV)*g - f(v));
   -- Let SF = (F + (m - pV)*g - f(v));
   -- dv = (dt/m) * SF;
   -- v = v + dv on dt
   -- v = v + (dt * SF)/m;
   procedure IntForce(This : in out World; Ent : not null access Entity'Class)
   is
   begin
      if Ent.all.InvMass /= 0.0 then
	declare
            --SF : constant Vec2D := (((Ent.Force - This.FluidFriction(Ent)) * Ent.InvMass) + Ent.Gravity);
            SF : constant Vec2D := Ent.Force + (Ent.Mass - This.Archimedes(Ent)) * Ent.Gravity - This.FluidFriction(Ent);
	begin
            Ent.all.Velocity := Ent.all.Velocity + (SF * This.dt * Ent.InvMass);
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
