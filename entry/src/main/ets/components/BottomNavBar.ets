import router from '@ohos.router'

@Component
export struct BottomNavBar {
  @State currentIndex: number = 0

  build() {
    Row() {
      Button() {
        Column() {
          Text('🏠')
            .fontSize(20)
          Text('首页')
            .fontSize(10)
            .margin({ top: 4 })
            .fontColor(this.currentIndex === 0 ? $r('app.color.primary') : $r('app.color.text_secondary'))
        }
      }
      .height(60)
      .width('33.33%')
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        if (this.currentIndex !== 0) {
          this.currentIndex = 0
          router.clear()
          router.replaceUrl({ url: 'pages/Index' })
        }
      })

      Button() {
        Column() {
          Text('👤')
            .fontSize(20)
          Text('我的')
            .fontSize(10)
            .margin({ top: 4 })
            .fontColor(this.currentIndex === 1 ? $r('app.color.primary') : $r('app.color.text_secondary'))
        }
      }
      .height(60)
      .width('33.33%')
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        if (this.currentIndex !== 1) {
          this.currentIndex = 1
          router.replaceUrl({ url: 'pages/UserCenterPage' })
        }
      })
    }
    .width('100%')
    .height(60)
    .backgroundColor($r('app.color.white'))
    .shadow({
      radius: 4,
      color: '#1A000000',
      offsetX: 0,
      offsetY: -2
    })
    .justifyContent(FlexAlign.SpaceEvenly)
    .alignItems(VerticalAlign.Center)
  }
}