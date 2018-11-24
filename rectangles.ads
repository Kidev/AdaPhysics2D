with Entities;
with Vectors2D; use Vectors2D;

package Rectangles is

   type Rectangle is new Entities.Entity with record
      Max : Vec2D;
   end record;
   type RectangleAcc is access all Rectangle'Class;

   -- Create a new Rectangle
   function Create(Pos, Vel, Grav, Max : in Vec2D; Mass, Rest : in Float) return RectangleAcc;

   function GetHeight(This : in out Rectangle) return Float;
   function GetWidth(This : in out Rectangle) return Float;
   
private

   -- Initialization of a Rectangle
   procedure Initialize(This : in RectangleAcc;
                        Pos, Vel, Grav, Max : in Vec2D; Mass, Rest : in Float);

end Rectangles;
