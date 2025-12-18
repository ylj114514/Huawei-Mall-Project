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
struct UserCenter {
  @State user: User | null = null
  @State orderCount: number = 5
  @State couponCount: number = 8
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
      // 返回按钮
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
          router.back()
        })

        Text('个人中心')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(COLORS.primary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank()
          .width(48)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 20 })

      // 用户信息
      Row() {
        // 头像
        Text(this.user ? this.user.username[0].toUpperCase() : '未')
          .fontSize(36)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .width(80)
          .height(80)
          .backgroundColor(COLORS.accent)
          .borderRadius(40)
          .textAlign(TextAlign.Center)

        Column() {
          Text(this.user ? this.user.username : '未登录')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(COLORS.primary)
            .margin({ bottom: 4 })

          Text(this.user ? `ID: ${this.user.account}` : '请先登录')
            .fontSize(14)
            .fontColor(COLORS.secondary)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 20 })

        if (this.user) {
          Button('退出登录')
            .fontSize(14)
            .fontColor(COLORS.secondary)
            .backgroundColor(COLORS.background)
            .borderRadius(20)
            .padding({ left: 20, right: 20, top: 8, bottom: 8 })
            .onClick(() => {
              this.logout()
            })
        }
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

        Text('全部订单 >')
          .fontSize(14)
          .fontColor(COLORS.secondary)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 16 })

      Row() {
        Column() {
          Text('💳')
            .fontSize(32)
            .margin({ bottom: 8 })
          Text('待付款')
            .fontSize(14)
            .fontColor(COLORS.secondary)
        }
        .width('25%')
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('📦')
            .fontSize(32)
            .margin({ bottom: 8 })
          Text('待发货')
            .fontSize(14)
            .fontColor(COLORS.secondary)
        }
        .width('25%')
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('🚚')
            .fontSize(32)
            .margin({ bottom: 8 })
          Text('待收货')
            .fontSize(14)
            .fontColor(COLORS.secondary)
        }
        .width('25%')
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('⭐')
            .fontSize(32)
            .margin({ bottom: 8 })
          Text('待评价')
            .fontSize(14)
            .fontColor(COLORS.secondary)
        }
        .width('25%')
        .alignItems(HorizontalAlign.Center)
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
      // 收藏
      Row() {
        Text('❤️')
          .fontSize(24)
          .width(40)

        Text('我的收藏')
          .fontSize(16)
          .fontColor(COLORS.primary)
          .layoutWeight(1)

        Text('>')
          .fontSize(18)
          .fontColor(COLORS.secondary)
      }
      .width('100%')
      .padding(20)
      .backgroundColor(COLORS.cardBg)
      .onClick(() => {
        this.onNavigate('pages/FavoritePage')
      })

      // 购物车
      Row() {
        Text('🛒')
          .fontSize(24)
          .width(40)

        Text('购物车')
          .fontSize(16)
          .fontColor(COLORS.primary)
          .layoutWeight(1)

        Text('>')
          .fontSize(18)
          .fontColor(COLORS.secondary)
      }
      .width('100%')
      .padding(20)
      .backgroundColor(COLORS.cardBg)
      .onClick(() => {
        this.onNavigate('pages/CartPageNew')
      })

      // 地址管理
      Row() {
        Text('📍')
          .fontSize(24)
          .width(40)

        Text('收货地址')
          .fontSize(16)
          .fontColor(COLORS.primary)
          .layoutWeight(1)

        Text('>')
          .fontSize(18)
          .fontColor(COLORS.secondary)
      }
      .width('100%')
      .padding(20)
      .backgroundColor(COLORS.cardBg)
      .onClick(() => {
        this.onNavigate('pages/AddressManagePage')
      })

      // 客服
      Row() {
        Text('🎧')
          .fontSize(24)
          .width(40)

        Text('客服中心')
          .fontSize(16)
          .fontColor(COLORS.primary)
          .layoutWeight(1)

        Text('>')
          .fontSize(18)
          .fontColor(COLORS.secondary)
      }
      .width('100%')
      .padding(20)
      .backgroundColor(COLORS.cardBg)

      // 设置
      Row() {
        Text('⚙️')
          .fontSize(24)
          .width(40)

        Text('设置')
          .fontSize(16)
          .fontColor(COLORS.primary)
          .layoutWeight(1)

        Text('>')
          .fontSize(18)
          .fontColor(COLORS.secondary)
      }
      .width('100%')
      .padding(20)
      .backgroundColor(COLORS.cardBg)
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