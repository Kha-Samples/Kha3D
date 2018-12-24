package kha3d;

import kha.math.FastMatrix4;
import kha.graphics4.ConstantLocation;
import kha.graphics4.DepthStencilFormat;
import kha.graphics4.TextureFormat;
import kha.graphics4.PipelineState;
import kha.Image;
import kha.Shaders;

class Shadows {
	static var shadowForestPipeline: PipelineState;
	public static var shadowMap: Image;
	static var mvpLocation: ConstantLocation;
	//static var heights: TextureUnit;

	public static function init() {
		shadowMap = Image.createRenderTarget(4096, 4096, TextureFormat.L8, DepthStencilFormat.Depth32Stencil8);
		shadowForestPipeline = new PipelineState();
		shadowForestPipeline.inputLayout = [Scene.meshes[0].mesh.structure, Scene.instancedStructure];
		shadowForestPipeline.vertexShader = Shaders.shadow_mesh_vert;
		shadowForestPipeline.fragmentShader = Shaders.shadowmap_frag;
		shadowForestPipeline.depthWrite = true;
		shadowForestPipeline.depthMode = Less;
		shadowForestPipeline.compile();

		mvpLocation = shadowForestPipeline.getConstantLocation("mvp");
		//heights = shadowForestPipeline.getTextureUnit("heights");
	}

	public static function render(sunMvp: FastMatrix4) {
		var g = shadowMap.g4;
		g.begin();
		g.clear(0xff00ffff, Math.POSITIVE_INFINITY);
		g.setPipeline(shadowForestPipeline);
		g.setMatrix(mvpLocation, sunMvp);
		//g.setTexture(heights, Assets.images.height);
		//**Forest.setBuffers(g);
		//**Forest.draw(g);
		g.end();
	}
}
