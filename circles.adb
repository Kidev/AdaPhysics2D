package body Circles is
   
   -- Initialization of a Circle
   procedure Initialize(This : in CircleAcc;
                        Pos, Vel : in Vec2D; Mass, Rest, Grav : in Float)
   is
   begin
      Entities.Initialize(Entity(This.all), EntCircle, Pos, Vel, Mass, Rest, Grav);
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

end Circles;
