import { OptionChipRow } from '../components/OptionChipRow';
import { ParamSlider } from '../components/ParamSlider';
import { SceneManager } from '../services/SceneManager';
import { CULL_MODE_OPTIONS, MATERIAL_PRESETS, PAGE_BG, TEXT_DIM } from '../constants/StudioConstants';

@Component
export struct MaterialPage {
  @State presetId: string = 'steel';
  @State roughness: number = 0.25;
  @State metallic: number = 1;
  @State emissive: number = 0;
  @State cullModeId: string = 'back';
  @State glassBlend: boolean = true;

  aboutToAppear(): void {
    const state = SceneManager.getInstance().materialState;
    this.presetId = state.presetId;
    this.roughness = state.roughness;
    this.metallic = state.metallic;
    this.emissive = state.emissive;
    this.cullModeId = state.cullModeId;
    this.glassBlend = state.glassBlend;
  }

  private selectPreset(id: string): void {
    this.presetId = id;
    SceneManager.getInstance().applyMaterialPreset(id);
    const state = SceneManager.getInstance().materialState;
    this.roughness = state.roughness;
    this.metallic = state.metallic;
    this.emissive = state.emissive;
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 10 }) {
          Text('Material')
            .fontSize(15)
            .fontColor(Color.White)
          OptionChipRow({
            title: 'Preset',
            options: MATERIAL_PRESETS,
            selectedId: this.presetId,
            onSelect: (id: string) => {
              this.selectPreset(id);
            }
          })
          ParamSlider({
            label: 'Roughness',
            value: this.roughness,
            onChange: (value: number) => {
              this.roughness = value;
              SceneManager.getInstance().setRoughness(value);
            }
          })
          ParamSlider({
            label: 'Metallic',
            value: this.metallic,
            onChange: (value: number) => {
              this.metallic = value;
              SceneManager.getInstance().setMetallic(value);
            }
          })
          ParamSlider({
            label: 'Lume glow',
            value: this.emissive,
            onChange: (value: number) => {
              this.emissive = value;
              SceneManager.getInstance().setEmissive(value);
            }
          })
          OptionChipRow({
            title: 'Culling',
            options: CULL_MODE_OPTIONS,
            selectedId: this.cullModeId,
            onSelect: (id: string) => {
              this.cullModeId = id;
              SceneManager.getInstance().setCullMode(id);
            }
          })
          Row() {
            Text('Glass blend')
              .fontSize(13)
              .fontColor(TEXT_DIM)
            Blank()
            Toggle({ type: ToggleType.Switch, isOn: this.glassBlend })
              .onChange((isOn: boolean) => {
                this.glassBlend = isOn;
                SceneManager.getInstance().setGlassBlend(isOn);
              })
          }
          .width('100%')
        }
        .padding({ left: 44, right: 44, top: 28, bottom: 48 })
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .backgroundColor(PAGE_BG)
  }
}
