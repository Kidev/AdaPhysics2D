with Vectors2D; use Vectors2D;

package Entity is
   
   type EntityTypes is (Disk);
   type Entity is abstract tagged limited private;
   
private
   
   type Entity is abstract tagged limited record
      EntityType : EntityTypes;
      Coords : Vec2D;
      Velocity : Vec2D;
      InvMass : Float;
      Restitution : Float;
   end record;
   type EntityAcc is access Entity;
   
   type Collision is limited record
      A : EntityAcc;
      B : EntityAcc;
      Normal : Vec2D;
      Penetration : Float;
   end record;
   type CollisionAcc is access Collision;
   
   -- This function must be implemented in each subclass
   -- It returns true if This collides with That; else false
   -- If they collide, Collision is filled with data about the collision
   -- Each subclass must 'case when' on each That.EntityType
   function Collide(This, That : in EntityAcc; Col : in out CollisionAcc)
   return Boolean is abstract;
   
   -- This procedure is called when This collides with That
   -- It impulses on This and That so that they no longer collide
   procedure Resolve(This, That : in EntityAcc; Col : in CollisionAcc);

end Entity;
