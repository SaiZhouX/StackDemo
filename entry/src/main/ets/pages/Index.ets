import { FloatWindow } from './FloatWindow';

@Entry
@Component
struct Index {
  // 父组件宽度
  @State containerWidth: number = 0;
  // 父组件高度
  @State containerHeight: number = 0;
  @State nZindexOne: number = 1;
  @State nZindexTwo: number = 2;
  private arr:string[] = ["1","2"];

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      // 商品信息展示组件
      this.rowItem()
    }
    .align(Alignment.Center)
    .width($r('app.string.float_window_full_size'))
    .height($r('app.string.float_window_full_size'))
    .backgroundColor($r('app.color.ohos_id_color_sub_background'))
    .onAreaChange((oldValue: Area, newValue: Area) => {
      // TODO：性能知识点：onAreaChange是高频回调，仅在父组件尺寸改变时获取新的父组件宽高，避免性能损耗
      if (oldValue.width !== newValue.width) {
        this.containerWidth = newValue.width as number;
      }
      if (oldValue.height !== newValue.height) {
        this.containerHeight = newValue.height as number;
      }
    })
  }

  @Builder
  rowItem() {
    ForEach(this.arr, (item: string) => {
      FloatWindow({
        containerWidth: this.containerWidth,
        containerHeight: this.containerHeight,
        nZindexOne: this.nZindexOne,
        nZindexTwo: this.nZindexTwo,
        nFlag: item
      })
    }, (item: string) => item)
  }
}