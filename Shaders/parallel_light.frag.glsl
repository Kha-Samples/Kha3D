#version 450

#include "normals.inc.glsl"
#include "cliptex.inc.glsl"

uniform sampler2D albedo;
uniform sampler2D normals;
uniform sampler2D depth;
uniform sampler2D shadowMap;
uniform mat4 inv;
uniform mat4 sunMVP;
uniform vec3 sunLightDir;

in vec2 position;

out vec4 frag;

bool inShadow(vec3 sunpos) {
	if (sunpos.x >= -1.0 && sunpos.x <= 1.0 && sunpos.y >= -1.0 && sunpos.y <= 1.0) {
		float texshadow = texture(shadowMap, vec2((sunpos.x + 1.0) / 2.0, (sunpos.y + 1.0) / 2.0)).r;
		float sunshadow = (sunpos.z + 1.0) / 2.0;
		return texshadow < sunshadow - 0.01;
	}
	else {
		return false;
	}
}

void main() {
	float z = texture(depth, clipToTex(position)).r * 2.0 - 1.0;
	vec4 pos = inv * vec4(position, z, 1.0);
	vec4 sunpos = sunMVP * pos;
	if (inShadow(sunpos.xyz / sunpos.w)) {
		frag = vec4(0.0, 0.0, 0.0, 1.0);
	}
	else {
		vec4 color = texture(albedo, clipToTex(position));
		vec4 normal = texture(normals, clipToTex(position));
		frag = vec4(dot(decodeNormal(normal.xyz), sunLightDir) * 0.5 * color.rgb, 1.0);
	}
}
