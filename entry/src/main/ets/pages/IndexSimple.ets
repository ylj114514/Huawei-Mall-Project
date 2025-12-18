import router from '@ohos.router'
import { ProductModel, MockData } from '../model/ProductModel'
import { StorageManager } from '../utils/StorageManager'
import { User } from '../model/DataModel'
import common from '@ohos.app.ability.common'

@Entry
@Component
struct IndexSimple {
  @State products: ProductModel[] = []
  @State isLoading: boolean = true
  @State user: User | null = null
  @State cartCount: number = 0
  private storage: StorageManager = StorageManager.getInstance()
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  aboutToAppear() {
    this.initStorage()
    this.loadData()
    this.checkLoginStatus()
  }

  private async initStorage() {
    try {
      await this.storage.init(this.context)
      console.log('IndexSimple: StorageManager初始化成功')
    } catch (error) {
      console.error('IndexSimple: StorageManager初始化失败:', error)
    }
  }

  private async loadData() {
    setTimeout(() => {
      this.products = MockData.generateProducts()
      this.isLoading = false
      console.log('加载商品数据完成，数量：', this.products.length)
    }, 500)
  }

  private async checkLoginStatus() {
    try {
      this.user = await this.storage.loadUser()
      console.log('登录状态检查完成，用户：', this.user?.username)
    } catch (error) {
      console.error('检查登录状态失败:', error)
    }
  }

  private onProductClick(product: ProductModel) {
    router.pushUrl({
      url: 'pages/ProductDetailComplete',
      params: {
        productId: product.id
      }
    })
  }

  @Builder
  HeroBanner() {
    Swiper() {
      ForEach([
        {
          title: '华为 Mate 60 Pro',
          subtitle: '王者归来 强势登场',
          desc: '麒麟回归 · 卫星通话 · 超光变影像',
          image: 'https://consumer-img.huawei.com/content/dam/huawei-cbg-site/cn/mkt/imgs/2024/01/mate-60-pro-list-kv.png',
          color: '#000000'
        },
        {
          title: '鸿蒙生态',
          subtitle: '万物互联 智慧生活',
          desc: '系统级连接 · 极简体验',
          image: 'https://consumer-img.huawei.com/content/dam/huawei-cbg-site/cn/mkt/imgs/2023/08/harmonyos-pc-kv.png',
          color: '#CF0A2C'
        },
        {
          title: 'WATCH GT 4',
          subtitle: '专业运动健康管家',
          desc: '14天超长续航 · 精准定位',
          image: 'https://consumer-img.huawei.com/content/dam/huawei-cbg-site/cn/market/wearables/watch-gt-4/img/kv/watch-gt-4-kv-black.png',
          color: '#1A5CFF'
        }
      ], (banner: Record<string, string>, index: number) => {
        Stack() {
          Image(banner.image)
            .width('100%')
            .height(180)
            .objectFit(ImageFit.Cover)
            .borderRadius(12)

          Column() {
            Text(banner.title || '')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .margin({ bottom: 4 })

            Text(banner.subtitle || '')
              .fontSize(16)
              .fontColor('rgba(255,255,255,0.9)')
              .margin({ bottom: 8 })

            Text(banner.desc || '')
              .fontSize(14)
              .fontColor('rgba(255,255,255,0.8)')
              .lineHeight(20)
          }
          .width('100%')
          .padding(20)
          .position({ x: 0, y: 0 })
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [
              ['rgba(0,0,0,0.6)', 0.0],
              ['rgba(0,0,0,0.3)', 0.7],
              ['rgba(0,0,0,0)', 1.0]
            ]
          })
          .borderRadius({ topLeft: 12, topRight: 12 })
        }
      })
    }
    .width('100%')
    .height(180)
    .autoPlay(true)
    .interval(3000)
    .indicatorStyle({
      size: 6,
      left: 0,
      right: 0,
      bottom: 12,
      color: 'rgba(255,255,255,0.4)',
      selectedColor: Color.White
    })
    .borderRadius(12)
    .margin({ bottom: 16 })
  }

  @Builder
  ProductCard(product: ProductModel) {
    Column() {
      // 图片容器
      Stack() {
        Image(product.image)
          .width('100%')
          .height(160)
          .objectFit(ImageFit.Contain)
          .backgroundColor('#F5F5F5')
          .borderRadius({ topLeft: 12, topRight: 12 })

        // 折扣标签
        if (product.originalPrice && product.originalPrice > product.price) {
          Text(`${Math.floor(((product.originalPrice - product.price) / product.originalPrice) * 100)}%`)
            .fontSize(12)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#FF0000')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius({ bottomLeft: 8, topRight: 12 })
            .position({ x: 0, y: 0 })
        }
      }

      // 商品信息
      Column() {
        Text(product.name)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ bottom: 8 })

        // 标签
        if (product.tags && product.tags.length > 0) {
          Text(product.tags[0])
            .fontSize(12)
            .fontColor('#999999')
            .backgroundColor('#F5F5F5')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(4)
            .margin({ bottom: 8 })
        }

        // 价格
        Row() {
          Row() {
            Text('¥')
              .fontSize(12)
              .fontColor('#FF0000')
              .margin({ top: 2 })
            Text(`${product.price}`)
              .fontSize(18)
              .fontColor('#FF0000')
              .fontWeight(FontWeight.Bold)
          }
          .alignItems(VerticalAlign.Bottom)

          // 销量
          Text(`月销 ${Math.floor(Math.random() * 1000 + 100)}`)
            .fontSize(12)
            .fontColor('#999999')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .padding(12)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 6,
      color: 'rgba(0,0,0,0.08)',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      this.onProductClick(product)
    })
  }

  @Builder
  BottomNav() {
    Row() {
      Column() {
        Text('🏠')
          .fontSize(24)
          .margin({ bottom: 4 })
        Text('首页')
          .fontSize(12)
          .fontColor('#FF0000')
      }
      .width('33.33%')
      .height(60)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        // 当前页面
      })

      Column() {
        Text('🛒')
          .fontSize(24)
          .margin({ bottom: 4 })
        Text('购物车')
          .fontSize(12)
          .fontColor('#666666')
      }
      .width('33.33%')
      .height(60)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        router.pushUrl({ url: 'pages/CartPageNew' })
      })

      Column() {
        Text(this.user ? '👤' : '👤')
          .fontSize(24)
          .margin({ bottom: 4 })
        Text(this.user ? '我的' : '登录')
          .fontSize(12)
          .fontColor('#666666')
      }
      .width('33.33%')
      .height(60)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        if (!this.user) {
          router.pushUrl({ url: 'pages/LoginPage' })
        } else {
          router.pushUrl({ url: 'pages/UserCenterPage' })
        }
      })
    }
    .width('100%')
    .height(60)
    .backgroundColor(Color.White)
    .position({ x: 0, y: '100%' })
    .translate({ x: 0, y: -60 })
    .shadow({
      radius: 10,
      color: 'rgba(0,0,0,0.1)',
      offsetX: 0,
      offsetY: -2
    })
  }

  build() {
    Stack() {
      // 主内容
      Scroll() {
        Column() {
          // 顶部标题
          Row() {
            Text('华为商城')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#000000')

            Blank()

            Button('登录')
              .fontSize(16)
              .fontColor('#FF0000')
              .backgroundColor(Color.Transparent)
              .border({ width: 1, color: '#FF0000' })
              .borderRadius(20)
              .padding({ left: 20, right: 20 })
              .height(36)
              .onClick(() => {
                router.pushUrl({ url: 'pages/LoginPage' })
              })
          }
          .width('100%')
          .padding(20)
          .margin({ bottom: 20 })

          // Hero 横幅
          this.HeroBanner()

          // 商品列表
          if (this.products.length > 0) {
            Grid() {
              ForEach(this.products, (product: ProductModel) => {
                GridItem() {
                  this.ProductCard(product)
                }
              })
            }
            .columnsTemplate('1fr 1fr')
            .rowsGap(12)
            .columnsGap(12)
            .padding({ left: 16, right: 16, bottom: 80 })
          } else {
            Text('暂无商品')
              .fontSize(18)
              .fontColor('#666666')
              .margin({ top: 100 })
          }
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

      // 底部导航
      this.BottomNav()

      // 加载状态
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#FF0000')
          Text('加载中...')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 16 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F5F5F5')
        .zIndex(1000)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}