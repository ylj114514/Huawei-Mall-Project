import router from '@ohos.router'
import { DatabaseManager } from '../database/DatabaseManager'
import { ProductModel, MockData } from '../model/ProductModel'
import common from '@ohos.app.ability.common'

interface Statistics {
  total: number
  totalValue: number
  lowStock: number
}

@Entry
@Component
struct AdminDashboard {
  @State products: ProductModel[] = []
  @State filteredProducts: ProductModel[] = []
  @State searchText: string = ''
  @State selectedCategory: string = '全部'
  @State isLoading: boolean = true
  @State statistics: Statistics = { total: 0, totalValue: 0, lowStock: 0 }

  private categories: string[] = ['全部', '手机', '平板', '电脑', '耳机', '智能手表', '其他']
  private dbManager: DatabaseManager = DatabaseManager.getInstance()

  aboutToAppear() {
    this.loadData()
  }

  // 页面显示时刷新数据
  onPageShow() {
    this.loadData()
  }

  private async loadData() {
    try {
      this.isLoading = true
      // ✅ 1. 获取上下文并初始化 DB
      const context = getContext(this) as common.UIAbilityContext
      await this.dbManager.init(context)

      // ✅ 2. 获取数据
      const rows = await this.dbManager.getAllProducts()
      const mockProducts = MockData.generateProducts() // 用于恢复图片

      // ✅ 3. 转换逻辑 (严格匹配你的 ProductModel 构造函数)
      this.products = rows.map(row => {
        // 尝试找回 Resource 图片
        const match = mockProducts.find(m => m.id === row.id)
        const images = match ? match.images : [$r('app.media.APP')]

        // 构造函数参数顺序：
        // id, name, price, originalPrice, description, detailDescription, images, category, tags, rating, reviewCount, stock
        const p = new ProductModel(
          row.id,
          row.name,
          row.price,
          row.originalPrice,
          row.description,
          row.detailDescription,
          images, // ✅ 传入 Resource[]
          row.category,
          row.tags,
          row.rating,
          row.reviewCount,
          row.stock
        )

        // 补全其他字段
        p.image = images.length > 0 ? images[0] : $r('app.media.APP')
        p.sales = row.sales
        p.isNew = row.isNew
        p.status = row.status
        return p
      })

      this.filteredProducts = this.products
      // 重新应用当前的搜索/筛选
      this.filterProducts()
      this.calculateStatistics()
    } catch (error) {
      console.error('加载后台数据失败:', error)
    } finally {
      this.isLoading = false
    }
  }

  private calculateStatistics() {
    this.statistics.total = this.products.length
    this.statistics.totalValue = this.products.reduce((sum, p) => sum + (p.price * p.stock), 0)
    this.statistics.lowStock = this.products.filter(p => p.stock < 10).length
  }

  private filterProducts() {
    let filtered = this.products

    if (this.selectedCategory !== '全部') {
      filtered = filtered.filter(product => product.category === this.selectedCategory)
    }

    if (this.searchText.trim() !== '') {
      const query = this.searchText.toLowerCase()
      filtered = filtered.filter(product =>
      product.name.toLowerCase().includes(query) ||
      (product.description || '').toLowerCase().includes(query)
      )
    }

    this.filteredProducts = filtered
  }

  private onSearch(text: string) {
    this.searchText = text
    this.filterProducts()
  }

  private onCategorySelect(category: string) {
    this.selectedCategory = category
    this.filterProducts()
  }

  private onAddProduct() {
    router.pushUrl({
      url: 'pages/ProductEditPage'
    })
  }

  private onEditProduct(product: ProductModel) {
    router.pushUrl({
      url: 'pages/ProductEditPage',
      params: { product: product }
    })
  }

  private async onDeleteProduct(product: ProductModel) {
    try {
      AlertDialog.show({
        title: '确认删除',
        message: `确定要删除商品"${product.name}"吗？此操作不可恢复。`,
        primaryButton: {
          value: '取消',
          action: () => {}
        },
        secondaryButton: {
          value: '删除',
          fontColor: '#ff4444',
          action: async () => {
            try {
              // ✅ 修正：使用 setProductStatus 软删除，直接传字符串ID，不转换 parseInt
              await this.dbManager.setProductStatus(product.id, 'deleted')
              console.info('商品删除成功')
              this.loadData()
            } catch (error) {
              console.error('删除失败:', error)
            }
          }
        }
      })
    } catch (error) {
      console.error('删除操作失败:', error)
    }
  }

  // --- UI 部分 (原封不动) ---

  @Builder
  StatisticsCard() {
    Column() {
      Text('数据概览')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1a1a1a')
        .width('100%')
        .margin({ bottom: 20 })

      Row() {
        Column() {
          Text(`${this.statistics.total}`)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#007aff')
          Text('商品总数')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)

        Column() {
          Text(`¥${this.statistics.totalValue.toFixed(0)}`)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#34c759')
          Text('库存总值')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)

        Column() {
          Text(`${this.statistics.lowStock}`)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#ff9500')
          Text('低库存')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(20)
    .shadow({
      radius: 8,
      color: '#00000010',
      offsetX: 0,
      offsetY: 2
    })
  }

  @Builder
  SearchBar() {
    Row() {
      Row() {
        Text('🔍')
          .fontSize(18)
          .fontColor('#666666')
          .margin({ left: 16 })
        TextInput({
          placeholder: '搜索商品名称',
          text: this.searchText
        })
          .fontSize(16)
          .fontColor('#1a1a1a')
          .backgroundColor(Color.Transparent)
          .layoutWeight(1)
          .placeholderColor('#666666')
          .onChange((value: string) => {
            this.onSearch(value)
          })
      }
      .width('60%')
      .height(48)
      .backgroundColor('#f5f5f7')
      .borderRadius(24)
      .padding({ right: 16 })

      Button('新增商品')
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor('#007aff')
        .borderRadius(24)
        .padding({ left: 24, right: 24 })
        .onClick(() => this.onAddProduct())
    }
    .width('100%')
    .padding(20)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  CategoryFilter() {
    Scroll() {
      Row({ space: 12 }) {
        ForEach(this.categories, (category: string) => {
          Button(category)
            .fontSize(14)
            .fontColor(this.selectedCategory === category ? Color.White : '#1a1a1a')
            .backgroundColor(this.selectedCategory === category ? '#007aff' : '#f0f0f0')
            .borderRadius(20)
            .padding({ left: 24, right: 24, top: 12, bottom: 12 })
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
  }

  @Builder
  ProductListItem(product: ProductModel) {
    Row() {
      // 商品图片
      Image(product.image)
        .width(80)
        .height(80)
        .objectFit(ImageFit.Cover)
        .borderRadius(12)
        .backgroundColor('#f0f0f0')

      Column() {
        Text(product.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1a1a1a')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Text(product.category)
          .fontSize(12)
          .fontColor('#666666')
          .margin({ top: 4 })

        Row() {
          Text(`¥${product.price}`)
            .fontSize(16)
            .fontColor('#ff4444')
            .fontWeight(FontWeight.Bold)

          Text(`库存: ${product.stock || 100}`)
            .fontSize(12)
            .fontColor((product.stock || 100) < 10 ? '#ff9500' : '#666666')
            .margin({ left: 12 })
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)

      // 操作按钮
      Column() {
        Button('编辑')
          .fontSize(12)
          .fontColor('#007aff')
          .backgroundColor('#007aff20')
          .borderRadius(16)
          .padding({ left: 16, right: 16 })
          .margin({ bottom: 8 })
          .onClick(() => this.onEditProduct(product))

        Button('删除')
          .fontSize(12)
          .fontColor('#ff4444')
          .backgroundColor('#ff444420')
          .borderRadius(16)
          .padding({ left: 16, right: 16 })
          .onClick(() => this.onDeleteProduct(product))
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({
      radius: 4,
      color: '#00000008',
      offsetX: 0,
      offsetY: 2
    })
    .margin({ bottom: 12 })
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('管理员后台')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1a1a1a')

        Blank()

        Button('返回商城')
          .fontSize(14)
          .fontColor('#007aff')
          .backgroundColor(Color.Transparent)
          .onClick(() => router.back())
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })

      // 主内容
      Scroll() {
        Column() {
          // 统计卡片
          Column() {
            this.StatisticsCard()
          }
          .margin({ top: 12 })

          // 搜索栏
          this.SearchBar()

          // 分类筛选
          this.CategoryFilter()

          // 商品列表标题
          Row() {
            Text(`商品列表 (${this.filteredProducts.length})`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1a1a1a')
            Blank()
          }
          .width('100%')
          .padding({ left: 20, right: 20 })
          .margin({ bottom: 12 })

          // 商品列表
          if (this.filteredProducts.length > 0) {
            Column() {
              ForEach(this.filteredProducts, (product: ProductModel) => {
                this.ProductListItem(product)
              })
            }
            .width('100%')
            .padding({ left: 20, right: 20 })
          } else if (!this.isLoading) {
            Column() {
              Text('📦')
                .fontSize(60)
                .margin({ bottom: 16 })
              Text('暂无商品')
                .fontSize(16)
                .fontColor('#666666')
            }
            .width('100%')
            .height(200)
            .justifyContent(FlexAlign.Center)
          }

          // 底部间距
          Column()
            .width('100%')
            .height(100)
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#f5f5f7')

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
        .backgroundColor('#f5f5f7')
        .position({ x: 0, y: 0 })
        .zIndex(1000)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f7')
  }
}