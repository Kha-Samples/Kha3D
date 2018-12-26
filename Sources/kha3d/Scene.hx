package kha3d;

import kha.math.Vector3;
import kha.Canvas;
import kha.System;
import kha.Image;
import kha.math.FastMatrix4;
import kha.graphics4.Graphics;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.TextureUnit;
import kha.graphics4.ConstantLocation;
import kha.graphics4.CompareMode;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.graphics4.PipelineState;
import kha.math.FastVector3;
import kha.Shaders;

class Scene {
	public static var heightMap: HeightMap = null;
	public static var meshes: Array<MeshObject> = [];
	public static var splines: Array<SplineMesh> = [];
	public static var lights: Array<FastVector3> = [];

	public static var instancedStructure: VertexStructure;
	static var instancedVertexBuffer: VertexBuffer;
	static var pipeline: PipelineState;
	static var mvp: ConstantLocation;
	static var texUnit: TextureUnit;

	static var colors: Image;
	static var depth: Image;
	static var normals: Image;
	static var image: Image;

	public static function init() {
		Lights.init();

		instancedStructure = new VertexStructure();
		instancedStructure.add("meshpos", VertexData.Float3);

		instancedVertexBuffer = new VertexBuffer(meshes.length, instancedStructure, Usage.DynamicUsage, 1);

		pipeline = new PipelineState();
		pipeline.inputLayout = [meshes[0].mesh.structure, instancedStructure];
		pipeline.vertexShader = Shaders.mesh_vert;
		pipeline.fragmentShader = Shaders.mesh_frag;
		pipeline.depthWrite = true;
		pipeline.depthMode = CompareMode.Less;
		pipeline.cullMode = Clockwise;
		pipeline.compile();
		
		mvp = pipeline.getConstantLocation("mvp");
		texUnit = pipeline.getTextureUnit("image");

		colors = depth = Image.createRenderTarget(System.windowWidth(), System.windowHeight(), RGBA32, Depth32Stencil8);
		normals = Image.createRenderTarget(System.windowWidth(), System.windowHeight(), RGBA32, NoDepthAndStencil);
		image = Image.createRenderTarget(System.windowWidth(), System.windowHeight(), RGBA32, NoDepthAndStencil);

		TextureViewer.init();

		Shadows.init();
	}

	static function setBuffers(g: Graphics): Void {
		g.setIndexBuffer(meshes[0].mesh.indexBuffer);
		g.setVertexBuffers([meshes[0].mesh.vertexBuffer, instancedVertexBuffer]);
	}

	static function draw(g: Graphics, instanceCount: Int): Void {
		g.drawIndexedVerticesInstanced(instanceCount, 0, meshes[0].mesh.indexBuffer.count());
	}

	public static function renderMeshes(g: Graphics, mvp: FastMatrix4, mv: FastMatrix4, vp: FastMatrix4, image: Image): Void {
		g.setPipeline(pipeline);
		g.setMatrix(Scene.mvp, mvp);
		g.setTexture(texUnit, image);

		var planes = Culling.perspectiveToPlanes(vp);

		var instanceIndex = 0;
		var b2 = instancedVertexBuffer.lock();
		var lastMesh: Mesh = null;
		for (mesh in meshes) {
			if (Culling.aabbInFrustum(planes, mesh.pos, mesh.pos)) {
				if (lastMesh != null && mesh.mesh != lastMesh) {
					setBuffers(g);
					draw(g, instanceIndex);
					instanceIndex = 0;
				}
				b2.set(instanceIndex * 3 + 0, mesh.pos.x);
				b2.set(instanceIndex * 3 + 1, mesh.pos.y);
				b2.set(instanceIndex * 3 + 2, mesh.pos.z);
				++instanceIndex;
			}
		}
		instancedVertexBuffer.unlock();

		if (instanceIndex > 0) {
			setBuffers(g);
			draw(g, instanceIndex);
		}
	}

	public static function renderGBuffer(mvp: FastMatrix4, mv: FastMatrix4, vp: FastMatrix4, meshImage: Image, splineImage: Image, heightsImage: Image) {
		var g = colors.g4;
		g.begin([normals]);
		g.clear(0xff00ffff, Math.POSITIVE_INFINITY);
		if (heightMap != null) {
			heightMap.render(g, mvp, mv);
		}
		for (spline in splines) {
			spline.render(g, mvp, mv, splineImage, heightsImage);
		}
		renderMeshes(g, mvp, mv, vp, meshImage);
		g.end();
	}

	public static function renderImage(suneye: FastVector3, sunat: FastVector3, mvp: FastMatrix4, inv: FastMatrix4, sunMvp: FastMatrix4) {
		var g = image.g4;
		g.begin();
		g.clear(0);
		var sunDir = suneye.sub(sunat);
		sunDir.normalize();
		Lights.render(g, colors, normals, depth, Shadows.shadowMap, inv, sunMvp, mvp, sunDir);
		g.end();
	}

	public static function render(frame: Canvas, position: Vector3, direction: Vector3) {
		meshes.sort(function (a, b) {
			return a.mesh.id - b.mesh.id;
		});

		var model = FastMatrix4.identity(); // FastMatrix4.rotationY(Scheduler.time());
		var view = FastMatrix4.lookAt(position.fast(), position.add(direction).fast(), new FastVector3(0, 1, 0));
		var projection = FastMatrix4.perspectiveProjection(45, System.windowWidth(0) / System.windowHeight(0), 0.1, 550.0);

		var suneye = new FastVector3(position.x + 50.0, 150.0, position.z - 100.0);
		var sunat = new FastVector3(position.x, 0, position.z);
		var sunview = FastMatrix4.lookAt(suneye, sunat, new FastVector3(0, 0, 1));
		var sunprojection = FastMatrix4.orthogonalProjection(-100, 100, -100, 100, 1.0, 300.0);

		var mv = view.multmat(model);
		var mvp = projection.multmat(view).multmat(model);
		var inv = mvp.inverse();

		var sunMvp = sunprojection.multmat(sunview).multmat(model);

		Shadows.render(sunMvp);

		Scene.renderGBuffer(mvp, mv, projection.multmat(view), meshes[0].texture, splines[0].texture, heightMap.heightsImage);
		
		Scene.renderImage(suneye, sunat, mvp, inv, sunMvp);

		var g = frame.g4;
		g.begin();
		TextureViewer.render(g, colors, false, -1, -1, 1, 1);
		TextureViewer.render(g, depth, true, -1, 0, 1, 1);
		//TextureViewer.render(g, shadowMap, true, 0, 0, 1, 1);
		TextureViewer.render(g, normals, false, 0, -1, 1, 1);
		TextureViewer.render(g, image, false, 0, 0, 1, 1);
		g.end();
	}
}
