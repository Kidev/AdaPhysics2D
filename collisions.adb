package body Collisions is

   function Collide(A, B : not null EntityClassAcc; Col : out Collision) return Boolean
   is
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
      Temp : EntityClassAcc;
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
      A : constant EntityClassAcc := Col.A;
      B : constant EntityClassAcc := Col.B;
      MuS : Float;
   begin

      -- Ignore collision between static objects
      if A.InvMass + B.InvMass = 0.0 then
         A.Velocity := Vec2D'(0.0, 0.0);
         B.Velocity := Vec2D'(0.0, 0.0);
         return;
      end if;

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
         MuS := Friction(A.Mat.StaticFriction, B.Mat.StaticFriction);
         if MuS /= 0.0 then
            declare
               Tangent : Vec2D;
               FrictionImpulse : Vec2D;
               ImpulseScalarTan : Float;
               MuC : Float;
            begin
               RelVel := B.Velocity - A.Velocity;
               Tangent := RelVel - (RelVel * Col.Normal) * Col.Normal;
               Tangent := Normalize(Tangent);

               ImpulseScalarTan := -(RelVel * Tangent);
               ImpulseScalarTan := ImpulseScalarTan / (A.InvMass + B.InvMass);

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
      A : constant EntityClassAcc := Col.A;
      B : constant EntityClassAcc := Col.B;
   begin
      if A.InvMass + B.InvMass /= 0.0 then
         ScCo := Float'Max(Col.Penetration - Slop, 0.0) / (A.InvMass + B.InvMass);
         Correction := ScCo * PosPerCorrection * Col.Normal;

         A.Velocity := A.Velocity - (A.InvMass * Correction);
         B.Velocity := B.Velocity + (B.InvMass * Correction);
      end if;
   end PosCorrection;

   -- for rectangle / rectangle it is accurate
   -- for circle / rectangle, approximation of the area of the overlap for this collision
   -- for circle / circle, approximation
   -- Used for Archimede's force
   function OverlapArea(Col : in Collision) return Float
   is
   begin
      if Col.A.EntityType = EntCircle and Col.B.EntityType = EntCircle then
         return OverlapAreaCircleCircle(Circles.CircleAcc(Col.A), Circles.CircleAcc(Col.B));
      end if;
      if Col.A.EntityType = EntRectangle and Col.B.EntityType = EntRectangle then
         return OverlapAreaRectangleRectangle(Col.A.Coords, Rectangles.RectangleAcc(Col.A).Dim,
                                              Col.B.Coords, Rectangles.RectangleAcc(Col.B).Dim);
      end if;
      if Col.A.EntityType = EntRectangle and Col.B.EntityType = EntCircle then
         return OverlapAreaCircleRectangle(Circles.CircleAcc(Col.B), Rectangles.RectangleAcc(Col.A));
      end if;
      if Col.A.EntityType = EntCircle and Col.B.EntityType = EntRectangle then
         return OverlapAreaCircleRectangle(Circles.CircleAcc(Col.A), Rectangles.RectangleAcc(Col.B));
      end if;
      return 0.0;
   end OverlapArea;

   function IsInside(Pos : Vec2D; Ent : not null EntityClassAcc) return Boolean
   is
   begin
      if Ent.EntityType = EntRectangle then
         declare
            Rect : constant Rectangles.RectangleAcc := Rectangles.RectangleAcc(Ent);
         begin
            return Pos.x >= Rect.Coords.x and Pos.x <= Rect.Coords.x + Rect.Dim.x
              and  Pos.y >= Rect.Coords.y and Pos.y <= Rect.Coords.y + Rect.Dim.y;
         end;
      elsif Ent.EntityType = EntCircle then
         declare
            Circ : constant Circles.CircleAcc := Circles.CircleAcc(Ent);
         begin
            return MagSq(Pos - Circ.Coords) <= Circ.Radius * Circ.Radius;
         end;
      end if;
      return False;
   end IsInside;

   -- A fast approximation of collision detection. Usefull for when precision is not important
   function CollideEx(A, B : not null EntityClassAcc) return Boolean
   is
      Col : constant Collision := (A, B, (0.0, 0.0), 0.0);
   begin
      return (OverlapArea(Col) /= 0.0);
   end CollideEx;

   -- http://jsfiddle.net/Lqh3mjr5/
   function OverlapAreaRectangleRectangle(PosA, DimA, PosB, DimB : Vec2D) return Float
   is
      d1x : constant Float := PosA.x;
      d1y : constant Float := PosA.y;
      d1xMax : constant Float := d1x + DimA.x;
      d1yMax : constant Float := d1y + DimA.y;

      d2x : constant Float := PosB.x;
      d2y : constant Float := PosB.y;
      d2xMax : constant Float := d2x + DimB.x;
      d2yMax : constant Float := d2y + DimB.y;

      xOverlap : constant Float := Float'Max(0.0, Float'Min(d1xMax, d2xMax) - Float'Max(d1x, d2x));
      yOverlap : constant Float := Float'Max(0.0, Float'Min(d1yMax, d2yMax) - Float'Max(d1y, d2y));
   begin
      return xOverlap * yOverlap;
   end OverlapAreaRectangleRectangle;

   function OverlapAreaCircleCircle(A, B : Circles.CircleAcc) return Float
   is
      CheatConst : constant Float := 0.84 * 0.84; -- AreaSquare - AreaCircle = 0.84
      PosA : constant Vec2D := A.Coords - (A.Radius, A.Radius);
      DimA : constant Vec2D := 2.0 * (A.Radius, A.Radius);
      PosB : constant Vec2D := B.Coords - (B.Radius, B.Radius);
      DimB : constant Vec2D := 2.0 * (B.Radius, B.Radius);
   begin
      return CheatConst * OverlapAreaRectangleRectangle(PosA, DimA, PosB, DimB);
   end OverlapAreaCircleCircle;

   function OverlapAreaCircleRectangle(A : Circles.CircleAcc; B : Rectangles.RectangleAcc) return Float
   is
      CheatConst : constant Float := 0.84; -- AreaSquare - AreaCircle = 0.84
      PosA : constant Vec2D := A.Coords - (A.Radius, A.Radius);
      DimA : constant Vec2D := 2.0 * (A.Radius, A.Radius);
   begin
      return CheatConst * OverlapAreaRectangleRectangle(PosA, DimA, B.Coords, B.Dim);
   end OverlapAreaCircleRectangle;

--  with Ada.Numerics.Generic_Elementary_Functions;
--     function OverlapAreaCircleRectangle(Radius, Height : Float) return Float
--     is
--        package TrigoFuncs is new Ada.Numerics.Generic_Elementary_Functions(Float);
--        use TrigoFuncs;
--        Param : constant Float := Clamp((1.0 - (Height / Radius)), -1.0, 1.0);
--        Alpha : constant Float := 2.0 * Arccos(Param);
--        Area : constant Float := 0.5 * Radius * Radius * (Alpha - Sin(Alpha));
--     begin
--        return Area;
--     end OverlapAreaCircleRectangle;

end Collisions;
