import router from '@ohos.router'

@Entry
@Component
struct MainFixed {
  @State clickCount: number = 0

  build() {
    Column() {
      Text('华为商城')
        .fontSize(30)
        .margin(50)

      Text(`点击次数: ${this.clickCount}`)
        .fontSize(20)
        .margin(20)

      Button('进入首页')
        .width(200)
        .height(50)
        .margin(20)
        .onClick(() => {
          console.log('进入首页按钮被点击')
          this.clickCount++
          try {
            router.pushUrl({ url: 'pages/IndexNewModern' })
          } catch (error) {
            console.error('路由失败:', error)
          }
        })

      Button('登录')
        .width(200)
        .height(50)
        .margin(20)
        .onClick(() => {
          console.log('登录按钮被点击')
          this.clickCount++
          try {
            router.pushUrl({ url: 'pages/LoginPageModern' })
          } catch (error) {
            console.error('路由失败:', error)
          }
        })

      Button('个人中心')
        .width(200)
        .height(50)
        .margin(20)
        .onClick(() => {
          console.log('个人中心按钮被点击')
          this.clickCount++
          try {
            router.pushUrl({ url: 'pages/ProfileModern' })
          } catch (error) {
            console.error('路由失败:', error)
          }
        })

      Button('商品详情')
        .width(200)
        .height(50)
        .margin(20)
        .onClick(() => {
          console.log('商品详情按钮被点击')
          this.clickCount++
          try {
            router.pushUrl({ url: 'pages/ProductDetailComplete' })
          } catch (error) {
            console.error('路由失败:', error)
          }
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}