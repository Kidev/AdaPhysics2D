with Entities; use Entities;
with Circles;
with Rectangles;
with Vectors2D; use Vectors2D;

package Collisions is

   -- Collision type, holding meaningful information
   -- about a collision
   type Collision is limited record
      A : access Entity'Class;
      B : access Entity'Class;
      Normal : Vec2D;
      Penetration : Float;
   end record;

   -- Return True if A collides with B; else false
   -- Fills Col with data about the collision
   function Collide(A, B : not null access Entity'Class; Col : out Collision)
                    return Boolean;

   -- This procedure is called when there is a collision
   -- It impulses on A and B so that they no longer collide
   procedure Resolve(Col : in Collision);

   -- This procedure, called after the collision resolution
   -- Ensures that objects do not sink in each other
   procedure PosCorrection(Col : in Collision);

private

   function CircleOnX(A : in Circles.CircleAcc; B : access Entity'Class; Col : out Collision)
                      return Boolean;
   function CircleOnCircle(A, B : in Circles.CircleAcc; Col : out Collision)
                           return Boolean;

   function RectangleOnX(A : in Rectangles.RectangleAcc; B : access Entity'Class; Col : out Collision)
                         return Boolean;

   function RectangleOnRectangle(A, B : in Rectangles.RectangleAcc; Col : out Collision)
                                 return Boolean;

   function RectangleOnCircle(A : in Rectangles.RectangleAcc; B : in Circles.CircleAcc; Col : out Collision)
                         return Boolean;

end Collisions;
