#version 450

in vec3 pos;
in vec3 normal;
in vec2 texcoord;

uniform mat4 mvp;
uniform sampler2D heights;

out vec3 norm;
out vec2 tex;

float f(float x, float z) {
	return texture(heights, vec2(x, z)).r * 50.0;
}

void main() {
	norm = normal;
	tex = texcoord;

	float xdiv = 100;
	float ydiv = 100;
	float x = pos.x;
	x /= xdiv * 10;
	x += 0.5;
	float z = pos.z;
	z /= ydiv * 10;
	z += 0.5;
	float y = f(x, z) + 0.5;

	gl_Position = mvp * vec4(pos.x, y, pos.z, 1.0);
}
