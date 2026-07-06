import { common2D, drawing } from '@kit.ArkGraphics2D';
import { Color } from '@kit.ArkGraphics3D';

const CHANNEL_MAX: number = 255;

export function toSceneColor(resourceColor: ResourceColor): Color {
  const argb: common2D.Color = drawing.Tool.makeColorFromResourceColor(resourceColor);
  return {
    r: argb.red / CHANNEL_MAX,
    g: argb.green / CHANNEL_MAX,
    b: argb.blue / CHANNEL_MAX,
    a: argb.alpha / CHANNEL_MAX
  };
}
