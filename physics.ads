with Worlds; use Worlds;
with Entities; use Entities;
with Vectors2D; use Vectors2D;
with Materials; use Materials;

package Physics is
   
   -- Update the world of dt
   procedure StepNormal(This : in out World);

   -- Update the world of dt with low ram usage
   procedure StepLowRAM(This : in out World);

   -- This compute the fluid friction between That and the env That is in (in This)
   -- It should depend of the shape and speed of That
   -- It returns a positive force that will oppose the movement in the end
   function FluidFriction(This : in out World; That : not null EntityClassAcc) return Vec2D;

   function Archimedes(This : in out World; That : not null EntityClassAcc) return Float;

   function Tension(This : in out World; Ent : not null EntityClassAcc) return Vec2D;

   procedure ResetForces(Ent : not null EntityClassAcc);

   procedure IntegrateForces(This : in out World; Ent : not null EntityClassAcc);

   procedure IntegrateVelocity(This : in out World; Ent : not null EntityClassAcc);
   
   function GetDensestMaterial(This : in out World; That : not null EntityClassAcc) return Material;

end Physics;
