import { OptionChipRow } from '../components/OptionChipRow';
import { ParamSlider } from '../components/ParamSlider';
import { SceneManager } from '../services/SceneManager';
import { LightColorOption } from '../model/StudioModels';
import {
  LIGHT_COLOR_OPTIONS, LIGHT_TYPE_OPTIONS, PAGE_BG, TEXT_DIM
} from '../constants/StudioConstants';

@Component
export struct LightingPage {
  @State typeId: string = 'directional';
  @State intensity: number = 3;
  @State colorId: string = 'neutral';

  aboutToAppear(): void {
    const state = SceneManager.getInstance().lightState;
    this.typeId = state.typeId;
    this.intensity = state.intensity;
    this.colorId = state.colorId;
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 10 }) {
          Text('Lighting')
            .fontSize(15)
            .fontColor(Color.White)
          OptionChipRow({
            title: 'Light type',
            options: LIGHT_TYPE_OPTIONS,
            selectedId: this.typeId,
            onSelect: (id: string) => {
              this.typeId = id;
              SceneManager.getInstance().setLightType(id);
            }
          })
          ParamSlider({
            label: 'Intensity',
            min: 0,
            max: 10,
            step: 0.1,
            value: this.intensity,
            onChange: (value: number) => {
              this.intensity = value;
              SceneManager.getInstance().setLightIntensity(value);
            }
          })
          Text('Light color')
            .fontSize(13)
            .fontColor(TEXT_DIM)
          Row({ space: 12 }) {
            ForEach(LIGHT_COLOR_OPTIONS, (item: LightColorOption) => {
              Column() {
              }
              .width(26)
              .height(26)
              .borderRadius(13)
              .backgroundColor(item.colorValue)
              .border({ width: item.id === this.colorId ? 2 : 0, color: Color.White })
              .onClick(() => {
                this.colorId = item.id;
                SceneManager.getInstance().setLightColor(item.id);
              })
            }, (item: LightColorOption) => item.id)
          }
          .justifyContent(FlexAlign.Center)
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
