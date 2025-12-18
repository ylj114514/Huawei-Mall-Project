import router from '@ohos.router'
import { ProductModel, MockData } from '../model/ProductModel'
import { StorageManager } from '../utils/StorageManager'
import { User } from '../model/DataModel'
import { AuthGuard } from '../components/AuthGuard.ets'
import common from '@ohos.app.ability.common'

// 奢华配色方案
interface ColorScheme {
  background: string
  primary: string
  accent: string
  secondary: string
  cardBg: string
  gold: string
  shadow: string
  overlay: string
}

const COLORS: ColorScheme = {
  background: '#FAFAFA',
  primary: '#000000',
  accent: '#CF0A2C',
  secondary: '#666666',
  cardBg: '#FFFFFF',
  gold: '#D4AF37',
  shadow: 'rgba(0, 0, 0, 0.08)',
  overlay: 'rgba(0, 0, 0, 0.04)'
}

@Entry
@Component
struct IndexLuxury {
  @State products: ProductModel[] = []
  @State filteredProducts: ProductModel[] = []
  @State searchText: string = ''
  @State selectedCategory: string = '全部'
  @State isLoading: boolean = true
  @State scrollOffset: number = 0
  @State searchExpanded: boolean = false
  @State user: User | null = null
  @State cartCount: number = 0

  private categories: string[] = ['全部', '手机', '平板', '笔记本', '手表', '耳机']
  private scroller: Scroller = new Scroller()
  private storage: StorageManager = StorageManager.getInstance()
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  aboutToAppear() {
    this.initStorage()
    this.loadData()
    this.checkLoginStatus()
  }

  private async initStorage() {
    try {
      await this.storage.init(this.context)
      console.log('IndexLuxury: StorageManager初始化成功')
    } catch (error) {
      console.error('IndexLuxury: StorageManager初始化失败:', error)
    }
  }

  private async loadData() {
    setTimeout(() => {
      this.products = MockData.generateProducts()
      this.filteredProducts = this.products
      this.isLoading = false
    }, 1200)
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
    this.searchExpanded = offset > 50
  }

  private onSearch(value: string) {
    this.searchText = value
    this.filterProducts()
  }

  private filterProducts() {
    let filtered = this.products

    if (this.selectedCategory !== '全部') {
      filtered = filtered.filter(product =>
        product.category === this.selectedCategory
      )
    }

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

  @Builder
  FloatingSearchBar() {
    Column() {
      // 顶部状态栏占位
      Row().width('100%').height(44)

      // 浮动搜索栏
      Column() {
        Row() {
          // 菜单按钮
          Button() {
            Text('☰')
              .fontSize(24)
              .fontColor(COLORS.primary)
          }
          .width(48)
          .height(48)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            // 侧边菜单逻辑
          })

          // 搜索框
          Row() {
            Text('🔍')
              .fontSize(18)
              .fontColor(COLORS.secondary)
              .margin({ left: 16 })

            TextInput({
              placeholder: '探索华为科技',
              text: this.searchText
            })
              .fontSize(16)
              .fontColor(COLORS.primary)
              .backgroundColor(Color.Transparent)
              .layoutWeight(1)
              .placeholderColor(COLORS.secondary)
              .margin({ left: 12 })
              .onChange((value: string) => {
                this.onSearch(value)
              })

            if (this.searchText) {
              Button() {
                Text('✕')
                  .fontSize(14)
                  .fontColor(COLORS.secondary)
              }
              .width(36)
              .height(36)
              .backgroundColor(Color.Transparent)
              .onClick(() => {
                this.searchText = ''
                this.onSearch('')
              })
            }
          }
          .width('100%')
          .height(48)
          .backgroundColor(COLORS.cardBg)
          .borderRadius(24)
          .shadow({
            radius: 20,
            color: COLORS.shadow,
            offsetX: 0,
            offsetY: 4
          })

          // 通知按钮
          Button() {
            Text('🔔')
              .fontSize(20)
              .fontColor(COLORS.primary)
          }
          .width(48)
          .height(48)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            // 通知逻辑
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20 })
      .backgroundColor(`rgba(250, 250, 250, ${this.searchExpanded ? 1 : 0.95})`)
      .backdropBlur(this.searchExpanded ? 20 : 10)
      .border({
        width: { bottom: this.searchExpanded ? 0.5 : 0 },
        color: 'rgba(0,0,0,0.08)'
      })
      .transition({ type: TransitionType.All })
    }
    .width('100%')
    .position({ x: 0, y: 0 })
    .zIndex(1000)
  }

  @Builder
  HeroSection() {
    Column() {
      // 品牌标语
      Text('HUAWEI')
        .fontSize(48)
        .fontWeight(FontWeight.Bold)
        .fontColor(COLORS.primary)
        .letterSpacing(8)
        .margin({ bottom: 8 })

      Text('构建万物互联的智能世界')
        .fontSize(18)
        .fontColor(COLORS.secondary)
        .margin({ bottom: 40 })

      // 轮播图
      Swiper() {
        ForEach([
          {
            title: 'Mate 60 Pro',
            subtitle: '王者归来',
            desc: '麒麟芯片 · 卫星通话',
            color: '#000000',
            bg: 'https://consumer-img.huawei.com/content/dam/huawei-cbg-site/cn/mkt/imgs/2024/01/mate-60-pro-list-kv.png'
          },
          {
            title: 'HarmonyOS',
            subtitle: '新一代操作系统',
            desc: '流畅 · 安全 · 万物互联',
            color: '#CF0A2C',
            bg: 'https://consumer-img.huawei.com/content/dam/huawei-cbg-site/cn/mkt/imgs/2023/08/harmonyos-pc-kv.png'
          },
          {
            title: 'WATCH GT 4',
            subtitle: '专业运动健康',
            desc: '续航14天 · 精准定位',
            color: '#D4AF37',
            bg: 'https://consumer-img.huawei.com/content/dam/huawei-cbg-site/cn/mkt/imgs/2023/09/watch-gt4-kv.png'
          }
        ], (item: Record<string, string>) => {
          Stack() {
            // 背景渐变
            Column()
              .width('100%')
              .height(400)
              .linearGradient({
                direction: GradientDirection.Bottom,
                colors: [
                  [item.color || COLORS.primary, 0.1],
                  ['#FFFFFF', 1]
                ]
              })

            Column() {
              Text(item.subtitle || '')
                .fontSize(16)
                .fontColor(item.color || COLORS.primary)
                .margin({ bottom: 8 })

              Text(item.title || '')
                .fontSize(42)
                .fontWeight(FontWeight.Bold)
                .fontColor(item.color || COLORS.primary)
                .margin({ bottom: 12 })

              Text(item.desc || '')
                .fontSize(16)
                .fontColor(COLORS.secondary)
                .lineHeight(24)
            }
            .width('100%')
            .padding(32)
            .alignItems(HorizontalAlign.Start)
          }
        })
      }
      .width('100%')
      .height(400)
      .autoPlay(true)
      .interval(4000)
      .indicatorStyle({
        size: 6,
        left: 32,
        bottom: 32,
        color: 'rgba(0,0,0,0.2)',
        selectedColor: COLORS.primary
      })
      .borderRadius(32)
      .margin({ left: 20, right: 20 })
      .shadow({
        radius: 30,
        color: COLORS.shadow,
        offsetX: 0,
        offsetY: 10
      })
    }
    .width('100%')
    .padding({ top: 100, bottom: 40 })
  }

  @Builder
  CategoryPills() {
    Column() {
      Row() {
        ForEach(this.categories, (category: string, index: number) => {
          Column() {
            Text(category)
              .fontSize(15)
              .fontWeight(this.selectedCategory === category ? FontWeight.Bold : FontWeight.Normal)
              .fontColor(this.selectedCategory === category ? Color.White : COLORS.primary)
              .padding({ left: 28, right: 28, top: 14, bottom: 14 })
          }
          .backgroundColor(this.selectedCategory === category ? COLORS.primary : COLORS.cardBg)
          .borderRadius(25)
          .shadow({
            radius: this.selectedCategory === category ? 15 : 8,
            color: COLORS.shadow,
            offsetX: 0,
            offsetY: this.selectedCategory === category ? 6 : 3
          })
          .transition({ type: TransitionType.All })
          .onClick(() => {
            this.onCategorySelect(category)
          })
          .margin({ left: index === 0 ? 0 : 12 })
        })
      }
      .width('100%')
      .padding({ left: 20, right: 20 })
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .margin({ bottom: 40 })
  }

  @Builder
  ProductCard(product: ProductModel) {
    Column() {
      // 图片容器
      Stack() {
        // 背景装饰
        Column()
          .width('100%')
          .height(240)
          .backgroundColor(COLORS.overlay)
          .borderRadius(24)
          .position({ x: 0, y: 8 })

        Image(product.image)
          .width('100%')
          .height(240)
          .objectFit(ImageFit.Contain)
          .backgroundColor('#FFFFFF')
          .borderRadius(24)
          .padding(20)

        // 新品标签
        if (product.isNew) {
          Column() {
            Text('NEW')
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
              .backgroundColor(COLORS.accent)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .borderRadius(12)
          }
          .position({ x: 16, y: 16 })
        }

        // 收藏按钮
        Button() {
          Text('♡')
            .fontSize(24)
            .fontColor(COLORS.accent)
        }
        .width(44)
        .height(44)
        .backgroundColor('rgba(255,255,255,0.9)')
        .borderRadius(22)
        .position({ x: '100%', y: 16 })
        .translate({ x: -60, y: 0 })
        .shadow({
          radius: 12,
          color: COLORS.shadow,
          offsetX: 0,
          offsetY: 2
        })
      }
      .margin({ bottom: 20 })

      // 产品信息
      Column() {
        Text(product.name)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(COLORS.primary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ bottom: 8 })

        // 标签
        Row() {
          if (product.tags && product.tags.length > 0) {
            ForEach(product.tags.slice(0, 2), (tag: string) => {
              Text(tag)
                .fontSize(12)
                .fontColor(COLORS.secondary)
                .backgroundColor(COLORS.overlay)
                .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                .borderRadius(8)
                .margin({ right: 8 })
            })
          }
        }
        .width('100%')
        .margin({ bottom: 16 })

        // 价格区域
        Row() {
          Row() {
            Text('¥')
              .fontSize(16)
              .fontColor(COLORS.accent)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 4 })
            Text(`${product.price}`)
              .fontSize(28)
              .fontColor(COLORS.accent)
              .fontWeight(FontWeight.Bold)
          }
          .alignItems(VerticalAlign.Bottom)

          Blank()

          // 购买按钮
          Button() {
            Text('购买')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
          }
          .width(80)
          .height(36)
          .backgroundColor(COLORS.primary)
          .borderRadius(18)
          .shadow({
            radius: 10,
            color: COLORS.shadow,
            offsetX: 0,
            offsetY: 3
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .padding(24)
    }
    .width('100%')
    .backgroundColor(COLORS.cardBg)
    .borderRadius(32)
    .shadow({
      radius: 20,
      color: COLORS.shadow,
      offsetX: 0,
      offsetY: 8
    })
    .onClick(() => {
      this.onProductClick(product)
    })
    .transition({ type: TransitionType.All })
  }

  @Builder
  ProductList() {
    Column() {
      // 标题
      Row() {
        Text('探索产品')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(COLORS.primary)
        Blank()
        Text(`共 ${this.filteredProducts.length} 件`)
          .fontSize(16)
          .fontColor(COLORS.secondary)
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 32 })

      // 产品网格
      if (this.filteredProducts.length > 0) {
        Grid() {
          ForEach(this.filteredProducts, (product: ProductModel) => {
            GridItem() {
              this.ProductCard(product)
            }
          })
        }
        .columnsTemplate('1fr')
        .rowsGap(32)
        .padding({ left: 20, right: 20, bottom: 140 })
      } else {
        Column() {
          Text('未找到相关产品')
            .fontSize(18)
            .fontColor(COLORS.secondary)
            .margin({ top: 80 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
  }

  @Builder
  BottomNavigation() {
    Row() {
      // 首页
      Column() {
        Text('🏠')
          .fontSize(28)
          .margin({ bottom: 4 })
        Text('首页')
          .fontSize(12)
          .fontColor(COLORS.primary)
          .fontWeight(FontWeight.Medium)
      }
      .width('33.33%')
      .height(70)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(COLORS.cardBg)

      // 购物车
      Column() {
        Stack() {
          Text('🛒')
            .fontSize(28)
            .margin({ bottom: 4 })

          if (this.cartCount > 0) {
            Text(`${this.cartCount}`)
              .fontSize(12)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
              .backgroundColor(COLORS.accent)
              .borderRadius(10)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .position({ x: 16, y: -4 })
          }
        }
        Text('购物车')
          .fontSize(12)
          .fontColor(COLORS.secondary)
          .fontWeight(FontWeight.Medium)
      }
      .width('33.33%')
      .height(70)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(COLORS.cardBg)
      .onClick(() => {
        router.pushUrl({ url: 'pages/CartPageNew' })
      })

      // 我的
      Column() {
        Text(this.user ? '👤' : '👤')
          .fontSize(28)
          .margin({ bottom: 4 })
        Text(this.user ? '我的' : '登录')
          .fontSize(12)
          .fontColor(COLORS.secondary)
          .fontWeight(FontWeight.Medium)
      }
      .width('33.33%')
      .height(70)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(COLORS.cardBg)
      .onClick(() => {
        if (!this.user) {
          router.pushUrl({ url: 'pages/LoginPage' })
        } else {
          router.pushUrl({ url: 'pages/UserCenterPage' })
        }
      })
    }
    .width('100%')
    .height(70)
    .backgroundColor(COLORS.cardBg)
    .border({
      width: { top: 0.5 },
      color: 'rgba(0,0,0,0.08)'
    })
    .position({ x: 0, y: '100%' })
    .translate({ x: 0, y: -70 })
    .shadow({
      radius: 20,
      color: COLORS.shadow,
      offsetX: 0,
      offsetY: -5
    })
  }

  build() {
    Column() {
      // 主内容
      Scroll(this.scroller) {
        Column() {
          // 顶部占位
          Row().width('100%').height(120)

          // Hero区域
          this.HeroSection()

          // 分类选择
          this.CategoryPills()

          // 产品列表
          this.ProductList()
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(COLORS.background)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .onScroll((xOffset: number, yOffset: number) => {
        this.onScroll(yOffset)
      })

      // 浮动搜索栏
      this.FloatingSearchBar()

      // 底部导航
      this.BottomNavigation()

      // 加载动画
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color(COLORS.primary)
          Text('加载中...')
            .fontSize(16)
            .fontColor(COLORS.secondary)
            .margin({ top: 20 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(COLORS.background)
        .zIndex(2000)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLORS.background)
  }
}