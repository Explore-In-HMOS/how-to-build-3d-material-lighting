import { display } from '@kit.ArkUI';
import { hdrCapability } from '@kit.ArkGraphics2D';

export interface HdrSupport {
  supported: boolean;
  label: string;
}

export function queryHdrSupport(): HdrSupport {
  let supported = false;
  try {
    const formats: hdrCapability.HDRFormat[] = display.getDefaultDisplaySync().hdrFormats;
    supported = formats.some((format: hdrCapability.HDRFormat) => format !== hdrCapability.HDRFormat.NONE);
  } catch (err) {
    supported = false;
  }
  return { supported: supported, label: supported ? 'HDR ready' : 'SDR display' };
}
