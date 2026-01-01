import router from '@ohos.router'
import { User } from '../model/DataModel'
import { DatabaseManager } from '../database/DatabaseManager'
import { AuthService } from '../services/AuthService'
import common from '@ohos.app.ability.common'
import promptAction from '@ohos.promptAction'
import notificationManager from '@ohos.notificationManager';
import notification from '@ohos.notification';

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

  // 验证码登录相关
  @State isCodeLogin: boolean = true
  @State verifyCode: string = ''
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
    if (this.timer !== -1) {
      clearInterval(this.timer)
    }
  }

  private async initStorage() {
    try {
      await this.db.init(this.context)
      this.isDbReady = true
    } catch (error) {
      // 忽略
    }
  }

  // ✅ 核心修改：发送验证码逻辑
  private async sendVerifyCode() {
    if (this.account.length === 0) {
      promptAction.showToast({ message: '请输入手机号' })
      return
    }
    if (this.countdown > 0) return

    promptAction.showToast({ message: '正在请求验证码...' })

    try {
      // 1. 调用 AuthService 发送请求 (连接华为云)
      await this.authService.requestVerifyCode('86', this.account);
      promptAction.showToast({ message: '请求成功' })

      // 2. 模拟弹窗通知 (这里保留您的原逻辑，方便给老师演示)
      this.showSimulationNotification();

      // 3. 开始倒计时
      this.startCountdown();

    } catch (error) {
      console.error('发送验证码出错:', JSON.stringify(error));
      // 为了演示流畅，即使报错也提示检查网络
      promptAction.showToast({ message: '发送请求异常，请检查网络或配置' });
      // 如果是为了测试UI，您可以取消下面这一行的注释强制倒计时：
      // this.startCountdown();
    }
  }

  // ✅ 核心修改：验证码登录逻辑
  private async loginByCode() {
    if (!this.account) {
      promptAction.showToast({ message: '请输入手机号' })
      return
    }
    if (!this.verifyCode) {
      promptAction.showToast({ message: '请输入验证码' })
      return
    }

    this.isLoading = true

    try {
      // 调用 AuthService 进行真实登录
      const success = await this.authService.loginWithPhone('86', this.account, this.verifyCode);

      if (success) {
        promptAction.showToast({ message: '登录成功' })
        setTimeout(() => {
          router.replaceUrl({ url: 'pages/Index' })
        }, 500)
      } else {
        promptAction.showToast({ message: '登录失败' })
      }
    } catch (e) {
      console.error('登录异常:', JSON.stringify(e));
      promptAction.showToast({ message: '验证码错误或过期' })
    } finally {
      this.isLoading = false
    }
  }

  // 辅助：模拟通知 (保持不变)
  private async showSimulationNotification() {
    try {
      const isEnabled = await notificationManager.isNotificationEnabled();
      if (!isEnabled) {
        promptAction.showDialog({
          title: '测试提示',
          message: '验证码已发送 (测试码: 666666)',
          buttons: [{ text: '好的', color: '#007AFF' }]
        });
        return;
      }
      let notificationRequest: notificationManager.NotificationRequest = {
        id: 1001,
        content: {
          contentType: notification.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: '【华为商城】安全验证',
            text: `您的验证码是：666666`,
            additionalText: '测试模式'
          }
        }
      }
      await notificationManager.publish(notificationRequest)
    } catch (err) {}
  }

  private startCountdown() {
    this.countdown = 60
    this.timer = setInterval(() => {
      this.countdown--
      if (this.countdown <= 0) {
        clearInterval(this.timer)
        this.timer = -1
        this.countdown = 0
      }
    }, 1000)
  }

  // -----------------------------------------------------------------------
  // ⬇️ 下方代码保持原样 (密码登录、注册逻辑、UI构建) ⬇️
  // -----------------------------------------------------------------------

  private async login(): Promise<void> {
    if (this.isCodeLogin) {
      this.loginByCode()
      return
    }
    if (!this.isDbReady) return
    this.isLoading = true
    try {
      const user = await this.db.login(this.account, this.password)
      if (user) {
        promptAction.showToast({ message: '登录成功' })
        setTimeout(() => { router.replaceUrl({ url: 'pages/Index' }) }, 500)
      } else {
        const exists = await this.db.getUserByAccount(this.account)
        if (exists) promptAction.showToast({ message: '密码错误' })
        else this.showUnregisteredDialogMsg()
      }
    } catch (error) {
      promptAction.showToast({ message: '系统错误' })
    } finally {
      this.isLoading = false
    }
  }

  private async register(): Promise<void> {
    if (!this.isDbReady) return
    if (this.password !== this.confirmPassword) {
      promptAction.showToast({ message: '密码不一致' })
      return
    }
    this.isLoading = true
    try {
      const exists = await this.db.getUserByAccount(this.account)
      if (exists) {
        promptAction.showToast({ message: '账号已存在' })
      } else {
        const success = await this.db.registerUser(this.account, this.password)
        if (success) {
          promptAction.showToast({ message: '注册成功' })
          setTimeout(() => { router.replaceUrl({ url: 'pages/Index' }) }, 500)
        }
      }
    } catch (error) {
      promptAction.showToast({ message: '注册错误' })
    } finally {
      this.isLoading = false
    }
  }

  private toggleMode(): void {
    this.isLoginMode = !this.isLoginMode
    this.resetForm()
  }

  private resetForm(): void {
    this.password = ''
    this.confirmPassword = ''
    this.verifyCode = ''
  }

  private showUnregisteredDialogMsg(): void {
    this.showUnregisteredDialog = true
  }

  private goToRegister(): void {
    this.showUnregisteredDialog = false
    this.isLoginMode = false
  }

  private closeDialog(): void {
    this.showUnregisteredDialog = false
  }

  // ⚠️ 重点：此 build 方法完全保留了您原版的前端代码，未做修改
  build() {
    Stack() {
      Column() {
        Row() {
          Text('本网站使用Cookie功能，为您提供最佳的用户体验。了解更多')
            .fontSize(12).fontColor('#999').layoutWeight(1).textAlign(TextAlign.Start)
          Button('×').width(30).height(30).backgroundColor(Color.Transparent).fontColor('#999')
        }
        .width('100%').padding(12).backgroundColor('#FFFFFF')

        Row() {
          Button('←').width(40).height(40).backgroundColor(Color.Transparent).fontColor($r('app.color.text_primary'))
            .onClick(() => { router.replaceUrl({url:'pages/Index'}) })
          Text(this.isCodeLogin ? '验证码登录' : '华为账号-登录')
            .fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center)
          Blank().width(40)
        }
        .width('100%').height(56).padding({ left: 16, right: 16 }).justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)

        Scroll() {
          Column() {
            Column() {
              Row() {
                Column() {
                  Text('HUAWEI').fontSize(16).fontWeight(FontWeight.Bold).fontColor(Color.White)
                }
                .width(60).height(60).backgroundColor('#CF0A2C').borderRadius(12)
                .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
              }
              .margin({ bottom: 24 })

              Text('华为账号').fontSize(24).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary')).margin({ bottom: 8 })
              Text('登录华为账号以使用云空间、华为应用及更多服务').fontSize(14).fontColor($r('app.color.text_secondary')).margin({ bottom: 40 }).textAlign(TextAlign.Center)
            }
            .width('100%').padding({ top: 60 }).alignItems(HorizontalAlign.Center)

            Column() {
              TextInput({ placeholder: '手机号/邮件地址/华为号', text: this.account })
                .width('100%').height(48).fontSize(16).backgroundColor('#FFFFFF').borderRadius(0).padding({ left: 16 })
                .border({ width: 1, color: '#E5E5E5' }).onChange((value) => { this.account = value })

              if (this.isCodeLogin) {
                Row() {
                  TextInput({ placeholder: '请输入验证码', text: this.verifyCode })
                    .layoutWeight(1).height(48).fontSize(16).backgroundColor('#FFFFFF').borderRadius(0).padding({ left: 16 })
                    .border({ width: { top: 0, right: 0, bottom: 1, left: 1 }, color: '#E5E5E5' }).onChange((value) => this.verifyCode = value)
                  Button(this.countdown > 0 ? `${this.countdown}s` : '获取验证码')
                    .width(110).height(48).fontSize(14).backgroundColor('#FFFFFF').fontColor(this.countdown > 0 ? '#999' : '#007DFF')
                    .borderRadius(0).border({ width: { top: 0, right: 1, bottom: 1, left: 0 }, color: '#E5E5E5' })
                    .enabled(this.countdown === 0).onClick(() => this.sendVerifyCode())
                }
                .width('100%')
              } else {
                TextInput({ placeholder: '密码', text: this.password })
                  .width('100%').height(48).fontSize(16).backgroundColor('#FFFFFF').borderRadius(0).padding({ left: 16 })
                  .border({ width: { top: 0, right: 1, bottom: 1, left: 1 }, color: '#E5E5E5' }).type(InputType.Password)
                  .onChange((value) => { this.password = value })
              }

              if (!this.isLoginMode && !this.isCodeLogin) {
                TextInput({ placeholder: '确认密码', text: this.confirmPassword })
                  .width('100%').height(48).fontSize(16).backgroundColor('#FFFFFF').borderRadius(0).padding({ left: 16 })
                  .border({ width: { top: 0, right: 1, bottom: 1, left: 1 }, color: '#E5E5E5' }).type(InputType.Password)
                  .onChange((value) => { this.confirmPassword = value })
              }

              Row() {
                Text(this.isCodeLogin ? '密码登录' : '短信验证码登录')
                  .fontSize(14).fontColor('#007DFF').layoutWeight(1).textAlign(TextAlign.Start)
                  .onClick(() => { this.isCodeLogin = !this.isCodeLogin; this.isLoginMode = true })

                if (!this.isCodeLogin) {
                  Text('忘记密码').fontSize(14).fontColor('#007DFF').margin({ right: 16 })
                  Text(this.isLoginMode ? '立即注册' : '返回登录').fontSize(14).fontColor('#007DFF').textAlign(TextAlign.End)
                    .onClick(() => this.toggleMode())
                }
              }
              .width('100%').margin({ top: 16, bottom: 24 })

              Button(this.isCodeLogin ? '登录 / 注册' : (this.isLoginMode ? '登录' : '注册'))
                .width('100%').height(50).fontSize(16).backgroundColor('#007DFF').fontColor(Color.White).borderRadius(0)
                .enabled(!this.isLoading).onClick(() => { if (this.isLoginMode) this.login(); else this.register() })

              if (this.isLoading) {
                Row() {
                  LoadingProgress().width(20).height(20)
                  Text(this.isLoginMode ? '登录中...' : '注册中...').fontSize(14).fontColor($r('app.color.text_secondary')).margin({ left: 8 })
                }
                .width('100%').justifyContent(FlexAlign.Center).margin({ top: 16 })
              }
            }
            .width('100%').padding(24)

            Row() {
              Text(this.showOtherLoginMethods ? '收起其他登录方式' : '其他登录方式').fontSize(14).fontColor('#666')
                .onClick(() => this.showOtherLoginMethods = !this.showOtherLoginMethods)
            }
            .width('100%').margin({ top: 16, bottom: 16 }).justifyContent(FlexAlign.Center)

            if (this.showOtherLoginMethods) {
              Column() {
                Text('第三方账号登录').fontSize(16).fontColor('#666').margin({ bottom: 16 })
                Row() {
                  Column() { Text('💬').fontSize(48); Text('微信').fontSize(14).fontColor('#666').margin({ top: 8 }) }.width('33.33%').alignItems(HorizontalAlign.Center)
                  Column() { Text('🐧').fontSize(48); Text('QQ').fontSize(14).fontColor('#666').margin({ top: 8 }) }.width('33.33%').alignItems(HorizontalAlign.Center)
                  Column() { Text('📱').fontSize(48); Text('微博').fontSize(14).fontColor('#666').margin({ top: 8 }) }.width('33.33%').alignItems(HorizontalAlign.Center)
                }
              }
              .width('100%').padding(24).backgroundColor('#FFFFFF').borderRadius(12).shadow({ radius: 10, color: 'rgba(0,0,0,0.08)', offsetY: 2 }).margin({ bottom: 20 })
            }

            if (this.isLoginMode && !this.isCodeLogin) {
              Button('注册账号').width('100%').height(50).fontSize(16).backgroundColor(Color.Transparent)
                .fontColor('#007DFF').border({ width: 1, color: '#007DFF' }).borderRadius(0).margin({ left: 24, right: 24, bottom: 40 })
                .onClick(() => this.toggleMode())
            }
          }
        }
        .width('100%').layoutWeight(1).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)
      }
      .width('100%').height('100%')

      if (this.showUnregisteredDialog) {
        Column() {
          Column().width('100%').height('100%').backgroundColor('rgba(0,0,0,0.5)').onClick(() => { this.closeDialog() })
          Column() {
            Text('⚠️').fontSize(48).fontColor('#faad14').margin({ bottom: 16 })
            Text('您未注册').fontSize(18).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_primary')).margin({ bottom: 8 })
            Text('该账号未注册，是否现在注册？').fontSize(14).fontColor($r('app.color.text_secondary')).margin({ bottom: 24 })
            Row() {
              Button('取消').height(44).fontSize(16).backgroundColor($r('app.color.background')).fontColor($r('app.color.text_primary')).layoutWeight(1).margin({ right: 8 }).onClick(() => this.closeDialog())
              Button('立即注册').height(44).fontSize(16).backgroundColor($r('app.color.primary')).fontColor(Color.White).layoutWeight(1).margin({ left: 8 }).onClick(() => this.goToRegister())
            }
            .width('100%')
          }
          .width(300).backgroundColor($r('app.color.white')).borderRadius(12).padding(24).position({ x: '50%', y: '50%' }).translate({ x: '-50%', y: '-50%' })
        }
        .width('100%').height('100%').position({ x: 0, y: 0 }).zIndex(1000)
      }
    }
    .width('100%').height('100%').backgroundColor($r('app.color.background'))
  }
}