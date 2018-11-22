package body Entities is

   procedure Initialize(This : out Entity; EntType : in EntityTypes;
                        Pos, Vel : in Vec2D; Mass, Rest, Grav : in Float)
   is
   begin
      This.EntityType = EntType;
      This.Coords = Pos;
      This.Velocity = Vel;
      This.InvMass = (if Mass = 0.0 then 0.0 else 1.0 / Mass);
      This.Restitution = Rest;
      This.Gravity = Grav;
   end Initialize;

end Entities;
