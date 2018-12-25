package kha3d;

import kha.math.FastVector3;
import kha.Image;

class MeshObject {
	public var mesh: Mesh;
	public var texture: Image;
	public var pos: FastVector3;

	public function new(mesh: Mesh, texture: Image, pos: FastVector3) {
		this.mesh = mesh;
		this.texture = texture;
		this.pos = pos;
	}
}
