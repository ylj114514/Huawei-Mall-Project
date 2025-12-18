import router from '@ohos.router'

@Entry
@Component
struct SimpleLogin {
  @State account: string = ''
  @State password: string = ''

  build() {
    Column() {
      Text('登录')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .margin(50)

      TextInput({ placeholder: '请输入账号', text: this.account })
        .width(300)
        .height(50)
        .margin(20)
        .onChange((value: string) => {
          this.account = value
        })

      TextInput({ placeholder: '请输入密码', text: this.password })
        .width(300)
        .height(50)
        .margin(20)
        .type(InputType.Password)
        .onChange((value: string) => {
          this.password = value
        })

      Button('登录')
        .width(300)
        .height(50)
        .margin(20)
        .backgroundColor('#007AFF')
        .onClick(() => {
          console.log('登录按钮被点击')
          console.log('账号:', this.account)
          console.log('密码:', this.password)
          if (this.account && this.password) {
            router.replaceUrl({ url: 'pages/SimplePage' })
          }
        })

      Button('注册')
        .width(300)
        .height(50)
        .margin(20)
        .backgroundColor('#FF3B30')
        .onClick(() => {
          console.log('注册按钮被点击')
          console.log('账号:', this.account)
          console.log('密码:', this.password)
          if (this.account && this.password) {
            router.replaceUrl({ url: 'pages/SimplePage' })
          }
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}