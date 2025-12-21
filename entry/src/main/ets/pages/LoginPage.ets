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
  @State showOtherLoginMethods: boolean = false
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
        // Cookie提示条
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

          Text('华为账号-登录')
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
              // 华为Logo - 使用红色背景和白色HUAWEI文字模拟
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
              // 账号输入（简化，不显示标签）
              TextInput({ placeholder: '手机号/邮件地址/华为号' })
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

              // 密码输入（简化，不显示标签）
              TextInput({ placeholder: '密码' })
                .width('100%')
                .height(48)
                .fontSize(16)
                .backgroundColor('#FFFFFF')
                .borderRadius(0)
                .padding({ left: 16 })
                .border({ width: 1, color: '#E5E5E5' })
                .borderTop({ width: 0 })
                .type(InputType.Password)
                .onChange((value: string) => {
                  this.password = value
                })

              // 辅助链接
              Row() {
                Text('短信验证码登录')
                  .fontSize(14)
                  .fontColor('#007DFF')
                  .layoutWeight(1)
                  .textAlign(TextAlign.Start)

                Text('忘记密码')
                  .fontSize(14)
                  .fontColor('#007DFF')
                  .margin({ right: 16 })

                Text('立即注册')
                  .fontSize(14)
                  .fontColor('#007DFF')
                  .textAlign(TextAlign.End)
                  .onClick(() => this.toggleMode())
              }
              .width('100%')
              .margin({ top: 16, bottom: 24 })

              // 登录/注册按钮
              Button(this.isLoginMode ? '登录' : '注册')
                .width('100%')
                .height(50)
                .fontSize(16)
                .backgroundColor('#007DFF')
                .fontColor(Color.White)
                .borderRadius(0)
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

            // 其他登录方式切换按钮
            Row() {
              Text(this.showOtherLoginMethods ? '收起其他登录方式' : '其他登录方式')
                .fontSize(14)
                .fontColor('#666666')
                .onClick(() => this.showOtherLoginMethods = !this.showOtherLoginMethods)
            }
            .width('100%')
            .margin({ top: 16, bottom: 16 })
            .justifyContent(FlexAlign.Center)

            // 其他登录方式卡片 - 默认隐藏
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
                  .onClick(() => {
                    console.log('微信登录')
                  })

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
                  .onClick(() => {
                    console.log('QQ登录')
                  })

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
                  .onClick(() => {
                    console.log('微博登录')
                  })
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

            // 底部注册按钮 - 登录模式下显示
            if (this.isLoginMode) {
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