import { Constants } from '../common/Constants';
import { curves } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  private scroller: Scroller = new Scroller();
  // 父组件宽度
  @State containerWidth: number = 0;
  // 父组件高度
  @State containerHeight: number = 0;
  @State nZindexOne: number = 1;
  @State nZindexTwo: number = 2;

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
    // 悬浮窗
    FloatWindow({
      containerWidth: this.containerWidth,
      containerHeight: this.containerHeight,
      nZindexOne: this.nZindexOne,
      nZindexTwo: this.nZindexTwo
    })
    // 悬浮窗
    FloatWindowx({
      containerWidth: this.containerWidth,
      containerHeight: this.containerHeight,
      nZindexOne: this.nZindexOne,
      nZindexTwo: this.nZindexTwo
    })
  }
}

@Component
struct FloatWindow {
  @Link nZindexOne: number;
  @Link nZindexTwo: number;
  // 悬浮窗相对于父组件四条边的距离，top和bottom同时设置时top生效，right和left同时设置时left生效
  @State edge: Edges = { top: Constants.INIT_POSITION_Y, right: Constants.PAGE_PADDING };
  @Link containerWidth: number;
  @Link containerHeight: number;
  // 拖拽移动开始时悬浮窗在窗口中的坐标，每次移动回调触发时更新
  private windowStartX: number = 0;
  private windowStartY: number = 0;
  private nFirstX: number = 0;
  private nFirstY: number = 0;
  private startEdge: Edges = { top: Constants.INIT_POSITION_Y, right: Constants.PAGE_PADDING };

  /**
   * 触摸回调，悬浮窗跟手和贴边动画
   */
  onTouchEvent(event: TouchEvent): void {
    switch (event.type) {
      case TouchType.Down: {
        hilog.info(0x0000, 'Red', 'TouchType.Down');
        // 获取拖拽开始时悬浮窗在窗口中的坐标
        this.nFirstX = this.windowStartX = event.touches[0].windowX;
        this.nFirstY = this.windowStartY = event.touches[0].windowY;
        break;
      }
      case TouchType.Move: {
        hilog.info(0x0000, 'Red', 'TouchType.Move');
        const windowX: number = event.touches[0].windowX;
        const windowY: number = event.touches[0].windowY;
        // TODO：知识点：跟手动画，推荐使用默认参数的弹性跟手动画曲线curves.responsiveSpringMotion。
        animateTo({ curve: curves.responsiveSpringMotion() }, () => {
          // 判断当前edge中属性left和right哪个不为undefined，用于控制悬浮窗水平方向的位置
          if (this.edge.left !== undefined) {
            hilog.info(0x0000, 'Red', 'edge.left !== undefined');
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
        hilog.info(0x0000, 'Red', 'TouchType.Up');
        // 计算悬浮窗中心点在父组件中水平方向的坐标
        let centerX: number;
        if (this.edge.left !== undefined) {
          centerX = this.edge.left as number + Constants.FLOAT_WINDOW_WIDTH / 2;
        } else {
          centerX = this.containerWidth - (this.edge.right as number) - Constants.FLOAT_WINDOW_WIDTH / 2;
        }
        // TODO：知识点：通过判断悬浮窗在父组件中的位置，设置悬浮窗贴边，使用curves.springMotion()弹性动画曲线，可以实现阻尼动画效果
        animateTo({ curve: curves.springMotion() }, () => {
          // 悬浮窗中心在水平方向是否超过父组件宽度的3/4或者小于父组件宽度的1/4，悬浮窗移至下一层，否则悬浮窗复位
          if (centerX > (this.containerWidth * 3 / 4) || centerX < (this.containerWidth / 4)){
            this.nZindexOne = 1;
            this.nZindexTwo = 2;
            this.windowStartX = this.nFirstX;
            this.windowStartY = this.nFirstY;
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
        .width('100%').height('100%').objectFit(ImageFit.Fill).border({ width: 1, color: Color.Red })
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
    .zIndex(this.nZindexOne)
  }
}

@Component
struct FloatWindowx {
  @Link nZindexOne: number;
  @Link nZindexTwo: number;
  // 悬浮窗相对于父组件四条边的距离，top和bottom同时设置时top生效，right和left同时设置时left生效
  @State edge: Edges = { top: Constants.INIT_POSITION_Y, right: Constants.PAGE_PADDING };
  @Link containerWidth: number;
  @Link containerHeight: number;
  // 拖拽移动开始时悬浮窗在窗口中的坐标，每次移动回调触发时更新
  private windowStartX: number = 0;
  private windowStartY: number = 0;
  private nFirstX: number = 0;
  private nFirstY: number = 0;
  private startEdge: Edges = { top: Constants.INIT_POSITION_Y, right: Constants.PAGE_PADDING };

  /**
   * 触摸回调，悬浮窗跟手和贴边动画
   */
  onTouchEvent(event: TouchEvent): void {
    switch (event.type) {
      case TouchType.Down: {
        hilog.info(0x0000, 'Green', 'TouchType.Down');
        // 获取拖拽开始时悬浮窗在窗口中的坐标
        this.nFirstX = this.windowStartX = event.touches[0].windowX;
        this.nFirstY = this.windowStartY = event.touches[0].windowY;
        break;
      }
      case TouchType.Move: {
        hilog.info(0x0000, 'Green', 'TouchType.Move');
        const windowX: number = event.touches[0].windowX;
        const windowY: number = event.touches[0].windowY;
        // TODO：知识点：跟手动画，推荐使用默认参数的弹性跟手动画曲线curves.responsiveSpringMotion。
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
        hilog.info(0x0000, 'Green', 'TouchType.Up');
        // 计算悬浮窗中心点在父组件中水平方向的坐标
        let centerX: number;
        if (this.edge.left !== undefined) {
          centerX = this.edge.left as number + Constants.FLOAT_WINDOW_WIDTH / 2;
        } else {
          centerX = this.containerWidth - (this.edge.right as number) - Constants.FLOAT_WINDOW_WIDTH / 2;
        }
        // TODO：知识点：通过判断悬浮窗在父组件中的位置，设置悬浮窗贴边，使用curves.springMotion()弹性动画曲线，可以实现阻尼动画效果
        animateTo({ curve: curves.springMotion() }, () => {
          // 悬浮窗中心在水平方向是否超过父组件宽度的3/4或者小于父组件宽度的1/4，悬浮窗移至下一层，否则悬浮窗复位
          if (centerX > (this.containerWidth * 3 / 4) || centerX < (this.containerWidth / 4)) {
            this.nZindexTwo = 1;
            this.nZindexOne = 2;
            this.windowStartX = this.nFirstX;
            this.windowStartY = this.nFirstY;
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
        .width('100%').height('100%').objectFit(ImageFit.Fill).border({ width: 1, color: Color.Green })
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
    .zIndex(this.nZindexTwo)
  }
}