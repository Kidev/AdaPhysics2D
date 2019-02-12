with Entities; use Entities;
with Materials; use Materials;
with Vectors2D; use Vectors2D;

package Circles is

   type Circle is new Entities.Entity with record
      Radius : Float;
   end record;
   pragma Pack (Circle);

   type CircleAcc is access all Circle;

   -- Create a new Circle
   function Create(Pos, Vel, Grav : in Vec2D; Rad : in Float; Mat : in Material) return EntityClassAcc;

   overriding
   function GetPosition(This : in Circle) return Vec2D;

private

   -- Initialization of a Circle
   procedure Initialize(This : in CircleAcc;
                        Pos, Vel, Grav : in Vec2D; Rad : in Float; Mat : in Material);

   overriding
   procedure ComputeMass(This : in out Circle);

   overriding
   procedure FreeEnt(This : access Circle);

end Circles;
