with Entities; use Entities;
with Materials; use Materials;
with Vectors2D; use Vectors2D;
with Ada.Containers.Doubly_Linked_Lists;

package Worlds is

   package DoublyLinkedListEnts is new Ada.Containers.Doubly_Linked_Lists(EntityClassAcc);
   use DoublyLinkedListEnts;

   type SearchModes is (SM_Entity, SM_Environment, SM_All);

   type ListAcc is access List;

   type EntCheckerAcc is access function(E : access Entity'Class) return Boolean;

   type World is tagged record
      Entities : ListAcc;
      Environments : ListAcc;
      MaxEntities : Natural;
      dt : Float;
      InvalidChecker : EntCheckerAcc;
      MaxSpeed : Vec2D;
   end record;
   pragma Pack (World);

   -- init world
   procedure Init(This : in out World; dt : in Float; MaxEnts : Natural := 32);

   -- clear the world (deep free)
   procedure Free(This : in out World);

   -- Add entity to the world
   procedure AddEntity(This : in out World; Ent : not null access Entity'Class);

   -- Add env to the world
   procedure AddEnvironment(This : in out World; Ent : not null access Entity'Class);

   -- Gives the world a function to check if entities are valid or not
   procedure SetInvalidChecker(This : in out World; Invalider : EntCheckerAcc);

   -- Remove entity from the world
   -- Entity is detroyed if Destroy is true
   procedure RemoveEntity(This : in out World; Ent : not null access Entity'Class; Destroy : Boolean);

   -- Remove env from the world
   -- Entity is detroyed if Destroy is true
   procedure RemoveEnvironment(This : in out World; Ent : not null access Entity'Class; Destroy : Boolean);

   -- Update the world of dt TODO make it work with the chained list
   -- procedure Step(This : in out World);

   -- Returns the closest entity to Pos in this world
   -- If SearchMode = SM_All, searches first entities, then envs (ents are "on top")
   function GetClosest(This : in out World; Pos : Vec2D; SearchMode : SearchModes := SM_All) return EntityClassAcc;

   -- Update the world of dt with low ram usage
   procedure StepLowRAM(This : in out World);

   -- Get the list of entities
   function GetEntities(This : in out World) return ListAcc;

   -- Get the list of envs
   function GetEnvironments(This : in out World) return ListAcc;

   -- Lets you set a maximum speed >= 0
   -- If max speed = 0 -> no max speed on that axis
   procedure SetMaxSpeed(This : in out World; Speed : Vec2D);

private

   -- This compute the fluid friction between That and the env That is in (in This)
   -- It should depend of the shape and speed of That
   -- It returns a positive force that will oppose the movement in the end
   function FluidFriction(This : in out World; That : access Entity'Class) return Vec2D;

   function GetDensestMaterial(This : in out World; That : access Entity'Class) return Material;

   function Archimedes(This : in out World; That : access Entity'Class) return Float;

   procedure ResetForces(Ent : not null access Entity'Class);

   procedure IntegrateForces(This : in out World; Ent : not null access Entity'Class);

   procedure IntegrateVelocity(This : in out World; Ent : not null access Entity'Class);

   -- Remove invalid entities according to InvalidChecker, if not null
   procedure CheckEntities(This : in out World);

end Worlds;
