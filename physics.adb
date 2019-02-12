with Interfaces; use Interfaces;
with Circles; use Circles;
with Rectangles; use Rectangles;
with Collisions; use Collisions;
with Links; use Links;

package body Physics is

   -- This procedure will perform Collision resolution
   -- in a way that doesnt require as much RAM as the StepNormal
   -- one: it will not store all collisions and then resolve
   -- them. Instead, it will resolve them one at a time
   -- The result might be less realistic, but more space efficient
   procedure StepLowRAM(This : in out World)
   is
      use EntsList;
      A, B : EntityClassAcc;
      C1, C2 : EntsList.Cursor;
      Col : Collision;
   begin

      C1 := This.Entities.First;
      while C1 /= EntsList.No_Element loop
         IntegrateForces(This, EntsList.Element(C1));
         C1 := EntsList.Next(C1);
      end loop;

      -- Broad phase
      C1 := This.Entities.First;
      while C1 /= EntsList.No_Element loop
         A := EntsList.Element(C1);
         C2 := EntsList.Next(C1);
         while C2 /= EntsList.No_Element loop
            B := EntsList.Element(C2);
            -- Narrow phase
            if (A.all.Layer and B.all.Layer) /= 2#00000000#
              and then Collide(A, B, Col) then
               Resolve(Col);
               PosCorrection(Col);
            end if;
            C2 := EntsList.Next(C2);
         end loop;
         C1 := EntsList.Next(C1);
      end loop;

      C1 := This.Entities.First;
      while C1 /= EntsList.No_Element loop
         IntegrateVelocity(This, EntsList.Element(C1));
         C1 := EntsList.Next(C1);
      end loop;

      C1 := This.Entities.First;
      while C1 /= EntsList.No_Element loop
         ResetForces(EntsList.Element(C1));
         C1 := EntsList.Next(C1);
      end loop;

      This.CheckEntities;

   end StepLowRAM;

   -- Update the world of dt
   -- This procedure is "RAM heavy", as it stores every collision inside
   -- the passed World between two calls of Step
   -- If RAM usage is an issue, use StepLowRAM instead
   -- Note that it will only be an issue for embedded software
   procedure StepNormal(This : in out World)
   is
      use EntsList;
      use ColsList;
      A, B : EntityClassAcc;
      Col : Collision;
      C1, C2 : EntsList.Cursor;
      C : ColsList.Cursor;
   begin
      
      This.Cols.Clear;

      -- Broad phase
      C1 := This.Entities.First;
      while C1 /= EntsList.No_Element loop
         A := EntsList.Element(C1);
         C2 := EntsList.Next(C1);
         while C2 /= EntsList.No_Element loop
            B := EntsList.Element(C2);
            -- Narrow phase
            if (A.all.Layer and B.all.Layer) /= 2#00000000#
              and then Collide(A, B, Col) then
               This.Cols.Append(Col);
            end if;
            C2 := EntsList.Next(C2);
         end loop;
         C1 := EntsList.Next(C1);
      end loop;

      -- Integrate forces
      C1 := This.Entities.First;
      while C1 /= EntsList.No_Element loop
         IntegrateForces(This, EntsList.Element(C1));
         C1 := EntsList.Next(C1);
      end loop;

      -- Resolves collisions
      C := This.Cols.First;
      while C /= ColsList.No_Element loop
         Resolve(ColsList.Element(C));
         C := ColsList.Next(C);
      end loop;

      -- Integrate velocities
      C1 := This.Entities.First;
      while C1 /= EntsList.No_Element loop
         IntegrateVelocity(This, EntsList.Element(C1));
         C1 := EntsList.Next(C1);
      end loop;

      -- Little positional correction to prevent jitter
      C := This.Cols.First;
      while C /= ColsList.No_Element loop
         PosCorrection(ColsList.Element(C));
         C := ColsList.Next(C);
      end loop;

      -- Reset all forces
      C1 := This.Entities.First;
      while C1 /= EntsList.No_Element loop
         ResetForces(EntsList.Element(C1));
         C1 := EntsList.Next(C1);
      end loop;

      This.CheckEntities;

   end StepNormal;
   
   procedure ResetForces(Ent : not null EntityClassAcc)
   is
   begin
      Ent.Force := Vec2D'(x => 0.0, y => 0.0);
   end ResetForces;

   function Archimedes(This : in out World; That : not null EntityClassAcc) return Float
   is
      use EntsList;
      TotalCoef : Float := 0.0; -- >= 0.0
      Curs : EntsList.Cursor := This.Environments.First;
      Env : EntityClassAcc;
      Col : Collision;
   begin
      while Curs /= EntsList.No_Element loop
         Env := EntsList.Element(Curs);
         if Env.Mat.Density > 0.0 and then Collide(Env, That, Col) then
            TotalCoef := TotalCoef + (Env.Mat.Density * OverlapArea(Col));
         end if;
         Curs := EntsList.Next(Curs);
      end loop;
      return TotalCoef;
   end Archimedes;
   
   -- This computes the fluid friction between That and the env That is in (in This)
   -- It should depend of the shape and speed of That
   -- It returns a positive force that will oppose the movement in the end
   function FluidFriction(This : in out World; That : not null EntityClassAcc) return Vec2D
   is
      QuadraticLimit : constant Float := 5.0;
   begin
      if Integer(This.Environments.Length) = 0 then
         return (0.0, 0.0);
      end if;

      declare
         MostDenseMat : constant Material := GetDensestMaterial(This, That);
         Density : constant Float := MostDenseMat.Density;
         Viscosity : constant Float := MostDenseMat.Viscosity;
      begin
         if Density = 0.0 or else Viscosity = 0.0 then
            return (0.0, 0.0);
         end if;
         if MagSq(That.Velocity) >= QuadraticLimit * QuadraticLimit then
            declare

               function GetCx(Ent : not null EntityClassAcc) return Float is
               begin
                  case Ent.EntityType is
                     when EntCircle => return 0.47;
                     when EntRectangle => return 1.05;
                  end case;
               end GetCx;

               function GetS(Ent : not null EntityClassAcc) return Float is
               begin
                  case Ent.EntityType is
                     when EntCircle =>
                        return 3.14 * CircleAcc(Ent).Radius;
                     when EntRectangle =>
                        return (RectangleAcc(Ent).Dim.x + RectangleAcc(Ent).Dim.y) / 2.0;
                  end case;
               end GetS;

               Rho : constant Float := Density; -- Density for the env
               S : constant Float := GetS(That); -- "Area" normal to speed
               Cx : constant Float := GetCx(That); -- Drag coeff
            begin
               return 0.5 * Rho * S * Cx * Sq(That.Velocity);
            end;
         end if;
         declare

            function GetK(Ent : not null EntityClassAcc) return Float is
            begin
               case Ent.EntityType is
                  when EntCircle =>
                     return 6.0 * 3.14 * CircleAcc(Ent).Radius;
                  when EntRectangle =>
                     return 6.0 * 3.14 * (RectangleAcc(Ent).Dim.x + RectangleAcc(Ent).Dim.y) / 2.0;
               end case;
            end GetK;

            Nu : constant Float := Viscosity * Density; -- viscosity coeff for env
            k : constant Float := GetK(That); -- shape coeff for That
         begin
            return Nu * k * That.Velocity;
         end;
      end;
   end FluidFriction;

   function Tension(This : in out World; Ent : not null EntityClassAcc) return Vec2D
   is
      use LinksList;
      TotalForce : Vec2D := (0.0, 0.0);
      Curs : LinksList.Cursor := This.Links.First;
      Target : EntityClassAcc;
      CurLink : LinkAcc;
      TmpDistance : Float := 0.0;
      AddForce : Vec2D;
   begin
      while Curs /= LinksList.No_Element loop
         CurLink := LinksList.Element(Curs);
         Target := null;
         if CurLink.A = Ent then
            Target := CurLink.B;
         elsif CurLink.B = Ent then
            Target := CurLink.A;
         end if;
         if Target /= null then
            TmpDistance := GetDistance(Ent.all, Target.all);
            AddForce := (CurLink.Factor * (TmpDistance - CurLink.RestLen)
                         * (1.0 / TmpDistance) * (Target.GetPosition - Ent.GetPosition));
            TotalForce := TotalForce + AddForce;
         end if;
         Curs := LinksList.Next(Curs);
      end loop;
      return TotalForce;
   end Tension;

   -- F: custom force | m: mass | g: grav acc | f(v) >= 0: dynamic friction | pV: density * volume
   -- m * a = F + mg - f(v) - pVg [Newton's second law]
   -- m * dv / dt = F + mg - f(v) - pVg
   -- dv = (dt/m) * (F + mg - f(v) - pVg)
   -- dv = (dt/m) * (F + (m - pV)*g - f(v));
   -- Let SF = (F + (m - pV)*g - f(v));
   -- dv = (dt/m) * SF;
   -- v = v + dv [on dt, Euler's integration method]
   -- v = v + (dt * SF)/m;
   procedure IntegrateForces(This : in out World; Ent : not null EntityClassAcc)
   is
   begin
      if Ent.all.InvMass /= 0.0 then
	declare
            SF : constant Vec2D :=
              Ent.Force + Tension(This, Ent) - FluidFriction(This, Ent)
              + ((Ent.Mass - Archimedes(This, Ent)) * Ent.Gravity);
            SpeedAdded : constant Vec2D := (SF * This.dt * Ent.InvMass);
	begin
            Ent.all.Velocity := ClampVec(Ent.all.Velocity + SpeedAdded, This.MaxSpeed); -- Ent.all.Velocity + SpeedAdded
	end;
      else
         Ent.all.Velocity := (0.0, 0.0);
      end if;
   end IntegrateForces;

   procedure IntegrateVelocity(This : in out World; Ent : not null EntityClassAcc)
   is
   begin
      if Ent.all.InvMass /= 0.0 then
         Ent.all.Coords := Ent.all.Coords + (Ent.all.Velocity * This.dt);
         IntegrateForces(This, Ent); -- TODO reconsider the purpose of this call (smoothes the step?)
      end if;
   end IntegrateVelocity;
   
   function GetDensestMaterial(This : in out World; That : not null EntityClassAcc) return Material
   is
      use EntsList;
      ReturnMat : Material := VACUUM;
      Curs : EntsList.Cursor := This.Environments.First;
      Env : EntityClassAcc;
      Col : Collision; -- TODO create a collide without all the normal / penetration stuff to optimize
   begin

      while Curs /= EntsList.No_Element loop
         Env := EntsList.Element(Curs);
         if Env.Mat.Density > ReturnMat.Density and then Collide(Env, That, Col) then
            ReturnMat := Env.Mat;
         end if;
         Curs := EntsList.Next(Curs);
      end loop;

      return ReturnMat;
   end GetDensestMaterial;

end Physics;
