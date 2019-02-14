with Ada.Unchecked_Deallocation;
with Physics; use Physics;
with Materials;
with Circles;

package body Worlds is

   -- init world
   procedure Init(This : in out World; dt : in Float; MaxEnts : Natural := 32)
   is
      VecZero : constant Vec2D := (0.0, 0.0);
   begin
      This.MaxEntities := MaxEnts;
      This.dt := dt;
      This.Invdt := 1.0 / dt;
      This.Entities := new EntsList.List;
      This.Environments := new EntsList.List;
      This.Links := new LinksList.List;
      This.Cols := new ColsList.List;
      This.InvalidChecker := null;
      This.MaxSpeed := VecZero;
      This.StaticEnt :=
        Circles.Create(VecZero, VecZero, VecZero, 1.0,
                       Materials.STATIC.SetFriction.SetRestitution(LinkTypesFactors(LTRope)));
   end Init;

   procedure IncreaseMaxEntities(This : in out World; Count : Positive)
   is
   begin
      This.MaxEntities := This.MaxEntities + Count;
   end IncreaseMaxEntities;

   procedure Step(This : in out World; Mode : StepModes := Step_Normal)
   is
   begin
      if Mode = Step_LowRAM then
         StepLowRAM(This);
      else
         StepNormal(This);
      end if;
   end Step;

   -- Add entity to the world
   procedure AddEntity(This : in out World; Ent : not null EntityClassAcc)
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
   procedure AddEnvironment(This : in out World; Ent : not null EntityClassAcc)
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

   procedure LinkEntities(This : in out World; A, B : EntityClassAcc; LinkType : LinkTypes; Factor : Float := 0.0) is
   begin
      if This.MaxEntities = 0
        or else Integer(This.Entities.Length)
              + Integer(This.Environments.Length)
              + Integer(This.Links.Length) < This.MaxEntities
      then
         This.Links.Append(CreateLink(A, B, LinkType, Factor));
      end if;
   end LinkEntities;

   procedure UnlinkEntity(This : in out World; E : EntityClassAcc) is
      CurLink : LinkAcc;
      Edited : Boolean := False;
   begin
      loop
         Edited := False;
         declare
            use LinksList;
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
      use EntsList; use LinksList;
      procedure FreeEntList is new Ada.Unchecked_Deallocation(EntsList.List, EntsListAcc);
      procedure FreeLinkList is new Ada.Unchecked_Deallocation(LinksList.List, LinksListAcc);
      procedure FreeColsList is new Ada.Unchecked_Deallocation(ColsList.List, ColsListAcc);
      Curs : EntsList.Cursor := This.Entities.First;
      CursL : LinksList.Cursor := This.Links.First;
      TmpLink : LinkAcc;
   begin

      while CursL /= LinksList.No_Element loop
         TmpLink := LinksList.Element(CursL);
         FreeLink(TmpLink);
         CursL := LinksList.Next(CursL);
      end loop;

      while Curs /= EntsList.No_Element loop
         FreeEnt(EntsList.Element(Curs));
         Curs := EntsList.Next(Curs);
      end loop;

      Curs := This.Environments.First;
      while Curs /= EntsList.No_Element loop
         FreeEnt(EntsList.Element(Curs));
         Curs := EntsList.Next(Curs);
      end loop;

      FreeEnt(This.StaticEnt);

      This.Entities.Clear;
      This.Environments.Clear;
      This.Links.Clear;
      This.Cols.Clear;

      FreeEntList(This.Entities);
      FreeEntList(This.Environments);
      FreeLinkList(This.Links);
      FreeColsList(This.Cols);
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
   procedure RemoveEntity(This : in out World; Ent : EntityClassAcc; Destroy : Boolean)
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
   procedure RemoveEnvironment(This : in out World; Ent : not null EntityClassAcc; Destroy : Boolean)
   is
      Curs : EntsList.Cursor := This.Environments.Find(Ent);
   begin
      This.Environments.Delete(Curs);
      if Destroy then
         FreeEnt(Ent);
      end if;
   end RemoveEnvironment;

   function GetEntities(This : in World) return EntsListAcc
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

   function GetEnvironments(This : in World) return EntsListAcc
   is
   begin
      return This.Environments;
   end GetEnvironments;

   function GetLinks(This : in World) return LinksListAcc
   is
   begin
      return This.Links;
   end GetLinks;

   procedure CheckEntities(This : in out World)
   is
   begin
      if This.InvalidChecker /= null then
         declare
            E : EntityClassAcc;
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

end Worlds;
