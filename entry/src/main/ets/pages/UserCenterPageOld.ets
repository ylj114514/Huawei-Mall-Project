import router from '@ohos.router'
import { User, Order, FavoriteItem } from '../model/DataModel'
import { StorageManager } from '../utils/StorageManager'
import { CartService } from '../services/CartService'
import { CommentService } from '../services/CommentService'

@Entry
@Component
struct UserCenterPage {
  @State user: User | null = null
  @State isLoading: boolean = true
  @State cartCount: number = 0
  @State orderCount: number = 0
  @State favoriteCount: number = 0
  @State commentCount: number = 0
  private storage: StorageManager = StorageManager.getInstance()
  private cartService: CartService = CartService.getInstance()
  private commentService: CommentService = CommentService.getInstance()

  aboutToAppear() {
    this.loadUserData()
    this.loadStatistics()
  }

  private async loadUserData() {
    try {
      this.user = await this.storage.loadUser()
      this.isLoading = false
    } catch (error) {
      console.error('加载用户数据失败:', error)
      this.isLoading = false
    }
  }

  private loadStatistics() {
    this.cartCount = this.cartService.getTotalCount()
    // 模拟订单和收藏数据
    this.orderCount = 3
    this.favoriteCount = 8
    this.commentCount = 12
  }

  private navigateToPage(page: string, params?: Record<string, Object>): void {
    router.pushUrl({
      url: page,
      params: params
    })
  }

  private logout() {
    // 清除用户数据
    this.user = null
    // 跳转到登录页面
    console.log('用户退出登录')
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('个人中心')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height(56)
      .padding(16)
      .backgroundColor($r('app.color.primary'))
      .justifyContent(FlexAlign.Center)

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
            UserCard({ user: this.user })

            // 统计信息
            StatisticsRow({
              cartCount: this.cartCount,
              orderCount: this.orderCount,
              favoriteCount: this.favoriteCount,
              commentCount: this.commentCount
            })

            // 我的订单
            Column() {
              SectionTitle({ title: '我的订单' })
              OrderSection({
                onViewOrders: (): void => this.navigateToPage('pages/OrderListPage'),
                onViewPending: (): void => this.navigateToPage('pages/OrderListPage'),
                onViewShipped: (): void => this.navigateToPage('pages/OrderListPage'),
                onViewCompleted: (): void => this.navigateToPage('pages/OrderListPage')
              })
            }

            // 我的服务
            Column() {
              SectionTitle({ title: '我的服务' })
              ServiceSection({
                onMyFavorite: (): void => this.navigateToPage('pages/FavoritePage'),
                onMyComment: (): void => this.navigateToPage('pages/MyCommentPage'),
                onMyAddress: (): void => this.navigateToPage('pages/AddressListPage'),
                onMyCoupon: (): void => this.navigateToPage('pages/CouponPage')
              })
            }

            // 设置
            Column() {
              SectionTitle({ title: '设置' })
              SettingsSection({
                onLogout: (): void => this.logout(),
                onAbout: (): void => this.navigateToPage('pages/AboutPage')
              })
            }

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
                this.navigateToPage('pages/LoginPage')
              })
          }
          .width('100%')
          .padding(48)
          .justifyContent(FlexAlign.Center)

          // 未登录时的功能入口
          Column() {
            SectionTitle({ title: '快速访问' })
            QuickAccessSection()
          }
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

// 用户信息卡片
@Component
struct UserCard {
  @Prop user: User

  build() {
    Row() {
      // 用户头像
      Image(this.user.avatar)
        .width(60)
        .height(60)
        .borderRadius(30)
        .margin({ right: 16 })

      // 用户信息
      Column() {
        Row() {
          Text(this.user.username)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))

          Text(this.user.getLevelText())
            .fontSize(12)
            .fontColor(this.user.getLevelColor())
            .backgroundColor($r('app.color.background'))
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(10)
            .margin({ left: 8 })
        }
        .width('100%')

        Text(`积分: ${this.user.points}`)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 4 })
      }
      .layoutWeight(1)

      // 箭头
      Text('>')
        .fontSize(16)
        .fontColor($r('app.color.text_secondary'))
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.white'))
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 16 })
    .onClick(() => {
      // 跳转到用户详情页
    })
  }
}

// 统计信息行
@Component
struct StatisticsRow {
  @Prop cartCount: number
  @Prop orderCount: number
  @Prop favoriteCount: number
  @Prop commentCount: number

  build() {
    Row() {
      StatisticItem({
        icon: '🛒',
        label: '购物车',
        count: this.cartCount,
        onClick: () => {}
      })

      StatisticItem({
        icon: '📦',
        label: '订单',
        count: this.orderCount,
        onClick: () => {}
      })

      StatisticItem({
        icon: '❤️',
        label: '收藏',
        count: this.favoriteCount,
        onClick: () => {}
      })

      StatisticItem({
        icon: '💬',
        label: '评价',
        count: this.commentCount,
        onClick: () => {}
      })
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.white'))
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 12 })
  }
}

// 统计项组件
@Component
struct StatisticItem {
  @Prop icon: string
  @Prop label: string
  @Prop count: number
  onClick: () => void = () => {}

  build() {
    Column() {
      Text(this.icon)
        .fontSize(24)
        .margin({ bottom: 4 })

      Text(this.count.toString())
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: 2 })

      Text(this.label)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
    }
    .width('25%')
    .justifyContent(FlexAlign.Center)
    .onClick(this.onClick)
  }
}

// 章节标题组件
@Component
struct SectionTitle {
  @Prop title: string

  build() {
    Row() {
      Text(this.title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)

      Text('查看全部')
        .fontSize(12)
        .fontColor($r('app.color.primary'))
        .onClick(() => {
          // 查看全部逻辑
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 8 })
  }
}

// 订单部分
@Component
struct OrderSection {
  onViewOrders: () => void = () => {}
  onViewPending: () => void = () => {}
  onViewShipped: () => void = () => {}
  onViewCompleted: () => void = () => {}

  build() {
    Column() {
      // 订单状态快捷入口
      Row() {
        OrderStatusItem({
          icon: '💳',
          label: '待付款',
          onClick: this.onViewPending
        })

        OrderStatusItem({
          icon: '📦',
          label: '待发货',
          onClick: () => {}
        })

        OrderStatusItem({
          icon: '🚚',
          label: '待收货',
          onClick: this.onViewShipped
        })

        OrderStatusItem({
          icon: '⭐',
          label: '待评价',
          onClick: this.onViewCompleted
        })

        OrderStatusItem({
          icon: '🔍',
          label: '全部订单',
          onClick: this.onViewOrders
        })
      }
      .width('100%')
      .padding(16)
      .backgroundColor($r('app.color.white'))
      .borderRadius(12)
      .margin({ left: 16, right: 16, bottom: 12 })
    }
    .width('100%')
  }
}

// 订单状态项
@Component
struct OrderStatusItem {
  @Prop icon: string
  @Prop label: string
  onClick: () => void = () => {}

  build() {
    Column() {
      Text(this.icon)
        .fontSize(24)
        .margin({ bottom: 4 })

      Text(this.label)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
    }
    .width('20%')
    .justifyContent(FlexAlign.Center)
    .onClick(this.onClick)
  }
}

// 服务部分
@Component
struct ServiceSection {
  onMyFavorite: () => void = () => {}
  onMyComment: () => void = () => {}
  onMyAddress: () => void = () => {}
  onMyCoupon: () => void = () => {}

  build() {
    Column() {
      ServiceItem({
        icon: '❤️',
        title: '我的收藏',
        description: '查看收藏的商品',
        onClick: this.onMyFavorite
      })

      ServiceItem({
        icon: '💬',
        title: '我的评价',
        description: '查看评价记录',
        onClick: this.onMyComment
      })

      ServiceItem({
        icon: '📍',
        title: '收货地址',
        description: '管理收货地址',
        onClick: this.onMyAddress
      })

      ServiceItem({
        icon: '🎫',
        title: '优惠券',
        description: '查看可用优惠券',
        onClick: this.onMyCoupon
      })
    }
    .width('100%')
    .backgroundColor($r('app.color.white'))
    .borderRadius(12)
    .margin({ left: 16, right: 16, bottom: 12 })
  }
}

// 服务项组件
@Component
struct ServiceItem {
  @Prop icon: string
  @Prop title: string
  @Prop description: string
  onClick: () => void = () => {}

  build() {
    Row() {
      Text(this.icon)
        .fontSize(20)
        .margin({ right: 12 })

      Column() {
        Text(this.title)
          .fontSize(14)
          .fontColor($r('app.color.text_primary'))
          .width('100%')

        Text(this.description)
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
    .onClick(this.onClick)

    if (this.description !== '') {
      Divider()
        .width('100%')
        .margin({ left: 16, right: 16 })
    }
  }
}

// 设置部分
@Component
struct SettingsSection {
  onLogout: () => void = () => {}
  onAbout: () => void = () => {}

  build() {
    Column() {
      ServiceItem({
        icon: 'ℹ️',
        title: '关于我们',
        description: '',
        onClick: this.onAbout
      })

      ServiceItem({
        icon: '🚪',
        title: '退出登录',
        description: '',
        onClick: this.onLogout
      })
    }
    .width('100%')
    .backgroundColor($r('app.color.white'))
    .borderRadius(12)
    .margin({ left: 16, right: 16, bottom: 16 })
  }
}

// 快速访问部分（未登录时）
@Component
struct QuickAccessSection {
  build() {
    Column() {
      Row() {
        QuickAccessItem({
          icon: '🔍',
          title: '搜索',
          onClick: () => {}
        })

        QuickAccessItem({
          icon: '🛒',
          title: '购物车',
          onClick: () => {}
        })

        QuickAccessItem({
          icon: '❤️',
          title: '收藏',
          onClick: () => {}
        })

        QuickAccessItem({
          icon: '📦',
          title: '订单',
          onClick: () => {}
        })
      }
      .width('100%')
      .padding(16)
      .backgroundColor($r('app.color.white'))
      .borderRadius(12)
      .margin({ left: 16, right: 16, bottom: 16 })
    }
    .width('100%')
  }
}

// 快速访问项
@Component
struct QuickAccessItem {
  @Prop icon: string
  @Prop title: string
  onClick: () => void = () => {}

  build() {
    Column() {
      Text(this.icon)
        .fontSize(24)
        .margin({ bottom: 4 })

      Text(this.title)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
    }
    .width('25%')
    .justifyContent(FlexAlign.Center)
    .onClick(this.onClick)
  }
}