import {CubeGeometry, CullMode, Camera, EnvironmentBackgroundType, Geometry, Image, Light, LightType,MaterialType, MetallicRoughnessMaterial, Sampler, SamplerAddressMode, SamplerFilter, Scene,SceneResourceFactory, SphereGeometry, SpotLight, Vec4} from '@kit.ArkGraphics3D';
import { buildBezelRing, buildDialDisc } from './DialGeometry';
import { queryHdrSupport } from './DisplayService';
import { toSceneColor } from '../utils/ColorUtils';
import {
  aimAtOrigin, multiplyQuaternions, orbitPosition, quaternionAboutX, quaternionAboutY, quaternionAboutZ
} from '../utils/RotationUtils';
import { LightColorOption, LightState, MaterialState, TextureState } from '../model/StudioModels';
import { BEZEL_INNER_RADIUS, BEZEL_LIFT, BEZEL_OUTER_RADIUS, BEZEL_UV_REPEAT, CAMERA_DISTANCE, CAMERA_FOV_RAD, CAMERA_PITCH_LIMIT_DEG, DEG_TO_RAD, DIAL_RADIUS, DIAL_SEGMENTS, DIAL_UV_SCALE, DIRECTIONAL_INTENSITY, GLASS_ALPHA, GLASS_FLATTEN, GLASS_RADIUS, GLASS_SEGMENTS, GLASS_TINT, HAND_BACK_TAIL, HAND_LIFT, HDR_EMISSIVE_BOOST, HOUR_HAND_ANGLE_RAD, HOUR_HAND_SIZE, INITIAL_PITCH_DEG, INITIAL_YAW_DEG, KEY_LIGHT_PITCH_RAD, KEY_LIGHT_YAW_RAD, LIGHT_COLOR_OPTIONS, LUME_TINT, MARKER_COUNT, MARKER_LIFT, MARKER_RADIUS, MARKER_SIZE, MINUTE_HAND_ANGLE_RAD, MINUTE_HAND_SIZE, SPOT_INTENSITY_SCALE, SPOT_POSITION} from '../constants/StudioConstants';

export class SceneManager {
  private static instance: SceneManager | null = null;
  scene: Scene | null = null;
  materialState: MaterialState = {
    presetId: 'steel', roughness: 0.25, metallic: 1, emissive: 0, cullModeId: 'back', glassBlend: true
  };
  lightState: LightState = { typeId: 'directional', intensity: DIRECTIONAL_INTENSITY, colorId: 'neutral' };
  textureState: TextureState = { textureEnabled: false, filterId: 'linear', addressModeId: 'repeat' };
  private camera: Camera | null = null;
  private directionalLight: Light | null = null;
  private spotLight: SpotLight | null = null;
  private dialMaterial: MetallicRoughnessMaterial | null = null;
  private glassMaterial: MetallicRoughnessMaterial | null = null;
  private trimMaterial: MetallicRoughnessMaterial | null = null;
  private checkerImage: Image | null = null;
  private dialSampler: Sampler | null = null;
  private yawDeg: number = INITIAL_YAW_DEG;
  private pitchDeg: number = INITIAL_PITCH_DEG;
  private hdrBoost: number = 1;

  static getInstance(): SceneManager {
    if (SceneManager.instance === null) {
      SceneManager.instance = new SceneManager();
    }
    return SceneManager.instance;
  }

  async init(): Promise<Scene> {
    if (this.scene !== null) {
      return this.scene;
    }
    this.hdrBoost = queryHdrSupport().supported ? HDR_EMISSIVE_BOOST : 1;
    const scene = await Scene.load();
    this.scene = scene;
    const factory: SceneResourceFactory = scene.getResourceFactory();
    await this.setupEnvironment(scene, factory);
    await this.setupCamera(factory);
    await this.setupLights(factory);
    await this.setupMaterials(factory);
    await this.buildDialAssembly(factory);
    this.applyMaterialPreset(this.materialState.presetId);
    this.setCullMode(this.materialState.cullModeId);
    this.setGlassBlend(this.materialState.glassBlend);
    this.setLightType(this.lightState.typeId);
    this.setLightColor(this.lightState.colorId);
    this.applySampler();
    return scene;
  }

  orbit(yawDeltaDeg: number, pitchDeltaDeg: number): void {
    this.yawDeg += yawDeltaDeg;
    const nextPitch = this.pitchDeg + pitchDeltaDeg;
    this.pitchDeg = Math.min(CAMERA_PITCH_LIMIT_DEG, Math.max(-CAMERA_PITCH_LIMIT_DEG, nextPitch));
    this.updateCameraOrbit();
  }

  applyMaterialPreset(id: string): void {
    this.materialState.presetId = id;
    if (this.dialMaterial === null) {
      return;
    }
    if (id === 'ceramic') {
      this.dialMaterial.baseColor.factor = { x: 0.92, y: 0.93, z: 0.95, w: 1 };
      this.setRoughness(0.7);
      this.setMetallic(0.05);
      this.setEmissive(0);
    } else if (id === 'lume') {
      this.dialMaterial.baseColor.factor = { x: 0.05, y: 0.08, z: 0.12, w: 1 };
      this.setRoughness(0.4);
      this.setMetallic(0.2);
      this.setEmissive(0.8);
    } else {
      this.dialMaterial.baseColor.factor = { x: 0.78, y: 0.8, z: 0.85, w: 1 };
      this.setRoughness(0.25);
      this.setMetallic(1);
      this.setEmissive(0);
    }
  }

  setRoughness(value: number): void {
    this.materialState.roughness = value;
    if (this.dialMaterial === null) {
      return;
    }
    const factor: Vec4 = this.dialMaterial.material.factor;
    this.dialMaterial.material.factor = { x: factor.x, y: value, z: factor.z, w: factor.w };
  }

  setMetallic(value: number): void {
    this.materialState.metallic = value;
    if (this.dialMaterial === null) {
      return;
    }
    const factor: Vec4 = this.dialMaterial.material.factor;
    this.dialMaterial.material.factor = { x: factor.x, y: factor.y, z: value, w: factor.w };
  }

  setEmissive(level: number): void {
    this.materialState.emissive = level;
    if (this.dialMaterial === null) {
      return;
    }
    const boosted = level * this.hdrBoost;
    this.dialMaterial.emissive.factor = {
      x: LUME_TINT.x * boosted, y: LUME_TINT.y * boosted, z: LUME_TINT.z * boosted, w: 1
    };
  }

  setCullMode(id: string): void {
    this.materialState.cullModeId = id;
    if (this.dialMaterial === null) {
      return;
    }
    this.dialMaterial.cullMode = this.cullModeFromId(id);
  }

  setGlassBlend(enabled: boolean): void {
    this.materialState.glassBlend = enabled;
    if (this.glassMaterial === null) {
      return;
    }
    this.glassMaterial.blend = { enabled: enabled };
    const alpha = enabled ? GLASS_ALPHA : 1;
    this.glassMaterial.baseColor.factor = { x: GLASS_TINT.x, y: GLASS_TINT.y, z: GLASS_TINT.z, w: alpha };
  }

  setLightType(id: string): void {
    this.lightState.typeId = id;
    if (this.directionalLight !== null) {
      this.directionalLight.enabled = id === 'directional';
    }
    if (this.spotLight !== null) {
      this.spotLight.enabled = id === 'spot';
    }
  }

  setLightIntensity(value: number): void {
    this.lightState.intensity = value;
    if (this.directionalLight !== null) {
      this.directionalLight.intensity = value;
    }
    if (this.spotLight !== null) {
      this.spotLight.intensity = value * SPOT_INTENSITY_SCALE;
    }
  }

  setLightColor(id: string): void {
    this.lightState.colorId = id;
    const option = LIGHT_COLOR_OPTIONS.find((item: LightColorOption) => item.id === id);
    if (option === undefined) {
      return;
    }
    const sceneColor = toSceneColor(option.colorValue);
    if (this.directionalLight !== null) {
      this.directionalLight.color = sceneColor;
    }
    if (this.spotLight !== null) {
      this.spotLight.color = sceneColor;
    }
  }

  setTextureEnabled(enabled: boolean): void {
    this.textureState.textureEnabled = enabled;
    if (this.dialMaterial === null) {
      return;
    }
    this.dialMaterial.baseColor.image = enabled ? this.checkerImage : null;
  }

  setSamplerFilter(id: string): void {
    this.textureState.filterId = id;
    this.applySampler();
  }

  setSamplerAddress(id: string): void {
    this.textureState.addressModeId = id;
    this.applySampler();
  }

  private applySampler(): void {
    const sampler = this.dialSampler;
    if (sampler === null || this.dialMaterial === null) {
      return;
    }
    const filter = this.filterFromId(this.textureState.filterId);
    const address = this.addressModeFromId(this.textureState.addressModeId);
    sampler.magFilter = filter;
    sampler.minFilter = filter;
    sampler.mipMapMode = filter;
    sampler.addressModeU = address;
    sampler.addressModeV = address;
    this.dialMaterial.baseColor.sampler = sampler;
  }

  private updateCameraOrbit(): void {
    if (this.camera === null) {
      return;
    }
    const yawRad = this.yawDeg * DEG_TO_RAD;
    const pitchRad = this.pitchDeg * DEG_TO_RAD;
    this.camera.position = orbitPosition(CAMERA_DISTANCE, yawRad, pitchRad);
    this.camera.rotation = aimAtOrigin(this.camera.position);
  }

  private async setupEnvironment(scene: Scene, factory: SceneResourceFactory): Promise<void> {
    const environment = await factory.createEnvironment({ name: 'studioEnv' });
    environment.backgroundType = EnvironmentBackgroundType.BACKGROUND_NONE;
    environment.indirectDiffuseFactor = { x: 0.35, y: 0.35, z: 0.4, w: 1 };
    environment.indirectSpecularFactor = { x: 0.45, y: 0.45, z: 0.5, w: 1 };
    scene.environment = environment;
  }

  private async setupCamera(factory: SceneResourceFactory): Promise<void> {
    const camera = await factory.createCamera({ name: 'orbitCamera' });
    camera.enabled = true;
    camera.fov = CAMERA_FOV_RAD;
    camera.clearColor = { r: 0.02, g: 0.02, b: 0.05, a: 1 };
    this.camera = camera;
    this.updateCameraOrbit();
  }

  private async setupLights(factory: SceneResourceFactory): Promise<void> {
    const keyLight = await factory.createLight({ name: 'keyLight' }, LightType.DIRECTIONAL);
    keyLight.intensity = this.lightState.intensity;
    keyLight.rotation = multiplyQuaternions(
      quaternionAboutY(KEY_LIGHT_YAW_RAD), quaternionAboutX(KEY_LIGHT_PITCH_RAD)
    );
    this.directionalLight = keyLight;
    const spotCandidate = await factory.createLight({ name: 'dialSpot' }, LightType.SPOT);
    if (spotCandidate.lightType === LightType.SPOT) {
      const spot = spotCandidate as SpotLight;
      spot.position = SPOT_POSITION;
      spot.rotation = aimAtOrigin(SPOT_POSITION);
      spot.intensity = this.lightState.intensity * SPOT_INTENSITY_SCALE;
      spot.enabled = false;
      this.spotLight = spot;
    }
  }

  private async setupMaterials(factory: SceneResourceFactory): Promise<void> {
    this.dialMaterial = await this.createPbrMaterial(factory, 'dialMaterial');
    this.glassMaterial = await this.createPbrMaterial(factory, 'glassMaterial');
    this.trimMaterial = await this.createPbrMaterial(factory, 'trimMaterial');
    this.trimMaterial.baseColor.factor = { x: 0.85, y: 0.7, z: 0.35, w: 1 };
    this.trimMaterial.material.factor = { x: 0, y: 0.3, z: 1, w: 0.5 };
    this.glassMaterial.material.factor = { x: 0, y: 0.05, z: 0, w: 0.9 };
    this.glassMaterial.cullMode = CullMode.BACK;
    this.checkerImage = await factory.createImage({
      name: 'checker', uri: $rawfile('textures/checker.png')
    });
    this.dialSampler = await factory.createSampler({ name: 'dialSampler' });
  }

  private async createPbrMaterial(
    factory: SceneResourceFactory, name: string
  ): Promise<MetallicRoughnessMaterial> {
    const material = await factory.createMaterial({ name: name }, MaterialType.METALLIC_ROUGHNESS);
    if (material.materialType !== MaterialType.METALLIC_ROUGHNESS) {
      throw new Error(`Unexpected material type for ${name}`);
    }
    return material as MetallicRoughnessMaterial;
  }

  private async buildDialAssembly(factory: SceneResourceFactory): Promise<void> {
    const dialMaterial = this.dialMaterial;
    const trimMaterial = this.trimMaterial;
    const glassMaterial = this.glassMaterial;
    if (dialMaterial === null || trimMaterial === null || glassMaterial === null) {
      return;
    }
    const discGeometry = buildDialDisc(DIAL_RADIUS, DIAL_SEGMENTS, DIAL_UV_SCALE);
    const dialMesh = await factory.createMesh({ name: 'dialMesh' }, discGeometry);
    const dial = await factory.createGeometry({ name: 'dial' }, dialMesh);
    dial.mesh.materialOverride = dialMaterial;
    const ringGeometry = buildBezelRing(
      BEZEL_INNER_RADIUS, BEZEL_OUTER_RADIUS, DIAL_SEGMENTS, BEZEL_LIFT, BEZEL_UV_REPEAT
    );
    const bezelMesh = await factory.createMesh({ name: 'bezelMesh' }, ringGeometry);
    const bezel = await factory.createGeometry({ name: 'bezel' }, bezelMesh);
    bezel.mesh.materialOverride = trimMaterial;
    const markerGeometry = new CubeGeometry();
    markerGeometry.size = MARKER_SIZE;
    const markerMesh = await factory.createMesh({ name: 'markerMesh' }, markerGeometry);
    for (let i = 0; i < MARKER_COUNT; i++) {
      const angle = (Math.PI * 2 * i) / MARKER_COUNT;
      const marker = await factory.createGeometry({ name: `marker${i}` }, markerMesh);
      marker.position = {
        x: Math.sin(angle) * MARKER_RADIUS, y: Math.cos(angle) * MARKER_RADIUS, z: MARKER_LIFT
      };
      marker.rotation = quaternionAboutZ(-angle);
      marker.mesh.materialOverride = trimMaterial;
    }
    const hourGeometry = new CubeGeometry();
    hourGeometry.size = HOUR_HAND_SIZE;
    const hourMesh = await factory.createMesh({ name: 'hourMesh' }, hourGeometry);
    const hourHand = await factory.createGeometry({ name: 'hourHand' }, hourMesh);
    this.placeHand(hourHand, HOUR_HAND_ANGLE_RAD, HOUR_HAND_SIZE.y);
    hourHand.mesh.materialOverride = trimMaterial;
    const minuteGeometry = new CubeGeometry();
    minuteGeometry.size = MINUTE_HAND_SIZE;
    const minuteMesh = await factory.createMesh({ name: 'minuteMesh' }, minuteGeometry);
    const minuteHand = await factory.createGeometry({ name: 'minuteHand' }, minuteMesh);
    this.placeHand(minuteHand, MINUTE_HAND_ANGLE_RAD, MINUTE_HAND_SIZE.y);
    minuteHand.mesh.materialOverride = trimMaterial;
    const domeGeometry = new SphereGeometry();
    domeGeometry.radius = GLASS_RADIUS;
    domeGeometry.segmentCount = GLASS_SEGMENTS;
    const domeMesh = await factory.createMesh({ name: 'glassMesh' }, domeGeometry);
    const dome = await factory.createGeometry({ name: 'glassDome' }, domeMesh);
    dome.scale = { x: 1, y: 1, z: GLASS_FLATTEN };
    dome.mesh.materialOverride = glassMaterial;
  }

  private placeHand(hand: Geometry, angleRad: number, length: number): void {
    const offset = length * 0.5 - HAND_BACK_TAIL;
    hand.position = { x: Math.sin(angleRad) * offset, y: Math.cos(angleRad) * offset, z: HAND_LIFT };
    hand.rotation = quaternionAboutZ(-angleRad);
  }

  private cullModeFromId(id: string): CullMode {
    if (id === 'none') {
      return CullMode.NONE;
    }
    if (id === 'front') {
      return CullMode.FRONT;
    }
    return CullMode.BACK;
  }

  private filterFromId(id: string): SamplerFilter {
    return id === 'nearest' ? SamplerFilter.NEAREST : SamplerFilter.LINEAR;
  }

  private addressModeFromId(id: string): SamplerAddressMode {
    if (id === 'mirror') {
      return SamplerAddressMode.MIRRORED_REPEAT;
    }
    if (id === 'clamp') {
      return SamplerAddressMode.CLAMP_TO_EDGE;
    }
    return SamplerAddressMode.REPEAT;
  }
}
