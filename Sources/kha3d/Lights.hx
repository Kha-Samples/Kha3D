package kha3d;

import kha.math.FastVector3;
import kha.graphics4.ConstantLocation;
import kha.graphics4.Graphics;
import kha.graphics4.IndexBuffer;
import kha.graphics4.PipelineState;
import kha.graphics4.TextureUnit;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexStructure;
import kha.math.FastMatrix4;
import kha.Image;
import kha.Shaders;

class Lights {
	static var pipeline: PipelineState;
	static var vertexBuffer: VertexBuffer;
	static var indexBuffer: IndexBuffer;
	static var albedo: TextureUnit;
	static var normals: TextureUnit;
	static var depth: TextureUnit;
	static var shadowMap: TextureUnit;
	static var inverse: ConstantLocation;
	static var sunMVP: ConstantLocation;
	static var sunLightDir: ConstantLocation;

	static var pointPipeline: PipelineState;
	static var pointVertexBuffer: VertexBuffer;
	static var pointVertexBuffer2: VertexBuffer;
	static var pointIndexBuffer: IndexBuffer;
	static var pointAlbedo: TextureUnit;
	static var pointNormals: TextureUnit;
	static var pointDepth: TextureUnit;
	static var pointHeights: TextureUnit;
	static var pointInverse: ConstantLocation;
	static var pointMvp: ConstantLocation;

	public static function init() {
		{
			var structure = new VertexStructure();
			structure.add("pos", Float2);

			pipeline = new PipelineState();
			pipeline.inputLayout = [structure];
			pipeline.vertexShader = Shaders.light_vert;
			pipeline.fragmentShader = Shaders.parallel_light_frag;
			pipeline.compile();

			vertexBuffer = new VertexBuffer(4, structure, StaticUsage);
			var vertices = vertexBuffer.lock();
			vertices.set(0, -1); vertices.set(1, -1);
			vertices.set(2, 1); vertices.set(3, -1);
			vertices.set(4, -1); vertices.set(5, 1);
			vertices.set(6, 1); vertices.set(7, 1);
			vertexBuffer.unlock();

			indexBuffer = new IndexBuffer(6, StaticUsage);
			var indices = indexBuffer.lock();
			indices.set(0, 0); indices.set(1, 1); indices.set(2, 2);
			indices.set(3, 1); indices.set(4, 3); indices.set(5, 2);
			indexBuffer.unlock();

			albedo = pipeline.getTextureUnit("albedo");
			normals = pipeline.getTextureUnit("normals");
			depth = pipeline.getTextureUnit("depth");
			shadowMap = pipeline.getTextureUnit("shadowMap");
			inverse = pipeline.getConstantLocation("inv");
			sunMVP  = pipeline.getConstantLocation("sunMVP");
			sunLightDir = pipeline.getConstantLocation("sunLightDir");
		}

		{
			var structure = new VertexStructure();
			structure.add("pos", Float3);

			var structure2 = new VertexStructure();
			structure2.add("meshpos", Float3);

			pointPipeline = new PipelineState();
			pointPipeline.inputLayout = [structure, structure2];
			pointPipeline.vertexShader = Shaders.point_light_vert;
			pointPipeline.fragmentShader = Shaders.point_light_frag;
			pointPipeline.cullMode = Clockwise;
			pointPipeline.blendSource = BlendOne;
			pointPipeline.blendDestination = BlendOne;
			pointPipeline.compile();

			pointVertexBuffer = new VertexBuffer(8, structure, StaticUsage);
			var vertices = pointVertexBuffer.lock();
			var index = 0;
			var scale = 40.0;
			vertices.set(index++, -scale); vertices.set(index++, scale); vertices.set(index++, -scale);
			vertices.set(index++, scale); vertices.set(index++, scale); vertices.set(index++, -scale);
			vertices.set(index++, scale); vertices.set(index++, -scale); vertices.set(index++, -scale);
			vertices.set(index++, -scale); vertices.set(index++, -scale); vertices.set(index++, -scale);
			vertices.set(index++, -scale); vertices.set(index++, scale); vertices.set(index++, scale);
			vertices.set(index++, scale); vertices.set(index++, scale); vertices.set(index++, scale);
			vertices.set(index++, scale); vertices.set(index++, -scale); vertices.set(index++, scale);
			vertices.set(index++, -scale); vertices.set(index++, -scale); vertices.set(index++, scale);
			pointVertexBuffer.unlock();

			pointVertexBuffer2 = new VertexBuffer(Scene.lights.length, structure2, StaticUsage, 1);
			var b2 = pointVertexBuffer2.lock();
			index = 0;
			for (light in Scene.lights) {
				b2.set(index++, light.x);
				b2.set(index++, light.y);
				b2.set(index++, light.z);
			}
			pointVertexBuffer2.unlock();

			pointIndexBuffer = new IndexBuffer(6 * 6, StaticUsage);
			var indices = pointIndexBuffer.lock();
			index = 0;
			indices.set(index++, 0); indices.set(index++, 1); indices.set(index++, 3);
			indices.set(index++, 1); indices.set(index++, 2); indices.set(index++, 3);

			indices.set(index++, 1); indices.set(index++, 5); indices.set(index++, 2);
			indices.set(index++, 5); indices.set(index++, 6); indices.set(index++, 2);

			indices.set(index++, 4); indices.set(index++, 0); indices.set(index++, 7);
			indices.set(index++, 0); indices.set(index++, 3); indices.set(index++, 7);

			indices.set(index++, 5); indices.set(index++, 4); indices.set(index++, 6);
			indices.set(index++, 4); indices.set(index++, 7); indices.set(index++, 6);

			indices.set(index++, 4); indices.set(index++, 5); indices.set(index++, 0);
			indices.set(index++, 5); indices.set(index++, 1); indices.set(index++, 0);

			indices.set(index++, 3); indices.set(index++, 2); indices.set(index++, 7);
			indices.set(index++, 2); indices.set(index++, 6); indices.set(index++, 7);
			pointIndexBuffer.unlock();

			pointAlbedo = pointPipeline.getTextureUnit("albedo");
			pointNormals = pointPipeline.getTextureUnit("normals");
			pointDepth = pointPipeline.getTextureUnit("depth");
			pointHeights = pointPipeline.getTextureUnit("heights");
			pointInverse = pointPipeline.getConstantLocation("inv");
			pointMvp = pointPipeline.getConstantLocation("mvp");
		}
	}

	public static function render(g: Graphics, albedoImage: Image, normalsImage: Image, depthImage: Image, shadowMapImage: Image, inverseMatrix: FastMatrix4, sunMVPMatrix: FastMatrix4, mvp: FastMatrix4, sunLightDirVec: FastVector3) {
		g.setPipeline(pipeline);
		g.setVertexBuffer(vertexBuffer);
		g.setIndexBuffer(indexBuffer);
		g.setTexture(albedo, albedoImage);
		g.setTexture(normals, normalsImage);
		g.setTextureDepth(depth, depthImage);
		g.setTextureDepth(shadowMap, shadowMapImage);
		g.setMatrix(inverse, inverseMatrix);
		g.setMatrix(sunMVP, sunMVPMatrix);
		g.setVector3(sunLightDir, sunLightDirVec);
		g.drawIndexedVertices();

		g.setPipeline(pointPipeline);
		g.setTexture(pointAlbedo, albedoImage);
		g.setTexture(pointNormals, normalsImage);
		g.setTextureDepth(pointDepth, depthImage);
		g.setMatrix(pointInverse, inverseMatrix);
		g.setMatrix(pointMvp, mvp);
		g.setTexture(pointHeights, kha.Assets.images.height);
		g.setIndexBuffer(pointIndexBuffer);
		g.setVertexBuffers([pointVertexBuffer, pointVertexBuffer2]);
		g.drawIndexedVerticesInstanced(Scene.lights.length, 0, pointIndexBuffer.count());
	}
}
