#version 450

#include "normals.inc.glsl"

in vec2 tex;
in vec3 norm;

uniform sampler2D image;

layout(location = 0) out vec4 frag;
layout(location = 1) out vec4 normals;

void main() {
	frag = texture(image, tex);
	normals = vec4(encodeNormal(norm.xyz), 1.0);
}
