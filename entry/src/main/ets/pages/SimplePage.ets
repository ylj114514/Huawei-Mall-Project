import router from '@ohos.router'

@Entry
@Component
struct SimplePage {
  build() {
    Column() {
      Text('华为商城')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .margin(50)

      Button('登录')
        .width(200)
        .height(50)
        .margin(20)
        .onClick(() => {
          router.pushUrl({ url: 'pages/SimpleLogin' })
        })

      Button('个人中心')
        .width(200)
        .height(50)
        .margin(20)
        .onClick(() => {
          router.pushUrl({ url: 'pages/ProfileSimple' })
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}