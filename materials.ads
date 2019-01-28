package Materials is
   
   -- To add materials, keep ETVacuum as the first env type,
   -- Or IsSolidMaterial will be messed up
   type MaterialType is (MTConcrete, MTWood, MTSteel, MTRubber, MTIce, MTStatic,
                         ETVacuum, ETAir, ETWater);

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
   CONCRETE : constant Material := (MTConcrete, 0.6, 0.3, 0.1, 0.05, 0.0);
   WOOD : constant Material := (MTWood, 0.4, 0.5, 0.1, 0.05, 0.0);
   STEEL : constant Material := (MTSteel, 1.2, 0.1, 0.1, 0.05, 0.0);
   RUBBER : constant Material := (MTRubber, 0.3, 0.8, 0.1, 0.05, 0.0);
   ICE : constant Material := (MTIce, 0.5, 0.3, 0.01, 0.001, 0.0);
   STATIC : constant Material := (MTStatic, 0.0, 1.0, 1.0, 1.0, 0.0);
   
   -- Liquid / Gaz / V O I D
   VACUUM : constant Material := (ETVacuum, 0.0, 0.0, 0.0, 0.0, 0.0);
   AIR : constant Material := (ETAir, 0.001225, 0.0, 0.0, 0.0, 0.000018);
   WATER : constant Material := (ETWater, 0.8, 0.0, 0.0, 0.0, 0.001);
   
   -- Allows you to transform any material into a static one
   function SetStatic(This : Material) return Material;
   
   -- Allows you to change friction for a material
   -- Disables it by default
   function SetFriction(This : Material; FStatic, FDynamic : Float := 0.0) return Material;
   
   -- Tells if a material is a solid
   function IsSolidMaterial(This : Material) return Boolean;

end Materials;
