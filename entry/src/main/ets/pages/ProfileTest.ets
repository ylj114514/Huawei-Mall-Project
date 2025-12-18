import router from '@ohos.router'

@Entry
@Component
struct ProfileTest {
  @State clickCount: number = 0
  @State message: string = '等待点击测试'

  build() {
    Column() {
      Text('个人中心测试')
        .fontSize(24)
        .margin(30)

      Text(this.message)
        .fontSize(18)
        .margin(20)
        .fontColor('#FF0000FF')

      Button('测试点击1')
        .width(200)
        .height(50)
        .margin(10)
        .backgroundColor('#007AFF')
        .fontColor(Color.White)
        .onClick(() => {
          this.clickCount++
          this.message = `点击了${this.clickCount}次`
          console.log('测试1被点击:', this.clickCount)
        })

      Button('测试点击2')
        .width(200)
        .height(50)
        .margin(10)
        .backgroundColor('#FF3B30')
        .fontColor(Color.White)
        .onClick(() => {
          this.clickCount++
          this.message = `点击了${this.clickCount}次`
          console.log('测试2被点击:', this.clickCount)
        })

      Button('返回')
        .width(200)
        .height(50)
        .margin(20)
        .backgroundColor('#28A745')
        .fontColor(Color.White)
        .onClick(() => {
          router.back()
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
    .justifyContent(FlexAlign.Center)
  }
}