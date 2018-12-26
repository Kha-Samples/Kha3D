package kha3d;

import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.graphics4.Usage;
import kha.graphics4.IndexBuffer;
import kha.graphics4.VertexBuffer;
import kha3d.ogex.OgexData;

class Mesh {
	static var currentId = 0;
	public var id: Int;
	public var structure: VertexStructure;
	public var vertexBuffer: VertexBuffer;
	public var indexBuffer: IndexBuffer;

	public function new(data: OgexData) {
		id = currentId++;
		var vertices = data.geometryObjects[0].mesh.vertexArrays[0].values;
		var normals = data.geometryObjects[0].mesh.vertexArrays[1].values;
		var texcoords = data.geometryObjects[0].mesh.vertexArrays[2].values;
		var indices = data.geometryObjects[0].mesh.indexArray.values;
		
		structure = new VertexStructure();
		structure.add("pos", VertexData.Float3);
		structure.add("normal", VertexData.Float3);
		structure.add("texcoord", VertexData.Float2);

		vertexBuffer = new VertexBuffer(vertices.length, structure, Usage.StaticUsage);
		var buffer = vertexBuffer.lock();
		for (i in 0...Std.int(vertices.length / 3)) {
			buffer.set(i * 8 + 0, vertices[i * 3 + 0]);
			buffer.set(i * 8 + 1, vertices[i * 3 + 1]);
			buffer.set(i * 8 + 2, vertices[i * 3 + 2]);
			buffer.set(i * 8 + 3, normals[i * 3 + 0]);
			buffer.set(i * 8 + 4, normals[i * 3 + 1]);
			buffer.set(i * 8 + 5, normals[i * 3 + 2]);
			buffer.set(i * 8 + 6, texcoords[i * 2 + 0]);
			buffer.set(i * 8 + 7, texcoords[i * 2 + 1]);
		}
		vertexBuffer.unlock();
		
		indexBuffer = new IndexBuffer(indices.length, Usage.StaticUsage);
		var ibuffer = indexBuffer.lock();
		for (i in 0...indices.length) {
			ibuffer[i] = indices[i];
		}
		indexBuffer.unlock();
	}
}
