package body Materials is

   function SetStatic(This : Material) return Material is
      That : Material := This;
   begin
      That.Density := 0.0;
      return That;
   end SetStatic;

   function SetFriction(This : Material; FStatic, FDynamic : Float := 0.0) return Material is
      That : Material := This;
   begin
      That.StaticFriction := FStatic;
      That.DynamicFriction := FDynamic;
      return That;
   end SetFriction;

   function IsSolidMaterial(This : Material) return Boolean is
   begin
      return (MaterialType'Pos(This.MType) < MaterialType'Pos(ETVacuum));
   end IsSolidMaterial;

end Materials;
