import router from '@ohos.router'

@Entry
@Component
struct TestClickPage {
  @State message: string = '点击按钮测试'

  build() {
    Column() {
      Text(this.message)
        .fontSize(20)
        .margin(20)

      Button('测试按钮1')
        .width(200)
        .height(50)
        .margin(10)
        .onClick(() => {
          console.log('按钮1被点击了！')
          this.message = '按钮1被点击了！'
        })

      Button('测试按钮2')
        .width(200)
        .height(50)
        .margin(10)
        .backgroundColor('#FF0000')
        .onClick(() => {
          console.log('按钮2被点击了！')
          this.message = '按钮2被点击了！'
        })

      Button('返回首页')
        .width(200)
        .height(50)
        .margin(20)
        .onClick(() => {
          router.back()
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}