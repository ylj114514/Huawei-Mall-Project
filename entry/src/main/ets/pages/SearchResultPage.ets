import router from '@ohos.router'
import { ProductModel, MockData } from '../model/ProductModel'
// import { SearchBar } from '../components/SearchBar' // 移除可能导致报错的自定义组件
import { ProductCard } from '../components/ProductCard'
import { CartService } from '../services/CartService'
import { CartItem } from '../model/DataModel'

interface RouteParams {
  query?: string
}

@Entry
@Component
struct SearchResultPage {
  @State products: ProductModel[] = []
  @State filteredProducts: ProductModel[] = []
  @State searchText: string = ''
  @State selectedSort: string = '综合'
  @State selectedPriceRange: string = '全部'
  @State isLoading: boolean = false
  @State showFilters: boolean = false
  @State resultCount: number = 0
  @State searchHistory: string[] = []
  @State hotSearches: string[] = ['华为Mate 60', 'iPhone 15', 'MacBook Pro', 'AirPods Pro', '小米14', 'OPPO Find']

  private cartService: CartService = CartService.getInstance()
  private sortOptions = ['综合', '销量', '价格↑', '价格↓', '好评']
  private priceRanges = ['全部', '0-1000', '1000-3000', '3000-5000', '5000-10000', '10000+']

  aboutToAppear() {
    this.loadAllProducts()
    const params = router.getParams() as RouteParams
    if (params?.query) {
      this.searchText = params.query
      this.performSearch()
    }
  }

  private loadAllProducts() {
    this.products = MockData.generateProducts()
    this.filteredProducts = this.products
    this.resultCount = this.filteredProducts.length
  }

  private performSearch() {
    if (!this.searchText.trim()) {
      this.loadAllProducts()
      return
    }

    this.isLoading = true

    setTimeout(() => {
      const query = this.searchText.toLowerCase()
      this.filteredProducts = this.products.filter(product =>
      product.name.toLowerCase().includes(query) ||
      product.description.toLowerCase().includes(query) ||
      product.tags.some(tag => tag.toLowerCase().includes(query))
      )

      this.applySortAndFilter()
      this.isLoading = false
    }, 500)
  }

  private applySortAndFilter() {
    let filtered = [...this.filteredProducts]

    // 价格筛选
    if (this.selectedPriceRange !== '全部') {
      const range = this.selectedPriceRange.split('-').map(v => v === '+' ? Infinity : parseInt(v))
      filtered = filtered.filter(product => {
        if (range.length === 1) {
          return product.price >= range[0]
        }
        return product.price >= range[0] && product.price <= range[1]
      })
    }

    // 排序
    switch (this.selectedSort) {
      case '销量':
        filtered.sort((a, b) => b.reviewCount - a.reviewCount)
        break
      case '价格↑':
        filtered.sort((a, b) => a.price - b.price)
        break
      case '价格↓':
        filtered.sort((a, b) => b.price - a.price)
        break
      case '好评':
        filtered.sort((a, b) => (b.rating || 0) - (a.rating || 0))
        break
      default:
      // 综合排序 - 保持默认
        break
    }

    this.filteredProducts = filtered
    this.resultCount = filtered.length
  }

  private onSearch(text: string) {
    this.searchText = text
    this.performSearch()
  }

  private onSortChange(sort: string) {
    this.selectedSort = sort
    this.applySortAndFilter()
  }

  private onPriceRangeChange(range: string) {
    this.selectedPriceRange = range
    this.applySortAndFilter()
  }

  private onProductClick(product: ProductModel) {
    router.pushUrl({
      url: 'pages/ProductDetailPage',
      params: {
        product: product
      }
    })
  }

  private async onQuickAddToCart(product: ProductModel) {
    try {
      const cartItems = this.cartService.getCartItems()
      const exists = cartItems.some((item: CartItem) => item.product.id === product.id)

      if (exists) {
        console.info('商品已在购物车中')
      } else {
        const success = await this.cartService.addToCart(product, 1)
        if (success) {
          console.info('快速加购成功')
        }
      }
    } catch (error) {
      console.error('快速加购失败:', error)
    }
  }

  private goBack() {
    router.back()
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button() {
          Text('←')
            .fontSize(20)
            .fontColor($r('app.color.text_primary'))
        }
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .onClick(() => this.goBack())

        // ✅ 修正：使用系统 Search 组件，保证不出错
        Search({ value: this.searchText, placeholder: '搜索商品' })
          .searchButton('搜索')
          .onSubmit((value) => this.onSearch(value))
          .onChange((value) => {
            this.searchText = value
          })
          .layoutWeight(1)
          .margin({ left: 12, right: 12 })
          .backgroundColor('#F5F5F5')
      }
      .width('100%')
      .height(60)
      .padding({ left: 16, right: 16 })
      .backgroundColor($r('app.color.white'))
      .shadow({
        radius: 2,
        color: '#1A000000',
        offsetX: 0,
        offsetY: 1
      })

      // 搜索统计和筛选
      Column() {
        Row() {
          if (this.searchText) {
            Text(`"${this.searchText}"`)
              .fontSize(16)
              .fontColor($r('app.color.text_primary'))
              .fontWeight(FontWeight.Medium)
            Text(` 找到${this.resultCount}个商品`)
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ left: 8 })
          } else {
            Text('全部商品')
              .fontSize(16)
              .fontColor($r('app.color.text_primary'))
              .fontWeight(FontWeight.Medium)
            Text(` 共${this.resultCount}个商品`)
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ left: 8 })
          }

          Blank()

          // 筛选按钮
          Button() {
            Row() {
              Text('筛选')
                .fontSize(14)
                .fontColor(this.showFilters ? $r('app.color.primary') : $r('app.color.text_primary'))
              Text('⚙')
                .fontSize(16)
                .fontColor(this.showFilters ? $r('app.color.primary') : $r('app.color.text_primary'))
                .margin({ left: 4 })
            }
          }
          .height(36)
          .backgroundColor(this.showFilters ? '#E6F2FF' : '#F5F5F5')
          .borderRadius(18)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            this.showFilters = !this.showFilters
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })

        // 筛选选项
        if (this.showFilters) {
          Column() {
            // 价格区间
            Column() {
              Text('价格区间')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary'))
                .width('100%')
                .margin({ bottom: 12 })

              Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
                ForEach(this.priceRanges, (range: string) => {
                  Button(range)
                    .height(32)
                    .fontSize(13)
                    .fontColor(this.selectedPriceRange === range ? $r('app.color.primary') : $r('app.color.text_secondary'))
                    .backgroundColor(this.selectedPriceRange === range ? '#E6F2FF' : '#F5F5F5')
                    .borderRadius(16)
                    .padding({ left: 16, right: 16 })
                    .margin({ right: 8, bottom: 8 })
                    .onClick(() => this.onPriceRangeChange(range))
                })
              }
              .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor($r('app.color.white'))
            .borderRadius(12)
            .margin({ bottom: 8 })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
        }

        // 排序选项
        Scroll() {
          Row({ space: 12 }) {
            ForEach(this.sortOptions, (sort: string) => {
              Button(sort)
                .fontSize(14)
                .fontColor(this.selectedSort === sort ? Color.White : $r('app.color.text_primary'))
                .backgroundColor(this.selectedSort === sort ? $r('app.color.primary') : $r('app.color.white'))
                .border({ width: 1, color: this.selectedSort === sort ? Color.Transparent : '#EEEEEE' })
                .borderRadius(18)
                .padding({ left: 20, right: 20, top: 10, bottom: 10 })
                .onClick(() => this.onSortChange(sort))
            })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
        }
        .width('100%')
        .height(50)
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Horizontal)
        .backgroundColor($r('app.color.white'))
      }
      .width('100%')
      .backgroundColor('#F5F5F5')

      // 商品列表
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
          Text('搜索中...')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.background'))
      } else if (this.filteredProducts.length > 0) {
        Grid() {
          ForEach(this.filteredProducts, (product: ProductModel) => {
            GridItem() {
              ProductCard({
                product: product
              })
                .onClick(() => this.onProductClick(product))
            }
          }, (product: ProductModel) => product.id)
        }
        .columnsTemplate('1fr 1fr')
        .rowsGap(12)
        .columnsGap(12)
        .padding(16)
        .width('100%')
        .layoutWeight(1)
        .backgroundColor($r('app.color.background'))
      } else {
        Column() {
          Text('🔍')
            .fontSize(80)
            .fontColor('#CCCCCC')
            .margin({ bottom: 16 })

          Text('没有找到相关商品')
            .fontSize(16)
            .fontColor($r('app.color.text_secondary'))
            .margin({ bottom: 8 })

          Text('试试其他关键词或查看热门推荐')
            .fontSize(14)
            .fontColor('#CCCCCC')
            .margin({ bottom: 24 })

          // 热门搜索
          Column() {
            Text('热门搜索')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .margin({ bottom: 12 })

            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
              ForEach(this.hotSearches, (item: string) => {
                Button(item)
                  .height(32)
                  .fontSize(13)
                  .fontColor($r('app.color.text_secondary'))
                  .backgroundColor('#F5F5F5')
                  .borderRadius(16)
                  .padding({ left: 16, right: 16 })
                  .margin({ right: 8, bottom: 8 })
                  .onClick(() => {
                    this.searchText = item
                    this.onSearch(item)
                  })
              })
            }
            .width('100%')
          }
          .width('100%')
          .padding(24)
          .backgroundColor($r('app.color.white'))
          .borderRadius(12)
          .margin({ left: 16, right: 16 })
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