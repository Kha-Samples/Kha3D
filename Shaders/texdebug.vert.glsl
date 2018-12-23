#version 450

in vec2 pos;
in vec2 tex;

out vec2 texcoord;

void main() {
	texcoord = tex;
	gl_Position = vec4(pos, 0.5, 1.0);
}
