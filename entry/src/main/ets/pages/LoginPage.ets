import router from '@ohos.router'
import { User } from '../model/DataModel'
import { StorageManager } from '../utils/StorageManager'
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
  private storage: StorageManager = StorageManager.getInstance()
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  aboutToAppear() {
    this.initStorage()
  }

  private async initStorage() {
    try {
      await this.storage.init(this.context)
      console.log('StorageManager初始化成功')
    } catch (error) {
      console.error('StorageManager初始化失败:', error)
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
      // 从存储中查找用户
      const existingUser = await this.loadUserByAccount(this.account)

      if (existingUser && existingUser.password === this.password) {
        // 登录成功
        await this.storage.saveUser(existingUser)
        console.log('登录成功:', existingUser.username)
        router.replaceUrl({ url: 'pages/IndexLuxury' })
      } else if (existingUser) {
        console.error('密码错误')
      } else {
        // 弹出未注册提示
        this.showUnregisteredDialogMsg()
      }
    } catch (error) {
      console.error('登录失败:', error)
    } finally {
      this.isLoading = false
    }
  }

  // 注册
  private async register(): Promise<void> {
    console.log('开始注册，账号:', this.account)

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
      // 检查账号是否已注册
      console.log('检查账号是否已存在...')
      const existingUser = await this.loadUserByAccount(this.account)

      if (existingUser) {
        console.error('该账号已注册')
      } else {
        // 创建新用户
        console.log('创建新用户...')
        const newUser = new User(this.account, this.password)
        // 设置默认用户名
        newUser.username = this.account
        await this.storage.saveUser(newUser)
        console.log('注册成功:', newUser.username)
        router.replaceUrl({ url: 'pages/IndexSimple' })
      }
    } catch (error) {
      console.error('注册失败:', error)
    } finally {
      this.isLoading = false
    }
  }

  // 根据账号加载用户（从本地数据库查询）
  private async loadUserByAccount(account: string): Promise<User | null> {
    try {
      // 使用StorageManager的新方法查找用户
      return await this.storage.findUserByAccount(account)
    } catch (error) {
      console.error('加载用户失败:', error)
      return null
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
        // 顶部导航
        Row() {
          Button('←')
            .width(40)
            .height(40)
            .backgroundColor(Color.Transparent)
            .fontColor($r('app.color.text_primary'))
            .onClick(() => {
              router.replaceUrl({url:'pages/IndexLuxury'})
            })

          Text(this.isLoginMode ? '登录' : '注册')
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
            // Logo和标题
            Column() {
              Text('🏪')
                .fontSize(80)
                .margin({ bottom: 24 })

              Text('华为商城')
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.primary'))
                .margin({ bottom: 8 })

              Text(this.isLoginMode ? '欢迎回来' : '创建账号开始购物')
                .fontSize(16)
                .fontColor($r('app.color.text_secondary'))
                .margin({ bottom: 40 })
            }
            .width('100%')
            .padding({ top: 60 })

            // 表单区域
            Column() {
              // 账号输入
              Column() {
                Text('账号')
                  .fontSize(14)
                  .fontColor($r('app.color.text_primary'))
                  .width('100%')
                  .margin({ bottom: 8 })

                TextInput({ placeholder: '请输入账号（字母、数字、下划线）' })
                  .width('100%')
                  .height(48)
                  .fontSize(16)
                  .backgroundColor($r('app.color.background'))
                  .borderRadius(8)
                  .padding({ left: 16 })
                  .onChange((value: string) => {
                    this.account = value
                  })
              }
              .width('100%')
              .margin({ bottom: 16 })

              // 密码输入
              Column() {
                Text('密码')
                  .fontSize(14)
                  .fontColor($r('app.color.text_primary'))
                  .width('100%')
                  .margin({ bottom: 8 })

                TextInput({ placeholder: '请输入密码' })
                  .width('100%')
                  .height(48)
                  .fontSize(16)
                  .backgroundColor($r('app.color.background'))
                  .borderRadius(8)
                  .padding({ left: 16 })
                  .type(InputType.Password)
                  .onChange((value: string) => {
                    this.password = value
                  })
              }
              .width('100%')
              .margin({ bottom: 16 })

              // 确认密码（注册模式）
              if (!this.isLoginMode) {
                Column() {
                  Text('确认密码')
                    .fontSize(14)
                    .fontColor($r('app.color.text_primary'))
                    .width('100%')
                    .margin({ bottom: 8 })

                  TextInput({ placeholder: '请再次输入密码' })
                    .width('100%')
                    .height(48)
                    .fontSize(16)
                    .backgroundColor($r('app.color.background'))
                    .borderRadius(8)
                    .padding({ left: 16 })
                    .type(InputType.Password)
                    .onChange((value: string) => {
                      this.confirmPassword = value
                    })
                }
                .width('100%')
                .margin({ bottom: 24 })
              }

              // 登录/注册按钮
              Button(this.isLoginMode ? '登录' : '注册')
                .width('100%')
                .height(50)
                .fontSize(16)
                .backgroundColor($r('app.color.primary'))
                .fontColor(Color.White)
                .borderRadius(25)
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

            // 切换模式
            Row() {
              Text(this.isLoginMode ? '还没有账号？' : '已有账号？')
                .fontSize(14)
                .fontColor($r('app.color.text_secondary'))

              Button(this.isLoginMode ? '立即注册' : '立即登录')
                .height(32)
                .fontSize(14)
                .backgroundColor(Color.Transparent)
                .fontColor($r('app.color.primary'))
                .onClick(() => this.toggleMode())
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .margin({ top: 24, bottom: 40 })
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

      // 未注册提示弹窗
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