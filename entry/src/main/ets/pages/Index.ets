import router from '@ohos.router'
import { ProductModel, MockData } from '../model/ProductModel'
import { User } from '../model/DataModel'
import { AuthService } from '../services/AuthService'
import common from '@ohos.app.ability.common'

// =========================================
// 1. 数据模型定义
// =========================================

// 路由参数类
class ProductParams {
  productId: string
  constructor(productId: string) {
    this.productId = productId
  }
}

// 轮播图数据类
class BannerItem {
  title: string
  subtitle: string
  desc: string
  bgColor: string

  constructor(title: string, subtitle: string, desc: string, bgColor: string) {
    this.title = title
    this.subtitle = subtitle
    this.desc = desc
    this.bgColor = bgColor
  }
}

// 现代化配色方案
interface ColorScheme {
  background: string
  surface: string
  primary: string
  secondary: string
  text: string
  textSecondary: string
  accent: string
}

const COLORS: ColorScheme = {
  background: '#F5F7FA',
  surface: '#FFFFFF',
  primary: '#1A1A1A',
  secondary: '#6C757D',
  text: '#2C3E50',
  textSecondary: '#7F8C8D',
  accent: '#3498DB'
}

@Entry
@Component
struct Index {
  @State allProducts: ProductModel[] = []
  @State products: ProductModel[] = []

  // ✅ 新增：搜索相关状态
  @State searchSuggestions: ProductModel[] = []
  @State isSearching: boolean = false
  @State searchText: string = ''

  @State user: User | null = null
  @State isLoading: boolean = true
  @State selectedCategory: string = ''

  private authService: AuthService = AuthService.getInstance()

  // 轮播图数据 (保留原配置)
  private banners: BannerItem[] = [
    new BannerItem('Mate 60 系列', '玄武架构 鸿蒙生态', '超光变影像 · 卫星通话', '#1A1A1A'),
    new BannerItem('nova 12 系列', '潮流影像 超级快充', '人像大片 · 超级闪充', '#FF6B6B'),
    new BannerItem('WATCH GT 4', '专业运动 健康管理', '100+运动模式 · 科学睡眠', '#4ECDC4')
  ]

  private categoryNames: string[] = ['手机', '笔记本', '平板', '手表', '耳机', '智慧屏', '相机', '音响']

  aboutToAppear() {
    this.loadData()
    this.checkLoginStatus()
  }

  onPageShow() {
    this.checkLoginStatus()
  }

  private loadData() {
    setTimeout(() => {
      this.allProducts = MockData.generateProducts()
      this.products = this.allProducts
      this.isLoading = false
    }, 500)
  }

  private async checkLoginStatus() {
    this.user = await this.authService.getCurrentUser()
  }

  // ✅ 新增：搜索输入处理逻辑
  private handleSearchInput(value: string) {
    this.searchText = value
    if (value.trim().length === 0) {
      this.isSearching = false
      this.searchSuggestions = []
      this.products = this.allProducts
      return
    }

    this.isSearching = true
    const query = value.toLowerCase()

    // 模糊匹配
    this.searchSuggestions = this.allProducts.filter(p =>
    p.name.toLowerCase().includes(query) ||
      (p.description && p.description.toLowerCase().includes(query))
    )

    // 主列表也同步更新
    this.products = this.searchSuggestions
  }

  // 根据分类筛选商品
  private filterProducts(category: string) {
    if (category === '' || category === '全部') {
      this.products = this.allProducts
    } else {
      let actualCategory = category
      if (category === '手表') actualCategory = '智能手表'
      if (category === '电脑') actualCategory = '笔记本'

      this.products = this.allProducts.filter(product =>
      product.category.includes(actualCategory) ||
      product.name.includes(actualCategory)
      )
    }
  }

  private onProductClick(product: ProductModel) {
    this.isSearching = false // 点击后关闭搜索状态
    router.pushUrl({
      url: 'pages/ProductDetailPage',
      params: new ProductParams(product.id)
    })
  }

  private getIcon(category: string): string {
    if (category === '手机') return '📱'
    if (category === '笔记本') return '💻'
    if (category === '平板') return '📲'
    if (category === '手表') return '⌚'
    if (category === '耳机') return '🎧'
    if (category === '智慧屏') return '📺'
    if (category === '相机') return '📷'
    if (category === '音响') return '🔊'
    return '📱'
  }

  // =========================================
  // UI 构建部分
  // =========================================

  @Builder
  Header() {
    Column() {
      Row() {
        // Logo
        Column() {
          Text('HUAWEI')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(COLORS.primary)
          Text('华为商城')
            .fontSize(12)
            .fontColor(COLORS.secondary)
            .margin({ top: -4 })
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        // 搜索栏
        Row() {
          TextInput({ placeholder: '搜索商品', text: this.searchText })
            .width(200)
            .height(36)
            .fontSize(14)
            .backgroundColor('#F0F2F5')
            .borderRadius(18)
            .padding({ left: 16 })
            .onChange((value: string) => {
              this.handleSearchInput(value) // ✅ 绑定搜索逻辑
            })
        }

        Blank().width(20)

        // 用户头像
        Button() {
          if (this.user && this.user.avatar) {
            Image(this.user.avatar)
              .width(36)
              .height(36)
              .borderRadius(18)
          } else {
            Text('👤')
              .fontSize(22)
          }
        }
        .width(36)
        .height(36)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          if (this.user) {
            router.pushUrl({ url: 'pages/UserCenterPage' })
          } else {
            router.pushUrl({ url: 'pages/LoginPage' })
          }
        })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 12 })
      .backgroundColor(COLORS.surface)

      // ✅ 新增：搜索联想列表 (悬浮在 Header 下方)
      if (this.isSearching && this.searchSuggestions.length > 0) {
        List() {
          ForEach(this.searchSuggestions, (item: ProductModel) => {
            ListItem() {
              Row() {
                Text('🔍').fontSize(12).fontColor(COLORS.secondary).margin({ right: 8 })
                Text(item.name)
                  .fontSize(14)
                  .fontColor(COLORS.text)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .layoutWeight(1)
              }
              .width('100%')
              .padding(12)
              .backgroundColor(COLORS.surface)
              .onClick(() => this.onProductClick(item))
            }
          })
        }
        .width('100%')
        .backgroundColor(COLORS.surface)
        .shadow({ radius: 10, color: 'rgba(0,0,0,0.1)', offsetY: 5 })
        .position({ x: 0, y: 60 })
        .zIndex(999)
        // ✅ 核心修复：使用 constraintSize 而不是 constraints
        .constraintSize({ maxHeight: 200 })
      }
    }
    .zIndex(100) // 确保 Header 整体在最上层
  }

  @Builder
  HeroBanner() {
    Swiper() {
      ForEach(this.banners, (banner: BannerItem) => {
        Column() {
          Text(banner.title)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .margin({ bottom: 8 })

          Text(banner.subtitle)
            .fontSize(16)
            .fontColor('rgba(255,255,255,0.9)')
            .margin({ bottom: 8 })

          Text(banner.desc)
            .fontSize(14)
            .fontColor('rgba(255,255,255,0.8)')
        }
        .width('100%')
        .height(200)
        .padding(20)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(banner.bgColor)
        .borderRadius(16)
      })
    }
    .width('100%')
    .height(200)
    .autoPlay(true)
    .interval(3000)
    .indicatorStyle({
      size: 6,
      left: 20,
      right: 20,
      bottom: 12,
      color: 'rgba(255,255,255,0.4)',
      selectedColor: Color.White
    })
    .padding({ left: 20, right: 20 })
  }

  @Builder
  CategoryGrid() {
    Column() {
      Text('商品分类')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(COLORS.text)
        .width('100%')
        .margin({ bottom: 20 })
        .padding({ left: 20 })

      Scroll() {
        Row({ space: 12 }) {
          ForEach(this.categoryNames, (item: string) => {
            Column() {
              Text(this.getIcon(item))
                .fontSize(30)
                .margin({ bottom: 8 })
              Text(item)
                .fontSize(12)
                .fontColor(COLORS.text)
            }
            .width(80)
            .height(80)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.selectedCategory === item ? '#E8E8E8' : Color.Transparent)
            .borderRadius(8)
            .onClick(() => {
              this.selectedCategory = item
              this.filterProducts(item)
            })
          })
        }
        .padding({ left: 20, right: 20 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .width('100%')
      .height(120)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .backgroundColor(COLORS.surface)
    .margin({ top: 12 })
  }

  @Builder
  ProductCard(product: ProductModel) {
    Column() {
      // 图片容器
      Stack() {
        Image(product.image)
          .width('100%')
          .height(180)
          .objectFit(ImageFit.Contain)
          .backgroundColor('#F8F9FA')
          .borderRadius({ topLeft: 12, topRight: 12 })

        // 折扣标签
        if (product.originalPrice && product.originalPrice > product.price) {
          Text(`-${Math.floor(((product.originalPrice - product.price) / product.originalPrice) * 100)}%`)
            .fontSize(12)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#FF6B6B')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius({ bottomLeft: 8, topRight: 12 })
            .position({ x: 0, y: 0 })
        }
      }

      // 商品信息
      Column() {
        Text(product.name)
          .fontSize(14)
          .fontColor(COLORS.text)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ bottom: 8 })

        // 评分
        Row() {
          ForEach([1, 2, 3, 4, 5], (star: number) => {
            Text('★')
              .fontSize(12)
              .fontColor(star <= 4 ? '#FFD700' : '#E0E0E0')
          })
          Text(' 4.8')
            .fontSize(12)
            .fontColor(COLORS.textSecondary)
            .margin({ left: 4 })
          Text('(2k+)')
            .fontSize(12)
            .fontColor(COLORS.textSecondary)
        }
        .width('100%')
        .margin({ bottom: 8 })

        // 价格
        Row() {
          Text(`¥${product.price}`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF6B6B')

          if (product.originalPrice && product.originalPrice > product.price) {
            Text(`¥${product.originalPrice}`)
              .fontSize(14)
              .fontColor(COLORS.textSecondary)
              .decoration({ type: TextDecorationType.LineThrough })
              .margin({ left: 8 })
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }
      .padding(12)
      .width('100%')
    }
    .width('100%')
    .backgroundColor(COLORS.surface)
    .borderRadius(12)
    .shadow({
      radius: 6,
      color: '#00000010',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => this.onProductClick(product))
  }

  @Builder
  BottomNav() {
    Row() {
      // 首页
      Column() {
        Text('🏠')
          .fontSize(28)
          .margin({ bottom: 4 })
        Text('首页')
          .fontSize(12)
          .fontColor(COLORS.primary)
      }
      .width('50%')
      .height(60)
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#F0F2F5')

      // 个人中心
      Column() {
        Text('👤')
          .fontSize(28)
          .margin({ bottom: 4 })
        Text('我的')
          .fontSize(12)
          .fontColor(COLORS.secondary)
      }
      .width('50%')
      .height(60)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        if (this.user) {
          router.pushUrl({ url: 'pages/UserCenterPage' })
        } else {
          router.pushUrl({ url: 'pages/LoginPage' })
        }
      })
    }
    .width('100%')
    .height(60)
    .backgroundColor(COLORS.surface)
    .border({ width: { top: 0.5 }, color: '#E5E5E5' })
  }

  build() {
    Column() {
      // 顶部导航
      this.Header()

      // 主内容
      Scroll() {
        Column() {
          // 轮播图
          this.HeroBanner()

          // 分类网格
          this.CategoryGrid()

          // 推荐商品
          Column() {
            Row() {
              Text('推荐商品')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor(COLORS.text)
              Blank()
              Text('查看全部')
                .fontSize(14)
                .fontColor(COLORS.textSecondary)
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 24, bottom: 16 })

            // 商品网格
            Grid() {
              ForEach(this.products, (product: ProductModel) => {
                GridItem() {
                  this.ProductCard(product)
                }
              }, (product: ProductModel) => product.id)
            }
            .columnsTemplate('1fr 1fr')
            .rowsGap(12)
            .columnsGap(12)
            .padding({ left: 20, right: 20, bottom: 80 })
          }
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(COLORS.background)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Off)

      // 底部导航
      this.BottomNav()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLORS.background)
  }
}