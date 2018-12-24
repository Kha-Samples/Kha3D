#version 450

#include "normals.inc.glsl"
#include "cliptex.inc.glsl"

uniform sampler2D albedo;
uniform sampler2D normals;
uniform sampler2D depth;
uniform mat4 inv;

in vec4 clipPosition;
in vec4 light;

out vec4 frag;

void main() {
	vec2 position = clipPosition.xy / clipPosition.w;
	float z = texture(depth, clipToTex(position)).r * 2.0 - 1.0;
	vec4 pos = inv * vec4(position, z, 1.0);
	vec4 color = texture(albedo, clipToTex(position));
	vec4 normal = texture(normals, clipToTex(position));
	float dist = distance(light.xyz / light.w, pos.xyz / pos.w);
	if (dist < 4.0) {
		vec3 lightVec = (light.xyz / light.w) - (pos.xyz / pos.w);
		vec3 lightdir = normalize(lightVec);
		//dist /= 1.5;
		frag = vec4(dot(decodeNormal(normal.xyz), lightdir) * (1.5 / pow(dist, 2.0)) * color.rgb, 1.0);
		//frag = vec4(encodeNormal(lightdir), 1.0);
		//frag = vec4(1.0, 0.0, 0.0, 1.0);
		//frag = vec4(normalize(light.xyz / light.w), 1.0);
	}
	else {
		discard;
	}
}
