package Materials is
   
   type MaterialType is (MTConcrete, MTWood, MTSteel, MTRubber, MTIce, MTStatic);

   type Material is record
      MType : MaterialType;
      Density : Float;
      Restitution : Float;
      StaticFriction : Float; -- on itself
      DynamicFriction : Float; -- on itself
   end record;
   
   CONCRETE : Material := (MTConcrete, 0.6, 0.3, 0.5, 0.3);
   WOOD : Material := (MTWood, 0.3, 0.5, 0.3, 0.2);
   STEEL : Material := (MTSteel, 1.2, 0.1, 0.74, 0.57);
   RUBBER : Material := (MTRubber, 0.3, 0.8, 1.0, 0.8);
   ICE : Material := (MTIce, 0.93, 0.3, 0.1, 0.03);
   STATIC : Material := (MTStatic, 0.0, 1.0, 1.0, 1.0);

end Materials;
