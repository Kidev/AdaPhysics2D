with Ada.Numerics;
with Ada.Unchecked_Deallocation;

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

   overriding
   procedure ComputeMass(This : in out Circle)
   is
   begin
      This.Mass := Ada.Numerics.Pi * This.Radius * This.Radius * This.Mat.Density;
      This.InvMass := (if This.Mass = 0.0 then 0.0 else 1.0 / This.Mass);
   end ComputeMass;

   procedure FreeEnt(This : access Circle)
   is
      procedure FreeCircle is new Ada.Unchecked_Deallocation(Circle, CircleAcc);
      P : CircleAcc := CircleAcc(This);
   begin
      FreeCircle(P);
   end FreeEnt;

end Circles;
