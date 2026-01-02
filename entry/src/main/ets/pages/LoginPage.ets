import router from '@ohos.router'
import promptAction from '@ohos.promptAction' // ✅ 补充提示工具
import { User } from '../model/DataModel'
import { DatabaseManager, UserProfilePatch } from '../database/DatabaseManager'
import { AuthService } from '../services/AuthService'
import common from '@ohos.app.ability.common'
import notification from '@ohos.notification'

// ✅ 规范化通知接口定义，确保符合 ArkTS 检查
interface VerifyCodeNormalContent {
  title: string
  text: string
}

interface VerifyCodeNotificationContent {
  contentType: notification.ContentType
  normal: VerifyCodeNormalContent
}

interface VerifyCodeNotificationRequest {
  id: number
  slotType: notification.SlotType
  content: VerifyCodeNotificationContent
}

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

  aboutToAppear() {
    this.initStorage()
  }

  aboutToDisappear() {
    this.clearCountdownTimer()
  }

  private clearCountdownTimer() {
    if (this.timer !== -1) {
      clearInterval(this.timer)
      this.timer = -1
    }
  }

  private async initStorage() {
    try {
      await this.db.init(this.context)
    } catch (error) {
      console.error('DatabaseManager初始化失败:', error)
    }
  }

  private validateAccount(account: string): boolean {
    return account.length >= 3
  }

  private validatePassword(password: string): boolean {
    return password.length >= 6
  }

  // ✅ 逻辑修正：发布通知的逻辑更加严谨
  private async publishVerifyCodeNotification(code: string) {
    try {
      const request: VerifyCodeNotificationRequest = {
        id: Math.floor(Math.random() * 1000),
        slotType: notification.SlotType.SERVICE_INFORMATION,
        content: {
          contentType: notification.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: '验证码通知',
            text: `您的登录验证码是：${code}，请勿泄露。`
          }
        }
      }

      await notification.publish(request)
    } catch (e) {
      console.error('发送验证码通知失败:', e)
    }
  }

  private sendVerifyCode() {
    if (!this.account) {
      return
    }

    const code = Math.floor(100000 + Math.random() * 900000).toString()
    this.generatedCode = code
    this.publishVerifyCodeNotification(code)

    this.countdown = 60
    this.clearCountdownTimer()
    this.timer = setInterval(() => {
      this.countdown--
      if (this.countdown <= 0) {
        this.clearCountdownTimer()
      }
    }, 1000)
  }

  private async loginByCode() {
    if (this.verifyCode !== this.generatedCode || !this.generatedCode) {
      return
    }
    this.isLoading = true
    try {
      let user = await this.db.getUserByAccount(this.account)
      if (!user) {
        const success = await this.db.registerUser(this.account, '123456')
        if (success) {
          user = await this.db.getUserByAccount(this.account)
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

  private async login(): Promise<void> {
    if (this.isCodeLogin) {
      await this.loginByCode() // ✅ 修正：必须加 await
      return
    }

    if (!this.validateAccount(this.account)) return
    if (!this.validatePassword(this.password)) return

    this.isLoading = true

    try {
      const user = await this.db.login(this.account, this.password)
      if (user) {
        this.authService.setCurrentAccount(user.account)
        router.replaceUrl({ url: 'pages/Index' })
      } else {
        const existingUser = await this.db.getUserByAccount(this.account)
        if (!existingUser) {
          this.showUnregisteredDialogMsg()
        }
      }
    } catch (error) {
      console.error('登录失败:', error)
    } finally {
      this.isLoading = false
    }
  }

  private async register(): Promise<void> {
    if (!this.validateAccount(this.account)) return
    if (!this.validatePassword(this.password)) return
    if (this.password !== this.confirmPassword) return

    this.isLoading = true
    try {
      const existingUser = await this.db.getUserByAccount(this.account)
      if (!existingUser) {
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

  private toggleMode(): void {
    this.isLoginMode = !this.isLoginMode
    this.resetForm()
  }

  private resetForm(): void {
    this.account = ''; this.password = ''; this.confirmPassword = ''
    this.verifyCode = ''; this.generatedCode = ''; this.countdown = 0
    this.clearCountdownTimer()
  }

  private showUnregisteredDialogMsg(): void { this.showUnregisteredDialog = true }
  private goToRegister(): void { this.showUnregisteredDialog = false; this.isLoginMode = false }
  private closeDialog(): void { this.showUnregisteredDialog = false }

  // ----------------------------------------------------------------
  // ✅ UI 部分：严格保留你提供的所有前端代码，不改动任何布局和样式
  // ----------------------------------------------------------------
  build() {
    Stack() {
      Column() {
        Row() {
          Text('本网站使用Cookie功能，为您提供最佳的用户体验。了解更多')
            .fontSize(12).fontColor('#999999').layoutWeight(1).textAlign(TextAlign.Start)
          Button('×').width(30).height(30).backgroundColor(Color.Transparent).fontColor('#999999')
        }.width('100%').padding(12).backgroundColor('#FFFFFF')

        Row() {
          Button('←').width(40).height(40).backgroundColor(Color.Transparent).fontColor($r('app.color.text_primary'))
            .onClick(() => { router.replaceUrl({url:'pages/Index'}) })
          Text(this.isCodeLogin ? '验证码登录' : '华为账号-登录').fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center)
          Blank().width(40)
        }.width('100%').height(56).padding({ left: 16, right: 16 }).justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)

        Scroll() {
          Column() {
            Column() {
              Row() {
                Column() {
                  Text('HUAWEI').fontSize(16).fontWeight(FontWeight.Bold).fontColor(Color.White)
                }.width(60).height(60).backgroundColor('#CF0A2C').borderRadius(12).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
              }.margin({ bottom: 24 })
              Text('华为账号').fontSize(24).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary')).margin({ bottom: 8 })
              Text('登录华为账号以使用云空间、华为应用及更多服务').fontSize(14).fontColor($r('app.color.text_secondary')).margin({ bottom: 40 }).textAlign(TextAlign.Center)
            }.width('100%').padding({ top: 60 }).alignItems(HorizontalAlign.Center)

            Column() {
              TextInput({ placeholder: '手机号/邮件地址/华为号', text: this.account }).width('100%').height(48).fontSize(16).backgroundColor('#FFFFFF').borderRadius(0).padding({ left: 16 }).border({ width: 1, color: '#E5E5E5' }).onChange((value) => { this.account = value })

              if (this.isCodeLogin) {
                Row() {
                  TextInput({ placeholder: '请输入验证码', text: this.verifyCode }).layoutWeight(1).height(48).fontSize(16).backgroundColor('#FFFFFF').borderRadius(0).padding({ left: 16 }).border({ width: { top: 0, right: 0, bottom: 1, left: 1 }, color: '#E5E5E5' }).onChange((value) => this.verifyCode = value)
                  Button(this.countdown > 0 ? `${this.countdown}s` : '获取验证码').width(110).height(48).fontSize(14).backgroundColor('#FFFFFF').fontColor(this.countdown > 0 ? '#999' : '#007DFF').borderRadius(0).border({ width: { top: 0, right: 1, bottom: 1, left: 0 }, color: '#E5E5E5' }).enabled(this.countdown === 0).onClick(() => this.sendVerifyCode())
                }.width('100%')
              } else {
                TextInput({ placeholder: '密码', text: this.password }).width('100%').height(48).fontSize(16).backgroundColor('#FFFFFF').borderRadius(0).padding({ left: 16 }).border({ width: { top: 0, right: 1, bottom: 1, left: 1 }, color: '#E5E5E5', style: BorderStyle.Solid }).type(InputType.Password).onChange((value) => { this.password = value })
              }

              if (!this.isLoginMode && !this.isCodeLogin) {
                TextInput({ placeholder: '确认密码', text: this.confirmPassword }).width('100%').height(48).fontSize(16).backgroundColor('#FFFFFF').borderRadius(0).padding({ left: 16 }).border({ width: { top: 0, right: 1, bottom: 1, left: 1 }, color: '#E5E5E5', style: BorderStyle.Solid }).type(InputType.Password).onChange((value) => { this.confirmPassword = value })
              }

              Row() {
                Text(this.isCodeLogin ? '密码登录' : '短信验证码登录').fontSize(14).fontColor('#007DFF').layoutWeight(1).textAlign(TextAlign.Start).onClick(() => { this.isCodeLogin = !this.isCodeLogin; this.isLoginMode = true })
                if (!this.isCodeLogin) {
                  Text('忘记密码').fontSize(14).fontColor('#007DFF').margin({ right: 16 })
                  Text(this.isLoginMode ? '立即注册' : '返回登录').fontSize(14).fontColor('#007DFF').textAlign(TextAlign.End).onClick(() => this.toggleMode())
                }
              }.width('100%').margin({ top: 16, bottom: 24 })

              Button(this.isCodeLogin ? '登录 / 注册' : (this.isLoginMode ? '登录' : '注册')).width('100%').height(50).fontSize(16).backgroundColor('#007DFF').fontColor(Color.White).borderRadius(0).enabled(!this.isLoading)
                .onClick(() => { if (this.isLoginMode) { this.login() } else { this.register() } })

              if (this.isLoading) {
                Row() { LoadingProgress().width(20).height(20); Text(this.isLoginMode ? '登录中...' : '注册中...').fontSize(14).fontColor($r('app.color.text_secondary')).margin({ left: 8 }) }.width('100%').justifyContent(FlexAlign.Center).margin({ top: 16 })
              }
            }.width('100%').padding(24)

            Row() { Text(this.showOtherLoginMethods ? '收起其他登录方式' : '其他登录方式').fontSize(14).fontColor('#666666').onClick(() => this.showOtherLoginMethods = !this.showOtherLoginMethods) }.width('100%').margin({ top: 16, bottom: 16 }).justifyContent(FlexAlign.Center)

            if (this.showOtherLoginMethods) {
              Column() {
                Text('第三方账号登录').fontSize(16).fontColor('#666666').margin({ bottom: 16 })
                Row() {
                  this.ThirdPartyItem('💬', '微信'); this.ThirdPartyItem('🐧', 'QQ'); this.ThirdPartyItem('📱', '微博')
                }
              }.width('100%').padding(24).backgroundColor('#FFFFFF').borderRadius(12).shadow({ radius: 10, color: 'rgba(0, 0, 0, 0.08)', offsetX: 0, offsetY: 2 }).margin({ bottom: 20 })
            }

            if (this.isLoginMode && !this.isCodeLogin) {
              Button('注册账号').width('100%').height(50).fontSize(16).backgroundColor(Color.Transparent).fontColor('#007DFF').border({ width: 1, color: '#007DFF' }).borderRadius(0).margin({ left: 24, right: 24, bottom: 40 }).onClick(() => this.toggleMode())
            }
          }.width('100%')
        }.width('100%').layoutWeight(1).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)
      }.width('100%').height('100%')

      if (this.showUnregisteredDialog) {
        this.UnregisteredDialog()
      }
    }.width('100%').height('100%').backgroundColor($r('app.color.background'))
  }

  @Builder ThirdPartyItem(icon: string, label: string) {
    Column() { Text(icon).fontSize(48); Text(label).fontSize(14).fontColor('#666666').margin({ top: 8 }) }.width('33.33%').alignItems(HorizontalAlign.Center)
  }

  @Builder UnregisteredDialog() {
    Stack() {
      Column().width('100%').height('100%').backgroundColor('rgba(0,0,0,0.5)').onClick(() => this.closeDialog())
      Column() {
        Text('⚠️').fontSize(48).fontColor('#faad14').margin({ bottom: 16 })
        Text('您未注册').fontSize(18).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary')).margin({ bottom: 8 })
        Text('该账号未注册，是否现在注册？').fontSize(14).fontColor($r('app.color.text_secondary')).margin({ bottom: 24 })
        Row() {
          Button('取消').height(44).fontSize(16).backgroundColor($r('app.color.background')).fontColor($r('app.color.text_primary')).layoutWeight(1).margin({ right: 8 }).onClick(() => this.closeDialog())
          Button('立即注册').height(44).fontSize(16).backgroundColor($r('app.color.primary')).fontColor(Color.White).layoutWeight(1).margin({ left: 8 }).onClick(() => this.goToRegister())
        }.width('100%')
      }.width(300).backgroundColor($r('app.color.white')).borderRadius(12).padding(24)
    }.width('100%').height('100%').zIndex(1000)
  }
}