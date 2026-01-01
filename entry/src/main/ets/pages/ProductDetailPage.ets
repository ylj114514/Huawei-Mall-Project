import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { ProductModel, MockData } from '../model/ProductModel'
import { CartService } from '../services/CartService'

@Entry
@Component
struct ProductDetailPage {
  @State product: ProductModel | null = null
  @State quantity: number = 1
  @State selectedColor: string = '雅川青'
  @State selectedStorage: string = '512GB'
  @State isLoading: boolean = true

  // 服务实例
  private cartService: CartService = CartService.getInstance()

  // 模拟的规格数据
  private colors: string[] = ['雅川青', '白沙银', '南糯紫', '雅丹黑']
  private storages: string[] = ['256GB', '512GB', '1TB']

  aboutToAppear() {
    // 1. 获取首页传递过来的参数
    const params = router.getParams() as Record<string, Object>

    let productId = ''
    if (params && params.productId) {
      productId = (params.productId as string)
    }
    // 兜底逻辑：如果参数不对，默认加载第一个商品，防止白屏
    this.loadProductDetails(productId)
  }

  private loadProductDetails(id: string) {
    setTimeout(() => {
      const allProducts = MockData.generateProducts()
      // 尝试找到对应商品，找不到就用第一个
      this.product = allProducts.find(p => p.id === id) || allProducts[0]
      this.isLoading = false
    }, 500)
  }

  private async addToCart() {
    if (this.product) {
      await this.cartService.addToCart(this.product, this.quantity)
      promptAction.showToast({ message: '已成功加入购物车' })
    }
  }

  private buyNow() {
    promptAction.showDialog({
      title: '确认订单',
      message: `您选择了：\n${this.product?.name}\n颜色：${this.selectedColor}\n容量：${this.selectedStorage}\n\n功能开发中，敬请期待！`,
      buttons: [{ text: '好的', color: '#CF0A2C' }]
    })
  }

  @Builder
  NavBar() {
    Row() {
      Button({ type: ButtonType.Circle }) {
        Text('<')
          .fontSize(20)
          .fontColor('#1a1a1a')
      }
      .width(40)
      .height(40)
      .backgroundColor('rgba(255,255,255,0.8)')
      .onClick(() => router.back())

      Blank()

      Button({ type: ButtonType.Circle }) {
        Text('🛒')
          .fontSize(20)
      }
      .width(40)
      .height(40)
      .backgroundColor('rgba(255,255,255,0.8)')
      .onClick(() => router.pushUrl({ url: 'pages/CartPage' }))
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12 })
    .position({ x: 0, y: 0 })
    .zIndex(10)
  }

  build() {
    Stack() {
      if (this.product) {
        Column() {
          Scroll() {
            Column() {
              // 1. 商品大图
              Image(this.product.image)
                .width('100%')
                .height(400)
                .objectFit(ImageFit.Contain)
                .backgroundColor('#F5F5F5')

              // 2. 价格与标题区域
              Column() {
                Row() {
                  Text('¥')
                    .fontSize(18)
                    .fontColor('#CF0A2C')
                    .margin({ top: 4 })
                  Text(`${this.product.price}`)
                    .fontSize(32)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#CF0A2C')

                  if (this.product.originalPrice > this.product.price) {
                    Text(`¥${this.product.originalPrice}`)
                      .fontSize(14)
                      .fontColor('#999')
                      .decoration({ type: TextDecorationType.LineThrough })
                      .margin({ left: 10, top: 10 })
                  }
                }
                .width('100%')
                .margin({ bottom: 12 })

                Text(this.product.name)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1a1a1a')
                  .margin({ bottom: 8 })

                Text(this.product.description)
                  .fontSize(14)
                  .fontColor('#666')
                  .lineHeight(20)
              }
              .padding(20)
              .backgroundColor(Color.White)
              .borderRadius({ topLeft: 24, topRight: 24 })
              .margin({ top: -20 })

              // 3. 规格选择
              Column() {
                Text('颜色选择')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .margin({ bottom: 12 })

                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.colors, (color: string) => {
                    Text(color)
                      .fontSize(14)
                      .fontColor(this.selectedColor === color ? '#CF0A2C' : '#333')
                      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                      .backgroundColor(this.selectedColor === color ? 'rgba(207, 10, 44, 0.1)' : '#F5F5F5')
                      .borderRadius(16)
                      .border({ width: 1, color: this.selectedColor === color ? '#CF0A2C' : 'transparent' })
                      .margin({ right: 12, bottom: 12 })
                      .onClick(() => this.selectedColor = color)
                  })
                }
                .margin({ bottom: 20 })

                Text('版本选择')
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .margin({ bottom: 12 })

                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.storages, (storage: string) => {
                    Text(storage)
                      .fontSize(14)
                      .fontColor(this.selectedStorage === storage ? '#CF0A2C' : '#333')
                      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                      .backgroundColor(this.selectedStorage === storage ? 'rgba(207, 10, 44, 0.1)' : '#F5F5F5')
                      .borderRadius(16)
                      .border({ width: 1, color: this.selectedStorage === storage ? '#CF0A2C' : 'transparent' })
                      .margin({ right: 12, bottom: 12 })
                      .onClick(() => this.selectedStorage = storage)
                  })
                }
              }
              .width('100%')
              .padding(20)
              .backgroundColor(Color.White)
              .margin({ top: 12 })

              // 底部留白
              Blank().height(80)
            }
          }
          .width('100%')
          .height('100%')
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#F5F5F5')

        // 底部购买栏
        Row() {
          Column() {
            Text('🎧')
              .fontSize(20)
            Text('客服')
              .fontSize(10)
              .fontColor('#666')
          }
          .margin({ right: 20 })

          Column() {
            Text('⭐')
              .fontSize(20)
            Text('收藏')
              .fontSize(10)
              .fontColor('#666')
          }
          .margin({ right: 20 })

          Button('加入购物车')
            .backgroundColor('#FF9500')
            .fontSize(14)
            .height(40)
            .layoutWeight(1)
            .margin({ right: 10 })
            .onClick(() => this.addToCart())

          Button('立即购买')
            .backgroundColor('#CF0A2C')
            .fontSize(14)
            .height(40)
            .layoutWeight(1)
            .onClick(() => this.buyNow())
        }
        .width('100%')
        .height(60)
        .backgroundColor(Color.White)
        .position({ x: 0, y: '100%' })
        .translate({ x: 0, y: -60 })
        .padding({ left: 16, right: 16 })
        .shadow({ radius: 10, color: 'rgba(0,0,0,0.1)', offsetY: -5 })

      } else {
        // 加载中
        Column() {
          LoadingProgress().width(50).height(50).color('#CF0A2C')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }

      // 顶部悬浮导航
      this.NavBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}