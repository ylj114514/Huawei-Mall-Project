import router from '@ohos.router'
import { ProductModel, MockData } from '../model/ProductModel'
import { BottomNavBar } from '../components/BottomNavBar'

@Entry
@Component
struct IndexModern {
  @State products: ProductModel[] = []
  @State currentBanner: number = 0
  @State searchText: string = ''
  @State categories: string[] = ['手机', '笔记本', '平板', '穿戴', '音频', '智慧屏']
  private bannerImages = [
    'https://consumer-img.huawei.com/content/dam/huawei-cbg-site/cn/market/mobiles-phones/mate-60-pro/img/kv/mate-60-pro-kv-black.png',
    'https://consumer-img.huawei.com/content/dam/huawei-cbg-site/cn/market/wearables/watch-gt-4/img/kv/watch-gt-4-kv-black.png',
    'https://consumer-img.huawei.com/content/dam/huawei-cbg-site/cn/market/tablets/matepad-pro/img/kv/matepad-pro-kv-gray.png'
  ]

  aboutToAppear() {
    this.loadProducts()
  }

  private async loadProducts() {
    // 模拟异步加载
    setTimeout(() => {
      this.products = MockData.generateProducts()
    }, 500)
  }

  @Builder
  HeroSection() {
    Stack() {
      // 背景渐变
      Column()
        .width('100%')
        .height(280)
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            ['#1a1a1a', 0.0],
            ['#2d2d2d', 0.5],
            ['#1a1a1a', 1.0]
          ]
        })

      // 主要内容
      Column() {
        // 顶部搜索栏
        Row() {
          Button() {
            Row() {
              Text('🔍')
                .fontSize(18)
                .fontColor('#666666')
              TextInput({
                placeholder: '搜索华为产品',
                text: this.searchText
              })
                .fontSize(16)
                .backgroundColor(Color.Transparent)
                .layoutWeight(1)
                .placeholderColor('#666666')
            }
          }
          .width('90%')
          .height(44)
          .backgroundColor('#ffffff08')
          .borderRadius(22)
          .backdropBlur(10)
          .padding({ left: 16, right: 16 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 20, bottom: 30 })

        // 轮播横幅
        Swiper() {
          ForEach(this.bannerImages, (img: string, index: number) => {
            Column() {
              Image(img)
                .width('100%')
                .height(160)
                .objectFit(ImageFit.Contain)
                .borderRadius(16)
                .shadow({
                  radius: 20,
                  color: '#00000030',
                  offsetX: 0,
                  offsetY: 10
                })
            }
          })
        }
        .width('90%')
        .height(160)
        .loop(true)
        .autoPlay(true)
        .interval(4000)
        .indicatorStyle({
          size: 6,
          color: '#ffffff40',
          selectedColor: '#ffffff'
        })

        // 品牌标语
        Text('华为 | 构建万物互联的智能世界')
          .fontSize(14)
          .fontColor('#ffffff80')
          .letterSpacing(2)
          .margin({ top: 20 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height(280)
  }

  @Builder
  CategorySection() {
    Column() {
      ForEach(this.categories, (category: string, index: number) => {
        Row() {
          // 图标
          Column() {
            Text(this.getCategoryIcon(category))
              .fontSize(24)
          }
          .width(40)
          .height(40)
          .backgroundColor(index % 2 === 0 ? '#FF3B30' : '#007AFF')
          .borderRadius(10)
          .justifyContent(FlexAlign.Center)

          Text(category)
            .fontSize(16)
            .fontColor('#1a1a1a')
            .fontWeight(FontWeight.Medium)
            .margin({ left: 12 })

          Blank()

          Text('>')
            .fontSize(16)
            .fontColor('#999999')
        }
        .width('90%')
        .height(60)
        .padding({ left: 20, right: 20 })
        .backgroundColor(Color.White)
        .borderRadius(16)
        .margin({ bottom: 12 })
        .shadow({
          radius: 8,
          color: '#00000008',
          offsetX: 0,
          offsetY: 2
        })
        .onClick(() => {
          // 处理分类点击
        })
      })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#f5f5f7')
  }

  private getCategoryIcon(category: string): string {
    const icons: Record<string, string> = {
      '手机': '📱',
      '笔记本': '💻',
      '平板': '📋',
      '穿戴': '⌚',
      '音频': '🎧',
      '智慧屏': '📺'
    }
    return icons[category] || '📱'
  }

  @Builder
  ProductCard(product: ProductModel) {
    Column() {
      // 图片容器
      Stack() {
        Image(product.image)
          .width('100%')
          .height(200)
          .objectFit(ImageFit.Cover)
          .borderRadius(20)
          .backgroundColor('#f5f5f7')

        // 折扣角标
        if (product.originalPrice > product.price) {
          Column() {
            Text('HOT')
              .fontSize(10)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
          .width(40)
          .height(20)
          .backgroundColor('#FF3B30')
          .borderRadius({ bottomLeft: 12, topRight: 20 })
          .position({ x: 0, y: 0 })
        }

        // 渐变遮罩
        Column()
          .width('100%')
          .height(80)
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [
              ['rgba(0,0,0,0)', 0.0],
              ['rgba(0,0,0,0.3)', 1.0]
            ]
          })
          .position({ x: 0, y: 120 })
      }

      // 产品信息
      Column() {
        Text(product.name)
          .fontSize(14)
          .fontColor('#1a1a1a')
          .fontWeight(FontWeight.Medium)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 8 })

        Row() {
          Column() {
            Row() {
              Text('¥')
                .fontSize(12)
                .fontColor('#FF3B30')
                .margin({ top: 2 })
              Text(`${product.price}`)
                .fontSize(20)
                .fontColor('#FF3B30')
                .fontWeight(FontWeight.Bold)
            }
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          Button() {
            Text('+')
              .fontSize(20)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
          .width(32)
          .height(32)
          .backgroundColor('#007AFF')
          .borderRadius(16)
          .shadow({
            radius: 8,
            color: '#007AFF40',
            offsetX: 0,
            offsetY: 2
          })
        }
        .width('100%')
        .alignItems(VerticalAlign.Bottom)
      }
      .padding(16)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(20)
    .shadow({
      radius: 12,
      color: '#00000010',
      offsetX: 0,
      offsetY: 4
    })
    .margin({ bottom: 16 })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/ProductDetailPage',
        params: { productId: product.id }
      })
    })
    .gesture(
      TapGesture()
        .onAction(() => {
          // 点击反馈动画
        })
    )
  }

  build() {
    Column() {
      // 主要内容区
      Scroll() {
        Column() {
          // Hero Section
          this.HeroSection()

          // 分类快捷入口
          Text('产品分类')
            .fontSize(24)
            .fontColor('#1a1a1a')
            .fontWeight(FontWeight.Bold)
            .margin({ top: 30, bottom: 20, left: 20 })
            .width('100%')

          this.CategorySection()

          // 热门产品
          Text('热门产品')
            .fontSize(24)
            .fontColor('#1a1a1a')
            .fontWeight(FontWeight.Bold)
            .margin({ top: 30, bottom: 20, left: 20 })
            .width('100%')

          // 产品网格
          Grid() {
            ForEach(this.products, (product: ProductModel) => {
              GridItem() {
                this.ProductCard(product)
              }
            })
          }
          .columnsTemplate('1fr')
          .padding({ left: 20, right: 20 })
          .width('100%')
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#f5f5f7')

      // 底部导航
      BottomNavBar()
        .position({ x: 0, y: '100%' })
        .translate({ x: 0, y: -60 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f7')
  }
}