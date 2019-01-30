with Collisions; use Collisions;
with Interfaces; use Interfaces;
with Circles; use Circles;
with Rectangles; use Rectangles;
with Ada.Unchecked_Deallocation;
with Worlds; use Worlds;

package body Worlds is

   -- init world
   procedure Init(This : in out World; dt : in Float; MaxEnts : Natural := 32)
   is
   begin
      This.MaxEntities := MaxEnts;
      This.dt := dt;
      This.Entities := new EntsList.List;
      This.Environments := new EntsList.List;
      This.Links := new LinksList.List;
      This.InvalidChecker := null;
      This.MaxSpeed := (0.0, 0.0);
   end Init;

   procedure IncreaseMaxEntities(This : in out World; Count : Positive)
   is
   begin
      This.MaxEntities := This.MaxEntities + Count;
   end AddMaxEntities;

   -- Add entity to the world
   procedure AddEntity(This : in out World; Ent : not null access Entity'Class)
   is
   begin
      if This.MaxEntities = 0
        or else Integer(This.Entities.Length)
              + Integer(This.Environments.Length)
              + Integer(This.Links.Length) < This.MaxEntities
      then
         This.Entities.Append(Ent);
      end if;
   end AddEntity;

   procedure SetMaxSpeed(This : in out World; Speed : Vec2D) is
   begin
      This.MaxSpeed := Speed;
   end SetMaxSpeed;

   -- Add env to the world
   procedure AddEnvironment(This : in out World; Ent : not null access Entity'Class)
   is
   begin
      if This.MaxEntities = 0
        or else Integer(This.Entities.Length)
              + Integer(This.Environments.Length)
              + Integer(This.Links.Length) < This.MaxEntities
      then
         This.Environments.Append(Ent);
      end if;
   end AddEnvironment;

   procedure LinkEntities(This : in out World; A, B : EntityClassAcc; Factor : Float) is
   begin
      if This.MaxEntities = 0
        or else Integer(This.Entities.Length)
              + Integer(This.Environments.Length)
              + Integer(This.Links.Length) < This.MaxEntities
      then
         This.Links.Append(CreateLink(A, B, Factor));
      end if;
   end LinkEntities;

   procedure LinkEntities(This : in out World; A, B : EntityClassAcc; LinkType : LinkTypes) is
   begin
      if This.MaxEntities = 0
        or else Integer(This.Entities.Length)
              + Integer(This.Environments.Length)
              + Integer(This.Links.Length) < This.MaxEntities
      then
         This.Links.Append(CreateLink(A, B, LinkType));
      end if;
   end LinkEntities;

   procedure UnlinkEntity(This : in out World; E : EntityClassAcc) is
      CurLink : LinkAcc;
      Edited : Boolean := False;
   begin
      loop
         declare
            Curs : LinksList.Cursor := This.Links.First;
         begin
            while Curs /= LinksList.No_Element loop
               CurLink := LinksList.Element(Curs);
               if CurLink.A = E or CurLink.B = E then
                  This.Links.Delete(Curs);
                  FreeLink(CurLink);
                  Edited := True;
               end if;
               exit when Edited;
               Curs := LinksList.Next(Curs);
            end loop;
         end;
         exit when not Edited;
      end loop;
   end UnlinkEntity;

   -- clear the world (deep free)
   procedure Free(This : in out World)
   is
      use EntsList;
      procedure FreeList is new Ada.Unchecked_Deallocation(EntsList.List, EntsListAcc);
      Curs : EntsList.Cursor := This.Entities.First;
   begin

      while Curs /= EntsList.No_Element loop
         This.UnlinkEntity(EntsList.Element(Curs));
         FreeEnt(EntsList.Element(Curs));
         Curs := EntsList.Next(Curs);
      end loop;

      Curs := This.Environments.First;
      while Curs /= EntsList.No_Element loop
         FreeEnt(EntsList.Element(Curs));
         Curs := EntsList.Next(Curs);
      end loop;
      This.Entities.Clear;
      This.Environments.Clear;
      This.Links.Clear;
      FreeList(This.Entities);
      FreeList(This.Environments);
      FreeList(This.Links);
   end Free;

   -- Gives the world a function to check if entities are valid or not
   procedure SetInvalidChecker(This : in out World; Invalider : EntCheckerAcc)
   is
   begin
      if Invalider /= null then
         This.InvalidChecker := Invalider;
      end if;
   end SetInvalidChecker;

   -- Remove entity from the world
   procedure RemoveEntity(This : in out World; Ent : not null access Entity'Class; Destroy : Boolean)
   is
      Curs : EntsList.Cursor := This.Entities.Find(Ent);
   begin
      This.Entities.Delete(Curs);
      This.UnlinkEntity(Ent);
      if Destroy then
         FreeEnt(Ent);
      end if;
   end RemoveEntity;

   -- Remove entity from the world
   procedure RemoveEnvironment(This : in out World; Ent : not null access Entity'Class; Destroy : Boolean)
   is
      Curs : EntsList.Cursor := This.Environments.Find(Ent);
   begin
      This.Environments.Delete(Curs);
      if Destroy then
         FreeEnt(Ent);
      end if;
   end RemoveEnvironment;

   function GetEntities(This : in out World) return EntsListAcc
   is
   begin
      return This.Entities;
   end GetEntities;

   function GetClosest(This : in out World; Pos : Vec2D; SearchMode : SearchModes := SM_All) return EntityClassAcc
   is
      use EntsList;
      EntList : constant EntsListAcc := (if SearchMode = SM_All or SearchMode = SM_Entity
                                     then This.Entities
                                     else This.Environments);
      Curs : EntsList.Cursor := EntList.First;
      Ent : EntityClassAcc;
   begin
      while Curs /= EntsList.No_Element loop
         Ent := EntsList.Element(Curs);
         if IsInside(Pos, Ent) then
            return Ent;
         end if;
         Curs := EntsList.Next(Curs);
      end loop;
      if SearchMode = SM_All then
         return This.GetClosest(Pos, SM_Environment);
      end if;
      return null;
   end GetClosest;

   function GetEnvironments(This : in out World) return EntsListAcc
   is
   begin
      return This.Environments;
   end GetEnvironments;

   -- This procedure will perform Collision resolution
   -- in a way that doesnt require as much RAM as the Step
   -- one: it will not store all collisions and then resolve
   -- them. Instead, it will resolve them one at a time
   -- The result might be less realistic, but more efficient
   procedure StepLowRAM(This : in out World)
   is
      use EntsList;
      A, B : access Entity'Class;
      C1, C2 : EntsList.Cursor;
      Col : Collision;
   begin

      C1 := This.Entities.First;
      while C1 /= EntsList.No_Element loop
         This.IntegrateForces(EntsList.Element(C1));
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
         This.IntegrateVelocity(EntsList.Element(C1));
         C1 := EntsList.Next(C1);
      end loop;

      C1 := This.Entities.First;
      while C1 /= EntsList.No_Element loop
         ResetForces(EntsList.Element(C1));
         C1 := EntsList.Next(C1);
      end loop;

      This.CheckEntities;

   end StepLowRAM;

   -- TODO redo the RAM heavy step procedure
   -- Update the world of dt
--     procedure Step(This : in out World)
--     is
--        use EntsList;
--        Cols : EntsList.List;
--        Col : access Collision;
--        A, B : access Entity'Class;
--        C1, C2 : EntsList.Cursor;
--        Count : ColIndex := 0;
--     begin
--
--        -- Broad phase
--        C1 := This.Entities.First;
--        while C1 /= EntsList.No_Element loop
--           A := EntsList.Element(C1);
--           C2 := EntsList.Next(C1);
--           while C2 /= EntsList.No_Element loop
--              B := EntsList.Element(C2);
--              -- Narrow phase
--              Col := new Collision;
--              if (A.all.Layer and B.all.Layer) /= 2#00000000#
--                and then Collide(A, B, Col) then
--                 Resolve(Col);
--                 PosCorrection(Col);
--              end if;
--              C2 := EntsList.Next(C2);
--           end loop;
--           C1 := EntsList.Next(C1);
--        end loop;
--
--        -- Broad phase
--        for I in 1 .. This.Index loop
--           A := This.Entities(I);
--           for J in I .. This.Index loop
--              B := This.Entities(J);
--              -- Narrow phase
--              if A /= B and then (A.all.Layer and B.all.Layer) /= 2#00000000#
--                and then Collide(A, B, Cols(Count)) then
--                 Count := Count + 1;
--              end if;
--           end loop;
--        end loop;
--
--        for I in 1 .. This.Index loop
--           This.IntForce(This.Entities(I));
--        end loop;
--
--        for I in 0 .. Count - 1 loop
--           Resolve(Cols(I));
--        end loop;
--
--        for I in 1 .. This.Index loop
--           This.IntVelocity(This.Entities(I));
--        end loop;
--
--        for I in 0 .. Count - 1 loop
--           PosCorrection(Cols(I));
--        end loop;
--
--        for I in 1 .. This.Index loop
--           ResetForces(This.Entities(I));
--        end loop;
--
--        This.CheckEntities;
--
--     end Step;

   procedure CheckEntities(This : in out World)
   is
   begin
      if This.InvalidChecker /= null then
         declare
            E : access Entity'Class;
            Edited : Boolean := False;
         begin
            loop
               Edited := False;
               declare
                  use EntsList;
                  Curs : EntsList.Cursor := This.Entities.First;
               begin
                  while Curs /= EntsList.No_Element loop
                     E := EntsList.Element(Curs);
                     if This.InvalidChecker.all(E) then
                        This.RemoveEntity(E, True);
                        Edited := True;
                     end if;
                     exit when Edited;
                     Curs := EntsList.Next(Curs);
                  end loop;
               end;
               exit when not Edited;
            end loop;
         end;
      end if;
   end CheckEntities;

   procedure ResetForces(Ent : not null access Entity'Class)
   is
   begin
      Ent.Force := Vec2D'(x => 0.0, y => 0.0);
   end ResetForces;

   function Archimedes(This : in out World; That : access Entity'Class) return Float
   is
      use EntsList;
      TotalCoef : Float := 0.0; -- >= 0.0
      Curs : EntsList.Cursor := This.Environments.First;
      Env : access Entity'Class;
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

   function GetDensestMaterial(This : in out World; That : access Entity'Class) return Material
   is
      use EntsList;
      ReturnMat : Material := VACUUM;
      Curs : EntsList.Cursor := This.Environments.First;
      Env : access Entity'Class;
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

   -- This computes the fluid friction between That and the env That is in (in This)
   -- It should depend of the shape and speed of That
   -- It returns a positive force that will oppose the movement in the end
   function FluidFriction(This : in out World; That : access Entity'Class) return Vec2D
   is
      QuadraticLimit : constant Float := 5.0;
   begin
      if Integer(This.Environments.Length) = 0 then
         return (0.0, 0.0);
      end if;

      declare
         MostDenseMat : constant Material := This.GetDensestMaterial(That);
         Density : constant Float := MostDenseMat.Density;
         Viscosity : constant Float := MostDenseMat.Viscosity;
      begin
         if Density = 0.0 or else Viscosity = 0.0 then
            return (0.0, 0.0);
         end if;
         if MagSq(That.Velocity) >= QuadraticLimit * QuadraticLimit then
            declare

               function GetCx(Ent : access Entity'Class) return Float is
               begin
                  case Ent.EntityType is
                     when EntCircle => return 0.47;
                     when EntRectangle => return 1.05;
                  end case;
               end GetCx;

               function GetS(Ent : access Entity'Class) return Float is
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

            function GetK(Ent : access Entity'Class) return Float is
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

   -- F: custom force | m: mass | g: grav acc | f(v) >= 0: dynamic friction | pV: density * volume
   -- m * a = F + mg - f(v) - pVg [Newton's second law]
   -- m * dv / dt = F + mg - f(v) - pVg
   -- dv = (dt/m) * (F + mg - f(v) - pVg)
   -- dv = (dt/m) * (F + (m - pV)*g - f(v));
   -- Let SF = (F + (m - pV)*g - f(v));
   -- dv = (dt/m) * SF;
   -- v = v + dv [on dt, Euler's integration method]
   -- v = v + (dt * SF)/m;
   procedure IntegrateForces(This : in out World; Ent : not null access Entity'Class)
   is
   begin
      if Ent.all.InvMass /= 0.0 then
	declare
            SF : constant Vec2D := Ent.Force + ((Ent.Mass - This.Archimedes(Ent)) * Ent.Gravity) - This.FluidFriction(Ent);
            SpeedAdded : constant Vec2D := (SF * This.dt * Ent.InvMass);
	begin
            Ent.all.Velocity := ClampVec(Ent.all.Velocity + SpeedAdded, This.MaxSpeed); -- Ent.all.Velocity + SpeedAdded
	end;
      else
         Ent.all.Velocity := (0.0, 0.0);
      end if;
   end IntegrateForces;

   procedure IntegrateVelocity(This : in out World; Ent : not null access Entity'Class)
   is
   begin
      if Ent.all.InvMass /= 0.0 then
         Ent.all.Coords := Ent.all.Coords + (Ent.all.Velocity * This.dt);
         This.IntegrateForces(Ent);
      end if;
   end IntegrateVelocity;

end Worlds;
