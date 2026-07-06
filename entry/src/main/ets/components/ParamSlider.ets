import { TEXT_DIM } from '../constants/StudioConstants';

@Component
export struct ParamSlider {
  label: string = '';
  min: number = 0;
  max: number = 1;
  step: number = 0.01;
  @Prop value: number = 0;
  onChange: (value: number) => void = () => {};

  build() {
    Column({ space: 2 }) {
      Row() {
        Text(this.label)
          .fontSize(13)
          .fontColor(TEXT_DIM)
        Blank()
        Text(this.value.toFixed(2))
          .fontSize(13)
          .fontColor(Color.White)
      }
      .width('100%')
      Slider({ value: this.value, min: this.min, max: this.max, step: this.step, style: SliderStyle.InSet })
        .width('100%')
        .onChange((value: number) => {
          this.value = value;
          this.onChange(value);
        })
    }
    .width('100%')
  }
}
