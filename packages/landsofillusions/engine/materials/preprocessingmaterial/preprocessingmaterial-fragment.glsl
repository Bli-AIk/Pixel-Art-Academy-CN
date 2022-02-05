// LandsOfIllusions.Engine.Materials.PreprocessingMaterial.fragment
#include <THREE>
#include <uv_pars_fragment>
#include <map_pars_fragment>
#include <packing>

#include <LandsOfIllusions.Engine.Materials.materialPropertiesParametersFragment>
#include <LandsOfIllusions.Engine.Materials.readTextureDataParametersFragment>

void main()	{
  // Read material properties.
  bool translucencyTint = readMaterialProperty3(materialPropertyTranslucency).z > 0.5;

  // Determine palette color (ramp and shade).
  vec2 paletteColor;

  // Discard transparent pixels for textured fragments.
  #ifdef USE_MAP
    #include <LandsOfIllusions.Engine.Materials.readTextureDataFragment>
  #endif

  if (translucencyTint) {
    #ifdef USE_MAP
      // We're reading the color from the texture, unpack it from the texture sample.
      #include <LandsOfIllusions.Engine.Materials.unpackSamplePaletteColorFragment>
    #else
      // We're using constants, read from uniforms.
      #include <LandsOfIllusions.Engine.Materials.setPaletteColorFromMaterialPropertiesFragment>
    #endif

    // Ramp is offset by 1 so that 0 can mean no preprocessing info.
    paletteColor.r += 1.0 / 256.0;
  }

  // Preprocessing map has the tint color (ramp and shade) written to red and green channels.
  gl_FragColor = vec4(paletteColor.r, paletteColor.g, 0.0, 0.0);
}
