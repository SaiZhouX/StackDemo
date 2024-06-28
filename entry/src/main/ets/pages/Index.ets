import { Constants } from '../common/Constants';
import { curves } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  private scroller: Scroller = new Scroller();
  // 父组件宽度
  @State containerWidth: number = 0;
  // 父组件高度
  @State containerHeight: number = 0;

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
    Row() {

    }
    .width(300)
    .height(500)
    .border({ width: 1 })
    .backgroundImageSize(ImageSize.Cover)
    .backgroundImage($r('app.media.test'));
    // 悬浮窗
    FloatWindow({ containerWidth: this.containerWidth, containerHeight: this.containerHeight })

    // Row(){
    //   Text('11111')
    //   Text('22222')
    // }
    // .width(30)
    // .backgroundColor(Color.Red)
    // Row(){
    //   Text('33333')
    //   Text('44444')
    // }
    // .width(50)
    // .backgroundColor(Color.Green)
  }

  @Builder
  scrollItem() {
    // 商品信息展示组件
    Scroll(this.scroller) {
      Column() {
        Image($r('app.media.float_window_product'))
          .objectFit(ImageFit.Contain)
          .backgroundColor($r('app.color.ohos_id_color_background'))
          .width($r('app.string.float_window_full_size'))
          .borderRadius($r('app.string.ohos_id_corner_radius_default_l'));
      };
    }
    .width($r('app.string.float_window_full_size'))
    .height($r('app.string.float_window_full_size'))
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
    .padding(Constants.PAGE_PADDING)

    // 悬浮窗
    FloatWindowView({ containerWidth: this.containerWidth, containerHeight: this.containerHeight })
  }

  @Builder
  rowtest() {
    Column() {
      Text('分类')
        .border({ width: 1, color: Color.Red })
        .fontColor(Color.Red)
        .alignSelf(ItemAlign.Start)
        .margin({ top: 10 });
      Row() {
        Text('唐诗三百首')
          .border({ width: 1, color: Color.Red });
        Text('爱')
          .border({ width: 1, color: Color.Red })
          .margin({ left: 15 });
        Text('日')
          .border({ width: 1, color: Color.Red })
          .margin({ left: 15 });
      }.justifyContent(FlexAlign.Start);
    }
  }
}

@Component
struct FloatWindow {
  // 悬浮窗相对于父组件四条边的距离，top和bottom同时设置时top生效，right和left同时设置时left生效
  @State edge: Edges = { top: Constants.INIT_POSITION_Y, right: Constants.PAGE_PADDING };
  @Link containerWidth: number;
  @Link containerHeight: number;
  // 拖拽移动开始时悬浮窗在窗口中的坐标，每次移动回调触发时更新
  private windowStartX: number = 0;
  private windowStartY: number = 0;
  private videoController: VideoController = new VideoController();

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
        // 计算悬浮窗中心点在父组件中水平方向的坐标
        let centerX: number;
        if (this.edge.left !== undefined) {
          centerX = this.edge.left as number + Constants.FLOAT_WINDOW_WIDTH / 2;
        } else {
          centerX = this.containerWidth - (this.edge.right as number) - Constants.FLOAT_WINDOW_WIDTH / 2;
        }
        // TODO：知识点：通过判断悬浮窗在父组件中的位置，设置悬浮窗贴边，使用curves.springMotion()弹性动画曲线，可以实现阻尼动画效果
        animateTo({ curve: curves.springMotion() }, () => {
          // 判断悬浮窗中心在水平方向是否超过父组件宽度的一半，根据结果设置靠左或靠右
          if (centerX > (this.containerWidth / 2)) {
            this.edge.right = Constants.PAGE_PADDING;
            this.edge.left = undefined;
          } else {
            this.edge.right = undefined;
            this.edge.left = Constants.PAGE_PADDING;
          }
          // 判断悬浮窗是否超出内容区上下边界，根据结果将悬浮窗设置在边界位置
          if (this.edge.top as number < Constants.PAGE_PADDING) {
            this.edge.top = Constants.PAGE_PADDING;
          } else if (this.edge.top as number >
            this.containerHeight - Constants.FLOAT_WINDOW_HEIGHT - Constants.PAGE_PADDING) {
            this.edge.top = this.containerHeight - Constants.FLOAT_WINDOW_HEIGHT - Constants.PAGE_PADDING;
          }
        })
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
        .width('100%').height('100%').objectFit(ImageFit.Fill)
    }
    .align(Alignment.Center)
    .clip(true)
    // .border({
    //   width: $r('app.integer.float_window_border_width'),
    //   color: $r('app.color.ohos_id_color_background')
    // })
    .border({width:1})
    .width(300)
    .height(500)
    .backgroundColor($r('app.color.ohos_id_color_foreground'))
    .position(this.edge)
    .onTouch((event: TouchEvent) => {
      this.onTouchEvent(event);
    })
  }
}

@Component
struct FloatWindowView {
  // 悬浮窗相对于父组件四条边的距离，top和bottom同时设置时top生效，right和left同时设置时left生效
  @State edge: Edges = { top: Constants.INIT_POSITION_Y, right: Constants.PAGE_PADDING };
  @Link containerWidth: number;
  @Link containerHeight: number;
  // 拖拽移动开始时悬浮窗在窗口中的坐标，每次移动回调触发时更新
  private windowStartX: number = 0;
  private windowStartY: number = 0;
  private videoController: VideoController = new VideoController();

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
        // 计算悬浮窗中心点在父组件中水平方向的坐标
        let centerX: number;
        if (this.edge.left !== undefined) {
          centerX = this.edge.left as number + Constants.FLOAT_WINDOW_WIDTH / 2;
        } else {
          centerX = this.containerWidth - (this.edge.right as number) - Constants.FLOAT_WINDOW_WIDTH / 2;
        }
        // TODO：知识点：通过判断悬浮窗在父组件中的位置，设置悬浮窗贴边，使用curves.springMotion()弹性动画曲线，可以实现阻尼动画效果
        animateTo({ curve: curves.springMotion() }, () => {
          // 判断悬浮窗中心在水平方向是否超过父组件宽度的一半，根据结果设置靠左或靠右
          if (centerX > (this.containerWidth / 2)) {
            this.edge.right = Constants.PAGE_PADDING;
            this.edge.left = undefined;
          } else {
            this.edge.right = undefined;
            this.edge.left = Constants.PAGE_PADDING;
          }
          // 判断悬浮窗是否超出内容区上下边界，根据结果将悬浮窗设置在边界位置
          if (this.edge.top as number < Constants.PAGE_PADDING) {
            this.edge.top = Constants.PAGE_PADDING;
          } else if (this.edge.top as number >
            this.containerHeight - Constants.FLOAT_WINDOW_HEIGHT - Constants.PAGE_PADDING) {
            this.edge.top = this.containerHeight - Constants.FLOAT_WINDOW_HEIGHT - Constants.PAGE_PADDING;
          }
        })
        break;
      }
      default: {
        break;
      }
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Video({
        src: $rawfile('float_window_video.mp4'),
        controller: this.videoController
      })
        .controls(false)
        .autoPlay(true)
        .loop(true)
        .muted(true)
        .width($r('app.string.float_window_full_size'))
        .onClick(() => {
          this.videoController.requestFullscreen(true);
        })
        .borderRadius($r('app.integer.float_window_content_border_radius'))
      Text($r('app.string.float_window_live_text'))
        .width($r('app.string.float_window_full_size'))
        .fontSize($r('app.string.ohos_id_text_size_body1'))
        .fontColor($r('app.color.ohos_id_color_background'))
        .textAlign(TextAlign.Center)
        .backgroundColor($r('app.color.ohos_id_color_list_alert'))
        .borderRadius({
          bottomLeft: $r('app.integer.float_window_content_border_radius'),
          bottomRight: $r('app.integer.float_window_content_border_radius')
        })
    }
    .clip(true)
    .border({
      width: $r('app.integer.float_window_border_width'),
      color: $r('app.color.ohos_id_color_background')
    })
    .borderRadius($r('app.string.ohos_id_corner_radius_default_l'))
    .width(Constants.FLOAT_WINDOW_WIDTH)
    .height(Constants.FLOAT_WINDOW_HEIGHT)
    .backgroundColor($r('app.color.ohos_id_color_foreground'))
    .position(this.edge)
    .onTouch((event: TouchEvent) => {
      this.onTouchEvent(event);
    })
  }
}