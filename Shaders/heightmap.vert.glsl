#version 450

in vec3 pos;
in vec2 texcoord;

uniform mat4 mv;
uniform mat4 mvp;
uniform sampler2D heights;

out vec2 tex;
out vec3 norm;

const float eps = 0.01;

float f(float x, float z) {
	return texture(heights, vec2(x, z)).r * 50.0;
}

// via https://mobile.twitter.com/erkaman2/status/988113178537099264
vec3 calcNormal(float x, float z) {
	return normalize(vec3(f(x - eps, z) - f(x + eps, z), 2.0 * eps, f(x, z - eps) - f(x, z + eps)));
}

void main() {
	tex = texcoord;
	float y = f(texcoord.x, texcoord.y);
	norm = calcNormal(texcoord.x, texcoord.y);
	gl_Position = mvp * vec4(pos.x, y, pos.z, 1.0);
}
