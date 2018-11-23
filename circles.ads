with Entities;
with Vectors2D; use Vectors2D;

package Circles is
   
   type Circle is new Entities.Entity with record
      Radius : Float;
   end record;
   type CircleAcc is access all Circle'Class;
  
   -- Create a new Circle
   function Create(Pos, Vel : in Vec2D; Mass, Rest, Grav, Rad : in Float) return CircleAcc;
   
private
   
   -- Initialization of a Circle
   procedure Initialize(This : in CircleAcc;
                        Pos, Vel : in Vec2D; Mass, Rest, Grav, Rad : in Float);

end Circles;
