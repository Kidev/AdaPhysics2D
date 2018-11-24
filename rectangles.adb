package body Rectangles is

   -- Initialization of a Rectangle
   procedure Initialize(This : in RectangleAcc;
                        Pos, Vel, Grav, Max : in Vec2D; Mass, Rest : in Float)
   is
   begin
      Entities.Initialize(Entities.Entity(This.all),
                          Entities.EntRectangle, Pos, Vel, Grav, Mass, Rest);
      This.all.Max := Max;
   end Initialize;

   -- Create a new Rectangle
   function Create(Pos, Vel, Grav, Max : in Vec2D; Mass, Rest : in Float) return RectangleAcc
   is
      TmpAcc : RectangleAcc;
   begin
      TmpAcc := new Rectangle;
      Initialize(TmpAcc, Pos, Vel, Grav, Max, Mass, Rest);
      return TmpAcc;
   end Create;
   
   function GetHeight(This : in out Rectangle) return Float
   is
   begin
      return This.Max.y - This.Coords.y;
   end GetHeight;

   function GetWidth(This : in out Rectangle) return Float
   is
   begin
      return This.Max.x - This.Coords.x;
   end GetWidth;

end Rectangles;
