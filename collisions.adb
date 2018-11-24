package body Collisions is

   function Collide(A, B : not null access Entity'Class; Col : out Collision)
   return Boolean
   is
   begin

      Col.A := A;
      Col.B := B;

      -- /!\ Strange warnings here and on the elsif (lines 10 & 12) ?
      -- /!\ warning: condition can only be False if invalid values present
      if A.all.EntityType = EntCircle then
         return CircleOnX(Circles.CircleAcc(A), B, Col);
      elsif B.all.EntityType = EntCircle then
         return CircleOnX(Circles.CircleAcc(B), A, Col);
      end if;

      if A.all.EntityType = EntRectangle then
         return RectangleOnX(Rectangles.RectangleAcc(A), B, Col);
      elsif B.all.EntityType = EntRectangle then
         return RectangleOnX(Rectangles.RectangleAcc(B), A, Col);
      end if;

      return False;

   end Collide;

   function CircleOnX(A : in Circles.CircleAcc; B : access Entity'Class;
                      Col : out Collision) return Boolean
   is
   begin
      case B.all.EntityType is
         when EntCircle => return CircleOnCircle(A, Circles.CircleAcc(B), Col);
         when EntRectangle => return RectangleOnCircle(Rectangles.RectangleAcc(B), A, Col);
      end case;
   end CircleOnX;

   function RectangleOnX(A : in Rectangles.RectangleAcc; B : access Entity'Class; Col : out Collision)
                         return Boolean
   is
   begin
      case B.all.EntityType is
         when EntCircle => return RectangleOnCircle(A, Circles.CircleAcc(B), Col);
         when EntRectangle => return RectangleOnRectangle(A, Rectangles.RectangleAcc(B), Col);
      end case;
   end RectangleOnX;

   function CircleOnCircle(A, B : in Circles.CircleAcc; Col : out Collision) return Boolean
   is
      NormalVec : Vec2D;
      TotRadius : Float;
      Distance : Float;
   begin

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

--      Col.A := A;
--      Col.B := B;

      return True;

   end CircleOnCircle;

   function RectangleOnRectangle(A, B : in Rectangles.RectangleAcc; Col : out Collision)
                                 return Boolean
   is
      Normal : Vec2D;
      AMid, BMid : Float;
      xOverlap, yOverlap : Float;
   begin
      Normal := B.all.Coords - A.all.Coords;
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

   function RectangleOnCircle(A : in Rectangles.RectangleAcc; B : in Circles.CircleAcc; Col : out Collision)
                              return Boolean
   is
   begin
      return False;
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
      -- /!\ If objects are immobile relative to each other
      -- /!\ This may cause problems in 0g
      -- /!\ A fix might be to add 0.01 in this case
      RelVel := B.Velocity - A.Velocity;
      VelNormal := RelVel * Col.Normal;

      -- objects are moving toward each other
      if VelNormal < 0.0 then

         -- resting collision correction (prevents infinite bounciness)
   --      if Mag(RelVel) < Float'Max(Mag(dt * A.all.Gravity), Mag(dt * B.all.Gravity)) + Epsilon then
   --         FinRestitution := 0.0;
   --      else
         FinRestitution := Float'Min(A.Restitution, B.Restitution);
   --      end if;

         ImpulseScalar := -(1.0 + FinRestitution) * VelNormal;
         ImpulseScalar := ImpulseScalar / (A.InvMass + B.InvMass);
         Impulse := ImpulseScalar * Col.Normal;

         A.Velocity := A.Velocity - (A.InvMass * Impulse);
         B.Velocity := B.Velocity + (B.InvMass * Impulse);

      end if;

   end Resolve;

   procedure PosCorrection(Col : in Collision) is
      PosPerCorrection : constant Float := 0.2;
      Slop : constant Float := 0.01;
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
