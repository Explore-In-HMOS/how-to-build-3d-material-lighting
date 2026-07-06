import { CustomGeometry, PrimitiveTopology, Vec2, Vec3 } from '@kit.ArkGraphics3D';

export function buildDialDisc(radius: number, segments: number, uvScale: number): CustomGeometry {
  const geometry = new CustomGeometry();
  geometry.topology = PrimitiveTopology.TRIANGLE_LIST;
  const vertices: Vec3[] = [{ x: 0, y: 0, z: 0 }];
  const normals: Vec3[] = [{ x: 0, y: 0, z: 1 }];
  const uvs: Vec2[] = [{ x: uvScale * 0.5, y: uvScale * 0.5 }];
  const indices: number[] = [];
  for (let i = 0; i <= segments; i++) {
    const angle = (Math.PI * 2 * i) / segments;
    const cosA = Math.cos(angle);
    const sinA = Math.sin(angle);
    vertices.push({ x: cosA * radius, y: sinA * radius, z: 0 });
    normals.push({ x: 0, y: 0, z: 1 });
    uvs.push({ x: (cosA * 0.5 + 0.5) * uvScale, y: (sinA * 0.5 + 0.5) * uvScale });
  }
  for (let i = 1; i <= segments; i++) {
    indices.push(0, i, i + 1);
  }
  geometry.vertices = vertices;
  geometry.normals = normals;
  geometry.uvs = uvs;
  geometry.indices = indices;
  return geometry;
}

export function buildBezelRing(
  innerRadius: number,
  outerRadius: number,
  segments: number,
  lift: number,
  uvRepeat: number
): CustomGeometry {
  const geometry = new CustomGeometry();
  geometry.topology = PrimitiveTopology.TRIANGLE_STRIP;
  const vertices: Vec3[] = [];
  const normals: Vec3[] = [];
  const uvs: Vec2[] = [];
  for (let i = 0; i <= segments; i++) {
    const angle = (Math.PI * 2 * i) / segments;
    const cosA = Math.cos(angle);
    const sinA = Math.sin(angle);
    const u = (i / segments) * uvRepeat;
    vertices.push({ x: cosA * innerRadius, y: sinA * innerRadius, z: lift });
    vertices.push({ x: cosA * outerRadius, y: sinA * outerRadius, z: lift });
    normals.push({ x: 0, y: 0, z: 1 });
    normals.push({ x: 0, y: 0, z: 1 });
    uvs.push({ x: u, y: 0 });
    uvs.push({ x: u, y: 1 });
  }
  geometry.vertices = vertices;
  geometry.normals = normals;
  geometry.uvs = uvs;
  return geometry;
}
