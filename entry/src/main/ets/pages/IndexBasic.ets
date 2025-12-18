@Entry
@Component
struct IndexBasic {
  build() {
    Column() {
      Text('华为商城')
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 100, bottom: 50 })

      Text('应用已成功启动')
        .fontSize(20)
        .margin({ bottom: 50 })

      Divider()
        .width('80%')
        .margin({ bottom: 50 })

      Column({ space: 20 }) {
        Text('🎉 欢迎使用华为商城')
          .fontSize(18)
          .fontColor('#666666')

        Text('这是一个基础的测试页面')
          .fontSize(16)
          .fontColor('#999999')
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#FFFFFF')
  }
}