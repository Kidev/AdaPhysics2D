with Vectors2D; use Vectors2D;
with Materials; use Materials;
with Interfaces; use Interfaces;

package Entities is

   -- List all the entity types
   type EntityTypes is (EntCircle, EntRectangle);

   -- Required for layering
   subtype Byte is Unsigned_8;

   -- Abstract superclass of all entities
   -- Lists the minimum fields for an entity to exist
   type Entity is abstract tagged record
      EntityType : EntityTypes;
      Coords : Vec2D;
      Velocity : Vec2D;
      Force : Vec2D;
      InvMass : Float;
      Mat : Material;
      Gravity : Vec2D;
      Layer : Byte := 2#10000000#;
   end record;

   -- Frees the entity
   procedure FreeEnt(This : access Entity) is abstract;

   procedure Initialize(This : out Entity; EntType : in EntityTypes;
                        Pos, Vel, Grav : in Vec2D; Mat : in Material);

   -- This must be implemented in each new entity class
   -- It converts the Material data into an inverse mass float
   procedure ComputeMass(This : in out Entity) is abstract;

   -- Apply a force to the entity
   procedure ApplyForce(This : in out Entity; Force : Vec2D);

   procedure SetGrav(This : in out Entity; Grav : Vec2D);

end Entities;
