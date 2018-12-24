in vec3 sunpos;

//uniform sampler2DShadow shadowImage;
uniform sampler2D shadowImage;

bool inShadow() {
	if (sunpos.x >= -1.0 && sunpos.x <= 1.0 && sunpos.y >= -1.0 && sunpos.y <= 1.0) {
		float texshadow = texture(shadowImage, vec2((sunpos.x + 1.0) / 2.0, (sunpos.y + 1.0) / 2.0)).r;
		float sunshadow = (sunpos.z + 1.0) / 2.0;
		return texshadow < sunshadow - 0.01;
	}
	else {
		return false;
	}
}
