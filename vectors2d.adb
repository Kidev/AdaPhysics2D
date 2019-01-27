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
   begin
      return Sqrt(MagSq(This));
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

end Vectors2D;
