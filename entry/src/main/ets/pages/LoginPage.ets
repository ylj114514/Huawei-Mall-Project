import router from '@ohos.router'
import { User } from '../model/DataModel'
// ✅ 使用 DatabaseManager
import { DatabaseManager } from '../database/DatabaseManager'
// ✅ 使用 AuthService
import { AuthService } from '../services/AuthService'
import common from '@ohos.app.ability.common'

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

  // ✅ 新增：验证码登录相关状态
  @State isCodeLogin: boolean = false
  @State verifyCode: string = ''
  @State generatedCode: string = ''
  @State countdown: number = 0
  private timer: number = -1

  private db: DatabaseManager = DatabaseManager.getInstance()
  private authService: AuthService = AuthService.getInstance()
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  aboutToAppear() {
    this.initStorage()
  }

  private async initStorage() {
    try {
      await this.db.init(this.context)
      console.info('DatabaseManager初始化成功')
    } catch (error) {
      console.error('DatabaseManager初始化失败:', error)
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

  // ✅ 新增：模拟发送验证码
  private sendVerifyCode() {
    if (!this.account) {
      AlertDialog.show({ message: '请输入账号/手机号/邮箱' })
      return
    }
    const code = Math.floor(100000 + Math.random() * 900000).toString()
    this.generatedCode = code

    // 技巧：打印到控制台
    console.info(`【模拟邮件】向 ${this.account} 发送验证码: ${code}`)
    AlertDialog.show({
      title: '验证码已发送',
      message: `(模拟环境) 验证码: ${code}\n已发送至Log控制台`,
      confirm: { value: '知道了', action: () => {} }
    })

    this.countdown = 60
    this.timer = setInterval(() => {
      this.countdown--
      if (this.countdown <= 0) {
        clearInterval(this.timer)
      }
    }, 1000)
  }

  // ✅ 新增：验证码登录逻辑
  private async loginByCode() {
    if (this.verifyCode !== this.generatedCode || !this.generatedCode) {
      AlertDialog.show({ message: '验证码错误' })
      return
    }
    this.isLoading = true
    try {
      let user = await this.db.getUserByAccount(this.account)
      if (!user) {
        // 自动注册
        const success = await this.db.registerUser(this.account, '123456')
        if (success) {
          user = await this.db.getUserByAccount(this.account)
          console.info('验证码登录：自动注册新用户')
        }
      }
      if (user) {
        this.authService.setCurrentAccount(user.account)
        router.replaceUrl({ url: 'pages/Index' })
      }
    } catch (e) {
      console.error('验证码登录失败', e)
    } finally {
      this.isLoading = false
    }
  }

  // 登录
  private async login(): Promise<void> {
    // ✅ 如果是验证码模式，走验证码逻辑
    if (this.isCodeLogin) {
      this.loginByCode()
      return
    }

    if (!this.validateAccount(this.account)) {
      console.error('请输入正确的账号格式')
      return
    }

    if (!this.validatePassword(this.password)) {
      console.error('密码至少6位')
      return
    }

    this.isLoading = true

    try {
      // ✅ 使用 DatabaseManager
      const user = await this.db.login(this.account, this.password)

      if (user) {
        // 登录成功
        this.authService.setCurrentAccount(user.account)
        console.info('登录成功:', user.username)
        // ✅ 修正跳转
        router.replaceUrl({ url: 'pages/Index' })
      } else {
        const existingUser = await this.db.getUserByAccount(this.account)
        if (existingUser) {
          AlertDialog.show({ message: '密码错误' })
        } else {
          this.showUnregisteredDialogMsg()
        }
      }
    } catch (error) {
      console.error('登录失败:', error)
    } finally {
      this.isLoading = false
    }
  }

  // 注册
  private async register(): Promise<void> {
    if (!this.validateAccount(this.account)) return

    if (!this.validatePassword(this.password)) return

    if (this.password !== this.confirmPassword) {
      AlertDialog.show({ message: '两次密码不一致' })
      return
    }

    this.isLoading = true

    try {
      // 检查账号是否已注册
      const existingUser = await this.db.getUserByAccount(this.account)

      if (existingUser) {
        AlertDialog.show({ message: '该账号已注册' })
      } else {
        // 创建新用户
        const success = await this.db.registerUser(this.account, this.password)
        if (success) {
          this.authService.setCurrentAccount(this.account)
          router.replaceUrl({ url: 'pages/Index' })
        }
      }
    } catch (error) {
      console.error('注册失败:', error)
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
    this.account = ''
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

  build() {
    Stack() {
      // 主要内容
      Column() {
        // Cookie提示条 (保留)
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

        // 顶部导航 (保留)
        Row() {
          Button('←')
            .width(40)
            .height(40)
            .backgroundColor(Color.Transparent)
            .fontColor($r('app.color.text_primary'))
            .onClick(() => {
              // ✅ 修正跳转
              router.replaceUrl({url:'pages/Index'})
            })

          // ✅ 标题动态显示
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

        // 主要内容区域
        Scroll() {
          Column() {
            // Logo和标题 (保留)
            Column() {
              // 华为Logo
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

            // 表单区域
            Column() {
              // 账号输入 (通用)
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

              // ✅ 根据模式显示不同输入框
              if (this.isCodeLogin) {
                // 验证码模式
                Row() {
                  TextInput({ placeholder: '请输入验证码', text: this.verifyCode })
                    .layoutWeight(1)
                    .height(48)
                    .fontSize(16)
                    .backgroundColor('#FFFFFF')
                    .borderRadius(0)
                    .padding({ left: 16 })
                    // ✅ 修复：使用正确的 border 语法
                    .border({ width: { top: 0, right: 0, bottom: 1, left: 1 }, color: '#E5E5E5' })
                    .onChange((value) => this.verifyCode = value)

                  Button(this.countdown > 0 ? `${this.countdown}s` : '获取验证码')
                    .width(110)
                    .height(48)
                    .fontSize(14)
                    .backgroundColor('#FFFFFF')
                    .fontColor(this.countdown > 0 ? '#999' : '#007DFF')
                    .borderRadius(0)
                    // ✅ 修复：使用正确的 border 语法
                    .border({ width: { top: 0, right: 1, bottom: 1, left: 0 }, color: '#E5E5E5' })
                    .enabled(this.countdown === 0)
                    .onClick(() => this.sendVerifyCode())
                }
                .width('100%')
              } else {
                // 密码模式
                TextInput({ placeholder: '密码', text: this.password })
                  .width('100%')
                  .height(48)
                  .fontSize(16)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(0)
                  .padding({ left: 16 })
                  // ✅ 修复：修复 borderTop 报错，使用标准 border 写法
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

              // 确认密码（仅注册模式）
              if (!this.isLoginMode && !this.isCodeLogin) {
                TextInput({ placeholder: '确认密码', text: this.confirmPassword })
                  .width('100%')
                  .height(48)
                  .fontSize(16)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(0)
                  .padding({ left: 16 })
                  // ✅ 修复：同上，移除 borderTop
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

              // 辅助链接
              Row() {
                // ✅ 切换模式按钮
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

              // 登录/注册按钮
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

              // 加载状态
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

            // 其他登录方式切换按钮 (保留)
            Row() {
              Text(this.showOtherLoginMethods ? '收起其他登录方式' : '其他登录方式')
                .fontSize(14)
                .fontColor('#666666')
                .onClick(() => this.showOtherLoginMethods = !this.showOtherLoginMethods)
            }
            .width('100%')
            .margin({ top: 16, bottom: 16 })
            .justifyContent(FlexAlign.Center)

            // 其他登录方式卡片 (保留)
            if (this.showOtherLoginMethods) {
              Column() {
                Text('第三方账号登录')
                  .fontSize(16)
                  .fontColor('#666666')
                  .margin({ bottom: 16 })

                Row() {
                  // 微信登录
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

                  // QQ登录
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

                  // 微博登录
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

            // 底部注册按钮 - 登录模式下显示 (保留)
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

      // 未注册提示弹窗 (保留)
      if (this.showUnregisteredDialog) {
        Column() {
          // 遮罩层
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.5)')
            .onClick(() => {
              this.closeDialog()
            })

          // 弹窗内容
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