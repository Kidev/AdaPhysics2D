with Vectors2D; use Vectors2D;
with Materials; use Materials;
with Interfaces; use Interfaces;

package Entities is

   -- Lists all the entity types
   type EntityTypes is (EntCircle, EntRectangle);

   -- Required for layering
   subtype Byte is Unsigned_8;

   -- Abstract superclass of all entities
   -- Lists the minimum fields for an entity to exist
   type Entity is abstract tagged record
      EntityType : EntityTypes;
      Coords : Vec2D := (0.0, 0.0);
      Velocity : Vec2D := (0.0, 0.0);
      Force : Vec2D := (0.0, 0.0);
      InvMass : Float;
      Mass : Float;
      Mat : Material;
      Gravity : Vec2D := (0.0, 0.0);
      Layer : Byte := 2#00000001#;
   end record;
   pragma Pack (Entity);

   type EntityClassAcc is access all Entity'Class;

   -- Frees the entity
   procedure FreeEnt(This : access Entity) is abstract;

   -- Apply a force to the entity
   procedure ApplyForce(This : in out Entity; Force : Vec2D);

   -- Update material
   procedure ChangeMaterial(This : in out Entity'Class; NewMat : Material);

   -- Get distance between two entities
   function GetDistance(A, B : in Entity'Class) return Float;

   procedure SetGravity(This : in out Entity; Grav : Vec2D);

   procedure SetLayer(This : in out Entity; Lay : Byte);

   -- Gets the center position of an entity
   function GetPosition(This : in Entity) return Vec2D is abstract;

   procedure AddLayer(This : in out Entity; Lay : Byte);

   -- This must be implemented in each new entity class
   -- It converts the Material data into an inverse mass float
   procedure ComputeMass(This : in out Entity) is abstract;

   procedure Initialize(This : out Entity; EntType : in EntityTypes;
                        Pos, Vel, Grav : in Vec2D; Mat : in Material);

end Entities;
