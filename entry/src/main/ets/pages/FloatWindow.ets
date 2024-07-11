import { Constants } from '../common/Constants';
import { curves } from '@kit.ArkUI';
import { Appreciation, Poetry } from '../model/Poetry';

@Reusable
@Component
export struct FloatWindow {
  private comments: string =
    '这首《锦瑟》，是李商隐的代表作，爱诗的无不乐道喜吟，堪称最享盛名;然而它又是最不易讲解的一篇难诗，自宋元以来，揣测纷纷，莫衷一是。诗题“锦瑟”是用了起句的头二个字。日说中，原有认为这是咏物.';
  private publishInfo: string = '周汝昌《唐诗鉴赏辞典》·上海辞书出版社';
  private appreciation:Appreciation = new Appreciation(this.comments, this.publishInfo)
  private appreciationArr:Appreciation[] = [this.appreciation]

  private poetryArr: string[] =
    ['锦瑟无端五十弦，一弦一柱思华年。', '庄生晓梦迷蝴蝶，望帝春心托杜鹃。', '沧海月明珠有泪，蓝田日暖玉生烟。',
      '此情可待成追忆?  只是当时已惘然。'];

  // private excerptArr: string[] = ['此情可待成追忆'];
  // private excerptArr: string[] = ['此情可待成追忆', '只是当时已惘然'];
  private excerptArr: string[] = ['此情可待成追忆', '只是当时已惘然', '蓝田日暖玉生烟', '沧海月明珠有泪'];
  private authorInfoStr: string =
    '李商隐，著名诗人。擅长诗歌写作，骈文文学价值也很高，他是晚唐最出色的诗人之一，和杜牧合称“小李杜”，与温庭筠合称为“温李”，因诗文与同时期的段成式、温庭筠风格相近，且三人都在家族里排行第十六，故并称为“三十六体”。其诗构思新奇，风格秾丽，尤其是一些爱情诗和无题诗写得缠绵悱恻，优美动人，广为人传诵。但部分诗歌过于隐晦迷离，难于索解，至有“诗家总爱西昆好，独恨无人作郑笺”之说。因处于牛李党争的夹缝之中，一生很不得志。死后葬于家乡沁阳(今沁阳与博爱县交界之处)。作品收录为《李义山诗集》。';
  private categoryArr: string[] = ['唐诗三百首', '家', '日'];

   private poetry:Poetry = new Poetry('1', '锦瑟', '【唐】', '李商隐', this.poetryArr, this.appreciationArr, this.authorInfoStr, this.excerptArr, this.categoryArr)


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
      this.componetX()
    }
    .align(Alignment.Center)
    .clip(true)
    .border({ width: 1, color: this.nFlag == "1" ? Color.Red : Color.Green })
    .width(Constants.FLOAT_WINDOW_WIDTH)
    .height(Constants.FLOAT_WINDOW_HEIGHT)
    // .backgroundColor($r('app.color.ohos_id_color_foreground'))
    .position(this.edge)
    .onTouch((event: TouchEvent) => {
      this.onTouchEvent(event);
    })
    .zIndex(this.nFlag == "1" ? this.nZindexOne : this.nZindexTwo)
  }

  @Builder
  componetX() {
    Column(){
      Column(){
        Text(this.poetry.author)// .border({ width: 1, color: Color.Red })
          .width(Constants.TEXT_WIDTH)
          .height(Constants.TEXT_HEIGHT)
          .fontSize($r('app.integer.author_font_size'))
          .textAlign(TextAlign.Center)
          .margin({ left: -200, top: 350 })
          // .border({width:1,color:Color.Red})
        Image($r('app.media.animal'))
          .width(40)
          .margin({left:-200,top:30})
      }

      ForEach(this.excerptArr, (item: string, index?: number) => {
        ListItem() {
          Text(item)// .border({ width: 1, color: Color.Red })
            .width(Constants.TEXT_WIDTH)
            .height(Constants.TEXT_HEIGHT)
            .fontSize($r('app.integer.excerpt_font_size'))
            .textAlign(TextAlign.Center)
            // .margin({left:200,top: -850})
            .margin({ left: 200 - GetStartPosition(index), top: -850 })
            .border({width:1,color:Color.Red});
        };
      }, (item: string) => item.toString());
    }
    .width(Constants.FLOAT_WINDOW_WIDTH)
    .height(Constants.FLOAT_WINDOW_HEIGHT)
    .border({ width: 2, color: Color.Blue })
    // .backgroundColor(Color.White)
  }
}

/**
 * 根据句数，获取起始位置
 * @param length
 * @returns
 */
function GetStartPosition(index: number): number {
  let left = index * (Constants.TEXT_WIDTH + 30)
  console.info("index = " + index + ",left =" + left);
  return left;
}