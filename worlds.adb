with Collisions; use Collisions;
with Vectors2D; use Vectors2D;
with Interfaces; use Interfaces;

package body Worlds is

   -- init world
   procedure Init(This : in out World; dt : in Float)
   is
   begin
      This.Index := 0;
      This.dt := dt;
      This.Entities := (others => null);
      This.InvalidChecker := null;
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
         IntForce(This.Entities(I), This.dt);
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
         IntVelocity(This.Entities(I), This.dt);
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
         IntForce(This.Entities(I), This.dt);
      end loop;

      for I in 0 .. Count - 1 loop
         Resolve(Cols(I));
      end loop;

      for I in 1 .. This.Index loop
         IntVelocity(This.Entities(I), This.dt);
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

   procedure IntForce(Ent : not null access Entity'Class; dt : Float)
   is
   begin
      if Ent.all.InvMass /= 0.0 then
         Ent.all.Velocity := Ent.all.Velocity + ((Ent.InvMass * Ent.Force) + Ent.Gravity) * dt;
      else
         Ent.all.Velocity := (0.0, 0.0);
      end if;
   end IntForce;

   procedure IntVelocity(Ent : not null access Entity'Class; dt : Float)
   is
   begin
      if Ent.all.InvMass /= 0.0 then
         Ent.all.Coords := Ent.all.Coords + (Ent.all.Velocity * dt);
         IntForce(Ent, dt);
      end if;
   end IntVelocity;

end Worlds;
