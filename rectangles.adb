package body Rectangles is

   -- Initialization of a Rectangle
   procedure Initialize(This : in RectangleAcc;
                        Pos, Vel, Grav, Dim : in Vec2D; Mass, Rest : in Float)
   is
   begin
      Entities.Initialize(Entities.Entity(This.all),
                          Entities.EntRectangle, Pos, Vel, Grav, Mass, Rest);
      This.all.Dim := Dim;
   end Initialize;

   -- Create a new Rectangle
   function Create(Pos, Vel, Grav, Dim : in Vec2D; Mass, Rest : in Float) return RectangleAcc
   is
      TmpAcc : RectangleAcc;
   begin
      TmpAcc := new Rectangle;
      Initialize(TmpAcc, Pos, Vel, Grav, Dim, Mass, Rest);
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

end Rectangles;
