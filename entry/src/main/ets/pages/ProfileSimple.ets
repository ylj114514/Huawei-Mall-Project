import router from '@ohos.router'

@Entry
@Component
struct ProfileSimple {
  @State username: string = '测试用户'
  @State cartCount: number = 5

  build() {
    Column() {
      // 头部
      Row() {
        Button('< 返回')
          .fontSize(16)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            router.back()
          })
      }
      .width('100%')
      .padding(20)
      .justifyContent(FlexAlign.Start)

      // 用户信息
      Row() {
        Text('用户：' + this.username)
          .fontSize(20)
          .margin(20)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      // 订单区域
      Column() {
        Text('我的订单')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin(20)

        Row() {
          Column() {
            Text('待付款')
              .fontSize(14)
            Text('2')
              .fontSize(16)
              .fontColor(Color.Red)
          }
          .width(100)
          .height(80)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .margin(10)
          .onClick(() => {
            console.log('点击了待付款！')
          })

          Column() {
            Text('待发货')
              .fontSize(14)
            Text('1')
              .fontSize(16)
              .fontColor(Color.Red)
          }
          .width(100)
          .height(80)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .margin(10)
          .onClick(() => {
            console.log('点击了待发货！')
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
      .margin(20)

      // 购物车
      Row() {
        Text('购物车')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        Text(this.cartCount + '件')
          .fontSize(16)
          .margin(20)
      }
      .width('100%')
      .padding(20)
      .backgroundColor('#F5F5F5')
      .onClick(() => {
        console.log('点击了购物车！')
      })

      Blank()

      // 退出登录
      Button('退出登录')
        .width(200)
        .height(50)
        .margin(50)
        .backgroundColor(Color.Red)
        .onClick(() => {
          console.log('点击了退出登录！')
          router.replaceUrl({ url: 'pages/SimplePage' })
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}