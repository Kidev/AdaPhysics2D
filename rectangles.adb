with Ada.Unchecked_Deallocation;

package body Rectangles is

   -- Initialization of a Rectangle
   procedure Initialize(This : in RectangleAcc;
                        Pos, Vel, Grav, Dim : in Vec2D; Mat : in Material)
   is
   begin
      Entities.Initialize(Entities.Entity(This.all),
                          Entities.EntRectangle, Pos, Vel, Grav, Mat);
      This.all.Dim := Dim;
      This.all.ComputeMass;
   end Initialize;

   -- Create a new Rectangle
   function Create(Pos, Vel, Grav, Dim : in Vec2D; Mat : in Material) return RectangleAcc
   is
      TmpAcc : RectangleAcc;
   begin
      TmpAcc := new Rectangle;
      Initialize(TmpAcc, Pos, Vel, Grav, Dim, Mat);
      return TmpAcc;
   end Create;
   
   function GetHeight(This : in out Rectangle) return Float
   is
   begin
      return This.Dim.y;
   end GetHeight;

   function GetWidth(This : in out Rectangle) return Float
   is
   begin
      return This.Dim.x;
   end GetWidth;
   
   function GetCenter(This : in out Rectangle) return Vec2D
   is
   begin
      return This.Coords + (This.Dim / 2.0);
   end GetCenter;
   
   procedure ComputeMass(This : in out Rectangle)
   is
   begin
      This.Mass := This.Dim.x * This.Dim.y * This.Mat.Density;
      This.InvMass := (if This.Mass = 0.0 then 0.0 else 1.0 / This.Mass);
   end ComputeMass;
   
   procedure FreeEnt(This : access Rectangle)
   is
      procedure FreeRectangle is new Ada.Unchecked_Deallocation(Rectangle, RectangleAcc);
      P : RectangleAcc := RectangleAcc(This);
   begin
      FreeRectangle(P);
   end FreeEnt;

end Rectangles;
