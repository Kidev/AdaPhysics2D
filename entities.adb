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
      This.Mass := 0.0; -- needs to be set for each entity with ComputeMass
      This.Mat := Mat;
      This.Gravity := Grav;
   end Initialize;

   procedure ApplyForce(This : in out Entity; Force : Vec2D)
   is
   begin
      This.Force := This.Force + Force;
   end ApplyForce;

   procedure SetGravity(This : in out Entity; Grav : Vec2D)
   is
   begin
      This.Gravity := Grav;
   end SetGravity;

   procedure SetLayer(This : in out Entity; Lay : Byte)
   is
   begin
      This.Layer := Lay;
   end SetLayer;

   procedure AddLayer(This : in out Entity; Lay : Byte)
   is
   begin
      This.Layer := This.Layer or Lay;
   end AddLayer;

end Entities;
