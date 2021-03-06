with Entities; use Entities;
with Materials; use Materials;
with Vectors2D; use Vectors2D;

package Rectangles is

   type Rectangle is new Entities.Entity with record
      Dim : Vec2D; -- (x => width, y => height)
   end record;
   pragma Pack (Rectangle);

   type RectangleAcc is access all Rectangle;

   -- Create a new Rectangle
   function Create(Pos, Vel, Grav, Dim : in Vec2D; Mat : in Material) return EntityClassAcc;
   
   function GetWidth(This : in Rectangle) return Float;
   function GetHeight(This : in Rectangle) return Float;
   function GetCenter(This : in Rectangle) return Vec2D;
   
   overriding
   function GetPosition(This : in Rectangle) return Vec2D;
   
private

   -- Initialization of a Rectangle
   procedure Initialize(This : in RectangleAcc;
                        Pos, Vel, Grav, Dim : in Vec2D; Mat : in Material);
   
   overriding
   procedure ComputeMass(This : in out Rectangle);
   
   overriding
   procedure FreeEnt(This : access Rectangle);

end Rectangles;
