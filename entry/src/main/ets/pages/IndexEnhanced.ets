import router from '@ohos.router'
import { ProductModel, MockData } from '../model/ProductModel'
import { SearchBarEnhanced } from '../components/SearchBarEnhanced'
import { ProductCardEnhanced } from '../components/ProductCardEnhanced'
import { BottomNavBar } from '../components/BottomNavBar'
import { AppService } from '../services/AppService'
import { CartService } from '../services/CartService'

interface BannerItem {
  title: string
  subtitle: string
  color: string
}

@Entry
@Component
struct IndexEnhanced {
  @State products: ProductModel[] = []
  @State filteredProducts: ProductModel[] = []
  @State searchText: string = ''
  @State selectedCategory: string = '全部'
  @State isLoading: boolean = true
  @State isSearching: boolean = false
  @State categories: string[] = ['全部', '手机', '平板', '电脑', '耳机', '智能手表', '配件']
  @State showScrollTop: boolean = false
  private appService: AppService = AppService.getInstance()
  private cartService: CartService = CartService.getInstance()
  private scrollScroller: Scroller = new Scroller()

  aboutToAppear() {
    this.initApp()
  }

  /**
   * 初始化应用
   */
  private async initApp(): Promise<void> {
    try {
      // 初始化AppService（包含数据库初始化）
      await this.appService.init(getContext(this))
      console.log('应用初始化完成')

      // 加载页面数据
      this.loadData()
    } catch (error) {
      console.error('应用初始化失败:', error)
      // 即使初始化失败，也加载基本数据
      this.loadData()
    }
  }

  private loadData() {
    // 模拟加载延迟
    setTimeout(() => {
      this.products = MockData.generateProducts()
      this.filteredProducts = this.products
      this.isLoading = false
    }, 800)
  }

  /**
   * 搜索处理
   */
  private onSearch(text: string) {
    this.searchText = text
    this.isSearching = text.trim() !== ''
    this.filterProducts()
  }

  /**
   * 筛选商品
   */
  private filterProducts() {
    let filtered = this.products

    // 按分类筛选
    if (this.selectedCategory !== '全部') {
      filtered = filtered.filter(product => {
        if (product.category === this.selectedCategory) {
          return true
        }
        // 匹配分类别名
        if (this.selectedCategory === '手机' && product.category === '智能手机') {
          return true
        }
        if (this.selectedCategory === '智能手表' && product.category === '智能穿戴') {
          return true
        }
        if (this.selectedCategory === '平板' && product.category === '平板电脑') {
          return true
        }
        if (this.selectedCategory === '电脑' && (product.category === '笔记本' || product.category === '台式机')) {
          return true
        }
        if (this.selectedCategory === '耳机' && (product.category === '音频' || product.name.includes('耳机') || product.name.includes('FreeBuds'))) {
          return true
        }
        return false
      })
    }

    // 按搜索关键词筛选
    if (this.searchText.trim() !== '') {
      const query = this.searchText.toLowerCase()
      filtered = filtered.filter(product =>
        product.name.toLowerCase().includes(query) ||
        product.description.toLowerCase().includes(query) ||
        product.tags.some(tag => tag.toLowerCase().includes(query))
      )
    }

    this.filteredProducts = filtered
  }

  /**
   * 选择分类
   */
  private onCategorySelect(category: string) {
    this.selectedCategory = category
    this.filterProducts()
    // 滚动到顶部
    this.scrollScroller.scrollTo({ xOffset: 0, yOffset: 0 })
  }

  /**
   * 点击商品
   */
  private onProductClick(product: ProductModel) {
    router.pushUrl({
      url: 'pages/ProductDetailPageEnhanced',
      params: {
        productId: product.id
      }
    })
  }

  /**
   * 快速加购
   */
  private async onQuickAddToCart(product: ProductModel) {
    try {
      if (this.cartService.isProductInCart(product.id)) {
        console.log('商品已在购物车中')
      } else {
        const success = await this.cartService.addToCart(product, 1)
        if (success) {
          console.log('快速加购成功')
        }
      }
    } catch (error) {
      console.error('快速加购失败:', error)
    }
  }

  /**
   * 滚动到顶部
   */
  private scrollToTop() {
    this.scrollScroller.scrollTo({ xOffset: 0, yOffset: 0 })
  }

  /**
   * 监听滚动事件
   */
  private onScroll(xOffset: number, yOffset: number) {
    this.showScrollTop = yOffset > 500
  }

  @Builder
  HeaderBanner() {
    Swiper() {
      ForEach([
        { title: '新品首发', subtitle: '华为Mate 60 Pro', color: '#3B82F6' } as BannerItem,
        { title: '限时优惠', subtitle: '全场8.8折起', color: '#F97316' } as BannerItem,
        { title: '品质生活', subtitle: '智能家居专场', color: '#10B981' } as BannerItem
      ], (banner: BannerItem) => {
        Column() {
          Text(banner.title)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .margin({ bottom: 8 })

          Text(banner.subtitle)
            .fontSize(16)
            .fontColor(Color.White)
            .opacity(0.9)
        }
        .width('100%')
        .height(120)
        .backgroundColor(banner.color)
        .borderRadius(12)
        .justifyContent(FlexAlign.Center)
      })
    }
    .width('100%')
    .height(120)
    .loop(true)
    .autoPlay(true)
    .interval(3000)
    .indicator(true)
    .indicatorStyle({
      size: 6,
      color: 'rgba(255,255,255,0.4)',
      selectedColor: 'rgba(255,255,255,0.9)'
    })
  }

  build() {
    Stack() {
      Column() {
        // 顶部区域
        Column() {
          // 搜索栏
          SearchBarEnhanced({
            onSearch: this.onSearch.bind(this),
            onTextChange: (value: string) => {
              this.searchText = value
            }
          })

          // 轮播横幅
          this.HeaderBanner()
        }
        .backgroundColor($r('app.color.white'))
        .padding({ top: 12, bottom: 12 })

        // 分类标签
        Column() {
          Scroll() {
            Row({ space: 12 }) {
              ForEach(this.categories, (category: string) => {
                Button(category)
                  .fontSize(14)
                  .fontColor(this.selectedCategory === category ? Color.White : $r('app.color.text_primary'))
                  .backgroundColor(this.selectedCategory === category ? $r('app.color.primary') : $r('app.color.background_gray'))
                  .borderRadius(18)
                  .padding({ left: 20, right: 20, top: 10, bottom: 10 })
                  .onClick(() => this.onCategorySelect(category))
                  .shadow(this.selectedCategory === category ? {
                    radius: 6,
                    color: $r('app.color.shadow_light'),
                    offsetX: 0,
                    offsetY: 2
                  } : undefined)
                  .animation({
                    duration: 200,
                    curve: Curve.EaseInOut
                  })
              })
            }
            .width('100%')
            .padding({ left: 16, right: 16 })
          }
          .width('100%')
          .height(50)
          .scrollBar(BarState.Off)
          .scrollable(ScrollDirection.Horizontal)
          .edgeEffect(EdgeEffect.Spring)
        }
        .backgroundColor($r('app.color.white'))
        .padding({ top: 8, bottom: 8 })

        // 搜索状态提示
        if (this.isSearching && this.searchText.trim() !== '') {
          Row() {
            Text(`搜索"${this.searchText}"`)
              .fontSize(14)
              .fontColor($r('app.color.text_primary'))
              .fontWeight(FontWeight.Medium)
            Text(` 共找到${this.filteredProducts.length}个商品`)
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ left: 8 })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor($r('app.color.white'))
          .borderRadius(8)
          .margin({ left: 16, right: 16, top: 8 })
        }

        // 商品网格列表
        if (this.filteredProducts.length > 0) {
          Grid() {
            ForEach(this.filteredProducts, (product: ProductModel) => {
              GridItem() {
                ProductCardEnhanced({
                  product: product,
                  onProductClick: this.onProductClick.bind(this),
                  onQuickAddToCart: this.onQuickAddToCart.bind(this)
                })
              }
              .animation({
                duration: 300,
                delay: 100,
                curve: Curve.EaseInOut
              })
            }, (product: ProductModel) => product.id)
          }
          .columnsTemplate('1fr 1fr')
          .rowsGap(12)
          .columnsGap(12)
          .padding(16)
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .onScroll((xOffset: number, yOffset: number) => {
            this.onScroll(xOffset, yOffset)
          })
        } else if (!this.isLoading) {
          // 空状态
          Column() {
            Text('📦')
              .fontSize(80)
              .fontColor($r('app.color.text_tertiary'))
              .margin({ bottom: 16 })

            Text(this.searchText.trim() !== '' ? '没有找到相关商品' : '暂无商品')
              .fontSize(16)
              .fontColor($r('app.color.text_secondary'))
              .margin({ bottom: 8 })

            Text(this.searchText.trim() !== '' ? '试试调整搜索关键词或筛选条件' : '商品正在路上，敬请期待')
              .fontSize(14)
              .fontColor($r('app.color.text_tertiary'))
              .margin({ bottom: 24 })

            if (this.searchText.trim() !== '') {
              Button('清除搜索条件')
                .height(40)
                .fontSize(14)
                .backgroundColor($r('app.color.primary'))
                .fontColor(Color.White)
                .borderRadius(20)
                .padding({ left: 24, right: 24 })
                .onClick(() => {
                  this.searchText = ''
                  this.selectedCategory = '全部'
                  this.filterProducts()
                })
            }
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('app.color.white'))
          .borderRadius(12)
          .margin({ left: 16, right: 16, top: 16 })
        } else {
          // 加载状态 - 骨架屏
          Column() {
            Grid() {
              ForEach(Array(6), (_: null, index: number) => {
                GridItem() {
                  Column() {
                    Column()
                      .width('100%')
                      .height(200)
                      .backgroundColor($r('app.color.background_gray'))
                      .borderRadius({ topLeft: 16, topRight: 16 })
                      .shimmer(true)

                    Column() {
                      Column()
                        .width('80%')
                        .height(16)
                        .backgroundColor($r('app.color.background_gray'))
                        .borderRadius(4)
                        .margin({ bottom: 8 })
                        .shimmer(true)

                      Column()
                        .width('60%')
                        .height(12)
                        .backgroundColor($r('app.color.background_gray'))
                        .borderRadius(4)
                        .shimmer(true)
                    }
                    .width('100%')
                    .padding(16)
                    .layoutWeight(1)
                  }
                  .width('100%')
                  .height(340)
                  .backgroundColor($r('app.color.white'))
                  .borderRadius(16)
                }
              })
            }
            .columnsTemplate('1fr 1fr')
            .rowsGap(12)
            .columnsGap(12)
            .padding(16)
            .width('100%')
          }
          .width('100%')
          .layoutWeight(1)
          .backgroundColor($r('app.color.background'))
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.background'))

      // 底部导航栏
      BottomNavBar()
        .position({ x: 0, y: '100%' })
        .translate({ x: 0, y: -60 })

      // 回到顶部按钮
      if (this.showScrollTop) {
        Button() {
          Text('↑')
            .fontSize(20)
            .fontColor(Color.White)
        }
        .width(48)
        .height(48)
        .backgroundColor($r('app.color.primary'))
        .borderRadius(24)
        .position({ x: '92%', y: '85%' })
        .shadow({
          radius: 8,
          color: $r('app.color.shadow_medium'),
          offsetX: 0,
          offsetY: 4
        })
        .onClick(() => this.scrollToTop())
        .animation({
          duration: 300,
          curve: Curve.EaseInOut
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}

// 扩展Column组件以支持shimmer效果
@Extend(Column)
function shimmer(value: boolean) {
  .animation({
    duration: 1500,
    curve: Curve.EaseInOut,
    iterations: -1,
    playMode: PlayMode.Alternate,
    onFinish: () => {
    }
  })
  .backgroundColor(value ? $r('app.color.background_gray') : $r('app.color.white'))
}