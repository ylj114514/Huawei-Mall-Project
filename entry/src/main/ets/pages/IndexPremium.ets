import router from '@ohos.router'
import { ProductModel, MockData } from '../model/ProductModel'
import { StorageManager } from '../utils/StorageManager'
import { User } from '../model/DataModel'

// 常量定义
const BACKGROUND_COLOR = '#F1F3F5'
const CARD_BACKGROUND = '#FFFFFF'
const TEXT_PRIMARY = '#000000'
const TEXT_SECONDARY = '#666666'
const TEXT_TERTIARY = '#999999'
const HUAWEI_RED = '#FF0000'
const BORDER_COLOR = '#E5E5E5'
const SHADOW_COLOR = 'rgba(0,0,0,0.05)'
const SEARCH_BAR_HEIGHT = 56

@Entry
@Component
struct IndexPremium {
  @State products: ProductModel[] = []
  @State filteredProducts: ProductModel[] = []
  @State searchText: string = ''
  @State selectedCategory: string = '全部'
  @State isLoading: boolean = true
  @State scrollOffset: number = 0
  @State searchOpacity: number = 0
  @State user: User | null = null
  @State cartCount: number = 0

  private categories: string[] = ['全部', '手机', '平板', '笔记本', '手表', '耳机']
  private scroller: Scroller = new Scroller()
  private storage: StorageManager = StorageManager.getInstance()

  aboutToAppear() {
    this.loadData()
    this.checkLoginStatus()
  }

  private async loadData() {
    setTimeout(() => {
      this.products = MockData.generateProducts()
      this.filteredProducts = this.products
      this.isLoading = false
    }, 800)
  }

  private async checkLoginStatus() {
    try {
      this.user = await this.storage.loadUser()
    } catch (error) {
      console.error('检查登录状态失败:', error)
    }
  }

  private onScroll(offset: number) {
    this.scrollOffset = offset
    // 搜索栏透明度插值：0-100px透明，100px以上不透明
    this.searchOpacity = Math.max(0, Math.min(1, (100 - offset) / 100))
  }

  private onSearch(value: string) {
    this.searchText = value
    this.filterProducts()
  }

  private filterProducts() {
    let filtered = this.products

    // 按分类筛选
    if (this.selectedCategory !== '全部') {
      filtered = filtered.filter(product =>
        product.category === this.selectedCategory
      )
    }

    // 按搜索关键词筛选
    if (this.searchText.trim()) {
      const query = this.searchText.toLowerCase()
      filtered = filtered.filter(product =>
        product.name.toLowerCase().includes(query) ||
        product.description.toLowerCase().includes(query)
      )
    }

    this.filteredProducts = filtered
  }

  private onCategorySelect(category: string) {
    this.selectedCategory = category
    this.filterProducts()
  }

  private onProductClick(product: ProductModel) {
    router.pushUrl({
      url: 'pages/ProductDetailComplete',
      params: {
        productId: product.id
      }
    })
  }

  private onSearchClick() {
    if (this.searchText) {
      this.filterProducts()
    }
  }

  @Builder
  SearchBar() {
    Column() {
      // 顶部状态栏占位
      Row().width('100%').height(44)

      // 搜索栏容器
      Row() {
        Row() {
          Text('🔍')
            .fontSize(20)
            .fontColor(TEXT_TERTIARY)
            .margin({ left: 20 })

          TextInput({
            placeholder: '搜索产品、型号、功能',
            text: this.searchText
          })
            .fontSize(16)
            .fontColor(TEXT_PRIMARY)
            .backgroundColor(Color.Transparent)
            .layoutWeight(1)
            .placeholderColor(TEXT_TERTIARY)
            .onChange((value: string) => {
              this.onSearch(value)
            })
            .onSubmit(() => {
              this.onSearchClick()
            })

          if (this.searchText) {
            Button() {
              Text('✕')
                .fontSize(16)
                .fontColor(TEXT_TERTIARY)
            }
            .width(40)
            .height(40)
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.searchText = ''
              this.onSearch('')
            })
          }
        }
        .width('100%')
        .height(48)
        .backgroundColor('#FAFAFA')
        .borderRadius(24)
        .border({
          width: 1,
          color: BORDER_COLOR
        })
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 16 })
    }
    .width('100%')
    .backgroundColor(`rgba(241, 243, 245, ${this.searchOpacity})`)
    .backdropBlur(this.searchOpacity > 0.5 ? 10 : 0)
    .border({
      width: { bottom: this.searchOpacity > 0 ? 0.5 : 0 },
      color: BORDER_COLOR
    })
    .zIndex(1000)
    .position({ x: 0, y: 0 })
    .transition({ type: TransitionType.All })
  }

  @Builder
  HeroBanner() {
    Swiper() {
      ForEach([
        { title: '华为 Mate 60 Pro', desc: '回归巅峰', image: 'https://consumer-img.huawei.com/content/dam/huawei-cbg-site/cn/mkt/imgs/2024/01/mate-60-pro-list-kv.png' },
        { title: '鸿蒙生态', desc: '万物互联', image: 'https://consumer-img.huawei.com/content/dam/huawei-cbg-site/cn/mkt/imgs/2023/08/harmonyos-pc-kv.png' },
        { title: '智慧屏', desc: '大屏精彩', image: 'https://consumer-img.huawei.com/content/dam/huawei-cbg-site/cn/mkt/imgs/2024/01/v85-kv.png' }
      ], (banner: Record<string, string>, index: number) => {
        Stack() {
          Image(banner.image)
            .width('100%')
            .height(200)
            .objectFit(ImageFit.Cover)
            .borderRadius(20)

          Column() {
            Text(banner.title)
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .margin({ bottom: 8 })

            Text(banner.desc)
              .fontSize(16)
              .fontColor('rgba(255,255,255,0.9)')
          }
          .width('100%')
          .padding(24)
          .position({ x: 0, y: 0 })
        }
      })
    }
    .width('100%')
    .height(200)
    .autoPlay(true)
    .interval(3000)
    .indicatorStyle({
      size: 8,
      color: 'rgba(255,255,255,0.5)',
      selectedColor: Color.White
    })
    .margin({ left: 20, right: 20 })
  }

  @Builder
  CategorySection() {
    Column() {
      Row() {
        Text('产品分类')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(TEXT_PRIMARY)

        Blank()
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20 })

      Row() {
        ForEach(this.categories, (category: string) => {
          Button(category)
            .fontSize(14)
            .fontColor(this.selectedCategory === category ? Color.White : TEXT_PRIMARY)
            .backgroundColor(this.selectedCategory === category ? HUAWEI_RED : CARD_BACKGROUND)
            .borderRadius(20)
            .padding({ left: 24, right: 24, top: 12, bottom: 12 })
            .height(44)
            .border({
              width: 1,
              color: this.selectedCategory === category ? HUAWEI_RED : BORDER_COLOR
            })
            .onClick(() => {
              this.onCategorySelect(category)
            })
        })
      }
      .width('100%')
      .padding({ left: 20, right: 20 })
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .width('100%')
    .backgroundColor(CARD_BACKGROUND)
    .borderRadius(20)
    .margin({ left: 20, right: 20, bottom: 24 })
  }

  @Builder
  ProductGrid() {
    Column() {
      if (this.filteredProducts.length > 0) {
        Grid() {
          ForEach(this.filteredProducts, (product: ProductModel) => {
            GridItem() {
              this.ProductCard(product)
            }
          })
        }
        .columnsTemplate('1fr 1fr')
        .rowsGap(20)
        .columnsGap(20)
        .padding({ left: 20, right: 20, bottom: 140 })
      } else if (!this.isLoading) {
        // 空状态
        Column() {
          Text('📦')
            .fontSize(64)
            .fontColor(TEXT_TERTIARY)
            .margin({ bottom: 16 })

          Text('暂无相关商品')
            .fontSize(16)
            .fontColor(TEXT_SECONDARY)
        }
        .width('100%')
        .height(300)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
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
          .backgroundColor('#F5F5F5')
          .borderRadius({ topLeft: 20, topRight: 20 })

        // 折扣标签
        if (product.originalPrice && product.originalPrice > product.price) {
          Text(`${Math.floor(((product.originalPrice - product.price) / product.originalPrice) * 100)}%`)
            .fontSize(12)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .backgroundColor(HUAWEI_RED)
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .borderRadius({ bottomLeft: 12, topRight: 20 })
            .position({ x: 0, y: 0 })
        }
      }

      // 商品信息
      Column() {
        Text(product.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(TEXT_PRIMARY)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ top: 16, bottom: 8 })

        // 标签
        if (product.tags && product.tags.length > 0) {
          Text(product.tags[0])
            .fontSize(12)
            .fontColor(TEXT_TERTIARY)
            .backgroundColor('#F5F5F5')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .borderRadius(4)
            .width('100%')
            .margin({ bottom: 12 })
        }

        // 价格
        Row() {
          Row() {
            Text('¥')
              .fontSize(12)
              .fontColor(HUAWEI_RED)
              .margin({ top: 2 })
            Text(`${product.price}`)
              .fontSize(20)
              .fontColor(HUAWEI_RED)
              .fontWeight(FontWeight.Bold)
          }
          .alignItems(VerticalAlign.Bottom)

          Blank()

          // 销量提示
          Text(`月销 ${Math.floor(Math.random() * 1000 + 100)}`)
            .fontSize(12)
            .fontColor(TEXT_TERTIARY)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .backgroundColor(CARD_BACKGROUND)
    .borderRadius(20)
    .shadow({
      radius: 8,
      color: SHADOW_COLOR,
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
      // 首页
      Column() {
        Text('🏠')
          .fontSize(24)
          .margin({ bottom: 4 })
        Text('首页')
          .fontSize(12)
          .fontColor(HUAWEI_RED)
      }
      .width('50%')
      .height(60)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        // 当前页面，无需操作
      })

      // 个人中心
      Column() {
        Text(this.user ? '👤' : '👤')
          .fontSize(24)
          .margin({ bottom: 4 })
        Text(this.user ? '我的' : '登录')
          .fontSize(12)
          .fontColor(TEXT_SECONDARY)
      }
      .width('50%')
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
    .backgroundColor(CARD_BACKGROUND)
    .border({
      width: { top: 0.5 },
      color: BORDER_COLOR
    })
    .position({ x: 0, y: '100%' })
    .translate({ x: 0, y: -60 })
  }

  build() {
    Stack() {
      // 主内容滚动区域
      Scroll(this.scroller) {
        Column() {
          // 顶部占位（为搜索栏留空间）
          Row().width('100%').height(SEARCH_BAR_HEIGHT + 44)

          // Hero Banner
          this.HeroBanner()

          // 分类导航
          this.CategorySection()

          // 商品标题
          Row() {
            Text(`热门商品 (${this.filteredProducts.length})`)
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor(TEXT_PRIMARY)
            Blank()
          }
          .width('100%')
          .padding({ left: 20, right: 20, bottom: 16 })

          // 商品网格
          this.ProductGrid()
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(BACKGROUND_COLOR)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .onScroll((xOffset: number, yOffset: number) => {
        this.onScroll(yOffset)
      })

      // 搜索栏（固定在顶部）
      this.SearchBar()

      // 底部导航
      this.BottomNav()

      // 加载状态
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color(HUAWEI_RED)
          Text('加载中...')
            .fontSize(14)
            .fontColor(TEXT_SECONDARY)
            .margin({ top: 16 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(BACKGROUND_COLOR)
        .zIndex(1001)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BACKGROUND_COLOR)
  }
}