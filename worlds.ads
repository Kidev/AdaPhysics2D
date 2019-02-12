with Entities; use Entities;
with Vectors2D; use Vectors2D;
with Ada.Containers.Doubly_Linked_Lists;
with Links; use Links;
with Collisions; use Collisions;

package Worlds is

   package EntsList is new Ada.Containers.Doubly_Linked_Lists(EntityClassAcc);
   type EntsListAcc is access EntsList.List;

   package LinksList is new Ada.Containers.Doubly_Linked_Lists(LinkAcc);
   type LinksListAcc is access LinksList.List;

   type SearchModes is (SM_Entity, SM_Environment, SM_All);
   type StepModes is (Step_Normal, Step_LowRAM);

   type EntCheckerAcc is access function(E : EntityClassAcc) return Boolean;

   type World is tagged record
      -- Access to accesses to the entities
      Entities : EntsListAcc;
      -- Access to accesses to the environments entities
      Environments : EntsListAcc;
      -- Access to accesses to the links
      Links : LinksListAcc;
      -- Access to collisions (note this is different from the 3 above)
      Cols : ColsListAcc;
      -- Entities.len + Environments.len + Links.len < MaxEntities
      MaxEntities : Natural;
      -- Timestep
      dt : Float;
      -- Function called when World checks the validity of its entities
      InvalidChecker : EntCheckerAcc;
      -- Max speed of entities
      MaxSpeed : Vec2D;
   end record;
   pragma Pack (World);

   -- init world
   procedure Init(This : in out World; dt : in Float; MaxEnts : Natural := 32);

   procedure Step(This : in out World; Mode : StepModes := Step_Normal);

   -- clear the world (deep free)
   procedure Free(This : in out World);

   -- Add entity to the world
   procedure AddEntity(This : in out World; Ent : not null EntityClassAcc);

   -- Add env to the world
   procedure AddEnvironment(This : in out World; Ent : not null EntityClassAcc);

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
   procedure RemoveEnvironment(This : in out World; Ent : not null EntityClassAcc; Destroy : Boolean);

   -- Returns the entity in which Pos is
   -- If SearchMode = SM_All, searches first entities, then envs (ents are "on top")
   function GetClosest(This : in out World; Pos : Vec2D; SearchMode : SearchModes := SM_All) return EntityClassAcc;

   -- Get the list of entities
   function GetEntities(This : in World) return EntsListAcc;

   -- Get the list of envs
   function GetEnvironments(This : in World) return EntsListAcc;

   -- Get the list of links
   function GetLinks(This : in World) return LinksListAcc;

   -- Lets you set a maximum speed >= 0
   -- If max speed = 0 -> no max speed on that axis
   procedure SetMaxSpeed(This : in out World; Speed : Vec2D);

   -- Remove invalid entities according to InvalidChecker, if not null
   procedure CheckEntities(This : in out World);

end Worlds;
