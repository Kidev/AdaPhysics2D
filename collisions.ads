limited with Entities;
with Vectors2D; use Vectors2D;

package Collisions is

   -- Collision type, holding meaningful information
   -- about a collision
   type Collision is limited record
      A : access Entities.Entity'Class;
      B : access Entities.Entity'Class;
      Normal : Vec2D;
      Penetration : Float;
   end record;
   
   -- This procedure is called when there is a collision
   -- It impulses on A and B so that they no longer collide
   procedure Resolve(Col : in Collision);
   
   -- This procedure, called after the collision resolution
   -- Ensures that objects do not sink in each other
   procedure PosCorrection(Col : in Collision);

end Collisions;
