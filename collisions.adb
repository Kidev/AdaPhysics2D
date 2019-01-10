with Circles;
with Rectangles;

package body Collisions is

   function Collide(A, B : not null access Entity'Class; Col : out Collision)
   return Boolean
   is
      type CollideFunc is access function (Col : in out Collision) return Boolean;
      type DispatcherArr is array (EntityTypes, EntityTypes) of CollideFunc;
      Dispatcher : constant DispatcherArr :=
        (EntCircle => (EntCircle => CircleOnCircle'Access,
                       EntRectangle => CircleOnRectangle'Access),
         EntRectangle => (EntCircle => RectangleOnCircle'Access,
                          EntRectangle => RectangleOnRectangle'Access));
   begin

      Col.A := A; Col.B := B;
      return Dispatcher(A.all.EntityType, B.all.EntityType).all(Col);

   end Collide;

   function CircleOnCircle(Col : in out Collision) return Boolean
   is
      NormalVec : Vec2D;
      TotRadius : Float;
      Distance : Float;
      A, B : Circles.CircleAcc;
   begin

      A := Circles.CircleAcc(Col.A);
      B := Circles.CircleAcc(Col.B);

      NormalVec := B.all.Coords - A.all.Coords;
      TotRadius := A.all.Radius + B.all.Radius;

      if MagSq(NormalVec) > (TotRadius * TotRadius) then
         return False; -- Not colliding
      end if;

      Distance := Mag(NormalVec);

      if Distance /= 0.0 then
         Col.Penetration := TotRadius - Distance;
         Col.Normal := NormalVec / Distance;
      else
         Col.Penetration := A.all.Radius;
         Col.Normal := Vec2D'(1.0, 0.0);
      end if;

      return True;

   end CircleOnCircle;

   function RectangleOnRectangle(Col : in out Collision) return Boolean
   is
      Normal : Vec2D;
      AMid, BMid : Float;
      xOverlap, yOverlap : Float;
      A, B : Rectangles.RectangleAcc;
   begin
      A := Rectangles.RectangleAcc(Col.A);
      B := Rectangles.RectangleAcc(Col.B);

      Normal := B.all.GetCenter - A.all.GetCenter;
      AMid := A.all.GetWidth / 2.0;
      BMid := B.all.GetWidth / 2.0;
      xOverlap := AMid + BMid - (abs Normal.x);

      if xOverlap > 0.0 then

         AMid := A.all.GetHeight / 2.0;
         BMid := B.all.GetHeight / 2.0;
         yOverlap := AMid + BMid - (abs Normal.y);

         if yOverlap > 0.0 then

            if xOverlap < yOverlap then

               Col.Normal :=
                 (
                  if Normal.x < 0.0 then Vec2D'(-1.0, 0.0) else Vec2D'(1.0, 0.0)
                 );
               Col.Penetration := xOverlap;

            else

               Col.Normal :=
                 (
                  if Normal.y < 0.0 then Vec2D'(0.0, -1.0) else Vec2D'(0.0, 1.0)
                 );
               Col.Penetration := yOverlap;

            end if;
            return True;

         end if;

      end if;
      return False;

   end RectangleOnRectangle;

   function CircleOnRectangle(Col : in out Collision) return Boolean
   is
      Result : Boolean;
      Temp : access Entity'Class;
   begin
      Temp := Col.A;
      Col.A := Col.B;
      Col.B := Temp;

      Result := RectangleOnCircle(Col);
      return Result;
   end CircleOnRectangle;

   function RectangleOnCircle(Col : in out Collision) return Boolean
   is
      AtoB : Vec2D;
      Normal : Vec2D;
      Closest : Vec2D;
      xExt, yExt : Float;
      Distance : Float;
      Inside : Boolean := False;
      Radius : Float;
      A : Rectangles.RectangleAcc;
      B : Circles.CircleAcc;
   begin
      A := Rectangles.RectangleAcc(Col.A);
      B := Circles.CircleAcc(Col.B);

      AtoB := B.all.Coords - A.all.GetCenter;
      xExt := A.all.GetWidth / 2.0;
      yExt := A.all.GetHeight / 2.0;
      Closest.x := Clamp(AtoB.x, -xExt, xExt);
      Closest.y := Clamp(AtoB.y, -yExt, yExt);

      -- special case of circle inside rectangle
      if AtoB = Closest then
         Inside := True;
         if (abs AtoB.x) < (abs AtoB.y) then
            Closest.x := (if AtoB.x > 0.0 then xExt else -xExt);
         else
            Closest.y := (if AtoB.y > 0.0 then yExt else -yExt);
         end if;
      end if;

      Normal := AtoB - Closest;
      Distance := MagSq(Normal);
      Radius := B.all.Radius;

      -- circle not inside of the rectangle
      if Distance > Radius * Radius and not Inside then
         return False;
      end if;

      Distance := Mag(Normal);

      Col.Penetration := Radius - Distance;
      if Inside then
         Col.Normal := -Normal / Distance;
      else
         Col.Normal := Normal / Distance;
      end if;

      return True;

   end RectangleOnCircle;

   procedure Resolve(Col : in Collision) is
      RelVel : Vec2D;
      VelNormal : Float;
      FinRestitution : Float;
      ImpulseScalar : Float;
      Impulse : Vec2D;
      A : constant access Entity'Class := Col.A;
      B : constant access Entity'Class := Col.B;
   begin

      -- Ignore collision between static objects
      if A.InvMass + B.InvMass = 0.0 then
         A.Velocity := Vec2D'(0.0, 0.0);
         B.Velocity := Vec2D'(0.0, 0.0);
         return;
      end if;

      -- /!\ If objects are immobile relative to each other
      -- /!\ This may cause problems in 0g
      -- /!\ A fix might be to add 0.01 in this case
      RelVel := B.Velocity - A.Velocity;
      VelNormal := RelVel * Col.Normal;

      -- objects are moving toward each other
      if VelNormal < 0.0 then

         FinRestitution := Float'Min(A.Mat.Restitution, B.Mat.Restitution);

         ImpulseScalar := -(1.0 + FinRestitution) * VelNormal;
         ImpulseScalar := ImpulseScalar / (A.InvMass + B.InvMass);
         Impulse := ImpulseScalar * Col.Normal;

         A.Velocity := A.Velocity - (A.InvMass * Impulse);
         B.Velocity := B.Velocity + (B.InvMass * Impulse);

         -- Compute friction
         declare
            Tangent : Vec2D;
            FrictionImpulse : Vec2D;
            ImpulseScalarTan : Float;
            MuS, MuC : Float;
         begin
            RelVel := B.Velocity - A.Velocity;
            Tangent := RelVel - (RelVel * Col.Normal) * Col.Normal;
            Tangent := Normalize(Tangent);

            ImpulseScalarTan := -(RelVel * Tangent);
            ImpulseScalarTan := ImpulseScalarTan / (A.InvMass + B.InvMass);

            MuS := Friction(A.Mat.StaticFriction, B.Mat.StaticFriction);

            if (abs ImpulseScalarTan) < (MuS * ImpulseScalar) then
               FrictionImpulse := ImpulseScalarTan * Tangent;
            else
               MuC := Friction(A.Mat.DynamicFriction, B.Mat.DynamicFriction);
               FrictionImpulse := -ImpulseScalar * Tangent * MuC;
            end if;

            A.Velocity := A.Velocity - (A.InvMass * FrictionImpulse);
            B.Velocity := B.Velocity + (B.InvMass * FrictionImpulse);
         end;
      end if;

   end Resolve;

   function Friction(A, B : Float) return Float is
   begin
      return Float'Min(A, B);
   end;

   procedure PosCorrection(Col : in Collision) is
      PosPerCorrection : constant Float := 1.0;
      Slop : constant Float := 0.01;
      Correction : Vec2D;
      ScCo : Float;
      A : constant access Entity'Class := Col.A;
      B : constant access Entity'Class := Col.B;
   begin
      ScCo := Float'Max(Col.Penetration - Slop, 0.0) / (A.InvMass + B.InvMass);
      Correction := ScCo * PosPerCorrection * Col.Normal;

      A.Velocity := A.Velocity - (A.InvMass * Correction);
      B.Velocity := B.Velocity + (B.InvMass * Correction);
   end PosCorrection;

   function Clamp(Value, Min, Max : Float) return Float
   is
   begin

      if Value < Min then return Min; end if;
      if Value > Max then return Max; end if;
      return Value;

   end Clamp;

end Collisions;
