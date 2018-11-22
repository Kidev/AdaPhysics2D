with Vectors2D; use Vectors2D;
with Collisions; use Collisions;

package Entities is
      
   -- List all the entity types
   type EntityTypes is (EntCircle);

   -- Abstract superclass of all entities
   -- Lists the minimum fields for an entity to exist
   type Entity is abstract tagged record
      EntityType : EntityTypes;
      Coords : Vec2D;
      Velocity : Vec2D;
      InvMass : Float;
      Restitution : Float;
      Gravity : Float;
   end record;
   
private
   
   procedure Initialize(This : out Entity; EntType : in EntityTypes;
                        Pos, Vel : in Vec2D; Mass, Rest, Grav : in Float); 

   -- This function must be implemented in each subclass
   -- It returns true if This collides with That; else false
   -- It fills Col with Collision data
   -- Each subclass must 'case when' on each That.EntityType
   function Collide(This, That : access Entity'Class; Col : out Collision)
   return Boolean is abstract;

end Entities;
