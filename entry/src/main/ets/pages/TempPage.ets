import router from '@ohos.router'

@Entry
@Component
struct TempPage {
  build() {
    Column() {
      Text('临时页面')
        .fontSize(24)
        .margin(50)

      Button('跳转到启动页')
        .width(200)
        .height(50)
        .onClick(() => {
          router.replaceUrl({ url: 'pages/SplashScreenModernFixed' })
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}