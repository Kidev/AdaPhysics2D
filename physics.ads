with Worlds; use Worlds;
with Entities; use Entities;
with Vectors2D; use Vectors2D;
with Materials; use Materials;

package Physics is
   
   -- Update the world of dt TODO make it work with the chained list
   -- Accuracy > 1 means each step of dt will be composed of Accuracy passes
   -- This means each dt will be computed using a mean value of Accuracy values
   procedure StepNormal(This : in out World; Accuracy : Positive);

   -- Update the world of dt with low ram usage
   procedure StepLowRAM(This : in out World);

   -- This compute the fluid friction between That and the env That is in (in This)
   -- It should depend of the shape and speed of That
   -- It returns a positive force that will oppose the movement in the end
   function FluidFriction(This : in out World; That : access Entity'Class) return Vec2D;

   function Archimedes(This : in out World; That : access Entity'Class) return Float;

   function Tension(This : in out World; Ent : access Entity'Class) return Vec2D;

   procedure ResetForces(Ent : not null access Entity'Class);

   procedure IntegrateForces(This : in out World; Ent : not null access Entity'Class);

   procedure IntegrateVelocity(This : in out World; Ent : not null access Entity'Class);
   
   function GetDensestMaterial(This : in out World; That : access Entity'Class) return Material;

end Physics;
