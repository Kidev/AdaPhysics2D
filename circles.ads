with Entities; use Entities;

package Circles is
   
   type Circle is new Entity with null record;
   type CircleAcc is access all Circle'Class;
  
   -- Create a new Circle
   function Create(Pos, Vel : in Vec2D; Mass, Rest, Grav : in Float) return CircleAcc;
   
private
   
   -- Initialization of a Circle
   procedure Initialize(This : in out CircleAcc;
                        Pos, Vel : in Vec2D; Mass, Rest, Grav : in Float);

   -- Defines the collision algorithm for a Circle
   overriding
   function Collide(This, That : in CircleAcc; in out Col : Collision)
   return Boolean is abstract;

end Circles;
