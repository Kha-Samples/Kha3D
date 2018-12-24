#version 450

in vec2 pos;

out vec2 position;

void main() {
	position = pos;
	gl_Position = vec4(pos, 0.5, 1.0);
}
