package body Entity is

   procedure Resolve(This, That : in EntityAcc; Col : in CollisionAcc) is
      RelVel : Vec2D;
      VelNormal : Float;
      FinRestitution : Float;
      ImpulseScalar : Float;
      Impulse : Vec2D;
   begin
      RelVel := That.Velocity - This.Velocity;
      VelNormal := RelVel * Col.Normal;

      -- objects are moving toward each other
      if VelNormal > 0.0 then

         FinRestitution := Float'Min(This.Restitution, That.Restitution);
         ImpulseScalar := -(1.0 + FinRestitution) * VelNormal;
         ImpulseScalar := ImpulseScalar / (This.InvMass + That.InvMass);
         Impulse := ImpulseScalar * Col.Normal;

         This.Velocity := This.Velocity - (This.InvMass * Impulse);
         That.Velocity := That.Velocity + (That.InvMass * Impulse);

      end if;

   end Resolve;

end Entity;
