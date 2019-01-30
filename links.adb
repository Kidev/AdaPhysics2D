with Ada.Unchecked_Deallocation;

package body Links is

   function CreateLink(A, B : EntityClassAcc; Factor : Float) return LinkAcc
   is
   begin
      return new Link'(A => A, B => B, Factor => Factor, RestLen => GetDistance(A.all, B.all));
   end CreateLink;
   
   function CreateLink(A, B : EntityClassAcc; LinkType : LinkTypes) return LinkAcc
   is
   begin
      return new Link'(A => A, B => B, Factor => LinkTypesFactors(LinkType), RestLen => GetDistance(A.all, B.all));
   end CreateLink;
   
   procedure FreeLink(This : in out LinkAcc) is
      procedure FreeL is new Ada.Unchecked_Deallocation(Link, LinkAcc);
   begin
      FreeL(This);
   end FreeLink;

end Links;
