import router from '@ohos.router'
import { StorageManager } from '../utils/StorageManagerSimple'
import { User } from '../model/DataModel'
import common from '@ohos.app.ability.common'

interface ColorScheme {
  background: string
  primary: string
  accent: string
  secondary: string
  cardBg: string
  gold: string
  shadow: string
  headerBg: string
  headerBgLight: string
  textLight: string
  textSecondary: string
}

const COLORS: ColorScheme = {
  background: '#F8F9FA',
  primary: '#1976D2',
  accent: '#FF4081',
  secondary: '#424242',
  cardBg: '#FFFFFF',
  gold: '#FFB300',
  shadow: 'rgba(0, 0, 0, 0.1)',
  headerBg: '#1976D2',
  headerBgLight: '#42A5F5',
  textLight: '#FFFFFF',
  textSecondary: '#757575'
}

@Entry
@Component
struct UserCenter {
  @State user: User | null = null
  @State orderCount: number = 5
  @State couponCount: number = 8
  @State orders: { status: string, icon: string, count: number }[] = [
    { status: '待付款', icon: '💳', count: 2 },
    { status: '待发货', icon: '📦', count: 1 },
    { status: '待收货', icon: '🚚', count: 3 },
    { status: '退换/售后', icon: '🔄', count: 0 }
  ]
  private storage: StorageManager = StorageManager.getInstance()
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  aboutToAppear() {
    this.initStorage()
    this.loadUserData()
  }

  private async initStorage() {
    try {
      await this.storage.init(this.context)
      console.log('UserCenter: StorageManager初始化成功')
    } catch (error) {
      console.error('UserCenter: StorageManager初始化失败:', error)
    }
  }

  private async loadUserData() {
    try {
      this.user = await this.storage.loadUser()
      // 模拟加载订单数据
      this.orders = [
        { status: '待付款', icon: '💳', count: Math.floor(Math.random() * 5) },
        { status: '待发货', icon: '📦', count: Math.floor(Math.random() * 3) },
        { status: '待收货', icon: '🚚', count: Math.floor(Math.random() * 4) },
        { status: '退换/售后', icon: '🔄', count: Math.floor(Math.random() * 2) }
      ]
    } catch (error) {
      console.error('加载用户数据失败:', error)
    }
  }

  private async logout() {
    try {
      await this.storage.saveUser(null)
      router.replaceUrl({ url: 'pages/LoginPage' })
    } catch (error) {
      console.error('登出失败:', error)
    }
  }

  private onNavigate(page: string) {
    router.pushUrl({ url: page })
  }

  @Builder
  HeaderSection() {
    Column() {
      // 顶部渐变背景区域
      Column() {
        // 返回按钮和设置
        Row() {
          Button() {
            Text('←')
              .fontSize(24)
              .fontColor(Color.White)
          }
          .width(48)
          .height(48)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            router.back()
          })

          Text('我的')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Row() {
            Button() {
              Text('•••')
                .fontSize(24)
                .fontColor(Color.White)
            }
            .width(48)
            .height(48)
            .backgroundColor(Color.Transparent)
            .margin({ right: 16 })
            .onClick(() => {
              // 设置功能
            })
            Button() {
              Text('🔍')
                .fontSize(24)
                .fontColor(Color.White)
            }
            .width(48)
            .height(48)
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              // 搜索功能
            })
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 20, bottom: 10 })

        // 用户信息
        Row() {
          // 头像
          Text(this.user ? this.user.username[0].toUpperCase() : 'U')
            .fontSize(36)
            .fontColor(COLORS.accent)
            .width(80)
            .height(80)
            .backgroundColor(Color.White)
            .borderRadius(40)
            .textAlign(TextAlign.Center)
            .lineHeight(80)
            .shadow({
              radius: 8,
              color: 'rgba(0, 0, 0, 0.15)',
              offsetX: 0,
              offsetY: 4
            })

          Column() {
            Text(this.user ? this.user.username : '未登录')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.textLight)
              .margin({ bottom: 4 })

            if (!this.user) {
              Button('去登录')
                .fontSize(14)
                .fontColor(COLORS.textLight)
                .backgroundColor('rgba(255, 255, 255, 0.2)')
                .borderRadius(16)
                .padding({ left: 16, right: 16, top: 4, bottom: 4 })
                .onClick(() => {
                  router.pushUrl({ url: 'pages/LoginPageModern' })
                })
            } else {
              Text(this.user.phone || '')
                .fontSize(14)
                .fontColor('rgba(255, 255, 255, 0.8)')
            }
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          .margin({ left: 20 })
        }
        .width('100%')
        .padding({ left: 20, right: 20, bottom: 20 })

        // 统计卡片区域
        Row() {
          // 待付款订单
          Column() {
            Text(this.orders[0].count.toString())
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.accent)
              .margin({ bottom: 4 })
            Text('待付款')
              .fontSize(14)
              .fontColor(COLORS.textLight)
              .opacity(0.9)
          }
          .width('25%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            this.onNavigate('pages/OrderListPage?status=unpaid')
          })

          // 待发货订单
          Column() {
            Text(this.orders[1].count.toString())
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.accent)
              .margin({ bottom: 4 })
            Text('待发货')
              .fontSize(14)
              .fontColor(COLORS.textLight)
              .opacity(0.9)
          }
          .width('25%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            this.onNavigate('pages/OrderListPage?status=shipping')
          })

          // 待收货订单
          Column() {
            Text(this.orders[2].count.toString())
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.accent)
              .margin({ bottom: 4 })
            Text('待收货')
              .fontSize(14)
              .fontColor(COLORS.textLight)
              .opacity(0.9)
          }
          .width('25%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            this.onNavigate('pages/OrderListPage?status=delivering')
          })

          // 待评价订单
          Column() {
            Text(this.orders[3].count.toString())
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.accent)
              .margin({ bottom: 4 })
            Text('待评价')
              .fontSize(14)
              .fontColor(COLORS.textLight)
              .opacity(0.9)
          }
          .width('25%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            this.onNavigate('pages/OrderListPage?status=review')
          })
        }
        .width('90%')
        .padding(20)
        .backgroundColor('rgba(255, 255, 255, 0.1)')
        .borderRadius(16)
        .margin({ bottom: -40 })
        .shadow({
          radius: 10,
          color: 'rgba(0, 0, 0, 0.1)',
          offsetX: 0,
          offsetY: 4
        })
      }
      .width('100%')
      .backgroundLinearGradient({
        colors: [COLORS.headerBg, COLORS.headerBgLight],
        direction: GradientDirection.Top
      })
      .padding({ bottom: 40 })
    }
  }

  @Builder
  OrderSection() {
    Column() {
      Row() {
        Text('我的订单')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(COLORS.primary)
          .layoutWeight(1)

        Button() {
          Text('查看全部 >')
            .fontSize(14)
            .fontColor(COLORS.secondary)
        }
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.onNavigate('pages/OrderListPage')
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 16 })

      Row() {
        ForEach(this.orders, (order, index) => {
          Column() {
            Row() {
              Column() {
                Stack() {
                  Text(order.icon)
                    .fontSize(32)
                  if (order.count > 0) {
                    Text(order.count.toString())
                      .fontSize(12)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Color.White)
                      .backgroundColor(COLORS.accent)
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                      .borderRadius(10)
                      .align(Alignment.TopEnd)
                      .position({ x: 35, y: -5 })
                  }
                }
                .width(60)
                .height(60)
                .borderRadius(30)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .backgroundColor(this.getIconBgColor(index))
                .shadow({
                  radius: 4,
                  color: 'rgba(0, 0, 0, 0.05)',
                  offsetX: 0,
                  offsetY: 2
                })
              }
            }
            .margin({ bottom: 8 })
            Text(order.status)
              .fontSize(14)
              .fontColor(COLORS.secondary)
          }
          .width('25%')
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            const statusMap = ['unpaid', 'shipping', 'delivering', 'aftersale']
            this.onNavigate(`pages/OrderListPage?status=${statusMap[index]}`)
          })
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(COLORS.cardBg)
    .borderRadius(16)
    .shadow({
      radius: 10,
      color: COLORS.shadow,
      offsetX: 0,
      offsetY: 2
    })
    .margin({ bottom: 20 })
  }

  @Builder
  ToolSection() {
    Column({ space: 1 }) {
      // 服务标题
      Text('我的服务')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(COLORS.primary)
        .width('100%')
        .padding(20)
        .backgroundColor(COLORS.cardBg)

      // 第一行服务
      Row() {
        this.ToolItem('📍', '收货地址', 0, () => {
          this.onNavigate('pages/AddressManagePage')
        })
        this.ToolItem('👤', '销售客服', 1)
        this.ToolItem('📦', '我的包图', 2)
        this.ToolItem('📤', '分享好友', 3)
      }

      // 第二行服务
      Row() {
        this.ToolItem('📖', '新手教程', 4)
        this.ToolItem('❤️', '我的收藏', 5, () => {
          this.onNavigate('pages/FavoritePage')
        })
        this.ToolItem('🛒', '购物车', 6, () => {
          this.onNavigate('pages/CartPageNew')
        })
        this.ToolItem('🎧', '客服中心', 7)
      }

      // 退出登录按钮（如果已登录）
      if (this.user) {
        Button('退出登录')
          .fontSize(16)
          .fontColor(COLORS.primary)
          .backgroundColor(Color.Transparent)
          .width('100%')
          .padding(20)
          .borderRadius(0)
          .onClick(() => {
            this.logout()
          })
      }
    }
    .width('100%')
    .borderRadius(16)
    .shadow({
      radius: 10,
      color: COLORS.shadow,
      offsetX: 0,
      offsetY: 2
    })
    .margin({ bottom: 20 })
  }

  @Builder
  ToolItem(icon: string, text: string, index: number, onClick?: () => void) {
    Column() {
      Row() {
        Text(icon)
          .fontSize(32)
          .backgroundColor(this.getIconBgColor(index))
          .width(60)
          .height(60)
          .borderRadius(30)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .shadow({
            radius: 4,
            color: 'rgba(0, 0, 0, 0.05)',
            offsetX: 0,
            offsetY: 2
          })
      }
      .margin({ bottom: 8 })
      Text(text)
        .fontSize(14)
        .fontColor(COLORS.textSecondary)
    }
    .width('25%')
    .alignItems(HorizontalAlign.Center)
    .padding(16)
    .backgroundColor(COLORS.cardBg)
    .onClick(() => {
      if (onClick) onClick()
    })
  }

  private getIconBgColor(index: number): string {
    const colors = ['#FFF0F5', '#F0F8FF', '#F0FFF0', '#FFFFF0', '#F5F5F5', '#FFF5EE', '#F0F8FF', '#F5FFFA']
    return colors[index % colors.length]
  }

  build() {
    Column() {
      // 内容区域
      Scroll() {
        Column() {
          this.HeaderSection()
          this.OrderSection()
          this.ToolSection()
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 20 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor(COLORS.background)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLORS.background)
  }
}