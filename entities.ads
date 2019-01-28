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
      Mass : Float;
      Volume : Float;
      Mat : Material;
      Gravity : Vec2D;
      Layer : Byte := 2#00000001#;
   end record;
   pragma Pack (Entity);

   type EntityClassAcc is access all Entity'Class;

   -- Frees the entity
   procedure FreeEnt(This : access Entity) is abstract;

   -- Apply a force to the entity
   procedure ApplyForce(This : in out Entity; Force : Vec2D);

   procedure SetGravity(This : in out Entity; Grav : Vec2D);

   procedure SetLayer(This : in out Entity; Lay : Byte);

   procedure AddLayer(This : in out Entity; Lay : Byte);

   -- This must be implemented in each new entity class
   -- It converts the Material data into an inverse mass float
   procedure ComputeMass(This : in out Entity) is abstract;

   procedure Initialize(This : out Entity; EntType : in EntityTypes;
                        Pos, Vel, Grav : in Vec2D; Mat : in Material);

end Entities;
