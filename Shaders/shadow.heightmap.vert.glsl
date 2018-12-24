#version 450

in vec3 pos;
in vec3 normal;
in vec2 texcoord;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;
uniform sampler2D heights;

out vec4 position;

void main() {
	gl_Position = position = projection * view * model * vec4(pos.x, texture(heights, texcoord).r * 50.0, pos.z, 1.0);
}
