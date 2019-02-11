with Entities; use Entities;

package Links is

   type LinkTypes is (LTRope, LTSpring);
   type LinkTypesFactorsArr is array (LinkTypes) of Float;
   type Link is record
      A, B : EntityClassAcc;
      Factor, RestLen : Float;
   end record;
   pragma Pack(Link);
   type LinkAcc is access Link;

   LinkTypesFactors : LinkTypesFactorsArr :=
     (LTRope => 100000.0,
      LTSpring => 500.0);
   
   function CreateLink(A, B : EntityClassAcc; Factor : Float) return LinkAcc;
   
   function CreateLink(A, B : EntityClassAcc; LinkType : LinkTypes) return LinkAcc;
   
   procedure FreeLink(This : in out LinkAcc);

end Links;
