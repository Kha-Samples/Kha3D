package kha3d;

import kha.FastFloat;
import kha.math.FastVector3;

class Plane {
	public var normal: FastVector3;
	public var d: FastFloat;

	public function new() {
		normal = new FastVector3();
	}
}
