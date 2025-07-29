shader_type spatial;

#define LIT diffuse_lambert, vertex_lighting
#define CULL cull_disabled
#define SPRITE
#define BLEND_ALPHA

#include "res://shaders/include/psx_base.gdshaderinc"
