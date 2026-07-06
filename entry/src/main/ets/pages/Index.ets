import { Scene } from '@kit.ArkGraphics3D';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { SceneManager } from '../services/SceneManager';
import { queryHdrSupport } from '../services/DisplayService';
import { MaterialPage } from './MaterialPage';
import { LightingPage } from './LightingPage';
import { TexturePage } from './TexturePage';
import { CHIP_BG, ORBIT_DEG_PER_PX, PAGE_BG, PREVIEW_VIEWPORT } from '../constants/StudioConstants';

@Entry
@Component
struct Index {
  @Provide('pathStack') pathStack: NavPathStack = new NavPathStack();
  @State scene: Scene | null = null;
  @State hdrLabel: string = '';
  @State loadError: string = '';
  private lastX: number = 0;
  private lastY: number = 0;

  aboutToAppear(): void {
    this.hdrLabel = queryHdrSupport().label;
    if (!canIUse('SystemCapability.ArkUi.Graphics3D')) {
      this.loadError = '3D rendering is not supported on this device image. Run the sample on a Huawei Watch 5.';
      return;
    }
    SceneManager.getInstance().init().then((scene: Scene) => {
      this.scene = scene;
    }).catch((err: Error) => {
      this.loadError = `3D scene unavailable: ${err.message}`;
      hilog.error(0x3D00, 'Studio3D', 'scene init failed: %{public}s', err.message);
    });
  }

  @Builder
  pageMap(name: string) {
    if (name === 'material') {
      MaterialPage()
    } else if (name === 'lighting') {
      LightingPage()
    } else if (name === 'texture') {
      TexturePage()
    }
  }

  @Builder
  navButton(label: string, target: string) {
    Text(label)
      .fontSize(13)
      .fontColor(Color.White)
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .borderRadius(16)
      .backgroundColor(CHIP_BG)
      .onClick(() => {
        this.pathStack.pushPathByName(target, null);
      })
  }

  build() {
    Navigation(this.pathStack) {
      Column({ space: 10 }) {
        Stack({ alignContent: Alignment.Top }) {
          if (this.scene !== null) {
            Component3D({ scene: this.scene, modelType: ModelType.SURFACE })
              .renderWidth('100%')
              .renderHeight('100%')
              .width('100%')
              .height('100%')
          } else if (this.loadError !== '') {
            Text(this.loadError)
              .fontSize(12)
              .fontColor('#FF8A80')
              .textAlign(TextAlign.Center)
              .padding(24)
              .margin({ top: 40 })
          } else {
            LoadingProgress()
              .width(36)
              .height(36)
              .margin({ top: 56 })
          }
          Text(this.hdrLabel)
            .fontSize(11)
            .fontColor('#B5BFD2')
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .borderRadius(10)
            .backgroundColor('#33000000')
            .margin({ top: 8 })
        }
        .width('100%')
        .height(PREVIEW_VIEWPORT.height)
        .gesture(
          PanGesture({ fingers: 1 })
            .onActionStart((event: GestureEvent) => {
              this.lastX = event.offsetX;
              this.lastY = event.offsetY;
            })
            .onActionUpdate((event: GestureEvent) => {
              const yawDelta = (event.offsetX - this.lastX) * ORBIT_DEG_PER_PX;
              const pitchDelta = (event.offsetY - this.lastY) * ORBIT_DEG_PER_PX;
              this.lastX = event.offsetX;
              this.lastY = event.offsetY;
              SceneManager.getInstance().orbit(yawDelta, pitchDelta);
            })
        )
        Row({ space: 8 }) {
          this.navButton('Material', 'material')
          this.navButton('Light', 'lighting')
          this.navButton('Texture', 'texture')
        }
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .navDestination(this.pageMap)
    .backgroundColor(PAGE_BG)
    .width('100%')
    .height('100%')
  }
}
