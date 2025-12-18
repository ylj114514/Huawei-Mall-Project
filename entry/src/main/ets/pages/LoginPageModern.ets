import router from '@ohos.router'
import { User } from '../model/DataModel'
import { StorageManager } from '../utils/StorageManagerSimple'
import common from '@ohos.app.ability.common'

interface ColorScheme {
  background: string
  surface: string
  primary: string
  primaryDark: string
  secondary: string
  text: string
  textSecondary: string
  accent: string
  error: string
  success: string
}

const COLORS: ColorScheme = {
  background: '#FFFFFF',
  surface: '#F8F9FA',
  primary: '#007AFF',
  primaryDark: '#0056D6',
  secondary: '#6C757D',
  text: '#2C3E50',
  textSecondary: '#7F8C8D',
  accent: '#FF6B6B',
  error: '#E74C3C',
  success: '#27AE60'
}

@Entry
@Component
struct LoginPageModern {
  @State isLoginMode: boolean = true
  @State account: string = ''
  @State password: string = ''
  @State confirmPassword: string = ''
  @State nickname: string = ''
  @State email: string = ''
  @State agreeTerms: boolean = false
  @State isLoading: boolean = false
  @State showPassword: boolean = false
  @State showConfirmPassword: boolean = false
  @State errorMessage: string = ''

  private storage: StorageManager = StorageManager.getInstance()
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  aboutToAppear() {
    this.initStorage()
  }

  private async initStorage() {
    try {
      await this.storage.init(this.context)
    } catch (error) {
      console.error('初始化存储失败:', error)
    }
  }

  private validateForm(): boolean {
    // 清除之前的错误信息
    this.errorMessage = ''

    if (!this.account) {
      this.errorMessage = '请输入账号'
      return false
    }

    if (this.account.length < 3) {
      this.errorMessage = '账号至少3位'
      return false
    }

    if (!this.password) {
      this.errorMessage = '请输入密码'
      return false
    }

    if (this.password.length < 6) {
      this.errorMessage = '密码至少6位'
      return false
    }

    if (!this.isLoginMode) {
      if (this.password !== this.confirmPassword) {
        this.errorMessage = '两次密码不一致'
        return false
      }

      if (!this.nickname || !this.nickname.trim()) {
        this.errorMessage = '请输入昵称'
        return false
      }

      if (!this.agreeTerms) {
        this.errorMessage = '请同意用户协议和隐私政策'
        return false
      }
    }

    return true
  }

  private async handleLogin() {
    if (!this.validateForm()) return

    this.isLoading = true

    try {
      const existingUser = await this.storage.findUserByAccount(this.account)

      if (existingUser && existingUser.password === this.password) {
        await this.storage.saveUser(existingUser)
        router.replaceUrl({ url: 'pages/IndexNewModern' })
      } else if (existingUser) {
        this.errorMessage = '密码错误'
      } else {
        this.errorMessage = '账号不存在'
      }
    } catch (error) {
      console.error('登录失败:', error)
      this.errorMessage = '登录失败，请稍后重试'
    } finally {
      this.isLoading = false
    }
  }

  private async handleRegister() {
    console.log('进入注册方法')
    console.log('账号:', this.account)
    console.log('密码:', this.password)
    console.log('昵称:', this.nickname)
    console.log('同意协议:', this.agreeTerms)

    if (!this.validateForm()) {
      console.log('表单验证失败:', this.errorMessage)
      return
    }

    console.log('表单验证通过')
    this.isLoading = true

    try {
      console.log('检查用户是否已存在')
      const existingUser = await this.storage.findUserByAccount(this.account)

      if (existingUser) {
        console.log('账号已存在')
        this.errorMessage = '该账号已注册'
      } else {
        console.log('创建新用户')
        const newUser = new User(this.account, this.password)
        newUser.username = this.nickname.trim()
        newUser.email = this.email
        newUser.registrationTime = Date.now()

        console.log('保存用户')
        await this.storage.saveUser(newUser)
        console.log('注册成功，跳转到首页')
        router.replaceUrl({ url: 'pages/IndexNewModern' })
      }
    } catch (error) {
      console.error('注册失败:', error)
      this.errorMessage = '注册失败，请稍后重试'
    } finally {
      this.isLoading = false
    }
  }

  private toggleMode() {
    this.isLoginMode = !this.isLoginMode
    this.clearForm()
  }

  private clearForm() {
    this.account = ''
    this.password = ''
    this.confirmPassword = ''
    this.nickname = ''
    this.email = ''
    this.agreeTerms = false
    this.errorMessage = ''
    this.showPassword = false
    this.showConfirmPassword = false
  }

  @Builder
  Header() {
    Column() {
      Row() {
        Button() {
          Text('←')
            .fontSize(24)
            .fontColor(COLORS.text)
        }
        .width(48)
        .height(48)
        .backgroundColor(Color.Transparent)
        .onClick(() => router.back())

        Blank()

        Text(this.isLoginMode ? '登录' : '注册')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(COLORS.text)

        Blank().width(48)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 12 })

      // Logo区域
      Column() {
        Text('HUAWEI')
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor(COLORS.primary)
          .letterSpacing(4)

        Text('华为商城')
          .fontSize(18)
          .fontColor(COLORS.secondary)
          .margin({ top: 8 })
      }
      .width('100%')
      .padding({ top: 40, bottom: 40 })
    }
    .width('100%')
    .backgroundColor(COLORS.background)
  }

  @Builder
  LoginForm() {
    Column() {
      // 错误提示
      if (this.errorMessage) {
        Text(this.errorMessage)
          .fontSize(14)
          .fontColor(COLORS.error)
          .width('100%')
          .textAlign(TextAlign.Center)
          .margin({ bottom: 20 })
          .padding(12)
          .backgroundColor('#FFE5E5')
          .borderRadius(8)
      }

      // 账号输入
      Column() {
        Text('账号')
          .fontSize(14)
          .fontColor(COLORS.text)
          .width('100%')
          .margin({ bottom: 8 })

        Row() {
          TextInput({ placeholder: '请输入账号' })
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontColor(COLORS.text)
            .backgroundColor(COLORS.surface)
            .borderRadius(12)
            .padding({ left: 16, right: 16 })
            .onChange((value: string) => {
              this.account = value
              this.errorMessage = ''
            })
        }
      }
      .width('100%')
      .margin({ bottom: 20 })

      // 密码输入
      Column() {
        Text('密码')
          .fontSize(14)
          .fontColor(COLORS.text)
          .width('100%')
          .margin({ bottom: 8 })

        Row() {
          TextInput({ placeholder: '请输入密码' })
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontColor(COLORS.text)
            .backgroundColor(COLORS.surface)
            .borderRadius(12)
            .padding({ left: 16, right: 16 })
            .type(this.showPassword ? InputType.Normal : InputType.Password)
            .onChange((value: string) => {
              this.password = value
              this.errorMessage = ''
            })

          Button() {
            Text(this.showPassword ? '👁️' : '🙈')
              .fontSize(20)
          }
          .width(48)
          .height(48)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.showPassword = !this.showPassword
          })
        }
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 忘记密码
      if (this.isLoginMode) {
        Row() {
          Blank()
          Text('忘记密码？')
            .fontSize(14)
            .fontColor(COLORS.primary)
            .onClick(() => {
              router.pushUrl({ url: 'pages/ForgotPasswordPage' })
            })
        }
        .width('100%')
        .margin({ bottom: 32 })
      }

      // 昵称输入（注册模式）
      if (!this.isLoginMode) {
        Column() {
          Text('昵称')
            .fontSize(14)
            .fontColor(COLORS.text)
            .width('100%')
            .margin({ bottom: 8 })

          TextInput({ placeholder: '请输入昵称' })
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontColor(COLORS.text)
            .backgroundColor(COLORS.surface)
            .borderRadius(12)
            .padding({ left: 16, right: 16 })
            .onChange((value: string) => {
              this.nickname = value
              this.errorMessage = ''
            })
        }
        .width('100%')
        .margin({ bottom: 20 })

        // 确认密码
        Column() {
          Text('确认密码')
            .fontSize(14)
            .fontColor(COLORS.text)
            .width('100%')
            .margin({ bottom: 8 })

          Row() {
            TextInput({ placeholder: '请再次输入密码' })
              .width('100%')
              .height(48)
              .fontSize(16)
              .fontColor(COLORS.text)
              .backgroundColor(COLORS.surface)
              .borderRadius(12)
              .padding({ left: 16, right: 16 })
              .type(this.showConfirmPassword ? InputType.Normal : InputType.Password)
              .onChange((value: string) => {
                this.confirmPassword = value
                this.errorMessage = ''
              })

            Button() {
              Text(this.showConfirmPassword ? '👁️' : '🙈')
                .fontSize(20)
            }
            .width(48)
            .height(48)
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.showConfirmPassword = !this.showConfirmPassword
            })
          }
        }
        .width('100%')
        .margin({ bottom: 20 })
      }

      // 邮箱输入（注册模式）
      if (!this.isLoginMode) {
        Column() {
          Text('邮箱（选填）')
            .fontSize(14)
            .fontColor(COLORS.text)
            .width('100%')
            .margin({ bottom: 8 })

          TextInput({ placeholder: '请输入邮箱' })
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontColor(COLORS.text)
            .backgroundColor(COLORS.surface)
            .borderRadius(12)
            .padding({ left: 16, right: 16 })
            .onChange((value: string) => {
              this.email = value
            })
        }
        .width('100%')
        .margin({ bottom: 20 })
      }

      // 用户协议（注册模式）
      if (!this.isLoginMode) {
        Row() {
          Checkbox()
            .select(this.agreeTerms)
            .onChange((checked: boolean) => {
              this.agreeTerms = checked
            })

          Text('我已阅读并同意')
            .fontSize(14)
            .fontColor(COLORS.textSecondary)
            .margin({ left: 8 })

          Text('《用户协议》')
            .fontSize(14)
            .fontColor(COLORS.primary)
            .onClick(() => {
              // 打开用户协议
            })

          Text('和')

          Text('《隐私政策》')
            .fontSize(14)
            .fontColor(COLORS.primary)
            .onClick(() => {
              // 打开隐私政策
            })
        }
        .width('100%')
        .margin({ bottom: 32 })
      }

      // 登录/注册按钮
      Button() {
        Text(this.isLoginMode ? '登录' : '注册')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .height(48)
      .fontColor(Color.White)
      .backgroundColor(this.isLoginMode ? COLORS.primary : '#FF3B30')
      .borderRadius(12)
      .onClick(() => {
        console.log('按钮被点击了!!!')
        if (!this.isLoginMode) {
          console.log('执行注册流程')
          this.handleRegister()
        } else {
          this.handleLogin()
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
    .padding(20)
  }

  @Builder
  Footer() {
    Column() {
      // 第三方登录
      if (this.isLoginMode) {
        Column() {
          Text('其他登录方式')
            .fontSize(14)
            .fontColor(COLORS.textSecondary)
            .margin({ bottom: 20 })

          Row({ space: 20 }) {
            Button() {
              Text('📱')
                .fontSize(24)
            }
            .width(48)
            .height(48)
            .backgroundColor('#1DAF57')
            .borderRadius(24)
            .onClick(() => {
              // 微信登录
            })

            Button() {
              Text('☁️')
                .fontSize(24)
            }
            .width(48)
            .height(48)
            .backgroundColor('#4A90E2')
            .borderRadius(24)
            .onClick(() => {
              // QQ登录
            })

            Button() {
              Text('🍎')
                .fontSize(24)
            }
            .width(48)
            .height(48)
            .backgroundColor('#000000')
            .borderRadius(24)
            .onClick(() => {
              // Apple ID登录
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }
      }

      // 切换登录/注册
      Row() {
        Text(this.isLoginMode ? '还没有账号？' : '已有账号？')
          .fontSize(14)
          .fontColor(COLORS.textSecondary)

        Button(this.isLoginMode ? '立即注册' : '立即登录')
          .fontSize(14)
          .fontColor(COLORS.primary)
          .backgroundColor(Color.Transparent)
          .onClick(() => this.toggleMode())
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 40, bottom: 20 })
    }
    .width('100%')
    .padding(20)
  }

  build() {
    Column() {
      // 顶部
      this.Header()

      // 表单
      Scroll() {
        Column() {
          this.LoginForm()
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // 底部
      this.Footer()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLORS.background)
  }
}