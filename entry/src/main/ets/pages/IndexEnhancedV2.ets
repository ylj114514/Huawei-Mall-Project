import router from '@ohos.router'
import { ProductModel, MockData } from '../model/ProductModel'
import { SearchBarSimpleV2 } from '../components/SearchBarSimpleV2'
import { BottomNavBar } from '../components/BottomNavBar'

@Entry
@Component
struct IndexEnhancedV2 {
  @State products: ProductModel[] = []
  @State filteredProducts: ProductModel[] = []
  @State searchText: string = ''
  @State selectedCategory: string = '全部'
  @State isLoading: boolean = true
  private categories: string[] = ['全部', '手机', '平板', '电脑', '耳机', '智能手表']

  aboutToAppear() {
    this.loadData()
  }

  private loadData() {
    // 模拟加载延迟
    setTimeout(() => {
      this.products = MockData.generateProducts()
      this.filteredProducts = this.products
      this.isLoading = false
      console.log('加载商品数量:', this.products.length)
    }, 800)
  }

  /**
   * 搜索处理
   */
  private onSearch(text: string) {
    this.searchText = text
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
        return false
      })
    }

    // 按搜索关键词筛选
    if (this.searchText.trim() !== '') {
      const query = this.searchText.toLowerCase()
      filtered = filtered.filter(product =>
        product.name.toLowerCase().includes(query) ||
        product.description.toLowerCase().includes(query)
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
  }

  /**
   * 点击商品
   */
  private onProductClick(product: ProductModel) {
    router.pushUrl({
      url: 'pages/ProductDetailPage',
      params: {
        productId: product.id
      }
    })
  }

  @Builder
  ProductCard(product: ProductModel) {
    Column() {
      // 商品图片
      Image(product.image)
        .width('100%')
        .height(180)
        .borderRadius({ topLeft: 12, topRight: 12 })
        .objectFit(ImageFit.Cover)
        .backgroundColor('#f5f5f5')
        .alt('商品图片')

      // 商品信息
      Column() {
        // 商品名称
        Text(product.name)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ bottom: 8 })

        // 价格
        Row() {
          Text(`¥${product.price}`)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#ff4444')

          if (product.originalPrice > product.price) {
            Text(`¥${product.originalPrice}`)
              .fontSize(12)
              .fontColor('#999999')
              .decoration({ type: TextDecorationType.LineThrough })
              .margin({ left: 8 })
          }
        }
        .width('100%')
      }
      .width('100%')
      .padding(12)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: '#10000000',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      this.onProductClick(product)
    })
  }

  build() {
    Stack() {
      Column() {
        // 顶部搜索栏
        Column() {
          SearchBarSimpleV2({ onSearch: this.onSearch.bind(this) })
        }
        .backgroundColor('#007DFF')
        .padding({ top: 8, bottom: 8 })

        // 分类标签
        Scroll() {
          Row({ space: 12 }) {
            ForEach(this.categories, (category: string) => {
              Button(category)
                .fontSize(14)
                .fontColor(this.selectedCategory === category ? Color.White : '#333333')
                .backgroundColor(this.selectedCategory === category ? '#007DFF' : '#f5f5f5')
                .borderRadius(18)
                .padding({ left: 20, right: 20, top: 10, bottom: 10 })
                .onClick(() => this.onCategorySelect(category))
            })
          }
          .width('100%')
          .padding({ left: 16, top: 12, bottom: 12 })
        }
        .width('100%')
        .height(50)
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Horizontal)
        .backgroundColor(Color.White)

        // 商品列表
        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(40)
              .height(40)
            Text('加载中...')
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 16 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else if (this.filteredProducts.length > 0) {
          Grid() {
            ForEach(this.filteredProducts, (product: ProductModel) => {
              GridItem() {
                this.ProductCard(product)
              }
            }, (product: ProductModel) => product.id)
          }
          .columnsTemplate('1fr 1fr')
          .rowsGap(12)
          .columnsGap(12)
          .padding(16)
          .width('100%')
          .layoutWeight(1)
        } else {
          Column() {
            Text('📦')
              .fontSize(60)
              .margin({ bottom: 16 })
            Text('暂无商品')
              .fontSize(16)
              .fontColor('#666666')
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f5f5f5')

      // 底部导航栏
      BottomNavBar()
        .position({ x: 0, y: '100%' })
        .translate({ x: 0, y: -60 })
    }
    .width('100%')
    .height('100%')
  }
}