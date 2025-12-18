import router from '@ohos.router'

@Entry
@Component
struct MainPage {
  build() {
    Column() {
      Text('华为商城')
        .fontSize(30)
        .margin(50)

      Button('进入首页')
        .width(200)
        .height(50)
        .margin(20)
        .onClick(() => {
          router.pushUrl({ url: 'pages/IndexNewModern' })
        })

      Button('登录')
        .width(200)
        .height(50)
        .margin(20)
        .onClick(() => {
          router.pushUrl({ url: 'pages/LoginPageModern' })
        })

      Button('个人中心')
        .width(200)
        .height(50)
        .margin(20)
        .onClick(() => {
          router.pushUrl({ url: 'pages/ProfileModern' })
        })

      Button('商品详情')
        .width(200)
        .height(50)
        .margin(20)
        .onClick(() => {
          router.pushUrl({ url: 'pages/ProductDetailComplete' })
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}