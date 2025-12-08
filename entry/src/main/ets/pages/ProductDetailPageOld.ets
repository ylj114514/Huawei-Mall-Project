import router from '@ohos.router'
import { ProductModel, MockData } from '../model/ProductModel'
import { CartService } from '../services/CartService'
import { CommentSection } from '../components/CommentSection'

@Entry
@Component
struct ProductDetailPage {
  @State product: ProductModel | null = null
  @State currentImageIndex: number = 0
  @State selectedSpec: string = ''
  @State quantity: number = 1
  @State isLoading: boolean = true
  @State showSpecDialog: boolean = false
  @State currentTab: number = 0
  private cartService: CartService

  aboutToAppear() {
    this.cartService = CartService.getInstance()
    this.loadProductData()
  }

  private loadProductData() {
    interface RouteParams {
      productId: string
    }
    const params = router.getParams() as RouteParams
    if (params && params.productId) {
      // 从模拟数据中查找商品
      const products = MockData.generateProducts()
      this.product = products.find(p => p.id === params.productId) || null
    }
    this.isLoading = false
  }

  private onImageChange(index: number) {
    this.currentImageIndex = index
  }

  private onQuantityChange(change: number) {
    const newQuantity = this.quantity + change
    if (newQuantity >= 1 && newQuantity <= (this.product?.stock || 0)) {
      this.quantity = newQuantity
    }
  }

  private async onAddToCart() {
    if (!this.product) return

    if (this.quantity > this.product.stock) {
      // 库存不足提示
      console.error('库存不足')
      return
    }

    try {
      const success = await this.cartService.addToCart(this.product, this.quantity)
      if (success) {
        console.log('添加到购物车成功')
        // 这里可以添加成功提示
        // 并跳转到购物车页面
        router.pushUrl({ url: 'pages/CartPage' })
      } else {
        console.error('添加到购物车失败')
      }
    } catch (error) {
      console.error('添加到购物车异常:', error)
    }
  }

  private onBuyNow() {
    if (!this.product) return
    // 直接购买逻辑
    console.log('立即购买:', this.product.name, '数量:', this.quantity)
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button('←')
          .width(40)
          .height(40)
          .backgroundColor(Color.Transparent)
          .fontColor($r('app.color.text_primary'))
          .onClick(() => {
            router.back()
          })

        Text('商品详情')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button('⋮')
          .width(40)
          .height(40)
          .backgroundColor(Color.Transparent)
          .fontColor($r('app.color.text_primary'))
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .backgroundColor($r('app.color.white'))

      if (this.isLoading) {
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
      } else if (this.product) {
        // 商品详情内容
        Scroll() {
          Column() {
            // 商品图片轮播
            Swiper() {
              ForEach(this.product.images, (image: string, index: number) => {
                Image(image)
                  .width('100%')
                  .height(350)
                  .objectFit(ImageFit.Contain)
                  .backgroundColor($r('app.color.background'))
                  .alt('商品图片')
              })
            }
            .width('100%')
            .height(350)
            .loop(false)
            .indicator(true)
            .onChange(this.onImageChange.bind(this))

            // 图片指示器
            Row() {
              ForEach(this.product.images, (image: string, index: number) => {
                Circle({ width: 8, height: 8 })
                  .fill(index === this.currentImageIndex ?
                    $r('app.color.primary') : $r('app.color.text_secondary'))
                  .opacity(index === this.currentImageIndex ? 1 : 0.4)
                  .margin({ left: 4, right: 4 })
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .margin({ top: 8, bottom: 16 })

            // 商品信息
            Column() {
              // 商品名称和价格
              Column() {
                Text(this.product.name)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.text_primary'))
                  .width('100%')
                  .margin({ bottom: 12 })

                Row() {
                  Text(`¥${this.product.price}`)
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                    .fontColor($r('app.color.price'))

                  Text(`¥${this.product.originalPrice}`)
                    .fontSize(16)
                    .fontColor($r('app.color.text_secondary'))
                    .decoration({ type: TextDecorationType.LineThrough })
                    .margin({ left: 12, top: 4 })
                }
                .width('100%')
                .alignItems(VerticalAlign.Bottom)
                .margin({ bottom: 12 })

                // 评分和销量
                Row() {
                  Row() {
                    Text('⭐')
                      .fontSize(14)
                    Text(this.product.rating.toFixed(1))
                      .fontSize(14)
                      .fontColor($r('app.color.text_secondary'))
                    Text(`(${this.product.reviewCount}条评价)`)
                      .fontSize(12)
                      .fontColor($r('app.color.text_secondary'))
                      .margin({ left: 4 })
                  }

                  Text(`库存 ${this.product.stock}`)
                    .fontSize(12)
                    .fontColor(this.product.stock > 50 ?
                      $r('app.color.success') : $r('app.color.warning'))
                    .margin({ left: 20 })
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .width('100%')
              .padding(16)
              .backgroundColor($r('app.color.white'))
              .borderRadius(12)
              .margin({ bottom: 12 })

              // 商品标签
              Column() {
                Text('商品特点')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .width('100%')
                  .margin({ bottom: 12 })

                Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
                  ForEach(this.product.tags, (tag: string) => {
                    Text(tag)
                      .fontSize(12)
                      .fontColor($r('app.color.primary'))
                      .backgroundColor($r('app.color.primary_light'))
                      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                      .borderRadius(4)
                      .margin({ right: 8 })
                    .margin({ bottom: 8 })
                  })
                }
                .width('100%')
              }
              .width('100%')
              .padding(16)
              .backgroundColor($r('app.color.white'))
              .borderRadius(12)
              .margin({ bottom: 12 })

              // 商品详细描述
              Column() {
                Text('商品详情')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .width('100%')
                  .margin({ bottom: 12 })

                Text(this.product.detailDescription)
                  .fontSize(14)
                  .fontColor($r('app.color.text_primary'))
                  .lineHeight(22)
                  .width('100%')
              }
              .width('100%')
              .padding(16)
              .backgroundColor($r('app.color.white'))
              .borderRadius(12)
              .margin({ bottom: 12 })

              // 选择数量
              Column() {
                Row() {
                  Text('购买数量')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .layoutWeight(1)

                  Row() {
                    Button('-')
                      .width(36)
                      .height(36)
                      .fontSize(16)
                      .backgroundColor($r('app.color.background'))
                      .fontColor($r('app.color.text_primary'))
                      .onClick(() => this.onQuantityChange(-1))

                    Text(this.quantity.toString())
                      .fontSize(16)
                      .fontColor($r('app.color.text_primary'))
                      .width(50)
                      .textAlign(TextAlign.Center)

                    Button('+')
                      .width(36)
                      .height(36)
                      .fontSize(16)
                      .backgroundColor($r('app.color.background'))
                      .fontColor($r('app.color.text_primary'))
                      .onClick(() => this.onQuantityChange(1))
                  }
                }
                .width('100%')
                .alignItems(VerticalAlign.Center)
              }
              .width('100%')
              .padding(16)
              .backgroundColor($r('app.color.white'))
              .borderRadius(12)
              .margin({ bottom: 100 }) // 为底部按钮留空间
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          }
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor($r('app.color.background'))
      } else {
        // 商品不存在
        Column() {
          Text('商品不存在')
            .fontSize(16)
            .fontColor($r('app.color.text_secondary'))
          Button('返回首页')
            .height(40)
            .fontSize(14)
            .margin({ top: 16 })
            .onClick(() => {
              router.replaceUrl({ url: 'pages/Index' })
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.background'))
      }

      // 底部购买栏
      if (this.product) {
        Row() {
          Button('加入购物车')
            .height(50)
            .fontSize(16)
            .backgroundColor($r('app.color.secondary'))
            .layoutWeight(1)
            .margin({ right: 8 })
            .onClick(() => this.onAddToCart())

          Button('立即购买')
            .height(50)
            .fontSize(16)
            .backgroundColor($r('app.color.primary'))
            .layoutWeight(1)
            .onClick(() => this.onBuyNow())
        }
        .width('100%')
        .padding(16)
        .backgroundColor($r('app.color.white'))
        .shadow({
          radius: 4,
          color: '#1A000000',
          offsetX: 0,
          offsetY: -2
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}