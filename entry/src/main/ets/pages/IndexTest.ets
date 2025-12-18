import router from '@ohos.router'

@Entry
@Component
struct IndexTest {
  @State message: string = '华为商城'

  build() {
    Column() {
      Text(this.message)
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 100, bottom: 50 })

      Button('进入首页')
        .fontSize(18)
        .width(200)
        .height(50)
        .margin({ bottom: 20 })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/IndexPremium'
          })
        })

      Button('进入奢华版')
        .fontSize(18)
        .width(200)
        .height(50)
        .margin({ bottom: 20 })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/IndexLuxury'
          })
        })

      Button('登录')
        .fontSize(18)
        .width(200)
        .height(50)
        .onClick(() => {
          router.pushUrl({
            url: 'pages/LoginPage'
          })
        })

      Button('商品详情')
        .fontSize(18)
        .width(200)
        .height(50)
        .margin({ top: 20 })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/ProductDetailComplete',
            params: {
              productId: '1'
            }
          })
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F5F5F5')
  }
}