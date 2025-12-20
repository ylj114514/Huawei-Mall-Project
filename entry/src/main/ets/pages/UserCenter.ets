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
  darkBg: string
  yellowCard: string
  yellowCardText: string
}

const COLORS: ColorScheme = {
  background: '#F5F5F5',
  primary: '#000000',
  accent: '#CF0A2C',
  secondary: '#666666',
  cardBg: '#FFFFFF',
  gold: '#D4AF37',
  shadow: 'rgba(0, 0, 0, 0.08)',
  darkBg: '#2F2F2F',
  yellowCard: '#FFD700',
  yellowCardText: '#8B6914'
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
      // 顶部深色背景区域
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
            Text('•••')
              .fontSize(24)
              .fontColor(Color.White)
              .margin({ right: 20 })
            Text('🔍')
              .fontSize(24)
              .fontColor(Color.White)
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 20, bottom: 10 })

        // 用户信息
        Row() {
          // 头像
          Text(this.user ? this.user.username[0].toUpperCase() : 'i')
            .fontSize(36)
            .fontColor('#FF7F50')
            .fontWeight(FontWeight.Bold)
            .width(80)
            .height(80)
            .backgroundColor(Color.White)
            .borderRadius(40)
            .textAlign(TextAlign.Center)

          Column() {
            Text(this.user ? '点击登录' : '点击登录')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .margin({ bottom: 4 })

            Text(this.user ? this.user.username : '登录更精彩')
              .fontSize(14)
              .fontColor('#CCCCCC')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          .margin({ left: 20 })
        }
        .width('100%')
        .padding({ left: 20, right: 20, bottom: 20 })

        // 礼券和收益卡片
        Row() {
          // 礼券余额
          Column() {
            Text('礼券余额')
              .fontSize(14)
              .fontColor(COLORS.yellowCardText)
              .margin({ bottom: 8 })
            Text('0')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.yellowCardText)
              .margin({ bottom: 16 })
            Button('立即查看')
              .fontSize(14)
              .fontColor(COLORS.yellowCardText)
              .backgroundColor('#FFFFFF')
              .borderRadius(20)
              .padding({ left: 20, right: 20, top: 6, bottom: 6 })
          }
          .width('50%')
          .height(120)
          .padding(20)
          .backgroundColor(COLORS.yellowCard)
          .borderRadius({ topLeft: 12, bottomLeft: 12 })
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)

          // 收益余额
          Column() {
            Text('收益余额 (元)')
              .fontSize(14)
              .fontColor(COLORS.yellowCardText)
              .margin({ bottom: 8 })
            Text('0')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.yellowCardText)
              .margin({ bottom: 16 })
            Button('立即提现')
              .fontSize(14)
              .fontColor(COLORS.yellowCardText)
              .backgroundColor('#FFFFFF')
              .borderRadius(20)
              .padding({ left: 20, right: 20, top: 6, bottom: 6 })
          }
          .width('50%')
          .height(120)
          .padding(20)
          .backgroundColor(COLORS.yellowCard)
          .borderRadius({ topRight: 12, bottomRight: 12 })
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
        .width('90%')
        .margin({ bottom: -40 })
        .shadow({
          radius: 10,
          color: 'rgba(0, 0, 0, 0.1)',
          offsetX: 0,
          offsetY: 4
        })
      }
      .width('100%')
      .backgroundColor(COLORS.darkBg)
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

        Text('查看全部 >')
          .fontSize(14)
          .fontColor(COLORS.secondary)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 16 })

      Row() {
        Column() {
          Row() {
            Column() {
              Text('💳')
                .fontSize(32)
                .backgroundColor('#FFF0F5')
                .width(60)
                .height(60)
                .borderRadius(30)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
            }
          }
          .margin({ bottom: 8 })
          Text('待付款')
            .fontSize(14)
            .fontColor(COLORS.secondary)
        }
        .width('25%')
        .alignItems(HorizontalAlign.Center)

        Column() {
          Row() {
            Column() {
              Text('📦')
                .fontSize(32)
                .backgroundColor('#F0F8FF')
                .width(60)
                .height(60)
                .borderRadius(30)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
            }
          }
          .margin({ bottom: 8 })
          Text('待发货')
            .fontSize(14)
            .fontColor(COLORS.secondary)
        }
        .width('25%')
        .alignItems(HorizontalAlign.Center)

        Column() {
          Row() {
            Column() {
              Text('🚚')
                .fontSize(32)
                .backgroundColor('#F0FFF0')
                .width(60)
                .height(60)
                .borderRadius(30)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
            }
          }
          .margin({ bottom: 8 })
          Text('待收货')
            .fontSize(14)
            .fontColor(COLORS.secondary)
        }
        .width('25%')
        .alignItems(HorizontalAlign.Center)

        Column() {
          Row() {
            Column() {
              Text('🔄')
                .fontSize(32)
                .backgroundColor('#FFFFF0')
                .width(60)
                .height(60)
                .borderRadius(30)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
            }
          }
          .margin({ bottom: 8 })
          Text('退换/售后')
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
        Column() {
          Text('📍')
            .fontSize(32)
            .margin({ bottom: 8 })
          Text('收货地址')
            .fontSize(14)
            .fontColor(COLORS.secondary)
        }
        .width('25%')
        .alignItems(HorizontalAlign.Center)
        .padding(16)
        .backgroundColor(COLORS.cardBg)
        .onClick(() => {
          this.onNavigate('pages/AddressManagePage')
        })

        Column() {
          Text('👤')
            .fontSize(32)
            .margin({ bottom: 8 })
          Text('销售客服')
            .fontSize(14)
            .fontColor(COLORS.secondary)
        }
        .width('25%')
        .alignItems(HorizontalAlign.Center)
        .padding(16)
        .backgroundColor(COLORS.cardBg)

        Column() {
          Text('📦')
            .fontSize(32)
            .margin({ bottom: 8 })
          Text('我的包图')
            .fontSize(14)
            .fontColor(COLORS.secondary)
        }
        .width('25%')
        .alignItems(HorizontalAlign.Center)
        .padding(16)
        .backgroundColor(COLORS.cardBg)

        Column() {
          Text('📤')
            .fontSize(32)
            .margin({ bottom: 8 })
          Text('分享好友')
            .fontSize(14)
            .fontColor(COLORS.secondary)
        }
        .width('25%')
        .alignItems(HorizontalAlign.Center)
        .padding(16)
        .backgroundColor(COLORS.cardBg)
      }

      // 第二行服务
      Row() {
        Column() {
          Text('📖')
            .fontSize(32)
            .margin({ bottom: 8 })
          Text('新手教程')
            .fontSize(14)
            .fontColor(COLORS.secondary)
        }
        .width('25%')
        .alignItems(HorizontalAlign.Center)
        .padding(16)
        .backgroundColor(COLORS.cardBg)

        Column() {
          Text('❤️')
            .fontSize(32)
            .margin({ bottom: 8 })
          Text('我的收藏')
            .fontSize(14)
            .fontColor(COLORS.secondary)
        }
        .width('25%')
        .alignItems(HorizontalAlign.Center)
        .padding(16)
        .backgroundColor(COLORS.cardBg)
        .onClick(() => {
          this.onNavigate('pages/FavoritePage')
        })

        Column() {
          Text('🛒')
            .fontSize(32)
            .margin({ bottom: 8 })
          Text('购物车')
            .fontSize(14)
            .fontColor(COLORS.secondary)
        }
        .width('25%')
        .alignItems(HorizontalAlign.Center)
        .padding(16)
        .backgroundColor(COLORS.cardBg)
        .onClick(() => {
          this.onNavigate('pages/CartPageNew')
        })

        Column() {
          Text('🎧')
            .fontSize(32)
            .margin({ bottom: 8 })
          Text('客服中心')
            .fontSize(14)
            .fontColor(COLORS.secondary)
        }
        .width('25%')
        .alignItems(HorizontalAlign.Center)
        .padding(16)
        .backgroundColor(COLORS.cardBg)
      }

      // 关于我们
      Text('关于我们')
        .fontSize(16)
        .fontColor(COLORS.primary)
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