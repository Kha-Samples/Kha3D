#version 450

in vec3 pos;
in vec3 meshpos;
in vec3 normal;
in vec2 texcoord;

uniform mat4 mvp;

void main() {
	vec4 position = vec4(pos * 0.1 + meshpos, 1.0);
	gl_Position = mvp * position;
}
