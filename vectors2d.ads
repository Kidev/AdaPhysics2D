package Vectors2D with SPARK_Mode => On is

   type Vec2D is record
      x : Float := 0.0;
      y : Float := 0.0;
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

   function Mag(This : Vec2D) return Float with SPARK_Mode => Off;

   function Normalize(This : Vec2D) return Vec2D with SPARK_Mode => Off;

   function Sq(This : Vec2D) return Vec2D;

   function Clamp(Value, Min, Max : Float) return Float
     with Pre => Min <= Max,
          Contract_Cases => (Value < Min => Clamp'Result = Min,
                             Value > Max => Clamp'Result = Max,
                             others => Clamp'Result = Value),
          Depends => (Clamp'Result => (Value, Min, Max));

   function ClampVec(This : Vec2D; Max : Vec2D) return Vec2D
     with Contract_Cases => (Max.x = 0.0 and Max.y /= 0.0 => abs ClampVec'Result.y <= abs Max.y,
                             Max.x /= 0.0 and Max.y = 0.0 => abs ClampVec'Result.x <= abs Max.x,
                             others => (if Max = (0.0, 0.0)
                                          then ClampVec'Result = This
                                          else ClampVec'Result.y <= abs Max.y and abs ClampVec'Result.x <= abs Max.x)),
          Depends => (ClampVec'Result => (This, Max));

end Vectors2D;
