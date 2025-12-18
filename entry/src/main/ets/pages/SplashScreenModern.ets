import router from '@ohos.router'

console.log('SplashScreenModern 页面加载')

@Entry
@Component
struct SplashScreenModern {
  @State contentOpacity: number = 0
  @State contentScale: number = 0.8
  @State showMain: boolean = false

  aboutToAppear() {
    // 启动动画
    setTimeout(() => {
      this.contentOpacity = 1
      this.contentScale = 1
    }, 100)

    // 3秒后自动进入首页
    console.log('设置3秒自动跳转定时器')
    setTimeout(() => {
      console.log('3秒定时器触发，调用 enterMain')
      this.enterMain()
    }, 3000)
  }

  private enterMain() {
    console.log('准备进入首页')

    // 隐藏按钮
    this.showMain = true

    animateTo({
      duration: 500,
      curve: Curve.EaseInOut
    }, () => {
      this.contentOpacity = 0
      this.contentScale = 1.2
    })

    // 3秒后跳转
    setTimeout(() => {
      console.log('执行路由跳转')
      router.replaceUrl({
        url: 'pages/IndexNewModern',
        params: {}
      }).then(() => {
        console.log('跳转成功')
      }).catch((err: Error) => {
        console.error('跳转失败:', err)
        // 如果跳转失败，尝试直接跳转
        router.pushUrl({ url: 'pages/IndexNewModern' })
      })
    }, 3000)
  }

  build() {
    Stack() {
      // 背景渐变
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            ['#000000', 0.0],
            ['#1A1A1A', 0.5],
            ['#000000', 1.0]
          ]
        })

      // 主要内容
      Column() {
        // Logo区域
        Column() {
          // Huawei标志
          Text('HUAWEI')
            .fontSize(48)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .letterSpacing(8)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.None })
            .opacity(this.contentOpacity)
            .scale({ x: this.contentScale, y: this.contentScale })

          // 副标题
          Text('华为商城')
            .fontSize(24)
            .fontColor('rgba(255,255,255,0.8)')
            .margin({ top: 16 })
            .opacity(this.contentOpacity)
            .scale({ x: this.contentScale, y: this.contentScale })

          // 标语
          Text('构建万物互联的智能世界')
            .fontSize(16)
            .fontColor('rgba(255,255,255,0.6)')
            .margin({ top: 80 })
            .opacity(this.contentOpacity * 0.8)
        }
        .width('100%')
        .height('60%')
        .justifyContent(FlexAlign.Center)

        // 底部提示
        Column() {
          // 上滑箭头动画
          Text('↑')
            .fontSize(36)
            .fontColor('#FFFFFF')
            .opacity(this.contentOpacity * 0.8)
            .animation({
              duration: 1500,
              curve: Curve.EaseInOut,
              iterations: -1,
              playMode: PlayMode.Alternate
            })

          Text(this.showMain ? '即将进入商城...' : '上滑或点击进入商城')
            .fontSize(16)
            .fontColor('rgba(255,255,255,0.8)')
            .margin({ top: 20 })
            .opacity(this.contentOpacity * 0.8)

          // 点击按钮（备用）
          if (!this.showMain) {
            Button('进入商城')
              .fontSize(16)
              .fontColor('#000000')
              .backgroundColor('#FFFFFF')
              .padding({ left: 30, right: 30, top: 10, bottom: 10 })
              .borderRadius(20)
              .margin({ top: 30 })
              .opacity(this.contentOpacity)
              .onClick(() => {
                console.log('点击按钮进入')
                this.enterMain()
              })
          }
        }
        .width('100%')
        .height('40%')
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height('100%')
      .padding({ left: 40, right: 40 })

      // 手势识别
      .gesture(
        PanGesture({ direction: PanDirection.Up, distance: 50 })
          .onActionEnd(() => {
            console.log('上滑手势触发')
            this.enterMain()
          })
      )
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }
}