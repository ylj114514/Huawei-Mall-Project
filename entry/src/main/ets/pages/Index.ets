import router from '@ohos.router'
import { ProductModel, MockData } from '../model/ProductModel'
import { BottomNavBar } from '../components/BottomNavBar'
// import { AppService } from '../services/AppService'

@Entry
@Component
struct Index {
  @State products: ProductModel[] = []
  @State filteredProducts: ProductModel[] = []
  @State searchText: string = ''
  @State selectedCategory: string = '全部'
  @State isLoading: boolean = true
  @State isSearching: boolean = false

  // 商品分类
  private categories: string[] = ['全部', '手机', '平板', '电脑', '耳机', '智能手表']

  aboutToAppear() {
    this.loadData()
  }

  private loadData() {
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
      url: 'pages/ProductDetailModern',
      params: {
        productId: product.id
      }
    })
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
        // 品牌标题
        Text('HUAWEI')
          .fontSize(32)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .letterSpacing(4)
          .margin({ top: 60, bottom: 20 })

        // 搜索栏
        Row() {
          Text('🔍')
            .fontSize(18)
            .fontColor('#666666')
            .margin({ left: 16 })
          TextInput({
            placeholder: '搜索您想要的产品',
            text: this.searchText
          })
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor(Color.Transparent)
            .layoutWeight(1)
            .placeholderColor('#666666')
            .onChange((value: string) => {
              this.searchText = value
              this.onSearch(value)
            })
        }
        .width('90%')
        .height(48)
        .backgroundColor('#ffffff15')
        .borderRadius(24)
        .backdropBlur(10)
        .padding({ right: 16 })

        // 品牌标语
        Text('构建万物互联的智能世界')
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

  build() {
    Column() {
      // Hero区域
      this.HeroSection()

      // 主要内容
      Scroll() {
        Column() {
          // 分类标题
          Row() {
            Text('产品分类')
              .fontSize(24)
              .fontColor('#1a1a1a')
              .fontWeight(FontWeight.Bold)
            Blank()
          }
          .width('100%')
          .padding(20)

          // 分类标签
          Scroll() {
            Row({ space: 12 }) {
              ForEach(this.categories, (category: string) => {
                Button(category)
                  .fontSize(14)
                  .fontColor(this.selectedCategory === category ? Color.White : '#1a1a1a')
                  .backgroundColor(this.selectedCategory === category ? '#007AFF' : '#f0f0f0')
                  .borderRadius(20)
                  .padding({ left: 24, right: 24, top: 12, bottom: 12 })
                  .shadow(this.selectedCategory === category ? {
                    radius: 8,
                    color: '#007AFF30',
                    offsetX: 0,
                    offsetY: 2
                  } : undefined)
                  .onClick(() => this.onCategorySelect(category))
              })
            }
            .width('100%')
            .padding({ left: 20, right: 20 })
          }
          .width('100%')
          .scrollBar(BarState.Off)
          .scrollable(ScrollDirection.Horizontal)
          .height(50)
          .margin({ bottom: 20 })

          // 商品网格列表
          if (this.filteredProducts.length > 0) {
            Grid() {
              ForEach(this.filteredProducts, (product: ProductModel) => {
                GridItem() {
                  this.ProductCard(product)
                }
              }, (product: ProductModel) => product.id)
            }
            .columnsTemplate('1fr 1fr')
            .rowsGap(16)
            .columnsGap(16)
            .padding(20)
            .width('100%')
          } else if (!this.isLoading) {
            // 空状态
            Column() {
              Text('📦')
                .fontSize(60)
                .margin({ bottom: 16 })
              Text(this.searchText.trim() !== '' ? '没有找到相关商品' : '暂无商品')
                .fontSize(16)
                .fontColor('#666666')
            }
            .width('100%')
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)
          } else {
            // 加载状态
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
          }
        }
        .width('100%')
        .padding({ bottom: 80 })
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#f5f5f7')

      // 底部导航栏
      BottomNavBar()
        .position({ x: 0, y: '100%' })
        .translate({ x: 0, y: -60 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f7')
  }

  @Builder
  ProductCard(product: ProductModel) {
    Column() {
      // 图片容器
      Stack() {
        // 商品图片
        Image(product.image)
          .width('100%')
          .height(200)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: 20, topRight: 20 })
          .backgroundColor('#f0f0f0')
          .alt('商品图片')

        // 折扣标签
        if (product.originalPrice > product.price) {
          Text(`${Math.floor(((product.originalPrice - product.price) / product.originalPrice) * 100)}% OFF`)
            .fontSize(12)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#FF3B30')
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .borderRadius({ bottomLeft: 12, topRight: 20 })
            .position({ x: 0, y: 0 })
        }
      }

      // 商品信息
      Column() {
        // 商品名称
        Text(product.name)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1a1a1a')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ bottom: 8 })

        // 价格区域
        Row() {
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

          Blank()

          // 加号按钮
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
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height(300)
    .backgroundColor(Color.White)
    .borderRadius(20)
    .shadow({
      radius: 12,
      color: '#00000010',
      offsetX: 0,
      offsetY: 4
    })
    .onClick(() => {
      this.onProductClick(product)
    })
  }
}