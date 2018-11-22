package body Circles is
   
   -- Initialization of a Circle
   procedure Initialize(This : in out CircleAcc;
                        Pos, Vel : in Vec2D; Mass, Rest, Grav : in Float)
   is
      Initialize(Circle(This.all), EntCircle, Pos, Vel, Mass, Rest, Grav);
   end Initialize;  
  
   -- Create a new Circle
   function Create(Pos, Vel : in Vec2D; Mass, Rest, Grav : in Float) return CircleAcc
   is
      TmpAcc : CircleAcc;
   begin
      TmpAcc := new Circle;
      Initialize(TmpAcc, Pos, Vel, Mass, Rest, Grav);
      return TmpAcc;
   end Create;
   
   -- Defines the collision algorithm for a Circle
   overriding
   function Collide(This, That : in CircleAcc; in out Col : Collision) return Boolean
   is
   begin
      return False;
   end Collide;

end Circles;
