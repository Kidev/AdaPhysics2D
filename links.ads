with Entities; use Entities;

package Links is

   type LinkTypes is (LTRope, LTSpring);
   type LinkTypesFactorsArr is array (LinkTypes) of Float;
   type Link is record
      A, B : EntityClassAcc;
      LinkType : LinkTypes;
      Factor, RestLen : Float;
   end record;
   pragma Pack(Link);
   type LinkAcc is access all Link;

   LinkTypesFactors : LinkTypesFactorsArr :=
     (LTRope => 0.5,
      LTSpring => 500.0);
   
   function CreateLink(A, B : EntityClassAcc; LinkType : LinkTypes; Factor : Float := 0.0) return LinkAcc;
   
   procedure FreeLink(This : in out LinkAcc);

end Links;
