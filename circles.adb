package body Circles is
   
   -- Initialization of a Circle
   procedure Initialize(This : in CircleAcc;
                        Pos, Vel : in Vec2D; Mass, Rest, Grav, Rad : in Float)
   is
   begin
      Entities.Initialize(Entities.Entity(This.all),
                          Entities.EntCircle, Pos, Vel, Mass, Rest, Grav);
      This.all.Radius := Rad;
   end Initialize;  
  
   -- Create a new Circle
   function Create(Pos, Vel : in Vec2D; Mass, Rest, Grav, Rad : in Float) return CircleAcc
   is
      TmpAcc : CircleAcc;
   begin
      TmpAcc := new Circle;
      Initialize(TmpAcc, Pos, Vel, Mass, Rest, Grav, Rad);
      return TmpAcc;
   end Create;

end Circles;
