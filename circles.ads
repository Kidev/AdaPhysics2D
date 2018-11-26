with Entities;
with Materials; use Materials;
with Vectors2D; use Vectors2D;

package Circles is

   type Circle is new Entities.Entity with record
      Radius : Float;
   end record;
   type CircleAcc is access all Circle'Class;

   -- Create a new Circle
   function Create(Pos, Vel, Grav : in Vec2D; Rad : in Float; Mat : in Material) return CircleAcc;

private

   -- Initialization of a Circle
   procedure Initialize(This : in CircleAcc;
                        Pos, Vel, Grav : in Vec2D; Rad : in Float; Mat : in Material);

   overriding
   procedure ComputeMass(This : in out Circle);

end Circles;
