with Entities; use Entities;

package Worlds is

   -- fixed number of entities: 32
   subtype EntArrIndex is Integer range 0 .. 32;
   type EntArray is array (EntArrIndex) of access Entity'Class;
   
   type World is tagged record
      Entities : EntArray;
      Index : EntArrIndex;
      dt : Float;
   end record;
   
   -- init world
   procedure Init(This : in out World; dt : in Float);
   
   -- Add entity to the world
   procedure Add(This : in out World; Ent : not null access Entity'Class);
   
   -- Update the world of dt
   procedure Step(This : in out World);
   
private
   
   procedure ResetForces(Ent : not null access Entity'Class);

   procedure IntForce(Ent : not null access Entity'Class; dt : Float);
   
   procedure IntVelocity(Ent : not null access Entity'Class; dt : Float);

end Worlds;
