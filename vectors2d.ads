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

   function Normalize(This : Vec2D) return Vec2D;

   function Sq(This : Vec2D) return Vec2D;

   function Clamp(Value, Min, Max : Float) return Float;

   function Clamp(This : Vec2D; Max : Vec2D) return Vec2D is
     (x => (if Max.x = 0.0 then This.x else Clamp(This.x, -Max.x, Max.x)),
      y => (if Max.y = 0.0 then This.y else Clamp(This.y, -Max.y, Max.y)));

end Vectors2D;
