import { OptionItem } from '../model/StudioModels';
import { ACCENT_COLOR, CHIP_BG, TEXT_DIM } from '../constants/StudioConstants';

@Component
export struct OptionChipRow {
  title: string = '';
  options: OptionItem[] = [];
  @Prop selectedId: string = '';
  onSelect: (id: string) => void = () => {};

  build() {
    Column({ space: 6 }) {
      Text(this.title)
        .fontSize(13)
        .fontColor(TEXT_DIM)
      Row({ space: 6 }) {
        ForEach(this.options, (item: OptionItem) => {
          Text(item.label)
            .fontSize(13)
            .fontColor(Color.White)
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .borderRadius(14)
            .backgroundColor(item.id === this.selectedId ? ACCENT_COLOR : CHIP_BG)
            .onClick(() => {
              this.onSelect(item.id);
            })
        }, (item: OptionItem) => item.id)
      }
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
