import { Position3, Quaternion } from '@kit.ArkGraphics3D';

export function quaternionAboutX(angleRad: number): Quaternion {
  const half = angleRad * 0.5;
  return { x: Math.sin(half), y: 0, z: 0, w: Math.cos(half) };
}

export function quaternionAboutY(angleRad: number): Quaternion {
  const half = angleRad * 0.5;
  return { x: 0, y: Math.sin(half), z: 0, w: Math.cos(half) };
}

export function quaternionAboutZ(angleRad: number): Quaternion {
  const half = angleRad * 0.5;
  return { x: 0, y: 0, z: Math.sin(half), w: Math.cos(half) };
}

export function multiplyQuaternions(a: Quaternion, b: Quaternion): Quaternion {
  return {
    x: a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,
    y: a.w * b.y - a.x * b.z + a.y * b.w + a.z * b.x,
    z: a.w * b.z + a.x * b.y - a.y * b.x + a.z * b.w,
    w: a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z
  };
}

export function orbitPosition(distance: number, yawRad: number, pitchRad: number): Position3 {
  const cosPitch = Math.cos(pitchRad);
  return {
    x: distance * cosPitch * Math.sin(yawRad),
    y: -distance * Math.sin(pitchRad),
    z: distance * cosPitch * Math.cos(yawRad)
  };
}

export function aimAtOrigin(position: Position3): Quaternion {
  const length = Math.sqrt(position.x * position.x + position.y * position.y + position.z * position.z);
  if (length === 0) {
    return { x: 0, y: 0, z: 0, w: 1 };
  }
  const dirX = -position.x / length;
  const dirY = -position.y / length;
  const dirZ = -position.z / length;
  const pitch = Math.asin(dirY);
  const yaw = Math.atan2(-dirX, -dirZ);
  return multiplyQuaternions(quaternionAboutY(yaw), quaternionAboutX(pitch));
}
