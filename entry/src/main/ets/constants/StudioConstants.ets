import { Rect, Vec3, Vec4 } from '@kit.ArkGraphics3D';
import { LightColorOption, OptionItem } from '../model/StudioModels';

export const PREVIEW_VIEWPORT: Rect = { x: 0, y: 0, width: 233, height: 150 };
export const ORBIT_DEG_PER_PX: number = 180 / PREVIEW_VIEWPORT.width;
export const DEG_TO_RAD: number = Math.PI / 180;
export const CAMERA_DISTANCE: number = 3.4;
export const CAMERA_FOV_RAD: number = Math.PI / 3;
export const CAMERA_PITCH_LIMIT_DEG: number = 80;
export const INITIAL_YAW_DEG: number = 0;
export const INITIAL_PITCH_DEG: number = -18;
export const DIAL_RADIUS: number = 1;
export const DIAL_SEGMENTS: number = 72;
export const DIAL_UV_SCALE: number = 3;
export const BEZEL_INNER_RADIUS: number = 0.98;
export const BEZEL_OUTER_RADIUS: number = 1.14;
export const BEZEL_LIFT: number = 0.03;
export const BEZEL_UV_REPEAT: number = 8;
export const MARKER_COUNT: number = 12;
export const MARKER_RADIUS: number = 0.8;
export const MARKER_LIFT: number = 0.04;
export const MARKER_SIZE: Vec3 = { x: 0.06, y: 0.18, z: 0.05 };
export const HOUR_HAND_SIZE: Vec3 = { x: 0.07, y: 0.46, z: 0.04 };
export const MINUTE_HAND_SIZE: Vec3 = { x: 0.05, y: 0.66, z: 0.04 };
export const HAND_LIFT: number = 0.09;
export const HAND_BACK_TAIL: number = 0.06;
export const HOUR_HAND_ANGLE_RAD: number = 5.306;
export const MINUTE_HAND_ANGLE_RAD: number = 0.838;
export const GLASS_RADIUS: number = 1.08;
export const GLASS_SEGMENTS: number = 48;
export const GLASS_FLATTEN: number = 0.42;
export const GLASS_ALPHA: number = 0.22;
export const GLASS_TINT: Vec4 = { x: 0.75, y: 0.85, z: 0.95, w: 0.22 };
export const HDR_EMISSIVE_BOOST: number = 1.6;
export const LUME_TINT: Vec3 = { x: 0.35, y: 0.85, z: 0.6 };
export const DIRECTIONAL_INTENSITY: number = 3;
export const SPOT_INTENSITY_SCALE: number = 25;
export const SPOT_POSITION: Vec3 = { x: 0.9, y: 0.9, z: 2.3 };
export const KEY_LIGHT_YAW_RAD: number = 0.5;
export const KEY_LIGHT_PITCH_RAD: number = -0.7;
export const PAGE_BG: string = '#0E1118';
export const CHIP_BG: string = '#1E2430';
export const ACCENT_COLOR: string = '#5B8CFF';
export const TEXT_DIM: string = '#8E97A8';
export const MATERIAL_PRESETS: OptionItem[] = [
  { id: 'steel', label: 'Steel' },
  { id: 'ceramic', label: 'Ceramic' },
  { id: 'lume', label: 'Lume' }
];
export const CULL_MODE_OPTIONS: OptionItem[] = [
  { id: 'back', label: 'Back' },
  { id: 'front', label: 'Front' },
  { id: 'none', label: 'None' }
];
export const LIGHT_TYPE_OPTIONS: OptionItem[] = [
  { id: 'directional', label: 'Directional' },
  { id: 'spot', label: 'Spot' }
];
export const LIGHT_COLOR_OPTIONS: LightColorOption[] = [
  { id: 'neutral', label: 'Neutral', colorValue: '#FFFFFF' },
  { id: 'warm', label: 'Warm', colorValue: '#FFD9A0' },
  { id: 'cool', label: 'Cool', colorValue: '#A8C8FF' },
  { id: 'rose', label: 'Rose', colorValue: '#FFB3C0' }
];
export const FILTER_OPTIONS: OptionItem[] = [
  { id: 'linear', label: 'Linear' },
  { id: 'nearest', label: 'Nearest' }
];
export const ADDRESS_MODE_OPTIONS: OptionItem[] = [
  { id: 'repeat', label: 'Repeat' },
  { id: 'mirror', label: 'Mirror' },
  { id: 'clamp', label: 'Clamp' }
];
