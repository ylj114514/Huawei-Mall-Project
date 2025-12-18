import router from '@ohos.router'
import { User } from '../model/DataModel'
import { StorageManager } from '../utils/StorageManagerSimple'
import common from '@ohos.app.ability.common'

// 奢华配色方案
interface ColorScheme {
  background: string
  primary: string
  accent: string
  secondary: string
  cardBg: string
  gold: string
  shadow: string
}

const COLORS: ColorScheme = {
  background: '#FAFAFA',
  primary: '#000000',
  accent: '#CF0A2C',
  secondary: '#666666',
  cardBg: '#FFFFFF',
  gold: '#D4AF37',
  shadow: 'rgba(0, 0, 0, 0.08)'
}

@Entry
@Component
struct LoginPageNew {
  @State account: string = ''
  @State password: string = ''
  @State confirmPassword: string = ''
  @State isLoginMode: boolean = true
  @State isLoading: boolean = false
  private storage: StorageManager = StorageManager.getInstance()
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  aboutToAppear() {
    this.initStorage()
  }

  private async initStorage() {
    try {
      await this.storage.init(this.context)
      console.log('LoginPageNew: StorageManager初始化成功')
    } catch (error) {
      console.error('LoginPageNew: StorageManager初始化失败:', error)
    }
  }

  // 验证账号格式
  private validateAccount(account: string): boolean {
    return account.length >= 3 && /^[a-zA-Z0-9_]+$/.test(account)
  }

  // 验证密码格式
  private validatePassword(password: string): boolean {
    return password.length >= 6
  }

  // 登录
  private async login(): Promise<void> {
    if (!this.validateAccount(this.account)) {
      console.error('请输入正确的账号格式（至少3位，只能包含字母、数字、下划线）')
      return
    }

    if (!this.validatePassword(this.password)) {
      console.error('密码至少6位')
      return
    }

    this.isLoading = true

    try {
      const existingUser = await this.storage.findUserByAccount(this.account)

      if (existingUser && existingUser.password === this.password) {
        await this.storage.saveUser(existingUser)
        console.log('登录成功:', existingUser.username)
        router.replaceUrl({ url: 'pages/IndexMain' })
      } else if (existingUser) {
        console.error('密码错误')
      } else {
        console.error('账号不存在')
      }
    } catch (error) {
      console.error('登录失败:', error)
    } finally {
      this.isLoading = false
    }
  }

  // 注册
  private async register(): Promise<void> {
    if (!this.validateAccount(this.account)) {
      console.error('请输入正确的账号格式（至少3位，只能包含字母、数字、下划线）')
      return
    }

    if (!this.validatePassword(this.password)) {
      console.error('密码至少6位')
      return
    }

    if (this.password !== this.confirmPassword) {
      console.error('两次密码不一致')
      return
    }

    this.isLoading = true

    try {
      const existingUser = await this.storage.findUserByAccount(this.account)

      if (existingUser) {
        console.error('该账号已注册')
      } else {
        const newUser = new User(this.account, this.password)
        newUser.username = this.account
        await this.storage.saveUser(newUser)
        console.log('注册成功:', newUser.username)
        router.replaceUrl({ url: 'pages/IndexMain' })
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
    this.account = ''
    this.password = ''
    this.confirmPassword = ''
  }

  @Builder
  LogoSection() {
    Column() {
      Text('HUAWEI')
        .fontSize(48)
        .fontWeight(FontWeight.Bold)
        .fontColor(COLORS.primary)
        .letterSpacing(8)
        .margin({ bottom: 8 })

      Text('华为商城')
        .fontSize(24)
        .fontColor(COLORS.secondary)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .margin({ top: 60, bottom: 60 })
  }

  @Builder
  FormSection() {
    Column() {
      // 账号输入
      Column() {
        Text('账号')
          .fontSize(14)
          .fontColor(COLORS.primary)
          .width('100%')
          .margin({ bottom: 8 })

        TextInput({ placeholder: '请输入账号（字母、数字、下划线）' })
          .width('100%')
          .height(52)
          .fontSize(16)
          .fontColor(COLORS.primary)
          .backgroundColor('#F5F5F5')
          .borderRadius(12)
          .padding({ left: 16 })
          .onChange((value: string) => {
            this.account = value
          })
      }
      .width('100%')
      .margin({ bottom: 20 })

      // 密码输入
      Column() {
        Text('密码')
          .fontSize(14)
          .fontColor(COLORS.primary)
          .width('100%')
          .margin({ bottom: 8 })

        TextInput({ placeholder: '请输入密码' })
          .width('100%')
          .height(52)
          .fontSize(16)
          .fontColor(COLORS.primary)
          .backgroundColor('#F5F5F5')
          .borderRadius(12)
          .padding({ left: 16 })
          .type(InputType.Password)
          .onChange((value: string) => {
            this.password = value
          })
      }
      .width('100%')
      .margin({ bottom: 20 })

      // 确认密码（注册模式）
      if (!this.isLoginMode) {
        Column() {
          Text('确认密码')
            .fontSize(14)
            .fontColor(COLORS.primary)
            .width('100%')
            .margin({ bottom: 8 })

          TextInput({ placeholder: '请再次输入密码' })
            .width('100%')
            .height(52)
            .fontSize(16)
            .fontColor(COLORS.primary)
            .backgroundColor('#F5F5F5')
            .borderRadius(12)
            .padding({ left: 16 })
            .type(InputType.Password)
            .onChange((value: string) => {
              this.confirmPassword = value
            })
        }
        .width('100%')
        .margin({ bottom: 30 })
      }

      // 登录/注册按钮
      Button(this.isLoginMode ? '登录' : '注册')
        .width('100%')
        .height(52)
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor(COLORS.primary)
        .borderRadius(26)
        .enabled(!this.isLoading && this.account.length >= 3 && this.password.length >= 6 &&
                (this.isLoginMode || this.confirmPassword.length >= 6))
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
            .color(Color.White)
          Text(this.isLoginMode ? '登录中...' : '注册中...')
            .fontSize(14)
            .fontColor(Color.White)
            .margin({ left: 8 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 16 })
      }
    }
    .width('100%')
    .padding(30)
  }

  @Builder
  ToggleSection() {
    Row() {
      Text(this.isLoginMode ? '还没有账号？' : '已有账号？')
        .fontSize(16)
        .fontColor(COLORS.secondary)

      Button(this.isLoginMode ? '立即注册' : '立即登录')
        .height(32)
        .fontSize(16)
        .backgroundColor(Color.Transparent)
        .fontColor(COLORS.primary)
        .onClick(() => this.toggleMode())
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .margin({ top: 30, bottom: 40 })
  }

  build() {
    Column() {
      // 顶部返回按钮
      Row() {
        Button() {
          Text('←')
            .fontSize(24)
            .fontColor(COLORS.primary)
        }
        .width(48)
        .height(48)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          router.replaceUrl({ url: 'pages/IndexMain' })
        })

        Blank().width(48)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20 })

      // 主要内容
      Scroll() {
        Column() {
          this.LogoSection()
          this.FormSection()
          this.ToggleSection()
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLORS.background)
  }
}