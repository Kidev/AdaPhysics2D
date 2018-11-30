package body Materials is

   function SetStatic(This : Material) return Material is
      That : Material := This;
   begin
      That.Density := 0.0;
      return That;
   end SetStatic;

end Materials;
