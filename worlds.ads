with Entities; use Entities;
with Materials; use Materials;
with Vectors2D; use Vectors2D;
with Ada.Containers.Doubly_Linked_Lists;
with Links; use Links;

package Worlds is

   package EntsList is new Ada.Containers.Doubly_Linked_Lists(EntityClassAcc);
   type EntsListAcc is access EntsList.List;

   package LinksList is new Ada.Containers.Doubly_Linked_Lists(LinkAcc);
   type LinksListAcc is access LinksList.List;

   type SearchModes is (SM_Entity, SM_Environment, SM_All);

   type EntCheckerAcc is access function(E : access Entity'Class) return Boolean;

   type World is tagged record
      Entities : EntsListAcc;
      Environments : EntsListAcc;
      Links : LinksListAcc;
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

   -- Add a link between two entities (rope, spring...)
   procedure LinkEntities(This : in out World; A, B : EntityClassAcc; Factor : Float);
   procedure LinkEntities(This : in out World; A, B : EntityClassAcc; LinkType : LinkTypes);

   -- Remove all links tied to the passed entity
   procedure UnlinkEntity(This : in out World; E : EntityClassAcc);

   -- Increases the number of max entities by Count
   procedure IncreaseMaxEntities(This : in out World; Count : Positive);

   -- Gives the world a function to check if entities are valid or not
   procedure SetInvalidChecker(This : in out World; Invalider : EntCheckerAcc);

   -- Remove entity from the world
   -- Entity is detroyed if Destroy is true
   procedure RemoveEntity(This : in out World; Ent : EntityClassAcc; Destroy : Boolean);

   -- Remove env from the world
   -- Entity is detroyed if Destroy is true
   procedure RemoveEnvironment(This : in out World; Ent : not null access Entity'Class; Destroy : Boolean);

   -- Update the world of dt TODO make it work with the chained list
   -- procedure Step(This : in out World);

   -- Returns the entity in which Pos is
   -- If SearchMode = SM_All, searches first entities, then envs (ents are "on top")
   function GetClosest(This : in out World; Pos : Vec2D; SearchMode : SearchModes := SM_All) return EntityClassAcc;

   -- Update the world of dt with low ram usage
   procedure StepLowRAM(This : in out World);

   -- Get the list of entities
   function GetEntities(This : in World) return EntsListAcc;

   -- Get the list of envs
   function GetEnvironments(This : in World) return EntsListAcc;

   -- Get the list of links
   function GetLinks(This : in World) return LinksListAcc;

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

   function Tension(This : in out World; Ent : access Entity'Class) return Vec2D;

   procedure ResetForces(Ent : not null access Entity'Class);

   procedure IntegrateForces(This : in out World; Ent : not null access Entity'Class);

   procedure IntegrateVelocity(This : in out World; Ent : not null access Entity'Class);

   -- Remove invalid entities according to InvalidChecker, if not null
   procedure CheckEntities(This : in out World);

end Worlds;
