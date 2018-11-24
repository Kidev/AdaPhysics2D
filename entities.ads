with Vectors2D; use Vectors2D;

package Entities is

   -- List all the entity types
   type EntityTypes is (EntCircle, EntRectangle);

   -- Abstract superclass of all entities
   -- Lists the minimum fields for an entity to exist
   type Entity is abstract tagged record
      EntityType : EntityTypes;
      Coords : Vec2D;
      Velocity : Vec2D;
      Force : Vec2D;
      InvMass : Float;
      Restitution : Float;
      Gravity : Vec2D;
   end record;

   procedure Initialize(This : out Entity; EntType : in EntityTypes;
                        Pos, Vel, Grav : in Vec2D; Mass, Rest : in Float);

end Entities;
