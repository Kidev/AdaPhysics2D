with Ada.Numerics.Generic_Elementary_Functions;

package Vectors2D is

   package flGEF is new Ada.Numerics.Generic_Elementary_Functions(Float);
   use flGEF;

   type Vec2D is record
      x : Float;
      y : Float;
   end record;

   function "=" (Left, Right : Vec2D) return Boolean;

   function "+" (Left, Right : Vec2D) return Vec2D;

   function "-" (Left, Right : Vec2D) return Vec2D;

   -- unary minus
   function "-" (Right : Vec2D) return Vec2D;

   -- unary plus, replacement for 'Image
   function "+" (Right : Vec2D) return String;

   -- scalar product
   function "*" (Left, Right : Vec2D) return Float;

   function "*" (Left : Float; Right : Vec2D) return Vec2D;

   function "*" (Left : Vec2D; Right : Float) return Vec2D;

   function "/" (Left : Vec2D; Right : Float) return Vec2D;

   function MagSq(This : Vec2D) return Float;

   function Mag(This : Vec2D) return Float;

end Vectors2D;
