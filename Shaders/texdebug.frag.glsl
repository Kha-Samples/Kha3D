#version 450

in vec2 texcoord;

uniform sampler2D image;
uniform bool isDepth;

out vec4 frag;

void main() {
	vec4 color = texture(image, texcoord);
	if (isDepth) {
		frag = vec4(color.rrr, 1.0);
	}
	else {
		frag = vec4(color.rgb, 1.0);
	}
}
