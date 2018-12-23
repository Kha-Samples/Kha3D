package kha3d;

import kha.math.FastMatrix4;
import kha.math.FastVector3;

class Culling {
	// see http://www.cs.otago.ac.nz/postgrads/alexis/planeExtraction.pdf
	public static function perspectiveToPlanes(vp: FastMatrix4) {
		var planes = new Array<Plane>();

		var zNear = new Plane();
		zNear.normal.x = vp._20 + vp._30;
		zNear.normal.y = vp._21 + vp._31;
		zNear.normal.z = vp._22 + vp._32;
		zNear.d = vp._23 + vp._33;
		zNear.normal.normalize();
		planes.push(zNear);

		var zFar = new Plane();
		zFar.normal.x = -vp._20 + vp._30;
		zFar.normal.y = -vp._21 + vp._31;
		zFar.normal.z = -vp._22 + vp._32;
		zFar.d = -vp._23 + vp._33;
		zFar.normal.normalize();
		planes.push(zFar);

		var bottom = new Plane();
		bottom.normal.x = vp._10 + vp._30;
		bottom.normal.y = vp._11 + vp._31;
		bottom.normal.z = vp._12 + vp._32;
		bottom.d = vp._13 + vp._33;
		bottom.normal.normalize();
		planes.push(bottom);

		var top = new Plane();
		top.normal.x = -vp._10 + vp._30;
		top.normal.y = -vp._11 + vp._31;
		top.normal.z = -vp._12 + vp._32;
		top.d = -vp._13 + vp._33;
		top.normal.normalize();
		planes.push(top);

		var left = new Plane();
		left.normal.x = vp._00 + vp._30;
		left.normal.y = vp._01 + vp._31;
		left.normal.z = vp._02 + vp._32;
		left.normal.normalize();
		left.d = vp._03 + vp._33;
		planes.push(left);

		var right = new Plane();
		right.normal.x = -vp._00 + vp._30;
		right.normal.y = -vp._01 + vp._31;
		right.normal.z = -vp._02 + vp._32;
		right.normal.normalize();
		right.d = -vp._03 + vp._33;
		planes.push(right);

		return planes;
	}

	public static function aabbInFrustum(planes: Array<Plane>, mins: FastVector3, maxs: FastVector3): Bool {
		var vmin: FastVector3 = new FastVector3();
		var vmax: FastVector3 = new FastVector3();

		for (plane in planes) {
			if (plane.normal.x > 0) {
				vmin.x = mins.x;
				vmax.x = maxs.x;
			}
			else {
				vmin.x = maxs.x;
				vmax.x = mins.x;
			}
			
			if (plane.normal.y > 0) {
				vmin.y = mins.y;
				vmax.y = maxs.y;
			}
			else {
				vmin.y = maxs.y;
				vmax.y = mins.y;
			}
			
			if (plane.normal.z > 0) {
				vmin.z = mins.z;
				vmax.z = maxs.z;
			}
			else {
				vmin.z = maxs.z;
				vmax.z = mins.z;
			}

			if (plane.normal.dot(vmin) + plane.d > 0) {
				return false; // outside
			}

			//if (plane.normal.dot(vmax) + plane.d >= 0) {
			//	return true; // intersection
			//}

			// inside
		}

		return true;
	}
}
