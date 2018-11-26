with Collisions; use Collisions;
with Vectors2D; use Vectors2D;

package body Worlds is

   -- init world
   procedure Init(This : in out World; dt : in Float)
   is
   begin
      This.Index := 0;
      This.dt := dt;
      This.Entities := (others => null);
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

   -- Remove entity from the world
   procedure Remove(This : in out World; Ent : not null access Entity'Class)
   is
      Ents : constant EArray := This.GetEntities;
   begin
      for I in Ents'Range loop
         if Ents(I) = Ent then
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

   -- Update the world of dt
   procedure Step(This : in out World)
   is
      type ColArray is array (EntArrIndex) of Collision;
      Cols : ColArray;
      A, B : access Entity'Class;
      Count : EntArrIndex := 0;
   begin
      -- Broad phase
      for I in 1 .. This.Index loop
         A := This.Entities(I);
         for J in I .. This.Index loop
            B := This.Entities(J);
            if A /= B and then Collide(A, B, Cols(Count)) then
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

   end Step;

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
