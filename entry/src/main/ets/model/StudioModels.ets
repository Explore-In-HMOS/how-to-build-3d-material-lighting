export interface OptionItem {
  id: string;
  label: string;
}

export interface LightColorOption {
  id: string;
  label: string;
  colorValue: ResourceColor;
}

export interface MaterialState {
  presetId: string;
  roughness: number;
  metallic: number;
  emissive: number;
  cullModeId: string;
  glassBlend: boolean;
}

export interface LightState {
  typeId: string;
  intensity: number;
  colorId: string;
}

export interface TextureState {
  textureEnabled: boolean;
  filterId: string;
  addressModeId: string;
}
