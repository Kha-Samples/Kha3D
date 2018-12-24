vec3 encodeNormal(vec3 normal) {
	return (normalize(normal) + 1.0) / 2.0;
}

vec3 decodeNormal(vec3 normal) {
	return normal * 2.0 - 1.0;
}
