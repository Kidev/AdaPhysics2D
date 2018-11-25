with Entities;
with Vectors2D; use Vectors2D;

package Rectangles is

   type Rectangle is new Entities.Entity with record
      Dim : Vec2D; -- (x => width, y => height)
   end record;
   type RectangleAcc is access all Rectangle'Class;

   -- Create a new Rectangle
   function Create(Pos, Vel, Grav, Dim : in Vec2D; Mass, Rest : in Float) return RectangleAcc;
   
   function GetWidth(This : in out Rectangle) return Float;
   function GetHeight(This : in out Rectangle) return Float;
   function GetCenter(This : in out Rectangle) return Vec2D;
   
private

   -- Initialization of a Rectangle
   procedure Initialize(This : in RectangleAcc;
                        Pos, Vel, Grav, Dim : in Vec2D; Mass, Rest : in Float);

end Rectangles;
