with Ada.Numerics;

package body Circles is

   -- Initialization of a Circle
   procedure Initialize(This : in CircleAcc;
                        Pos, Vel, Grav : in Vec2D; Rad : in Float; Mat : in Material)
   is
   begin
      Entities.Initialize(Entities.Entity(This.all),
                          Entities.EntCircle, Pos, Vel, Grav, Mat);
      This.all.Radius := Rad;
      This.all.ComputeMass;
   end Initialize;

   -- Create a new Circle
   function Create(Pos, Vel, Grav : in Vec2D; Rad : in Float; Mat : in Material) return CircleAcc
   is
      TmpAcc : CircleAcc;
   begin
      TmpAcc := new Circle;
      Initialize(TmpAcc, Pos, Vel, Grav, Rad, Mat);
      return TmpAcc;
   end Create;

   procedure ComputeMass(This : in out Circle)
   is
      Mass : Float;
   begin
      Mass := Ada.Numerics.Pi * This.Radius * This.Radius * This.Mat.Density;
      This.InvMass := (if Mass = 0.0 then 0.0 else 1.0 / Mass);
   end ComputeMass;

end Circles;
