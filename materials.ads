package Materials is
   
   type MaterialType is (MTConcrete, MTWood, MTSteel, MTRubber, MTIce, MTStatic);

   type Material is record
      MType : MaterialType;
      Density : Float;
      Restitution : Float;
      StaticFriction : Float; -- on itself
      DynamicFriction : Float; -- on itself
   end record;
   
   CONCRETE : Material := (MTConcrete, 0.6, 0.3, 0.1, 0.05);
   WOOD : Material := (MTWood, 0.3, 0.5, 0.1, 0.05);
   STEEL : Material := (MTSteel, 1.2, 0.1, 0.1, 0.05);
   RUBBER : Material := (MTRubber, 0.3, 0.8, 0.1, 0.05);
   ICE : Material := (MTIce, 0.93, 0.3, 0.01, 0.001);
   STATIC : Material := (MTStatic, 0.0, 1.0, 1.0, 1.0);

end Materials;
