import { Constants } from '../common/Constants';
import { curves } from '@kit.ArkUI';

@Reusable
@Component
export struct FloatWindow {
  @Link nZindexOne: number;
  @Link nZindexTwo: number;
  // 悬浮窗相对于父组件四条边的距离，top和bottom同时设置时top生效，right和left同时设置时left生效
  @State edge: Edges = { top: Constants.INIT_POSITION_Y, right: Constants.PAGE_PADDING };
  @Link containerWidth: number;
  @Link containerHeight: number;
  @State nFlag: string = "";
  // 拖拽移动开始时悬浮窗在窗口中的坐标，每次移动回调触发时更新
  private windowStartX: number = 0;
  private windowStartY: number = 0;
  private startEdge: Edges = { top: Constants.INIT_POSITION_Y, right: Constants.PAGE_PADDING };

  /**
   * 触摸回调，悬浮窗跟手和贴边动画
   */
  onTouchEvent(event: TouchEvent): void {
    switch (event.type) {
      case TouchType.Down: {
        // 获取拖拽开始时悬浮窗在窗口中的坐标
        this.windowStartX = event.touches[0].windowX;
        this.windowStartY = event.touches[0].windowY;
        break;
      }
      case TouchType.Move: {
        const windowX: number = event.touches[0].windowX;
        const windowY: number = event.touches[0].windowY;
        // 知识点：跟手动画，推荐使用默认参数的弹性跟手动画曲线curves.responsiveSpringMotion。
        animateTo({ curve: curves.responsiveSpringMotion() }, () => {
          // 判断当前edge中属性left和right哪个不为undefined，用于控制悬浮窗水平方向的位置
          if (this.edge.left !== undefined) {
            this.edge.left = this.edge.left as number + (windowX - this.windowStartX);
          } else {
            this.edge.right = this.edge.right as number - (windowX - this.windowStartX);
          }
          this.edge.top = this.edge.top as number + (windowY - this.windowStartY);
          this.windowStartX = windowX;
          this.windowStartY = windowY;
        })
        break;
      }
      case TouchType.Up: {
        // 计算悬浮窗中心点在父组件中水平方向的坐标
        let centerX: number;
        if (this.edge.left !== undefined) {
          centerX = this.edge.left as number + Constants.FLOAT_WINDOW_WIDTH / 2;
        } else {
          centerX = this.containerWidth - (this.edge.right as number) - Constants.FLOAT_WINDOW_WIDTH / 2;
        }
        // 知识点：通过判断悬浮窗在父组件中的位置，设置悬浮窗贴边，使用curves.springMotion()弹性动画曲线，可以实现阻尼动画效果
        animateTo({ curve: curves.springMotion() }, () => {
          // 悬浮窗中心在水平方向是否超过父组件宽度的3/4或者小于父组件宽度的1/4，悬浮窗移至下一层，否则悬浮窗复位
          if (centerX > (this.containerWidth * 3 / 4) || centerX < (this.containerWidth / 4)) {
            if (this.nFlag == "1") {
              this.nZindexOne = 1;
              this.nZindexTwo = 2;
            } else {
              this.nZindexTwo = 1;
              this.nZindexOne = 2;
            }
          }
        })
        this.edge.right = this.startEdge.right;
        this.edge.top = this.startEdge.top;
        break;
      }
      default: {
        break;
      }
    }
  }

  build() {
    Stack() {
      Image($r('app.media.test'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Fill)
        .border({ width: 1, color: this.nFlag == "1" ? Color.Red : Color.Green })
    }
    .align(Alignment.Center)
    .clip(true)
    .border({ width: 1 })
    .width(Constants.FLOAT_WINDOW_WIDTH)
    .height(Constants.FLOAT_WINDOW_HEIGHT)
    .backgroundColor($r('app.color.ohos_id_color_foreground'))
    .position(this.edge)
    .onTouch((event: TouchEvent) => {
      this.onTouchEvent(event);
    })
    .zIndex(this.nFlag == "1" ? this.nZindexOne : this.nZindexTwo)
  }
}