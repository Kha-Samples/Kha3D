package kha3d;

import kha.Image;
import kha.math.FastMatrix4;
import kha.graphics4.Graphics;
import kha.Shaders;
import kha.graphics4.PipelineState;
import kha.graphics4.TextureUnit;
import kha.graphics4.ConstantLocation;
import kha.math.Vector2;
import kha.math.Vector3;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexStructure;

class SplineMesh {
	final width = 1.0;
	final extraHeight = 0.5;

	var splineMv: ConstantLocation;
	var splineMvp: ConstantLocation;
	var splineTexUnit: TextureUnit;
	var splineHeightsTexUnit: TextureUnit;
	var splinePipeline: PipelineState;

	static function createIndexBufferForQuads(count: Int): IndexBuffer {
		var ib = new IndexBuffer(count * 3 * 2, StaticUsage);
		var buffer = ib.lock();
		var i = 0;
		var bi = 0;
		while (bi < count * 3 * 2) {
			buffer[bi + 0] = i;
			buffer[bi + 1] = i + 1;
			buffer[bi + 2] = i + 2;
			buffer[bi + 3] = i + 2;
			buffer[bi + 4] = i + 1;
			buffer[bi + 5] = i + 3;

			i += 4;
			bi += 6;
		}
		ib.unlock();
		return ib;
	}

	static function getHeightAt(x: Float, z: Float): Float {
		return HeightMap.height(x, z);
	}

	public function new(spline: Array<Vector3>, subdivision: Float = 0.0005) {
		this.subdivision = subdivision;

		var size = Std.int(1.0 / subdivision);

		structure = new VertexStructure();
		structure.add("pos", Float3);
		structure.add("normal", Float3);
		structure.add("texcoord", Float2);

		splinePipeline = new PipelineState();
		splinePipeline.vertexShader = Shaders.spline_vert;
		splinePipeline.fragmentShader = Shaders.spline_frag;
		splinePipeline.inputLayout = [structure];
		splinePipeline.depthWrite = true;
		splinePipeline.depthMode = Less;
		splinePipeline.compile();

		splineMv = splinePipeline.getConstantLocation("mv");
		splineMvp = splinePipeline.getConstantLocation("mvp");
		splineTexUnit = splinePipeline.getTextureUnit("image");
		splineHeightsTexUnit = splinePipeline.getTextureUnit("heights");

		vertices = new VertexBuffer(size * 4 * 2, structure, StaticUsage);
		indices = createIndexBufferForQuads(size * 2 - 1);

		var distance = 0.0;

		var splineVertices = vertices.lock();

		var lastDistance = 0.0;
		var lastpos1 = Spline.deBoor(spline, 0);
		var lastpos2 = Spline.deBoor(spline, 0);
		var lastpos3 = Spline.deBoor(spline, 0);
		var lastpos4 = Spline.deBoor(spline, 0);

		var i = 0;
		var pos = 0.0;
		while (pos < 1) {
			var direction = Spline.deBoor(spline, pos + subdivision).sub(Spline.deBoor(spline, pos));
			var dir2d = new Vector2(direction.x, direction.z);
			
			var nextDistance: Float = distance + dir2d.length / 50.0;
			
			dir2d.normalize();
			var deviationDir = new Vector3(dir2d.y, 0, -dir2d.x);
			deviationDir.normalize();
			deviationDir = deviationDir.mult(width);

			var pos1 = Spline.deBoor(spline, pos + subdivision).sub(deviationDir);
			var pos2 = Spline.deBoor(spline, pos).sub(deviationDir);
			var pos3 = Spline.deBoor(spline, pos + subdivision).add(deviationDir);
			var pos4 = Spline.deBoor(spline, pos).add(deviationDir);

			splineVertices[i * 8 * 8 + 0] = pos2.x;
			splineVertices[i * 8 * 8 + 1] = getHeightAt(pos2.x, pos2.z) + extraHeight;
			splineVertices[i * 8 * 8 + 2] = pos2.z;
			splineVertices[i * 8 * 8 + 3] = 0;
			splineVertices[i * 8 * 8 + 4] = 1;
			splineVertices[i * 8 * 8 + 5] = 0;
			splineVertices[i * 8 * 8 + 6] = 0;
			splineVertices[i * 8 * 8 + 7] = distance;

			splineVertices[i * 8 * 8 + 8] = lastpos1.x;
			splineVertices[i * 8 * 8 + 9] = getHeightAt(lastpos1.x, lastpos1.z) + extraHeight;
			splineVertices[i * 8 * 8 + 10] = lastpos1.z;
			splineVertices[i * 8 * 8 + 11] = 0;
			splineVertices[i * 8 * 8 + 12] = 1;
			splineVertices[i * 8 * 8 + 13] = 0;
			splineVertices[i * 8 * 8 + 14] = 0;
			splineVertices[i * 8 * 8 + 15] = lastDistance;

			splineVertices[i * 8 * 8 + 16] = pos4.x;
			splineVertices[i * 8 * 8 + 17] = getHeightAt(pos4.x, pos4.z) + extraHeight;
			splineVertices[i * 8 * 8 + 18] = pos4.z;
			splineVertices[i * 8 * 8 + 19] = 0;
			splineVertices[i * 8 * 8 + 20] = 1;
			splineVertices[i * 8 * 8 + 21] = 0;
			splineVertices[i * 8 * 8 + 22] = 1;
			splineVertices[i * 8 * 8 + 23] = distance;

			splineVertices[i * 8 * 8 + 24] = lastpos3.x;
			splineVertices[i * 8 * 8 + 25] = getHeightAt(lastpos3.x, lastpos3.z) + extraHeight;
			splineVertices[i * 8 * 8 + 26] = lastpos3.z;
			splineVertices[i * 8 * 8 + 27] = 0;
			splineVertices[i * 8 * 8 + 28] = 1;
			splineVertices[i * 8 * 8 + 29] = 0;
			splineVertices[i * 8 * 8 + 30] = 1;
			splineVertices[i * 8 * 8 + 31] = lastDistance;

			//

			splineVertices[i * 8 * 8 + 32] = pos1.x;
			splineVertices[i * 8 * 8 + 33] = getHeightAt(pos1.x, pos1.z) + extraHeight;
			splineVertices[i * 8 * 8 + 34] = pos1.z;
			splineVertices[i * 8 * 8 + 35] = 0;
			splineVertices[i * 8 * 8 + 36] = 1;
			splineVertices[i * 8 * 8 + 37] = 0;
			splineVertices[i * 8 * 8 + 38] = 0;
			splineVertices[i * 8 * 8 + 39] = nextDistance;

			splineVertices[i * 8 * 8 + 40] = pos2.x;
			splineVertices[i * 8 * 8 + 41] = getHeightAt(pos2.x, pos2.z) + extraHeight;
			splineVertices[i * 8 * 8 + 42] = pos2.z;
			splineVertices[i * 8 * 8 + 43] = 0;
			splineVertices[i * 8 * 8 + 44] = 1;
			splineVertices[i * 8 * 8 + 45] = 0;
			splineVertices[i * 8 * 8 + 46] = 0;
			splineVertices[i * 8 * 8 + 47] = distance;

			splineVertices[i * 8 * 8 + 48] = pos3.x;
			splineVertices[i * 8 * 8 + 49] = getHeightAt(pos3.x, pos3.z) + extraHeight;
			splineVertices[i * 8 * 8 + 50] = pos3.z;
			splineVertices[i * 8 * 8 + 51] = 0;
			splineVertices[i * 8 * 8 + 52] = 1;
			splineVertices[i * 8 * 8 + 53] = 0;
			splineVertices[i * 8 * 8 + 54] = 1;
			splineVertices[i * 8 * 8 + 55] = nextDistance;

			splineVertices[i * 8 * 8 + 56] = pos4.x;
			splineVertices[i * 8 * 8 + 57] = getHeightAt(pos4.x, pos4.z) + extraHeight;
			splineVertices[i * 8 * 8 + 58] = pos4.z;
			splineVertices[i * 8 * 8 + 59] = 0;
			splineVertices[i * 8 * 8 + 60] = 1;
			splineVertices[i * 8 * 8 + 61] = 0;
			splineVertices[i * 8 * 8 + 62] = 1;
			splineVertices[i * 8 * 8 + 63] = distance;

			lastDistance = distance;
			distance = nextDistance;
			++i;

			lastpos1 = pos1;
			lastpos2 = pos2;
			lastpos3 = pos3;
			lastpos4 = pos4;

			pos += subdivision;
		}
		vertices.unlock();
	}

	public var structure: VertexStructure;
	public var vertices: VertexBuffer;
	public var indices: IndexBuffer;
	public var subdivision: Float;

	public function render(g: Graphics, mvp: FastMatrix4, mv: FastMatrix4, image: Image, heights: Image): Void {
		g.setPipeline(splinePipeline);
		g.setMatrix(splineMvp, mvp);
		g.setMatrix(splineMv, mv);
		g.setTexture(splineTexUnit, image);
		g.setTexture(splineHeightsTexUnit, heights);
		g.setTextureParameters(splineTexUnit, Repeat, Repeat, LinearFilter, LinearFilter, NoMipFilter);
		g.setVertexBuffer(vertices);
		g.setIndexBuffer(indices);
		g.drawIndexedVertices();
	}
}
