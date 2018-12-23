package kha3d;

import kha.Assets;
import kha.Image;
import kha.Shaders;
import kha.graphics4.CompareMode;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.graphics4.Usage;
import kha.graphics4.Graphics;
import kha.graphics4.IndexBuffer;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexBuffer;
import kha.graphics4.ConstantLocation;
import kha.graphics4.TextureUnit;
import kha.math.FastMatrix4;

class HeightMap {
	static var pipeline: PipelineState;
	static var vertexBuffer: VertexBuffer;
	static var indexBuffer: IndexBuffer;
	static var mvp: ConstantLocation;
	static var mv: ConstantLocation;
	static var texUnit: TextureUnit;
	static var heights: TextureUnit;
	static final xdiv: Int = 100;
	static final ydiv: Int = 100;

	public static function init(): Void {
		var structure = new VertexStructure();
		structure.add("pos", VertexData.Float3);
		structure.add("texcoord", VertexData.Float2);

		pipeline = new PipelineState();
		pipeline.inputLayout = [structure];
		pipeline.vertexShader = Shaders.heightmap_vert;
		pipeline.fragmentShader = Shaders.heightmap_frag;
		pipeline.depthWrite = true;
		pipeline.depthMode = CompareMode.Less;
		pipeline.compile();

		mvp = pipeline.getConstantLocation("mvp");
		mv = pipeline.getConstantLocation("mv");
		texUnit = pipeline.getTextureUnit("image");
		heights = pipeline.getTextureUnit("heights");

		vertexBuffer = new VertexBuffer(xdiv * ydiv, structure, Usage.StaticUsage);
		var vertices = vertexBuffer.lock();
		for (y in 0...ydiv) {
			for (x in 0...xdiv) {
				vertices.set(y * xdiv * 5 + x * 5 + 0, (x - Std.int(xdiv / 2)) * 10);
				vertices.set(y * xdiv * 5 + x * 5 + 1, 0);
				vertices.set(y * xdiv * 5 + x * 5 + 2, (y - Std.int(ydiv / 2)) * 10);
				vertices.set(y * xdiv * 5 + x * 5 + 3, x / xdiv);
				vertices.set(y * xdiv * 5 + x * 5 + 4, y / ydiv);
			}
		}
		vertexBuffer.unlock();

		indexBuffer = new IndexBuffer((xdiv - 1) * (ydiv - 1) * 6, Usage.StaticUsage);
		var indices = indexBuffer.lock();
		var w = xdiv - 1;
		for (y in 0...ydiv - 1) {
			for (x in 0...xdiv - 1) {
				indices[y * w * 6 + x * 6 + 0] = y * xdiv + x;
				indices[y * w * 6 + x * 6 + 1] = y * xdiv + (x + 1);
				indices[y * w * 6 + x * 6 + 2] = (y + 1) * xdiv + x;
				indices[y * w * 6 + x * 6 + 3] = y * xdiv + (x + 1);
				indices[y * w * 6 + x * 6 + 4] = (y + 1) * xdiv + (x + 1);
				indices[y * w * 6 + x * 6 + 5] = (y + 1) * xdiv + x;
			}
		}
		indexBuffer.unlock();
	}

	public static function height(x: Float, z: Float): Float {
		// return texture(heights, vec2(x, z)).r * 50.0;
		// max = xdiv / 2 * 10
		x /= xdiv * 10;
		x += 0.5;
		x *= Assets.images.height.width;
		z /= ydiv * 10;
		z += 0.5;
		z *= Assets.images.height.height;

		/*var xleft = Math.floor(x);
		var xright = Math.ceil(x);
		var ztop = Math.floor(z);
		var zbottom = Math.ceil(z);

		var topleft = Assets.images.height.at(xleft, ztop).R;
		var topright = Assets.images.height.at(xleft, ztop).R;
		var bottomleft = Assets.images.height.at(xleft, ztop).R;
		var bottomright = Assets.images.height.at(xleft, ztop).R;*/

		return Assets.images.height.at(Math.round(x), Math.round(z)).R * 50.0;
	}

	public static function render(g: Graphics, mvp: FastMatrix4, mv: FastMatrix4) {
		g.setPipeline(pipeline);
		g.setMatrix(HeightMap.mvp, mvp);
		g.setMatrix(HeightMap.mv, mv);
		g.setTexture(texUnit, Assets.images.grass);
		g.setTexture(heights, Assets.images.height);
		g.setVertexBuffer(vertexBuffer);
		g.setIndexBuffer(indexBuffer);
		g.drawIndexedVertices();
	}
}
