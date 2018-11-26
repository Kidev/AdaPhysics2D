package body Entities is

   procedure Initialize(This : out Entity; EntType : in EntityTypes;
                        Pos, Vel, Grav : in Vec2D; Mat : in Material)
   is
   begin
      This.EntityType := EntType;
      This.Coords := Pos;
      This.Velocity := Vel;
      This.Force := Vec2D'(x => 0.0, y => 0.0);
      This.InvMass := 0.0; -- needs to be set for each entity with ComputeMass
      This.Mat := Mat;
      This.Gravity := Grav;
   end Initialize;

end Entities;
