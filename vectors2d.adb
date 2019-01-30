with Ada.Numerics.Generic_Elementary_Functions;

package body Vectors2D is

   function "=" (Left, Right : Vec2D) return Boolean is
   begin
      return (Left.x = Right.x) and (Left.y = Right.y);
   end "=";

   function "+" (Left, Right : Vec2D) return Vec2D is
   begin
      return Vec2D'(x => Left.x + Right.x, y => Left.y + Right.y);
   end "+";

   function "-" (Left, Right : Vec2D) return Vec2D is
   begin
      return Vec2D'(x => Left.x - Right.x, y => Left.y - Right.y);
   end "-";

   -- unary minus
   function "-" (Right : Vec2D) return Vec2D is
   begin
      return Vec2D'(x => -Right.x, y => -Right.y);
   end "-";

   -- unary plus, replacement for 'Image
   function "+" (Right : Vec2D) return String is
   begin
      return "[" & Right.x'Image & ";" & Right.y'Image & "]";
   end "+";

   -- scalar product
   function "*" (Left, Right : Vec2D) return Float is
   begin
      return (Left.x * Right.x) + (Left.y * Right.y);
   end "*";

   function "*" (Left : Float; Right : Vec2D) return Vec2D is
   begin
      return Vec2D'(x => Left * Right.x, y => Left * Right.y);
   end "*";

   function "*" (Left : Vec2D; Right : Float) return Vec2D is
   begin
      return Vec2D'(x => Left.x * Right, y => Left.y * Right);
   end "*";

   function "/" (Left : Vec2D; Right : Float) return Vec2D is
   begin
      return Vec2D'(x => Left.x / Right, y => Left.y / Right);
   end "/";

   function MagSq(This : Vec2D) return Float is
   begin
      return (This.x * This.x) + (This.y * This.y);
   end MagSq;

   function Mag(This : Vec2D) return Float is
      package flGEF is new Ada.Numerics.Generic_Elementary_Functions(Float);
   begin
      return flGEF.Sqrt(MagSq(This));
   end Mag;

   function Sq(This : Vec2D) return Vec2D is
      SignX : constant Float := (if This.x >= 0.0 then 1.0 else -1.0);
      SignY : constant Float := (if This.y >= 0.0 then 1.0 else -1.0);
   begin
      return ((SignX * This.x * This.x), (SignY * This.y * This.y));
   end Sq;

   function Normalize(This : Vec2D) return Vec2D is
      Norm : constant Float := Mag(This);
   begin
      if Norm = 0.0 then return This; end if;
      return This / Norm;
   end Normalize;

   function Clamp(Value, Min, Max : Float) return Float
   is
   begin

      if Value < Min then return Min; end if;
      if Value > Max then return Max; end if;
      return Value;

   end Clamp;

   function ClampVec(This : Vec2D; Max : Vec2D) return Vec2D is
      pragma Assume(This.x'Valid and This.y'Valid and Max.x'Valid and Max.y'Valid);
   begin
      return (x => (if Max.x = 0.0 then This.x else Clamp(This.x, -Max.x, Max.x)),
              y => (if Max.y = 0.0 then This.y else Clamp(This.y, -Max.y, Max.y)));
   end ClampVec;

end Vectors2D;
