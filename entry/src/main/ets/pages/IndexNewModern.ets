import router from '@ohos.router'
import { ProductModel, MockData } from '../model/ProductModel'
import { StorageManager } from '../utils/StorageManagerSimple'
import { User } from '../model/DataModel'
import { BannerData } from '../model/PageModels'
import common from '@ohos.app.ability.common'

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

// 图标数据类
class IconData {
  name: string
  icon: string

  constructor(name: string, icon: string) {
    this.name = name
    this.icon = icon
  }
}

@Entry
@Component
struct IndexNewModern {
  @State allProducts: ProductModel[] = []
  @State products: ProductModel[] = []
  @State user: User | null = null
  @State isLoading: boolean = true
  @State searchText: string = ''
  @State currentCategory: string = '推荐'
  private storage: StorageManager = StorageManager.getInstance()
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  // 当前选中的分类
  @State selectedCategory: string = ''

  aboutToAppear() {
    this.initStorage()
    this.loadData()
    this.checkLoginStatus()
  }

  private async initStorage() {
    try {
      await this.storage.init(this.context)
    } catch (error) {
      console.error('初始化存储失败:', error)
    }
  }

  private loadData() {
    setTimeout(() => {
      this.allProducts = MockData.generateProducts()
      this.products = this.allProducts
      this.isLoading = false
    }, 500)
  }

  // 根据分类筛选商品
  private filterProducts(category: string) {
    if (category === '' || category === '全部') {
      this.products = this.allProducts
    } else {
      // 处理分类映射
      let actualCategory = category
      if (category === '耳机') actualCategory = '音频'
      if (category === '手表') actualCategory = '智能穿戴'

      this.products = this.allProducts.filter(product => product.category === actualCategory)
    }
  }

  private async checkLoginStatus() {
    this.user = await this.storage.loadUser()
  }

  private onProductClick(product: ProductModel) {
    router.pushUrl({
      url: 'pages/ProductDetailFixed',
      params: { productId: product.id }
    })
  }

  private onCategoryClick(category: IconData) {
    this.selectedCategory = category.name
    console.log('点击分类:', category.name)
  }

  @Builder
  Header() {
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
        TextInput({ placeholder: '搜索商品' })
          .width(200)
          .height(36)
          .fontSize(14)
          .backgroundColor('#F0F2F5')
          .borderRadius(18)
          .padding({ left: 16 })
          .onChange((value: string) => {
            this.searchText = value
          })
      }

      Blank().width(20)

      // 用户
      Button() {
        Text(this.user ? '👤' : '👤')
          .fontSize(22)
      }
      .width(36)
      .height(36)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        console.log('用户头像点击')
        router.pushUrl({
          url: 'pages/ProfileModernFixed'
        }).then(() => {
          console.log('导航到个人中心成功')
        }).catch((err: Error) => {
          console.error('导航失败:', err)
        })
      })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 12, bottom: 12 })
    .backgroundColor(COLORS.surface)
  }

  @Builder
  HeroBanner() {
    Swiper() {
      ForEach([
        {
          title: 'Mate 60 系列',
          subtitle: '玄武架构 鸿蒙生态',
          desc: '超光变影像 · 卫星通话',
          bgColor: '#1A1A1A'
        },
        {
          title: 'nova 12 系列',
          subtitle: '潮流影像 超级快充',
          desc: '人像大片 · 超级闪充',
          bgColor: '#FF6B6B'
        },
        {
          title: 'WATCH GT 4',
          subtitle: '专业运动 健康管理',
          desc: '100+运动模式 · 科学睡眠',
          bgColor: '#4ECDC4'
        }
      ], (banner: Record<string, string>) => {
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
          ForEach(['手机', '笔记本', '平板', '手表', '耳机', '智慧屏', '相机', '音响'], (item: string) => {
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
              console.log(`分类按钮点击: ${item}`)
              this.filterProducts(item)
            })
          })
        }
        .padding({ left: 20, right: 20 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .width('100%')
      .height(120)
    }
    .width('100%')
    .backgroundColor(COLORS.surface)
    .margin({ top: 12 })
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
      .onClick(() => {
        // 当前页面
      })

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
        console.log('导航到个人中心')
        router.pushUrl({
          url: 'pages/ProfileModernFixed'
        }).then(() => {
          console.log('导航成功')
        }).catch((err: Error) => {
          console.error('导航失败:', err)
        })
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
              })
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

      // 底部导航
      this.BottomNav()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLORS.background)
  }
}