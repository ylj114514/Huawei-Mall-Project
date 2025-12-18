import router from '@ohos.router'
import { StorageManager } from '../utils/StorageManagerSimple'
import { User } from '../model/DataModel'
import common from '@ohos.app.ability.common'

// 颜色类
class ColorScheme {
  static background: string = '#F5F7FA'
  static surface: string = '#FFFFFF'
  static primary: string = '#1A1A1A'
  static secondary: string = '#6C757D'
  static text: string = '#2C3E50'
  static textSecondary: string = '#7F8C8D'
  static accent: string = '#3498DB'
  static danger: string = '#E74C3C'
}

@Entry
@Component
struct ProfileModernFixed {
  @State user: User | null = null
  @State isLoading: boolean = true
  @State cartCount: number = 0
  private storage: StorageManager = StorageManager.getInstance()
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  aboutToAppear() {
    this.initStorage()
    this.loadUserData()
  }

  private async initStorage() {
    try {
      await this.storage.init(this.context)
    } catch (error) {
      console.error('初始化存储失败:', error)
    }
  }

  private async loadUserData() {
    try {
      this.user = await this.storage.loadUser()

      // 模拟加载购物车数量
      if (this.user) {
        const cartItems = await this.storage.loadCart()
        this.cartCount = cartItems.length
      }

      this.isLoading = false
    } catch (error) {
      console.error('加载用户数据失败:', error)
      this.isLoading = false
    }
  }

  private async logout() {
    try {
      await this.storage.saveUser(null)
      router.replaceUrl({ url: 'pages/LoginPageModern' })
    } catch (error) {
      console.error('登出失败:', error)
    }
  }

  private navigateTo(page: string) {
    console.log(`导航到页面: ${page}`)
    router.pushUrl({ url: page }).catch((error: Error) => {
      console.error('导航失败:', error)
    })
  }

  @Builder
  Header() {
    Row() {
      Button() {
        Text('← 返回')
          .fontSize(24)
          .fontColor(ColorScheme.text)
      }
      .width(100)
      .height(48)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        console.log('返回按钮被点击')
        router.back()
      })

      Text('个人中心')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor(ColorScheme.text)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Button() {
        Text('设置 ⚙️')
          .fontSize(24)
          .fontColor(ColorScheme.text)
      }
      .width(100)
      .height(48)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        console.log('设置按钮被点击')
      })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 12, bottom: 12 })
    .backgroundColor(ColorScheme.surface)
  }

  @Builder
  UserInfoSection() {
    Column() {
      // 用户头像和基本信息
      Row() {
        // 头像
        Stack() {
          Circle({ width: 80, height: 80 })
            .fill(ColorScheme.accent)

          Text(this.user ? this.user.username[0].toUpperCase() : 'U')
            .fontSize(32)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)

          // VIP标签
          if (this.user) {
            Text('VIP')
              .fontSize(10)
              .fontColor('#FFD700')
              .fontWeight(FontWeight.Bold)
              .backgroundColor('#1A1A1A')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(8)
              .position({ x: 45, y: 0 })
          }
        }
        .margin({ right: 20 })

        // 用户信息
        Column() {
          if (this.user) {
            Text(this.user.username || '用户昵称')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor(ColorScheme.text)
              .margin({ bottom: 8 })

            Row() {
              Text('会员等级: ')
                .fontSize(14)
                .fontColor(ColorScheme.textSecondary)
              Text(this.user.getLevelText())
                .fontSize(14)
                .fontColor(this.user.getLevelColor())
                .fontWeight(FontWeight.Medium)
            }
            .margin({ bottom: 4 })

            Text(`积分: ${this.user.points}`)
              .fontSize(14)
              .fontColor(ColorScheme.textSecondary)
          } else {
            Text('未登录')
              .fontSize(18)
              .fontColor(ColorScheme.text)
              .margin({ bottom: 8 })

            Button('去登录')
              .fontSize(14)
              .fontColor(Color.White)
              .backgroundColor(ColorScheme.primary)
              .padding({ left: 20, right: 20, top: 8, bottom: 8 })
              .borderRadius(20)
              .onClick(() => {
                router.pushUrl({ url: 'pages/LoginPageModern' })
              })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .backgroundColor(ColorScheme.surface)
    .margin({ top: 1 })
  }

  @Builder
  OrderSection() {
    if (this.user) {
      Column() {
        Text('我的订单')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(ColorScheme.text)
          .width('100%')
          .margin({ bottom: 20 })
          .padding({ left: 20 })

        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceAround }) {
          Column() {
            Text('💳')
              .fontSize(30)
              .margin({ bottom: 8 })
            Text('待付款')
              .fontSize(12)
            Text('2')
              .fontSize(14)
              .fontColor(Color.Red)
          }
          .width(80)
          .height(80)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onClick(() => {
            this.showOrderDialog('待付款', '您有2个待付款订单')
          })

          Column() {
            Text('📦')
              .fontSize(30)
              .margin({ bottom: 8 })
            Text('待发货')
              .fontSize(12)
            Text('1')
              .fontSize(14)
              .fontColor(Color.Red)
          }
          .width(80)
          .height(80)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onClick(() => {
            this.showOrderDialog('待发货', '您有1个待发货订单')
          })

          Column() {
            Text('🚚')
              .fontSize(30)
              .margin({ bottom: 8 })
            Text('待收货')
              .fontSize(12)
            Text('3')
              .fontSize(14)
              .fontColor(Color.Red)
          }
          .width(80)
          .height(80)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onClick(() => {
            this.showOrderDialog('待收货', '您有3个待收货订单')
          })

          Column() {
            Text('⭐')
              .fontSize(30)
              .margin({ bottom: 8 })
            Text('待评价')
              .fontSize(12)
            Text('5')
              .fontSize(14)
              .fontColor(Color.Red)
          }
          .width(80)
          .height(80)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onClick(() => {
            this.showOrderDialog('待评价', '您有5个待评价订单')
          })
        }
        .width('100%')
      }
      .width('100%')
      .padding(20)
      .backgroundColor(ColorScheme.surface)
      .margin({ top: 12 })
    } else {
      // 未登录状态的订单提示
      Column() {
        Row() {
          Text('📋')
            .fontSize(20)
            .fontColor('#CCCCCC')
            .margin({ right: 12 })
          Text('登录后查看订单')
            .fontSize(16)
            .fontColor('#999999')
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .height(80)
        .backgroundColor('#FAFAFA')
        .borderRadius(8)
        .onClick(() => {
          router.pushUrl({ url: 'pages/LoginPageModern' })
        })
      }
      .width('100%')
      .padding(20)
      .backgroundColor(ColorScheme.surface)
      .margin({ top: 12 })
    }
  }

  private showOrderDialog(title: string, message: string) {
    AlertDialog.show({
      title: title,
      message: message,
      primaryButton: {
        value: '确定',
        action: () => {
          console.log(`对话框确定按钮被点击`)
        }
      },
      secondaryButton: {
        value: '取消',
        action: () => {
          console.log(`对话框取消按钮被点击`)
        }
      }
    })
  }

  @Builder
  ToolsSection() {
    Column() {
      Row() {
        Text('我的工具')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(ColorScheme.text)
      }
      .width('100%')
      .margin({ bottom: 20 })

      // 工具列表
      if (this.user) {
        Column({ space: 1 }) {
          // 购物车
          Row() {
            Row() {
              Text('🛒')
                .fontSize(22)
                .width(40)
              Column() {
                Text('购物车')
                  .fontSize(16)
                  .fontColor(ColorScheme.text)
                Text(`${this.cartCount}件商品`)
                  .fontSize(12)
                  .fontColor(ColorScheme.textSecondary)
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              .margin({ left: 12 })
            }
            .width('100%')
            .padding(20)
            .backgroundColor(ColorScheme.surface)
            .onClick(() => {
              router.pushUrl({ url: 'pages/CartPage' })
            })
          }

          // 地址管理
          Row() {
            Row() {
              Text('📍')
                .fontSize(22)
                .width(40)
              Column() {
                Text('地址管理')
                  .fontSize(16)
                  .fontColor(ColorScheme.text)
                Text('管理收货地址')
                  .fontSize(12)
                  .fontColor(ColorScheme.textSecondary)
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              .margin({ left: 12 })
            }
            .width('100%')
            .padding(20)
            .backgroundColor(ColorScheme.surface)
            .onClick(() => {
              console.log('地址管理')
            })
          }

          // 客服中心
          Row() {
            Row() {
              Text('💬')
                .fontSize(22)
                .width(40)
              Column() {
                Text('客服中心')
                  .fontSize(16)
                  .fontColor(ColorScheme.text)
                Text('在线客服反馈')
                  .fontSize(12)
                  .fontColor(ColorScheme.textSecondary)
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              .margin({ left: 12 })
            }
            .width('100%')
            .padding(20)
            .backgroundColor(ColorScheme.surface)
            .onClick(() => {
              console.log('客服中心')
            })
          }
        }
        .width('100%')
        .borderRadius(16)
        .margin({ top: 12 })
      } else {
        // 未登录状态的工具提示
        Column() {
          Row() {
            Text('🔧')
              .fontSize(20)
              .fontColor('#CCCCCC')
              .margin({ right: 12 })
            Text('登录后使用更多功能')
              .fontSize(16)
              .fontColor('#999999')
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .height(80)
          .backgroundColor('#FAFAFA')
          .borderRadius(8)
          .onClick(() => {
            router.pushUrl({ url: 'pages/LoginPageModern' })
          })
        }
        .width('100%')
        .padding(20)
        .backgroundColor(ColorScheme.surface)
        .margin({ top: 12 })
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor(ColorScheme.background)
  }

  @Builder
  LogoutSection() {
    Button('退出登录')
      .width('100%')
      .height(48)
      .fontSize(16)
      .fontColor(ColorScheme.danger)
      .backgroundColor(Color.Transparent)
      .border({ width: 1, color: ColorScheme.danger })
      .borderRadius(24)
      .margin({ top: 20 })
      .onClick(() => {
        AlertDialog.show({
          title: '提示',
          message: '确定要退出登录吗？',
          primaryButton: {
            value: '确定',
            action: () => this.logout()
          },
          secondaryButton: {
            value: '取消',
            action: () => {}
          }
        })
      })
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航
        this.Header()

        // 主内容
        Scroll() {
          Column() {
            // 用户信息
            this.UserInfoSection()

            // 订单部分
            this.OrderSection()
            this.ToolsSection()
            if (this.user) {
              this.LogoutSection()
            }
          }
          .width('100%')
          .padding({ bottom: 80 })
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(ColorScheme.background)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(ColorScheme.background)

      // 加载状态
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
          Text('加载中...')
            .fontSize(14)
            .fontColor(ColorScheme.textSecondary)
            .margin({ top: 16 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('rgba(0,0,0,0.5)')
        .zIndex(9999)
      }
    }
    .width('100%')
    .height('100%')
  }
}