import { OptionChipRow } from '../components/OptionChipRow';
import { SceneManager } from '../services/SceneManager';
import {
  ADDRESS_MODE_OPTIONS, FILTER_OPTIONS, PAGE_BG, TEXT_DIM
} from '../constants/StudioConstants';

@Component
export struct TexturePage {
  @State textureEnabled: boolean = false;
  @State filterId: string = 'linear';
  @State addressModeId: string = 'repeat';

  aboutToAppear(): void {
    const state = SceneManager.getInstance().textureState;
    this.textureEnabled = state.textureEnabled;
    this.filterId = state.filterId;
    this.addressModeId = state.addressModeId;
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 10 }) {
          Text('Texture')
            .fontSize(15)
            .fontColor(Color.White)
          Row() {
            Text('Checker texture')
              .fontSize(13)
              .fontColor(TEXT_DIM)
            Blank()
            Toggle({ type: ToggleType.Switch, isOn: this.textureEnabled })
              .onChange((isOn: boolean) => {
                this.textureEnabled = isOn;
                SceneManager.getInstance().setTextureEnabled(isOn);
              })
          }
          .width('100%')
          OptionChipRow({
            title: 'Filter',
            options: FILTER_OPTIONS,
            selectedId: this.filterId,
            onSelect: (id: string) => {
              this.filterId = id;
              SceneManager.getInstance().setSamplerFilter(id);
            }
          })
          OptionChipRow({
            title: 'Wrap mode',
            options: ADDRESS_MODE_OPTIONS,
            selectedId: this.addressModeId,
            onSelect: (id: string) => {
              this.addressModeId = id;
              SceneManager.getInstance().setSamplerAddress(id);
            }
          })
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
