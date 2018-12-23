package kha3d;

import kha.math.Vector3;

class Spline {
	static function deBoor3(k: Int, degree: Int, i: Int, x: Float, knots: Array<Float>, ctrlPoints: Array<Vector3>): Vector3 {
		if (k == 0) return ctrlPoints[i];
		else {
			var alpha: Float = (x - knots[i]) / (knots[i + degree + 1 - k] - knots[i]);
			return (deBoor3(k - 1, degree, i - 1, x, knots, ctrlPoints).mult(1 - alpha).add(deBoor3(k - 1, degree, i, x, knots, ctrlPoints).mult(alpha)));
		}
	}

	static function findInterval(x: Float, knots: Array<Float>): Int {
		for (i in 1...knots.length - 1) {
			if (x < knots[i]) return i - 1;
			else if (x == knots[knots.length - 1]) return knots.length - 1;
		}
		return -1;
	}

	static function deBoor2(degree: Int, x: Float, knots: Array<Float>, ctrlPoints: Array<Vector3>): Vector3 {
		return deBoor3(degree, degree, findInterval(x, knots), x, knots, ctrlPoints);
	}

	public static function deBoor(ctrlPoints: Array<Vector3>, x: Float, degree: Int = 3): Vector3 {
		var knots = new Array<Float>();
		knots[ctrlPoints.length + degree] = 0;
		for (i in 0...degree + 1) knots[i] = 0;
		for (i in knots.length - degree - 2...knots.length) knots[i] = 1.01;
		var count = knots.length - (degree + 1) * 2 + 1;
		for (i in degree + 1...knots.length - degree - 1) {
			knots[i] = 1.0 * (i - degree) / count;
		}
		return deBoor2(degree, x, knots, ctrlPoints);
	}

	public static function deBoorThirdDegree(ctrlPoints: Array<Vector3>, x: Float): Vector3 {
		return deBoor(ctrlPoints, x);
	}

	public static function deCasteljau(P: Array<Vector3>, u: Float): Vector3 {
		var Q = new Array<Vector3>();
		Q[P.length - 1] = new Vector3();
		for (i in 0...P.length) Q[i] = P[i];
		for (k in 1...P.length) {
			for (i in 0...P.length - k) {
				Q[i] = Q[i].mult(1 - u).add(Q[i + 1].mult(u));
			}
		}
		return Q[0];
	}

	static final stepLength = 0.0001;
	static var splineLength: Float;
	static var lengthSteps = new Array<Float>();
	static var posSteps = new Array<Vector3>();

	static function calculateSplineLength(points: Array<Vector3>, func: Array<Vector3>->Float->Vector3) {
		var length = 0.0;
		lengthSteps[0] = 0;
		var last = func(points, 0);
		posSteps[0] = last;
		for (i in 1...10000) {
			var position = stepLength * i;
			var current = func(points, position);
			length += current.sub(last).length;
			lengthSteps[i] = length;
			posSteps[i] = current;
			last = current;
		}
		length += func(points, 1.0).sub(last).length;
		lengthSteps[10000] = length;
		posSteps[10000] = func(points, 1.0);
		return length;
	}

	public static function constantSpeedSpline(t: Float): Vector3 {
		return constantSpeedSplineDistance(t * splineLength);
	}

	public static function constantSpeedSplineDistance(aim: Float): Vector3 {
		if (aim >= lengthSteps[10000]) return posSteps[10000];
	
		var i = 0;
		
		while (lengthSteps[i] < aim) ++i;
	
		if (i == 0) return posSteps[0];
	
		var length = lengthSteps[i];
		var prevLength = lengthSteps[i - 1];
		
		var current = posSteps[i];
		var last = posSteps[i - 1];
	
		var dif = current.sub(last);
		var toNextLength = length - prevLength;
		var toAim = aim - prevLength;
		return last.add(dif).mult(toAim / toNextLength);
	}

	public static function prepareSpline(points: Array<Vector3>, splineFunc: Array<Vector3>->Float->Vector3) {
		splineLength = calculateSplineLength(points, splineFunc);
	}
}
