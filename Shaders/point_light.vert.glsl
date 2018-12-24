#version 450

uniform mat4 mvp;

in vec3 pos;
in vec3 meshpos;

out vec4 clipPosition;
out vec4 light;

void main() {
	light = vec4(meshpos, 1.0);
	gl_Position = clipPosition = mvp * vec4(pos * 0.1 + meshpos, 1.0);
}
