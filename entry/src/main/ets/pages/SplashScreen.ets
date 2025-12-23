import router from '@ohos.router'

@Entry
@Component
struct SplashScreen {
  @State scrollY: number = 0
  @State contentOpacity: number = 1
  @State contentScale: number = 1
  @State showEnterText: boolean = false
  @State hasNavigated: boolean = false
  private scroller: Scroller = new Scroller()

  aboutToAppear() {
    // 延迟显示"上滑进入"文字
    setTimeout(() => {
      this.showEnterText = true
    }, 1000)
  }

  private onScroll(xOffset: number, yOffset: number) {
    console.info('SplashScreen scroll offset:', yOffset)
    this.scrollY = yOffset
    // 根据滚动距离计算透明度和缩放
    this.contentOpacity = Math.max(0, 1 - yOffset / 300)
    this.contentScale = Math.max(0.8, 1 - yOffset / 1000)

    // 滚动到一定程度后跳转
    if (yOffset > 200 && !this.hasNavigated) {
      this.hasNavigated = true
      console.info('Navigating to Index')
      // ✅ 修复：跳转到正确的首页
      router.replaceUrl({
        url: 'pages/Index'
      })
    }
  }

  private handleNavigate() {
    if (!this.hasNavigated) {
      this.hasNavigated = true
      // ✅ 修复：跳转到正确的首页
      router.replaceUrl({
        url: 'pages/Index'
      })
    }
  }

  @Builder
  HeroContent() {
    Column() {
      // 品牌标志
      Text('HUAWEI')
        .fontSize(72)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .letterSpacing(12)
        .opacity(this.contentOpacity)
        .scale({ x: this.contentScale, y: this.contentScale })

      Text('构建万物互联的智能世界')
        .fontSize(20)
        .fontColor('rgba(255,255,255,0.9)')
        .margin({ top: 20 })
        .opacity(this.contentOpacity)
        .scale({ x: this.contentScale, y: this.contentScale })

      // 核心产品展示
      Column({ space: 40 }) {
        Row() {
          Column() {
            Text('Mate 60')
              .fontSize(16)
              .fontColor('rgba(255,255,255,0.8)')
              .margin({ bottom: 8 })
            Text('麒麟回归')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
          .opacity(this.contentOpacity)
          .layoutWeight(1)

          Column() {
            Text('鸿蒙OS')
              .fontSize(16)
              .fontColor('rgba(255,255,255,0.8)')
              .margin({ bottom: 8 })
            Text('万物互联')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
          .opacity(this.contentOpacity)
          .layoutWeight(1)

          Column() {
            Text('智慧生态')
              .fontSize(16)
              .fontColor('rgba(255,255,255,0.8)')
              .margin({ bottom: 8 })
            Text('创新引领')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
          .opacity(this.contentOpacity)
          .layoutWeight(1)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceAround)
        .margin({ top: 80 })
      }
      .opacity(this.contentOpacity * 0.8)
    }
  }

  @Builder
  FloatingIndicator() {
    if (this.showEnterText) {
      Column() {
        Row() {
          Text('👆')
            .fontSize(28)
            .animation({
              duration: 1000,
              curve: Curve.EaseInOut,
              iterations: -1,
              playMode: PlayMode.Alternate
            })
        }
        .margin({ bottom: 12 })

        Text('上滑进入商城')
          .fontSize(16)
          .fontColor('rgba(255,255,255,0.8)')
          .animation({
            duration: 1000,
            curve: Curve.EaseInOut,
            iterations: -1,
            playMode: PlayMode.Alternate
          })
      }
      .position({ x: '50%', y: '75%' })
      .translate({ x: '-50%', y: 0 })
      .onClick(() => {
        this.handleNavigate()
      })
    }
  }

  build() {
    Stack() {
      // 背景层
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            ['#000000', 0.0],
            ['#1A1A1A', 0.3],
            ['#000000', 1.0]
          ]
        })

      // 主内容
      Scroll(this.scroller) {
        Column() {
          // 顶部留白（用于滚动）
          Column()
            .width('100%')
            .height(600)

          // 展示内容
          this.HeroContent()

          // 底部留白和点击区域
          Column() {
            // 可点击的进入区域
            Button() {
              Column() {
                Text('点击进入商城')
                  .fontSize(18)
                  .fontColor('#FFFFFF')
                  .margin({ bottom: 8 })
                Text('或继续上滑')
                  .fontSize(14)
                  .fontColor('rgba(255,255,255,0.7)')
              }
            }
            .width('100%')
            .height(120)
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.handleNavigate()
            })

            Blank()
              .layoutWeight(1)
          }
          .width('100%')
          .height(600)
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .onScroll((xOffset: number, yOffset: number) => {
        this.onScroll(xOffset, yOffset)
      })

      // 浮动指示器
      this.FloatingIndicator()

      // 装饰元素
      Column() {
        // 左上角装饰
        Text('EMPOWER')
          .fontSize(12)
          .fontColor('rgba(255,255,255,0.3)')
          .letterSpacing(4)
          .position({ x: 40, y: 100 })
          .rotate({ angle: -90 })

        // 右下角装饰
        Text('INNOVATION')
          .fontSize(12)
          .fontColor('rgba(255,255,255,0.3)')
          .letterSpacing(4)
          .position({ x: '100%', y: '100%' })
          .translate({ x: -140, y: -100 })
          .rotate({ angle: 90 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
    .gesture(
      PanGesture({ direction: PanDirection.Up, fingers: 1 })
        .onActionEnd(() => {
          this.handleNavigate()
        })
    )
    .onClick(() => {
      this.handleNavigate()
    })
  }
}