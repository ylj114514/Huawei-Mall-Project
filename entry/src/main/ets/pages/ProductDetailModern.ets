import router from '@ohos.router'
import { ProductModel, MockData } from '../model/ProductModel'
import { FavoriteService } from '../services/FavoriteService'

interface ProductParams {
  productId: string
}

// 评论数据模型
interface Comment {
  id: string
  userName: string
  avatar: string
  rating: number
  content: string
  images: string[]
  date: string
  helpfulCount: number
  spec: string
}

// 模拟评论数据
const MockComments: Comment[] = [
  {
    id: '1',
    userName: '张先生',
    avatar: '',
    rating: 5,
    content: '手机非常出色，麒麟芯片性能强劲，鸿蒙系统流畅。拍照效果惊艳，特别是夜景模式。续航能力强，一天使用无压力。',
    images: [],
    date: '2024-01-15',
    helpfulCount: 234,
    spec: '12GB+512GB 雅川青'
  },
  {
    id: '2',
    userName: '李女士',
    avatar: '',
    rating: 4,
    content: '整体使用体验很好，系统流畅，外观设计精美。唯一的小缺点是有点重，但考虑到配置和电池容量，可以接受。',
    images: [],
    date: '2024-01-10',
    helpfulCount: 156,
    spec: '12GB+256GB 雅黑'
  }
]

@Entry
@Component
struct ProductDetailModern {
  @State product: ProductModel | null = null
  @State selectedSpec: string = '12GB+512GB'
  @State selectedColor: string = '雅川青'
  @State quantity: number = 1
  @State isLoading: boolean = true
  @State isFavorite: boolean = false
  @State showReviewModal: boolean = false
  @State comments: Comment[] = MockComments
  @State currentImageIndex: number = 0

  private specs: string[] = ['12GB+256GB', '12GB+512GB', '16GB+512GB', '16GB+1TB']
  private colors: string[] = ['雅川青', '雅黑', '雅白', '雅丹霞']
  private favoriteService: FavoriteService = FavoriteService.getInstance()

  aboutToAppear() {
    this.loadProductData()
  }

  private async loadProductData() {
    const params = router.getParams() as ProductParams
    if (params?.productId) {
      const products = MockData.generateProducts()
      this.product = products.find(p => p.id === params.productId) || null

      if (this.product) {
        this.isFavorite = await this.favoriteService.isFavorite(this.product.id)
      }
    }
    this.isLoading = false
  }

  private async onToggleFavorite() {
    if (!this.product) return

    try {
      if (this.isFavorite) {
        await this.favoriteService.removeFromFavorites(this.product.id)
        this.isFavorite = false
      } else {
        await this.favoriteService.addToFavorites(this.product)
        this.isFavorite = true
      }
    } catch (error) {
      console.error('切换收藏状态失败:', error)
    }
  }

  private onAddToCart() {
    // 添加到购物车逻辑
    console.log('添加到购物车')
  }

  private onBuyNow() {
    // 立即购买逻辑
    console.log('立即购买')
  }

  @Builder
  NavigationBar() {
    Row() {
      // 返回按钮 - 增大点击区域
      Button() {
        Text('←')
          .fontSize(24)
          .fontColor('#FFFFFF')
      }
      .width(48)
      .height(48)
      .backgroundColor(Color.Transparent)
      .onClick(() => router.back())

      Blank()

      Text('商品详情')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')

      Blank()

      Row({ space: 20 }) {
        // 分享按钮
        Button() {
          Text('↗')
            .fontSize(24)
            .fontColor('#FFFFFF')
        }
        .width(48)
        .height(48)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          console.log('分享')
        })

        // 收藏按钮
        Button() {
          Text(this.isFavorite ? '❤️' : '🤍')
            .fontSize(20)
        }
        .width(48)
        .height(48)
        .backgroundColor(Color.Transparent)
        .onClick(() => this.onToggleFavorite())
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .position({ x: 0, y: 0 })
    .zIndex(1000)
  }

  @Builder
  HeroSection() {
    Column() {
      Swiper() {
        ForEach(this.product?.images || [this.product?.image], (image: string, index?: number) => {
          Image(image)
            .width('100%')
            .height(450)
            .objectFit(ImageFit.Contain)
            .backgroundColor('#0A0A0A')
            .borderRadius(0)
        })
      }
      .width('100%')
      .height(450)
      .loop(true)
      .autoPlay(true)
      .interval(3000)
      .indicatorStyle({
        size: 8,
        left: 0,
        right: 0,
        top: 400,
        color: 'rgba(255,255,255,0.3)',
        selectedColor: '#FFFFFF'
      })
      .onChange((index: number) => {
        this.currentImageIndex = index
      })

      // 图片指示器
      Row() {
        ForEach(this.product?.images || [this.product?.image], (image: string, index?: number) => {
          Circle({ width: 8, height: 8 })
            .fill(index === this.currentImageIndex ? '#FFFFFF' : 'rgba(255,255,255,0.3)')
            .margin({ left: 4, right: 4 })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: -20 })
      .zIndex(10)
    }
    .width('100%')
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [
        ['#0A0A0A', 0.0],
        ['#1A1A1A', 0.3],
        ['#0A0A0A', 1.0]
      ]
    })
  }

  @Builder
  ProductInfo() {
    Column() {
      // 价格和标题
      Column() {
        Row() {
          Text(`¥${this.product?.price || 0}`)
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')

          if (this.product?.originalPrice && this.product.originalPrice > this.product.price) {
            Text(`¥${this.product.originalPrice}`)
              .fontSize(20)
              .fontColor('rgba(255,255,255,0.5)')
              .decoration({ type: TextDecorationType.LineThrough })
              .margin({ left: 16 })
          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Bottom)

        Text(this.product?.name || '')
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .width('100%')
          .margin({ top: 16 })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        // 标签
        Row({ space: 8 }) {
          ForEach(this.product?.tags || [], (tag: string) => {
            Text(tag)
              .fontSize(12)
              .fontColor('#FFFFFF')
              .backgroundColor('rgba(255,255,255,0.1)')
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .borderRadius(4)
          })
        }
        .width('100%')
        .margin({ top: 12 })
      }
      .width('100%')
      .padding(24)
      .backgroundColor('#1A1A1A')
      .borderRadius(24)
      .margin({ top: -40 })
      .zIndex(10)

      // 规格选择
      Column() {
        Text('选择规格')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
          .width('100%')
          .margin({ bottom: 16 })

        // 内存版本
        Column() {
          Row() {
            Text('版本')
              .fontSize(14)
              .fontColor('#666666')
              .width('20%')
            Blank()
          }
          .width('100%')
          .margin({ bottom: 12 })

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.specs, (spec: string) => {
              Text(spec)
                .fontSize(14)
                .fontColor(this.selectedSpec === spec ? '#FFFFFF' : '#1A1A1A')
                .backgroundColor(this.selectedSpec === spec ? '#1A1A1A' : '#F5F5F5')
                .padding({ left: 20, right: 20, top: 12, bottom: 12 })
                .borderRadius(8)
                .margin({ right: 12, bottom: 8 })
                .onClick(() => {
                  this.selectedSpec = spec
                })
            })
          }
          .width('100%')
        }
        .width('100%')
        .margin({ bottom: 24 })

        // 颜色选择
        Column() {
          Row() {
            Text('颜色')
              .fontSize(14)
              .fontColor('#666666')
              .width('20%')
            Text(this.selectedColor)
              .fontSize(14)
              .fontColor('#1A1A1A')
              .margin({ right: 8 })
            Text('>')
              .fontSize(16)
              .fontColor('#666666')
            Blank()
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onClick(() => {
            console.log('选择颜色')
          })
        }
        .width('100%')
      }
      .width('100%')
      .padding(24)
      .backgroundColor('#FFFFFF')
      .borderRadius(24)
      .margin({ top: 12 })

      // 服务保障
      Row() {
        Row() {
          Text('✓')
            .fontSize(16)
            .fontColor('#00C853')
            .fontWeight(FontWeight.Bold)
          Text('官方正品')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ left: 4 })
        }

        Row() {
          Text('✓')
            .fontSize(16)
            .fontColor('#00C853')
            .fontWeight(FontWeight.Bold)
          Text('七天无理由')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ left: 4 })
        }

        Row() {
          Text('✓')
            .fontSize(16)
            .fontColor('#00C853')
            .fontWeight(FontWeight.Bold)
          Text('顺丰包邮')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ left: 4 })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(24)
      .margin({ top: 12 })
    }
    .width('100%')
    .padding({ bottom: 100 })
  }

  @Builder
  CommentSection() {
    Column() {
      Row() {
        Text('用户评价')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')

        Row() {
          Text('查看全部')
            .fontSize(14)
            .fontColor('#666666')
          Text('>')
            .fontSize(16)
            .fontColor('#666666')
        }
        .onClick(() => {
          this.showReviewModal = true
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 20 })

      // 评论列表
      ForEach(this.comments, (comment: Comment) => {
        Column() {
          Row() {
            Text(comment.userName[0])
              .fontSize(18)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .width(40)
              .height(40)
              .backgroundColor('#E0E0E0')
              .borderRadius(20)
              .textAlign(TextAlign.Center)

            Column() {
              Text(comment.userName)
                .fontSize(14)
                .fontColor('#1A1A1A')
                .fontWeight(FontWeight.Medium)
              Text(comment.spec)
                .fontSize(12)
                .fontColor('#999999')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            .margin({ left: 12 })

            Text(comment.date)
              .fontSize(12)
              .fontColor('#999999')
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
          .margin({ bottom: 12 })

          // 评分
          Row() {
            ForEach([1, 2, 3, 4, 5], (star: number) => {
              Text('★')
                .fontSize(16)
                .fontColor(star <= comment.rating ? '#FFD700' : '#E0E0E0')
            })
          }
          .margin({ bottom: 12 })

          Text(comment.content)
            .fontSize(14)
            .fontColor('#333333')
            .lineHeight(22)
            .width('100%')
            .margin({ bottom: 12 })

          Row() {
            Text('有用 (${comment.helpfulCount})')
              .fontSize(12)
              .fontColor('#666666')
              .backgroundColor('#F5F5F5')
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .borderRadius(4)
          }
          .width('100%')
          .justifyContent(FlexAlign.End)
        }
        .width('100%')
        .padding(20)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .margin({ bottom: 12 })
      })
    }
    .width('100%')
    .padding({ left: 20, right: 20 })
    .margin({ top: 12 })
  }

  @Builder
  BottomActionBar() {
    Row() {
      // 购物车按钮
      Column() {
        Text('🛒')
          .fontSize(28)
          .fontColor('#1A1A1A')

        Text('购物车')
          .fontSize(12)
          .fontColor('#666666')
          .margin({ top: 4 })
      }
      .width(48)
      .height(48)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        router.pushUrl({ url: 'pages/CartPageNew' })
      })

      Button('加入购物车')
        .height(50)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor('#1A1A1A')
        .borderRadius(25)
        .layoutWeight(1)
        .margin({ left: 20, right: 12 })
        .onClick(() => this.onAddToCart())

      Button('立即购买')
        .height(50)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor('#FF3B30')
        .borderRadius(25)
        .layoutWeight(1)
        .onClick(() => this.onBuyNow())
    }
    .width('100%')
    .padding({ left: 20, right: 20, bottom: 20, top: 12 })
    .backgroundColor('rgba(255,255,255,0.98)')
    .backdropBlur(20)
    .border({ width: { top: 0.5 }, color: '#E5E5E5' })
  }

  build() {
    Stack() {
      Scroll() {
        Column() {
          // Hero 区域
          this.HeroSection()

          // 商品信息
          this.ProductInfo()

          // 评价区域
          this.CommentSection()

          // 商品详情
          Column() {
            Text('商品详情')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1A1A1A')
              .width('100%')
              .margin({ bottom: 20 })

            Text(this.product?.detailDescription || '')
              .fontSize(14)
              .fontColor('#666666')
              .lineHeight(24)
              .width('100%')
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(24)
          .margin({ top: 12, bottom: 120 })
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F7')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      // 导航栏
      this.NavigationBar()

      // 底部操作栏
      Stack() {
        this.BottomActionBar()
      }
      .position({ x: 0, y: '100%' })
      .translate({ x: 0, y: -110 })

      // 加载状态
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#1A1A1A')
          Text('加载中...')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 16 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F5F5F7')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F7')
  }
}