import router from '@ohos.router'

@Entry
@Component
struct SplashScreenModernFixed {
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
    setTimeout(() => {
      this.enterMain()
    }, 3000)
  }

  private enterMain() {
    animateTo({
      duration: 500,
      curve: Curve.EaseInOut
    }, () => {
      this.contentOpacity = 0
      this.contentScale = 1.2
    })

    setTimeout(() => {
      router.replaceUrl({ url: 'pages/IndexNewModern' })
    }, 500)
  }

  build() {
    Column() {
      Text('HUAWEI')
        .fontSize(48)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .letterSpacing(8)
        .opacity(this.contentOpacity)
        .scale({ x: this.contentScale, y: this.contentScale })

      Text('华为商城')
        .fontSize(24)
        .fontColor('rgba(255,255,255,0.8)')
        .margin({ top: 16 })
        .opacity(this.contentOpacity)
        .scale({ x: this.contentScale, y: this.contentScale })

      Text('上滑进入商城')
        .fontSize(14)
        .fontColor('rgba(255,255,255,0.5)')
        .opacity(this.contentOpacity * 0.8)
        .position({ x: 0, y: '50%' })

      Text('↑')
        .fontSize(24)
        .fontColor('#FFFFFF')
        .margin({ top: 12 })
        .opacity(this.contentOpacity * 0.6)
        .position({ x: 0, y: '55%' })
        .animation({
          duration: 1500,
          curve: Curve.EaseInOut,
          iterations: -1,
          playMode: PlayMode.Alternate
        })

      Button('进入商城')
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor('#FF3B30')
        .padding({ left: 32, right: 32, top: 12, bottom: 12 })
        .margin({ top: 100 })
        .onClick(() => this.enterMain())
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
    .justifyContent(FlexAlign.Center)
  }
}