import router from '@ohos.router'

@Entry
@Component
struct IndexTest {
  @State categorySelected: string = ''
  @State clickCount: number = 0

  build() {
    Column() {
      Text('华为商城')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .margin(50)

      Text('选择分类: ' + this.categorySelected)
        .fontSize(16)
        .margin(20)
        .fontColor('#666666')

      Row() {
        ForEach(['手机', '笔记本', '平板', '手表', '耳机'], (item: string, index?: number) => {
          Button(item)
            .width(100)
            .height(60)
            .margin(5)
            .backgroundColor(this.categorySelected === item ? '#FFD700' : '#F0F0F0')
            .fontColor(this.categorySelected === item ? Color.White : '#333333')
            .onClick(() => {
              console.log(`点击了分类: ${item}`)
              this.categorySelected = item
              this.clickCount++
            })
        })
      }
      .width('200)
      .center(true)
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ top: 20 })

      Text(`点击次数: ${this.clickCount}`)
        .fontSize(18)
        .margin(20)

      Button('测试页面')
        .width(200)
        .height(50)
        .margin(20)
        .backgroundColor('#28A745')
        .fontColor(Color.White)
        .onClick(() => {
          console.log('测试页面按钮被点击')
        })
    }
    .width('100%)
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
    .justifyContent(FlexAlign.Center)
  }
}