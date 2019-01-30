with Entities; use Entities;

package Links is

   type LinkTypes is (LTRope, LTSpring);
   type Link is record
      A, B : EntityClassAcc;
      Factor : Float;
   end record;
   pragma Pack(Link);
   type LinkAcc is access Link;

   LinkTypesFactors : array (LinkTypes) of Float :=
     (LTRope => 1.0,
      LTSpring => 0.5);
   
   function CreateLink(A, B : EntityClassAcc; Factor : Float) return LinkAcc;
   
   function CreateLink(A, B : EntityClassAcc; LinkType : LinkTypes) return LinkAcc;
   
   procedure FreeLink(This : in out LinkAcc);

end Links;
