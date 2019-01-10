with Entities; use Entities;
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
   pragma Pack (Collision);

   -- Return True if A collides with B; else false
   -- Fills Col with data about the collision
   function Collide(A, B : not null access Entity'Class; Col : out Collision)
                    return Boolean;

   -- This procedure is called when there is a collision
   -- It impulses on A and B so that they no longer collide
   -- Solves for friction too
   procedure Resolve(Col : in Collision);

   -- This procedure, called after the collision resolution
   -- Ensures that objects do not sink in each other
   procedure PosCorrection(Col : in Collision);

private

   function Friction(A, B : Float) return Float;

   function Clamp(Value, Min, Max : Float) return Float;

   function CircleOnCircle(Col : in out Collision) return Boolean;

   function RectangleOnRectangle(Col : in out Collision) return Boolean;

   function RectangleOnCircle(Col : in out Collision) return Boolean;

   function CircleOnRectangle(Col : in out Collision) return Boolean;

end Collisions;
