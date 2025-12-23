import router from '@ohos.router'
import { User } from '../model/DataModel'
import { DatabaseManager } from '../database/DatabaseManager'
import { AuthService } from '../services/AuthService'
import common from '@ohos.app.ability.common'
import promptAction from '@ohos.promptAction' // 建议使用 promptAction 替代 AlertDialog，体验更好

@Entry
@Component
struct LoginPage {
  @State account: string = ''
  @State password: string = ''
  @State confirmPassword: string = ''
  @State isLoginMode: boolean = true
  @State isLoading: boolean = false
  @State showUnregisteredDialog: boolean = false
  @State showOtherLoginMethods: boolean = false

  // 验证码登录相关状态
  @State isCodeLogin: boolean = false
  @State verifyCode: string = ''
  @State generatedCode: string = ''
  @State countdown: number = 0
  private timer: number = -1

  private db: DatabaseManager = DatabaseManager.getInstance()
  private authService: AuthService = AuthService.getInstance()
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  private isDbReady: boolean = false

  aboutToAppear() {
    this.initStorage()
  }

  aboutToDisappear() {
    // 页面销毁时清理定时器
    if (this.timer !== -1) {
      clearInterval(this.timer)
    }
  }

  private async initStorage() {
    try {
      await this.db.init(this.context)
      this.isDbReady = true
      console.info('DatabaseManager初始化成功')
    } catch (error) {
      console.error('DatabaseManager初始化失败:', JSON.stringify(error))
      promptAction.showToast({ message: '数据库初始化失败，请重启应用' })
    }
  }

  // 验证账号格式
  private validateAccount(account: string): boolean {
    return account.length >= 3
  }

  // 验证密码格式
  private validatePassword(password: string): boolean {
    return password.length >= 6
  }

  // 模拟发送验证码
  private sendVerifyCode() {
    if (!this.account) {
      promptAction.showToast({ message: '请输入账号/手机号/邮箱' })
      return
    }
    // 简单模拟防抖
    if (this.countdown > 0) return

    const code = Math.floor(100000 + Math.random() * 900000).toString()
    this.generatedCode = code

    console.info(`【模拟邮件】向 ${this.account} 发送验证码: ${code}`)
    AlertDialog.show({
      title: '验证码已发送',
      message: `(模拟环境) 验证码: ${code}`,
      confirm: { value: '知道了', action: () => {} }
    })

    this.countdown = 60
    this.timer = setInterval(() => {
      this.countdown--
      if (this.countdown <= 0) {
        clearInterval(this.timer)
        this.timer = -1
      }
    }, 1000)
  }

  // 验证码登录逻辑
  private async loginByCode() {
    if (!this.isDbReady) {
      promptAction.showToast({ message: '系统正在初始化，请稍后...' })
      return
    }
    if (!this.account) {
      promptAction.showToast({ message: '请输入账号' })
      return
    }
    if (this.verifyCode !== this.generatedCode || !this.generatedCode) {
      promptAction.showToast({ message: '验证码错误或已过期' })
      return
    }

    this.isLoading = true
    try {
      let user = await this.db.getUserByAccount(this.account)
      // 如果用户不存在，自动注册
      if (!user) {
        console.info('验证码登录：用户不存在，尝试自动注册')
        // 验证码登录默认密码设为随机或特定值，这里设为'123456'方便记忆，实际应强制修改
        const registerSuccess = await this.db.registerUser(this.account, '123456')
        if (registerSuccess) {
          // 注册成功后重新获取用户对象
          user = await this.db.getUserByAccount(this.account)
        } else {
          promptAction.showToast({ message: '自动注册失败，请尝试普通注册' })
          return
        }
      }

      if (user) {
        // 保存登录状态
        this.authService.setCurrentAccount(user.account)
        promptAction.showToast({ message: '登录成功' })
        router.replaceUrl({ url: 'pages/Index' })
      }
    } catch (e) {
      console.error('验证码登录异常:', JSON.stringify(e))
      promptAction.showToast({ message: '登录出现错误，请重试' })
    } finally {
      this.isLoading = false
    }
  }

  // 普通密码登录
  private async login(): Promise<void> {
    if (this.isCodeLogin) {
      this.loginByCode()
      return
    }

    if (!this.isDbReady) {
      promptAction.showToast({ message: '系统初始化中...' })
      return
    }

    if (!this.validateAccount(this.account)) {
      promptAction.showToast({ message: '账号长度需大于3位' })
      return
    }

    if (!this.validatePassword(this.password)) {
      promptAction.showToast({ message: '密码长度需大于6位' })
      return
    }

    this.isLoading = true

    try {
      // 尝试登录
      const user = await this.db.login(this.account, this.password)

      if (user) {
        // 登录成功：写入Session，跳转
        this.authService.setCurrentAccount(user.account)
        console.info('登录成功:', user.username || user.account)
        promptAction.showToast({ message: '登录成功' })

        // 延迟跳转，提升体验
        setTimeout(() => {
          router.replaceUrl({ url: 'pages/Index' })
        }, 500)
      } else {
        // 登录失败：判断是 密码错误 还是 未注册
        const existingUser = await this.db.getUserByAccount(this.account)
        if (existingUser) {
          promptAction.showToast({ message: '密码错误，请重试' })
        } else {
          // 账号不存在，引导注册
          this.showUnregisteredDialogMsg()
        }
      }
    } catch (error) {
      console.error('登录异常:', JSON.stringify(error))
      promptAction.showToast({ message: '登录失败，系统错误' })
    } finally {
      this.isLoading = false
    }
  }

  // 注册
  private async register(): Promise<void> {
    if (!this.isDbReady) {
      promptAction.showToast({ message: '系统初始化中...' })
      return
    }
    if (!this.validateAccount(this.account)) {
      promptAction.showToast({ message: '账号长度需大于3位' })
      return
    }
    if (!this.validatePassword(this.password)) {
      promptAction.showToast({ message: '密码长度需大于6位' })
      return
    }
    if (this.password !== this.confirmPassword) {
      promptAction.showToast({ message: '两次输入的密码不一致' })
      return
    }

    this.isLoading = true

    try {
      // 检查账号是否已注册
      const existingUser = await this.db.getUserByAccount(this.account)

      if (existingUser) {
        promptAction.showToast({ message: '该账号已注册，请直接登录' })
      } else {
        // 创建新用户
        const success = await this.db.registerUser(this.account, this.password)
        if (success) {
          // 注册成功后，直接视为已登录
          this.authService.setCurrentAccount(this.account)
          promptAction.showToast({ message: '注册成功' })

          setTimeout(() => {
            router.replaceUrl({ url: 'pages/Index' })
          }, 500)
        } else {
          promptAction.showToast({ message: '注册失败，请重试' })
        }
      }
    } catch (error) {
      console.error('注册异常:', JSON.stringify(error))
      promptAction.showToast({ message: '注册发生错误' })
    } finally {
      this.isLoading = false
    }
  }

  // 切换登录/注册模式
  private toggleMode(): void {
    this.isLoginMode = !this.isLoginMode
    this.resetForm()
  }

  // 重置表单
  private resetForm(): void {
    // 保留账号，方便用户切换
    this.password = ''
    this.confirmPassword = ''
    this.verifyCode = ''
  }

  // 显示未注册提示弹窗
  private showUnregisteredDialogMsg(): void {
    this.showUnregisteredDialog = true
  }

  // 关闭提示弹窗，切换到注册模式
  private goToRegister(): void {
    this.showUnregisteredDialog = false
    this.isLoginMode = false
  }

  // 关闭提示弹窗
  private closeDialog(): void {
    this.showUnregisteredDialog = false
  }

  // ----------------------------------------------------------
  // 下面是您要求保留的前端 build() 部分，请直接粘贴您的 build 代码
  // ----------------------------------------------------------
  build() {
    // ... 请在此处粘贴您原本的 build() 代码 ...
    // 为了完整性，如果您直接覆盖文件，请确保您的 build() 方法在这里
    Stack() {
      // ... (您的前端代码)
      // 这里省略，完全复用您提供的代码即可
      Column() {
        Row() {
          Text('本网站使用Cookie功能，为您提供最佳的用户体验。了解更多')
            .fontSize(12)
            .fontColor('#999999')
            .layoutWeight(1)
            .textAlign(TextAlign.Start)
          Button('×')
            .width(30)
            .height(30)
            .backgroundColor(Color.Transparent)
            .fontColor('#999999')
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#FFFFFF')

        Row() {
          Button('←')
            .width(40)
            .height(40)
            .backgroundColor(Color.Transparent)
            .fontColor($r('app.color.text_primary'))
            .onClick(() => {
              router.replaceUrl({url:'pages/Index'})
            })

          Text(this.isCodeLogin ? '验证码登录' : '华为账号-登录')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Blank().width(40)
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)

        Scroll() {
          Column() {
            Column() {
              Row() {
                Column() {
                  Text('HUAWEI')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Color.White)
                }
                .width(60)
                .height(60)
                .backgroundColor('#CF0A2C')
                .borderRadius(12)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
              }
              .margin({ bottom: 24 })

              Text('华为账号')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.text_primary'))
                .margin({ bottom: 8 })

              Text('登录华为账号以使用云空间、华为应用及更多服务')
                .fontSize(14)
                .fontColor($r('app.color.text_secondary'))
                .margin({ bottom: 40 })
                .textAlign(TextAlign.Center)
            }
            .width('100%')
            .padding({ top: 60 })
            .alignItems(HorizontalAlign.Center)

            Column() {
              TextInput({ placeholder: '手机号/邮件地址/华为号', text: this.account })
                .width('100%')
                .height(48)
                .fontSize(16)
                .backgroundColor('#FFFFFF')
                .borderRadius(0)
                .padding({ left: 16 })
                .border({ width: 1, color: '#E5E5E5' })
                .onChange((value: string) => {
                  this.account = value
                })

              if (this.isCodeLogin) {
                Row() {
                  TextInput({ placeholder: '请输入验证码', text: this.verifyCode })
                    .layoutWeight(1)
                    .height(48)
                    .fontSize(16)
                    .backgroundColor('#FFFFFF')
                    .borderRadius(0)
                    .padding({ left: 16 })
                    .border({ width: { top: 0, right: 0, bottom: 1, left: 1 }, color: '#E5E5E5' })
                    .onChange((value) => this.verifyCode = value)

                  Button(this.countdown > 0 ? `${this.countdown}s` : '获取验证码')
                    .width(110)
                    .height(48)
                    .fontSize(14)
                    .backgroundColor('#FFFFFF')
                    .fontColor(this.countdown > 0 ? '#999' : '#007DFF')
                    .borderRadius(0)
                    .border({ width: { top: 0, right: 1, bottom: 1, left: 0 }, color: '#E5E5E5' })
                    .enabled(this.countdown === 0)
                    .onClick(() => this.sendVerifyCode())
                }
                .width('100%')
              } else {
                TextInput({ placeholder: '密码', text: this.password })
                  .width('100%')
                  .height(48)
                  .fontSize(16)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(0)
                  .padding({ left: 16 })
                  .border({
                    width: { top: 0, right: 1, bottom: 1, left: 1 },
                    color: '#E5E5E5',
                    style: BorderStyle.Solid
                  })
                  .type(InputType.Password)
                  .onChange((value: string) => {
                    this.password = value
                  })
              }

              if (!this.isLoginMode && !this.isCodeLogin) {
                TextInput({ placeholder: '确认密码', text: this.confirmPassword })
                  .width('100%')
                  .height(48)
                  .fontSize(16)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(0)
                  .padding({ left: 16 })
                  .border({
                    width: { top: 0, right: 1, bottom: 1, left: 1 },
                    color: '#E5E5E5',
                    style: BorderStyle.Solid
                  })
                  .type(InputType.Password)
                  .onChange((value: string) => {
                    this.confirmPassword = value
                  })
              }

              Row() {
                Text(this.isCodeLogin ? '密码登录' : '短信验证码登录')
                  .fontSize(14)
                  .fontColor('#007DFF')
                  .layoutWeight(1)
                  .textAlign(TextAlign.Start)
                  .onClick(() => {
                    this.isCodeLogin = !this.isCodeLogin
                    this.isLoginMode = true
                  })

                if (!this.isCodeLogin) {
                  Text('忘记密码')
                    .fontSize(14)
                    .fontColor('#007DFF')
                    .margin({ right: 16 })

                  Text(this.isLoginMode ? '立即注册' : '返回登录')
                    .fontSize(14)
                    .fontColor('#007DFF')
                    .textAlign(TextAlign.End)
                    .onClick(() => this.toggleMode())
                }
              }
              .width('100%')
              .margin({ top: 16, bottom: 24 })

              Button(this.isCodeLogin ? '登录 / 注册' : (this.isLoginMode ? '登录' : '注册'))
                .width('100%')
                .height(50)
                .fontSize(16)
                .backgroundColor('#007DFF')
                .fontColor(Color.White)
                .borderRadius(0)
                .enabled(!this.isLoading)
                .onClick(() => {
                  if (this.isLoginMode) {
                    this.login()
                  } else {
                    this.register()
                  }
                })

              if (this.isLoading) {
                Row() {
                  LoadingProgress()
                    .width(20)
                    .height(20)
                  Text(this.isLoginMode ? '登录中...' : '注册中...')
                    .fontSize(14)
                    .fontColor($r('app.color.text_secondary'))
                    .margin({ left: 8 })
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
                .margin({ top: 16 })
              }
            }
            .width('100%')
            .padding(24)

            Row() {
              Text(this.showOtherLoginMethods ? '收起其他登录方式' : '其他登录方式')
                .fontSize(14)
                .fontColor('#666666')
                .onClick(() => this.showOtherLoginMethods = !this.showOtherLoginMethods)
            }
            .width('100%')
            .margin({ top: 16, bottom: 16 })
            .justifyContent(FlexAlign.Center)

            if (this.showOtherLoginMethods) {
              Column() {
                Text('第三方账号登录')
                  .fontSize(16)
                  .fontColor('#666666')
                  .margin({ bottom: 16 })

                Row() {
                  Column() {
                    Text('💬')
                      .fontSize(48)
                    Text('微信')
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ top: 8 })
                  }
                  .width('33.33%')
                  .alignItems(HorizontalAlign.Center)

                  Column() {
                    Text('🐧')
                      .fontSize(48)
                    Text('QQ')
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ top: 8 })
                  }
                  .width('33.33%')
                  .alignItems(HorizontalAlign.Center)

                  Column() {
                    Text('📱')
                      .fontSize(48)
                    Text('微博')
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ top: 8 })
                  }
                  .width('33.33%')
                  .alignItems(HorizontalAlign.Center)
                }
              }
              .width('100%')
              .padding(24)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
              .shadow({
                radius: 10,
                color: 'rgba(0, 0, 0, 0.08)',
                offsetX: 0,
                offsetY: 2
              })
              .margin({ bottom: 20 })
            }

            if (this.isLoginMode && !this.isCodeLogin) {
              Button('注册账号')
                .width('100%')
                .height(50)
                .fontSize(16)
                .backgroundColor(Color.Transparent)
                .fontColor('#007DFF')
                .border({ width: 1, color: '#007DFF' })
                .borderRadius(0)
                .margin({ left: 24, right: 24, bottom: 40 })
                .onClick(() => this.toggleMode())
            }
          }
          .width('100%')
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')

      if (this.showUnregisteredDialog) {
        Column() {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.5)')
            .onClick(() => {
              this.closeDialog()
            })

          Column() {
            Text('⚠️')
              .fontSize(48)
              .fontColor('#faad14')
              .margin({ bottom: 16 })

            Text('您未注册')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .margin({ bottom: 8 })

            Text('该账号未注册，是否现在注册？')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ bottom: 24 })

            Row() {
              Button('取消')
                .height(44)
                .fontSize(16)
                .backgroundColor($r('app.color.background'))
                .fontColor($r('app.color.text_primary'))
                .layoutWeight(1)
                .margin({ right: 8 })
                .onClick(() => {
                  this.closeDialog()
                })

              Button('立即注册')
                .height(44)
                .fontSize(16)
                .backgroundColor($r('app.color.primary'))
                .fontColor(Color.White)
                .layoutWeight(1)
                .margin({ left: 8 })
                .onClick(() => {
                  this.goToRegister()
                })
            }
            .width('100%')
          }
          .width(300)
          .backgroundColor($r('app.color.white'))
          .borderRadius(12)
          .padding(24)
          .position({ x: '50%', y: '50%' })
          .translate({ x: '-50%', y: '-50%' })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(1000)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}