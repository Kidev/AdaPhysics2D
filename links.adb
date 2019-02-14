with Ada.Unchecked_Deallocation;

package body Links is
   
   function CreateLink(A, B : EntityClassAcc; LinkType : LinkTypes; Factor : Float := 0.0) return LinkAcc
   is
      UseFactor : constant Float := (if Factor = 0.0 then LinkTypesFactors(LinkType) else Factor);
   begin
      return new Link'(A => A, B => B, LinkType => LinkType, Factor => UseFactor, RestLen => GetDistance(A.all, B.all));
   end CreateLink;
   
   procedure FreeLink(This : in out LinkAcc) is
      procedure FreeL is new Ada.Unchecked_Deallocation(Link, LinkAcc);
   begin
      FreeL(This);
   end FreeLink;

end Links;
