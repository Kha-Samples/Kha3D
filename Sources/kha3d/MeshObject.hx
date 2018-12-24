package kha3d;

import kha.math.FastVector3;

class MeshObject {
	public var mesh: Mesh;
	public var pos: FastVector3;

	public function new(mesh: Mesh, pos: FastVector3) {
		this.mesh = mesh;
		this.pos = pos;
	}
}
