import router from '@ohos.router'
import { ProductModel, MockData } from '../model/ProductModel'
import { SearchBarSimple } from '../components/SearchBarSimple'
import { BottomNavBar } from '../components/BottomNavBar'
import { AppService } from '../services/AppService'

@Component
struct ProductCard {
  @Prop product: ProductModel
  onProductClick: (product: ProductModel) => void = () => {}

  build() {
    Column() {
      // 商品图片容器
      Stack() {
        // 商品图片
        Image(this.product.image)
          .width('100%')
          .height(180)
          .borderRadius({ topLeft: 12, topRight: 12 })
          .objectFit(ImageFit.Cover)
          .backgroundColor('#f8f8f8')
          .alt('商品图片')

        // 折扣标签
        if (this.product.originalPrice > this.product.price) {
          Text(`省${Math.floor(((this.product.originalPrice - this.product.price) / this.product.originalPrice) * 100)}%`)
            .fontSize(10)
            .fontColor(Color.White)
            .backgroundColor('#ff4444')
            .borderRadius(8)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .position({ x: 8, y: 8 })
        }
      }

      // 商品信息
      Column() {
        // 商品名称
        Text(this.product.name)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ bottom: 6 })
          .lineHeight(20)

        // 商品描述/标签
        if (this.product.tags && this.product.tags.length > 0) {
          Row() {
            ForEach(this.product.tags.slice(0, 2), (tag: string, index: number) => {
              Text(tag)
                .fontSize(10)
                .fontColor($r('app.color.primary'))
                .backgroundColor('#f0f8ff')
                .borderRadius(4)
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .margin({ right: index === 0 ? 6 : 0 })
            })
          }
          .width('100%')
          .margin({ bottom: 8 })
        }

        // 价格区域
        Row() {
          Column() {
            Row() {
              Text('¥')
                .fontSize(12)
                .fontWeight(FontWeight.Bold)
                .fontColor('#ff4444')
                .margin({ top: 2 })
              Text(`${this.product.price}`)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#ff4444')
            }

            // 原价
            if (this.product.originalPrice > this.product.price) {
              Text(`¥${this.product.originalPrice}`)
                .fontSize(12)
                .fontColor('#999999')
                .decoration({ type: TextDecorationType.LineThrough })
            }
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          // 评分
          if (this.product.rating) {
            Row() {
              Text('⭐')
                .fontSize(10)
              Text(this.product.rating.toFixed(1))
                .fontSize(10)
                .fontColor('#666666')
            }
          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Bottom)

        // 销量信息
        Text(`已售${Math.floor(this.product.reviewCount * 10)}+`)
          .fontSize(10)
          .fontColor('#999999')
          .width('100%')
          .margin({ top: 4 })
      }
      .width('100%')
      .padding(12)
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height(300)
    .backgroundColor($r('app.color.white'))
    .borderRadius(12)
    .shadow({
      radius: 6,
      color: '#10000000',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      this.onProductClick(this.product)
    })
  }
}

@Entry
@Component
struct Index {
  @State products: ProductModel[] = []
  @State filteredProducts: ProductModel[] = []
  @State searchText: string = ''
  @State selectedCategory: string = '全部'
  @State isLoading: boolean = true
  @State isSearching: boolean = false
  private appService: AppService = AppService.getInstance()

  // 商品分类
  private categories: string[] = ['全部', '手机', '平板', '电脑', '耳机', '智能手表']

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
    }, 1000)
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

    // 按分类筛选 - 更严格的匹配
    if (this.selectedCategory !== '全部') {
      filtered = filtered.filter(product => {
        // 直接匹配分类
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

  build() {
    Stack() {
      Column() {
        // 顶部搜索栏
        Column() {
          SearchBarSimple({ onSearch: this.onSearch.bind(this) })
        }
        .backgroundColor($r('app.color.primary'))
        .padding({ top: 8, bottom: 8 })

        // 空白区域
        Column()
          .width('100%')
          .height(8)

        // 搜索状态提示
        if (this.isSearching && this.searchText.trim() !== '') {
          Text(`搜索"${this.searchText}"的结果`)
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .width('100%')
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor($r('app.color.background'))
        }

        // 商品分类
        Scroll() {
          Row({ space: 12 }) {
            ForEach(this.categories, (category: string) => {
              Button(category)
                .fontSize(14)
                .fontColor(this.selectedCategory === category ? Color.White : $r('app.color.text_primary'))
                .backgroundColor(this.selectedCategory === category ? $r('app.color.primary') : $r('app.color.background'))
                .borderRadius(18)
                .padding({ left: 20, right: 20, top: 10, bottom: 10 })
                .margin({ right: category === this.categories[this.categories.length - 1] ? 16 : 0 })
                .onClick(() => this.onCategorySelect(category))
                .shadow(this.selectedCategory === category ? {
                  radius: 4,
                  color: '#33000000',
                  offsetX: 0,
                  offsetY: 2
                } : undefined)
            })
          }
          .width('100%')
          .padding({ left: 16, top: 12, bottom: 12 })
        }
        .width('100%')
        .height(50)
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Horizontal)
        .edgeEffect(EdgeEffect.Spring)
        .backgroundColor($r('app.color.white'))

        // 商品网格列表
        if (this.filteredProducts.length > 0) {
          Grid() {
            ForEach(this.filteredProducts, (product: ProductModel) => {
              GridItem() {
                ProductCard({ product: product, onProductClick: this.onProductClick.bind(this) })
              }
            }, (product: ProductModel) => product.id)
          }
          .columnsTemplate('1fr 1fr')
          .rowsGap(12)
          .columnsGap(12)
          .padding(16)
          .width('100%')
          .layoutWeight(1)
        } else if (!this.isLoading) {
          // 空状态
          Column() {
            Text('📦')
              .fontSize(60)
              .margin({ bottom: 16 })
            Text(this.searchText.trim() !== '' ? '没有找到相关商品' : '暂无商品')
              .fontSize(16)
              .fontColor($r('app.color.text_secondary'))
            if (this.searchText.trim() !== '') {
              Button('清除搜索条件')
                .height(36)
                .fontSize(14)
                .margin({ top: 16 })
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
          .backgroundColor($r('app.color.background'))
        } else {
          // 加载状态
          Column() {
            LoadingProgress()
              .width(40)
              .height(40)
            Text('加载中...')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 16 })
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

      // 底部导航栏 - 固定在底部
      BottomNavBar()
        .position({ x: 0, y: '100%' })
        .translate({ x: 0, y: -60 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}