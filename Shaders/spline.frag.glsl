#version 450

#include "normals.inc.glsl"

in vec3 norm;
in vec2 tex;

uniform sampler2D image;

layout(location = 0) out vec4 frag;
layout(location = 1) out vec4 normals;

void main() {
	frag = texture(image, vec2(tex.x, 1 - tex.y));
	normals = vec4(encodeNormal(norm.xyz), 1.0);
}
