import router from '@ohos.router'
import { User } from '../model/DataModel'
import { StorageManager } from '../utils/StorageManager'
import { CartService } from '../services/CartService'
import { AppService } from '../services/AppService'

@Entry
@Component
struct UserCenterPageSimple {
  @State user: User | null = null
  @State isLoading: boolean = true
  @State cartCount: number = 0
  private appService: AppService = AppService.getInstance()
  private storage: StorageManager = StorageManager.getInstance()
  private cartService: CartService = CartService.getInstance()

  aboutToAppear() {
    this.refreshData()
  }

  /**
   * 加载用户数据
   */
  private async loadUserData(): Promise<void> {
    try {
      this.user = await this.storage.loadUser()
      if (this.user) {
        this.isLoading = false
      } else {
        // 没有用户数据，跳转到登录页
        this.isLoading = false
        router.replaceUrl({ url: 'pages/LoginPage' })
      }
    } catch (error) {
      console.error('加载用户数据失败:', error)
      this.isLoading = false
    }
  }

  /**
   * 加载统计信息
   */
  private async loadStatistics(): Promise<void> {
    try {
      this.cartCount = this.cartService.getTotalCount()
    } catch (error) {
      console.error('加载统计信息失败:', error)
      this.cartCount = 0
    }
  }

  private navigateToPage(page: string): void {
    try {
      console.log('导航到页面:', page)
      router.pushUrl({ url: page })
    } catch (error) {
      console.error('页面导航失败:', error)
    }
  }

  /**
   * 刷新数据
   */
  private async refreshData(): Promise<void> {
    await Promise.all([
      this.loadUserData(),
      this.loadStatistics()
    ])
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button('←')
          .width(40)
          .height(40)
          .backgroundColor(Color.Transparent)
          .fontColor(Color.White)
          .fontSize(18)
          .onClick(() => {
            router.replaceUrl({ url: 'pages/Index' })
          })

        Text('个人中心')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .fontColor(Color.White)

        Blank().width(40)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor($r('app.color.primary'))
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      if (this.isLoading) {
        // 加载状态
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
          Text('加载中...')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.background'))
      } else if (this.user) {
        // 已登录状态
        Scroll() {
          Column() {
            // 用户信息卡片
            Row() {
              Text('👤')
                .fontSize(40)
                .margin({ right: 16 })

              Column() {
                Text(this.user.username)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.text_primary'))
                  .width('100%')

                Text(`${this.user.getLevelText()} | 积分: ${this.user.points}`)
                  .fontSize(14)
                  .fontColor($r('app.color.text_secondary'))
                  .width('100%')
                  .margin({ top: 4 })
              }
              .layoutWeight(1)

              Text('>')
                .fontSize(16)
                .fontColor($r('app.color.text_secondary'))
            }
            .width('100%')
            .padding(16)
            .backgroundColor($r('app.color.white'))
            .borderRadius(12)
            .margin({ left: 16, right: 16, top: 16 })
            .onClick(() => {})

            // 统计信息
            Row() {
              Column() {
                Text('🛒')
                  .fontSize(24)
                  .margin({ bottom: 4 })
                Text(this.cartCount.toString())
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.text_primary'))
                  .margin({ bottom: 2 })
                Text('购物车')
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('33%')
              .justifyContent(FlexAlign.Center)
              .onClick(() => this.navigateToPage('pages/CartPageNew'))

              Column() {
                Text('📦')
                  .fontSize(24)
                  .margin({ bottom: 4 })
                Text('0')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.text_primary'))
                  .margin({ bottom: 2 })
                Text('订单')
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('33%')
              .justifyContent(FlexAlign.Center)

              Column() {
                Text('💬')
                  .fontSize(24)
                  .margin({ bottom: 4 })
                Text('0')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.text_primary'))
                  .margin({ bottom: 2 })
                Text('评价')
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('34%')
              .justifyContent(FlexAlign.Center)
            }
            .width('100%')
            .padding(16)
            .backgroundColor($r('app.color.white'))
            .borderRadius(12)
            .margin({ left: 16, right: 16, top: 12 })

            // 功能菜单
            Column() {
              Text('我的服务')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.text_primary'))
                .width('100%')
                .margin({ bottom: 12 })

              
              Row() {
                Text('💬')
                  .fontSize(20)
                  .margin({ right: 12 })

                Column() {
                  Text('我的评价')
                    .fontSize(14)
                    .fontColor($r('app.color.text_primary'))
                    .width('100%')
                  Text('查看评价记录')
                    .fontSize(12)
                    .fontColor($r('app.color.text_secondary'))
                    .width('100%')
                    .margin({ top: 2 })
                }
                .layoutWeight(1)

                Text('>')
                  .fontSize(16)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('100%')
              .padding(16)
              .justifyContent(FlexAlign.Start)
              .onClick(() => {
                this.navigateToPage('pages/MyReviewsPage')
              })

              Divider()
                .width('100%')
                .margin({ left: 16, right: 16 })

              Row() {
                Text('📍')
                  .fontSize(20)
                  .margin({ right: 12 })

                Column() {
                  Text('收货地址')
                    .fontSize(14)
                    .fontColor($r('app.color.text_primary'))
                    .width('100%')
                  Text('管理收货地址')
                    .fontSize(12)
                    .fontColor($r('app.color.text_secondary'))
                    .width('100%')
                    .margin({ top: 2 })
                }
                .layoutWeight(1)

                Text('>')
                  .fontSize(16)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('100%')
              .padding(16)
              .justifyContent(FlexAlign.Start)
              .onClick(() => this.navigateToPage('pages/AddressManagePage'))
            }
            .width('100%')
            .backgroundColor($r('app.color.white'))
            .borderRadius(12)
            .margin({ left: 16, right: 16, bottom: 12 })

            // 设置
            Column() {
              Row() {
                Text('🚪')
                  .fontSize(20)
                  .margin({ right: 12 })

                Text('退出登录')
                  .fontSize(14)
                  .fontColor($r('app.color.text_primary'))
                  .layoutWeight(1)

                Text('>')
                  .fontSize(16)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('100%')
              .padding(16)
              .backgroundColor($r('app.color.white'))
              .borderRadius(12)
              .margin({ left: 16, right: 16, bottom: 16 })
              .justifyContent(FlexAlign.Start)
              .onClick(async () => {
                try {
                  // 清除用户数据
                  await this.storage.saveUser(null)
                  this.user = null
                  console.log('用户退出登录')
                  // 跳转到登录页
                  router.replaceUrl({ url: 'pages/LoginPage' })
                } catch (error) {
                  console.error('退出登录失败:', error)
                }
              })
            }
            .width('100%')

            // 底部占位
            Column()
              .width('100%')
              .height(20)
          }
          .width('100%')
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor($r('app.color.background'))
      } else {
        // 未登录状态
        Column() {
          // 用户头像和登录按钮
          Column() {
            Text('👤')
              .fontSize(80)
              .margin({ bottom: 24 })
            Text('登录后享受更多服务')
              .fontSize(16)
              .fontColor($r('app.color.text_secondary'))
              .margin({ bottom: 32 })

            Button('立即登录')
              .width(200)
              .height(44)
              .fontSize(16)
              .backgroundColor($r('app.color.primary'))
              .fontColor(Color.White)
              .borderRadius(22)
              .onClick(() => {
                router.pushUrl({ url: 'pages/LoginPage' })
              })
          }
          .width('100%')
          .padding(48)
          .justifyContent(FlexAlign.Center)

          // 快速访问
          Row() {
            Column() {
              Text('🏠')
                .fontSize(24)
                .margin({ bottom: 4 })
              Text('首页')
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
            }
            .width('25%')
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              router.replaceUrl({ url: 'pages/Index' })
            })

            Column() {
              Text('🛒')
                .fontSize(24)
                .margin({ bottom: 4 })
              Text('购物车')
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
            }
            .width('25%')
            .justifyContent(FlexAlign.Center)
            .onClick(() => this.navigateToPage('pages/CartPageNew'))

            
            Column() {
              Text('📦')
                .fontSize(24)
                .margin({ bottom: 4 })
              Text('订单')
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
            }
            .width('25%')
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.white'))
          .borderRadius(12)
          .margin({ left: 16, right: 16, bottom: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.background'))
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}