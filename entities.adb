package body Entities is

   procedure Initialize(This : out Entity; EntType : in EntityTypes;
                        Pos, Vel, Grav : in Vec2D; Mass, Rest : in Float)
   is
   begin
      This.EntityType := EntType;
      This.Coords := Pos;
      This.Velocity := Vel;
      This.Force := Vec2D'(x => 0.0, y => 0.0);
      This.InvMass := (if Mass = 0.0 then 0.0 else 1.0 / Mass);
      This.Restitution := Rest;
      This.Gravity := Grav;
   end Initialize;

end Entities;
