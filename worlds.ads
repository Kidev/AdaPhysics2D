with Entities; use Entities;
with Materials; use Materials;
with Vectors2D; use Vectors2D;

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
      InvalidChecker : EChecker;
      Env : Environment;
   end record;

   -- init world
   procedure Init(This : in out World; dt : in Float);

   -- Add entity to the world
   procedure Add(This : in out World; Ent : not null access Entity'Class);

   -- Gives the world a function to check if entities are valid or not
   procedure SetInvalidChecker(This : in out World; Invalider : EChecker);

   -- Sets the environment material
   procedure SetEnvironment(This : in out World; Env : Environment);

   -- This compute the fluid friction between That and the ambiant air in This
   -- It should depend of the shape and speed of That
   -- It returns a positive force that will oppose the movement in the end
   function FluidFriction(This : in out World; That : access Entity'Class) return Vec2D;

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

   procedure IntForce(This : in out World; Ent : not null access Entity'Class);

   procedure IntVelocity(This : in out World; Ent : not null access Entity'Class);

end Worlds;
