package Materials is
   
   type MaterialType is (MTConcrete, MTWood, MTSteel, MTRubber, MTIce, MTStatic, ETVacuum, ETAir, ETWater);

   type Material is record
      MType : MaterialType;
      Density : Float;
      Restitution : Float; -- tension of surface for water ? TODO investigate
      StaticFriction : Float; -- on itself
      DynamicFriction : Float; -- on itself
      Viscosity : Float; -- only for non solid
   end record;
   pragma Pack (Material);
   
   -- Solid
   CONCRETE : constant Material := (MTConcrete, 0.6, 0.3, 0.1, 0.05);
   WOOD : constant Material := (MTWood, 0.3, 0.5, 0.1, 0.05);
   STEEL : constant Material := (MTSteel, 1.2, 0.1, 0.1, 0.05);
   RUBBER : constant Material := (MTRubber, 0.3, 0.8, 0.1, 0.05);
   ICE : constant Material := (MTIce, 0.93, 0.3, 0.01, 0.001);
   STATIC : constant Material := (MTStatic, 0.0, 1.0, 1.0, 1.0);
   
   -- Liquid / Gaz / V O I D
   VACUUM : constant Environment := (ETVacuum, 0.0, 0.0, 0.0, 0.0, 0.0);
   AIR : constant Environment := (ETAir, 0.001225, 0.0, 0.0, 0.0, 0.000018);
   WATER : constant Environment := (ETWater, 1.0, 0.0, 0.0, 0.0, 0.001);
   
   -- Allows you to transform any material into a static one
   function SetStatic(This : Material) return Material;
   
   -- Allows you to change friction for a material
   -- Disables it by default
   function SetFriction(This : Material; FStatic, FDynamic : Float := 0.0) return Material;

end Materials;
