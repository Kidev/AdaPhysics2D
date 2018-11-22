package body Collisions is
   
   function Collide(A, B : not null access Entity'Class; Col : out Collision)
   return Boolean
   is
   begin
      
      Col.A := A;
      Col.B := B;
      
      if A.all.EntityType = EntCircle then
         return CircleOnX(Circles.CircleAcc(A), B, Col);
      elsif B.all.EntityType = EntCircle then
         return CircleOnX(Circles.CircleAcc(B), A, Col);
      end if;

      return False;

   end Collide;
   
   function CircleOnX(A : in Circles.CircleAcc; B : access Entity'Class;
                      Col : out Collision) return Boolean
   is
   begin
      case B.all.EntityType is
         when EntCircle => return CircleOnCircle(A, Circles.CircleAcc(B), Col);
      end case;
   end CircleOnX;

   function CircleOnCircle(A, B : in Circles.CircleAcc; Col : out Collision) return Boolean
   is
   begin
      Col.Normal := A.all.Velocity;
      Col.Penetration := B.all.InvMass;
      return True;
   end CircleOnCircle;

   procedure Resolve(Col : in Collision) is
      RelVel : Vec2D;
      VelNormal : Float;
      FinRestitution : Float;
      ImpulseScalar : Float;
      Impulse : Vec2D;
      A : constant access Entity'Class := Col.A;
      B : constant access Entity'Class := Col.B;
   begin
      RelVel := B.Velocity - A.Velocity;
      VelNormal := RelVel * Col.Normal;

      -- objects are moving toward each other
      if VelNormal < 0.0 then

         FinRestitution := Float'Min(A.Restitution, B.Restitution);
         ImpulseScalar := -(1.0 + FinRestitution) * VelNormal;
         ImpulseScalar := ImpulseScalar / (A.InvMass + B.InvMass);
         Impulse := ImpulseScalar * Col.Normal;

         A.Velocity := A.Velocity - (A.InvMass * Impulse);
         B.Velocity := B.Velocity + (B.InvMass * Impulse);

      end if;

   end Resolve;
   
   procedure PosCorrection(Col : in Collision) is
      PosPerCorrection : constant Float := 0.3;
      Slop : constant Float := 0.05;
      Correction : Vec2D;
      ScCo : Float;
      A : constant access Entity'Class := Col.A;
      B : constant access Entity'Class := Col.B;
   begin
      ScCo := Float'Max(Col.Penetration - Slop, 0.0) / (A.InvMass + B.InvMass);
      Correction := ScCo * PosPerCorrection * Col.Normal;
      
      A.Velocity := A.Velocity - (A.InvMass * Correction);
      B.Velocity := B.Velocity - (B.InvMass * Correction);
   end PosCorrection;

end Collisions;
