with Entities; use Entities;

package Worlds is

   -- fixed number of entities
   subtype EntArrIndex is Integer range 0 .. 64;
   type EntArray is array (EntArrIndex) of access Entity'Class;
   type EArray is array (EntArrIndex range <>) of access Entity'Class;
   type EChecker is access function(E : access Entity'Class) return Boolean;

   type World is tagged record
      Entities : EntArray;
      Index : EntArrIndex;
      dt : Float;
      InvalidChecker : EChecker := null;
   end record;

   -- init world
   procedure Init(This : in out World; dt : in Float);

   -- Add entity to the world
   procedure Add(This : in out World; Ent : not null access Entity'Class);

   -- Gives the world a function to check if entities are valid or not
   procedure SetInvalidChecker(This : in out World; Invalider : EChecker);

   -- Remove entity from the world
   -- Entity is detroyed if Destroy is true
   procedure Remove(This : in out World; Ent : not null access Entity'Class; Destroy : Boolean);

   -- Update the world of dt
   procedure Step(This : in out World);

   -- Update the world of dt with low ram usage
   procedure StepLowRAM(This : in out World);

   -- Get an array of entities
   function GetEntities(This : in out World) return EArray;

   -- Remove invalid entities according to InvalidChecker, if not null
   procedure CheckEntities(This : in out World);

private

   procedure ResetForces(Ent : not null access Entity'Class);

   procedure IntForce(Ent : not null access Entity'Class; dt : Float);

   procedure IntVelocity(Ent : not null access Entity'Class; dt : Float);

end Worlds;
