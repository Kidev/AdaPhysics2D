package body Circles is

   -- Initialization of a Circle
   procedure Initialize(This : in CircleAcc;
                        Pos, Vel, Grav : in Vec2D; Mass, Rest, Rad : in Float)
   is
   begin
      Entities.Initialize(Entities.Entity(This.all),
                          Entities.EntCircle, Pos, Vel, Grav, Mass, Rest);
      This.all.Radius := Rad;
   end Initialize;

   -- Create a new Circle
   function Create(Pos, Vel, Grav : in Vec2D; Mass, Rest, Rad : in Float) return CircleAcc
   is
      TmpAcc : CircleAcc;
   begin
      TmpAcc := new Circle;
      Initialize(TmpAcc, Pos, Vel, Grav, Mass, Rest, Rad);
      return TmpAcc;
   end Create;

end Circles;
