import router from '@ohos.router'
import { ProductModel, MockData } from '../model/ProductModel'
import { BottomNavBar } from '../components/BottomNavBar'

@Entry
@Component
struct IndexBeautiful {
  @State products: ProductModel[] = []
  @State filteredProducts: ProductModel[] = []
  @State searchText: string = ''
  @State selectedCategory: string = '推荐'
  @State scrollOffset: number = 0
  @State isLoading: boolean = true
  @State cartCount: number = 0

  private categories: string[] = ['推荐', '手机', '平板', '电脑', '耳机', '智能手表']
  private scroller: Scroller = new Scroller()

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

  private onSearch(text: string) {
    this.searchText = text
    this.filterProducts()
  }

  private filterProducts() {
    let filtered = this.products

    if (this.selectedCategory !== '推荐') {
      filtered = filtered.filter(product => {
        return product.category === this.selectedCategory
      })
    }

    if (this.searchText.trim() !== '') {
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

  @Builder
  SearchBar() {
    Column() {
      // 顶部状态栏占位
      Row()
        .width('100%')
        .height(44)

      // 搜索栏
      Row() {
        Text('🔍')
          .fontSize(20)
          .fontColor('#666666')
          .margin({ left: 16 })

        TextInput({
          placeholder: '搜索你想要的产品',
          text: this.searchText
        })
          .fontSize(16)
          .fontColor('#1A1A1A')
          .backgroundColor(Color.Transparent)
          .layoutWeight(1)
          .placeholderColor('#999999')
          .onChange((value: string) => {
            this.onSearch(value)
          })

        if (this.searchText) {
          Button('✕')
            .fontSize(16)
            .fontColor('#666666')
            .backgroundColor(Color.Transparent)
            .width(40)
            .height(40)
            .onClick(() => {
              this.searchText = ''
              this.onSearch('')
            })
        }
      }
      .width('100%')
      .height(48)
      .backgroundColor('#F5F5F7')
      .borderRadius(24)
      .padding({ right: 8 })
      .margin({ left: 20, right: 20, bottom: 20 })

      // 分类标签
      Scroll() {
        Row({ space: 16 }) {
          ForEach(this.categories, (category: string) => {
            Button(category)
              .fontSize(14)
              .fontColor(this.selectedCategory === category ? '#FFFFFF' : '#666666')
              .backgroundColor(this.selectedCategory === category ? '#1A1A1A' : 'transparent')
              .border({
                width: 1,
                color: this.selectedCategory === category ? 'transparent' : '#E5E5E5'
              })
              .borderRadius(20)
              .padding({ left: 24, right: 24, top: 10, bottom: 10 })
              .height(40)
              .onClick(() => this.onCategorySelect(category))
          })
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
      }
      .width('100%')
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Horizontal)
    }
    .width('100%')
    .backgroundColor('rgba(255,255,255,0.95)')
    .backdropBlur(20)
    .border({ width: { bottom: 0.5 }, color: '#E5E5E5' })
  }

  @Builder
  BannerSection() {
    Swiper() {
      ForEach([
        { title: '华为Mate 60 Pro', desc: '重返巅峰', color: '#1A1A1A' },
        { title: '鸿蒙生态', desc: '万物互联', color: '#FF3B30' },
        { title: '智能家居', desc: '智慧生活', color: '#007AFF' }
      ], (banner: Record<string, string>, index?: number) => {
        Column() {
          Text(banner.title)
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .margin({ bottom: 8 })

          Text(banner.desc)
            .fontSize(16)
            .fontColor('rgba(255,255,255,0.8)')
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(banner.color)
        .borderRadius(24)
        .margin({ left: 20, right: 20 })
      })
    }
    .width('100%')
    .height(200)
    .loop(true)
    .autoPlay(true)
    .interval(3000)
        .margin({ top: 20 })
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
          .borderRadius({ topLeft: 16, topRight: 16 })
          .backgroundColor('#F5F5F7')
          .alt('商品图片')

        // 折扣标签
        if (product.originalPrice > product.price) {
          Text(`${Math.floor(((product.originalPrice - product.price) / product.originalPrice) * 100)}% OFF`)
            .fontSize(12)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .backgroundColor('#FF3B30')
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .borderRadius({ bottomLeft: 12, topRight: 16 })
            .position({ x: 0, y: 0 })
        }

        // 快速加购按钮
        Button('+')
          .fontSize(20)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .width(36)
          .height(36)
          .backgroundColor('#1A1A1A')
          .borderRadius(18)
          .position({ x: '85%', y: '75%' })
          .shadow({
            radius: 8,
            color: '#00000020',
            offsetX: 0,
            offsetY: 2
          })
          .onClick(() => {
            console.log('快速加购')
          })
      }

      // 商品信息
      Column() {
        Text(product.name)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ top: 12, bottom: 8 })

        // 标签
        if (product.tags && product.tags.length > 0) {
          Text(product.tags[0])
            .fontSize(10)
            .fontColor('#666666')
            .backgroundColor('#F5F5F7')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(4)
            .margin({ bottom: 8 })
            .width('100%')
        }

        // 价格
        Row() {
          Row() {
            Text('¥')
              .fontSize(12)
              .fontColor('#FF3B30')
              .margin({ top: 4 })
            Text(`${product.price}`)
              .fontSize(20)
              .fontColor('#FF3B30')
              .fontWeight(FontWeight.Bold)
          }

          Blank()

          // 销量
          Text(`已售 ${Math.floor(Math.random() * 10000)}`)
            .fontSize(10)
            .fontColor('#999999')
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: '#00000008',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      this.onProductClick(product)
    })
  }

  @Builder
  CategorySection() {
    Column() {
      Row() {
        Text('分类浏览')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
        Blank()
        Text('查看全部')
          .fontSize(14)
          .fontColor('#666666')
      }
      .width('100%')
      .padding(20)

      Grid() {
        ForEach([
          { icon: '📱', name: '手机', color: '#1A1A1A' },
          { icon: '💻', name: '电脑', color: '#007AFF' },
          { icon: '⌚', name: '手表', color: '#FF3B30' },
          { icon: '🎧', name: '耳机', color: '#34C759' },
          { icon: '📺', name: '平板', color: '#FF9500' },
          { icon: '🖱️', name: '配件', color: '#AF52DE' }
        ], (item: Record<string, string | Resource>) => {
          GridItem() {
            Column() {
              Text(item.icon as string)
                .fontSize(32)
                .margin({ bottom: 8 })

              Text(item.name as string)
                .fontSize(12)
                .fontColor('#666666')
            }
            .width('100%')
            .height(80)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(item.color as string + '10')
            .borderRadius(16)
            .onClick(() => {
              this.onCategorySelect(item.name as string)
            })
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsGap(12)
      .columnsGap(12)
      .padding({ left: 20, right: 20 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(24)
    .margin({ top: 20 })
  }

  build() {
    Column() {
      // 可滚动内容
      Scroll(this.scroller) {
        Column() {
          // 顶部占位（为搜索栏留空间）
          Row()
            .width('100%')
            .height(330)

          // Banner区域
          this.BannerSection()

          // 分类区域
          this.CategorySection()

          // 商品标题
          Row() {
            Text('热门商品')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A1A1A')
            Blank()
          }
          .width('100%')
          .padding(20)
          .margin({ top: 20 })

          // 商品网格
          if (this.filteredProducts.length > 0) {
            Grid() {
              ForEach(this.filteredProducts, (product: ProductModel) => {
                GridItem() {
                  this.ProductCard(product)
                }
              })
            }
            .columnsTemplate('1fr 1fr')
            .rowsGap(16)
            .columnsGap(16)
            .padding({ left: 20, right: 20, bottom: 100 })
          } else if (!this.isLoading) {
            // 空状态
            Column() {
              Text('🔍')
                .fontSize(60)
                .margin({ bottom: 16 })
              Text('没有找到相关商品')
                .fontSize(16)
                .fontColor('#666666')
            }
            .width('100%')
            .height(200)
            .justifyContent(FlexAlign.Center)
          }
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F7')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      // 搜索栏（固定在顶部）
      Stack() {
        this.SearchBar()
      }
      .width('100%')
      .position({ x: 0, y: 0 })

      // 底部导航栏
      Stack() {
        BottomNavBar()
      }
      .position({ x: 0, y: '100%' })
      .translate({ x: 0, y: -60 })

      // 加载状态
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