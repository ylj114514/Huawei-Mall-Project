import router from '@ohos.router'
import { ProductModel, MockData } from '../model/ProductModel'
import { CartService } from '../services/CartService'
import { CommentSectionNew } from '../components/CommentSectionNew'

@Entry
@Component
struct ProductDetailPage {
  @State product: ProductModel | null = null
  @State currentImageIndex: number = 0
  @State quantity: number = 1
  @State isLoading: boolean = true
  @State showCartDialog: boolean = false
  @State showAlreadyInCartDialog: boolean = false
  @State scrollY: number = 0
  @State imageHeight: number = 375 // 图片高度，类似京东/淘宝
  private cartService: CartService = CartService.getInstance()

  aboutToAppear() {
    this.loadProductData()
  }

  private loadProductData() {
    interface RouteParams {
      productId: string
    }
    const params = router.getParams() as RouteParams
    if (params && params.productId) {
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

  private onAddToCart() {
    if (!this.product) return

    if (this.quantity > this.product.stock) {
      console.error('库存不足')
      return
    }

    try {
      if (this.cartService.isProductInCart(this.product.id)) {
        // 商品已在购物车中，显示提示对话框
        this.showAlreadyInCartDialog = true
      } else {
        const success = this.cartService.addToCart(this.product, this.quantity)
        if (!success) {
          console.error('添加到购物车失败')
          return
        }
        console.log('添加到购物车成功')
        this.showCartSuccessDialog()
      }
    } catch (error) {
      console.error('添加到购物车异常:', error)
    }
  }

  private showCartSuccessDialog(): void {
    this.showCartDialog = true
  }

  private goToCart(): void {
    this.showCartDialog = false
    router.pushUrl({ url: 'pages/CartPageNew' })
  }

  private continueShopping(): void {
    this.showCartDialog = false
  }

  private closeAlreadyInCartDialog(): void {
    this.showAlreadyInCartDialog = false
  }

  private onBuyNow() {
    if (!this.product) return
    console.log('立即购买:', this.product.name, '数量:', this.quantity)
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航栏
        Row() {
          Button() {
            Row() {
              Text('←')
                .fontSize(18)
                .fontColor($r('app.color.text_primary'))
              Text('返回')
                .fontSize(16)
                .fontColor($r('app.color.text_primary'))
                .margin({ left: 4 })
            }
          }
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            try {
              router.back()
            } catch (error) {
              console.error('返回失败:', error)
            }
          })

          Blank().layoutWeight(1)

          Text(this.product?.name || '商品详情')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('40%')

          Blank().layoutWeight(1)

          // 购物车按钮
          Button() {
            Row() {
              Text('🛒')
                .fontSize(20)
              Text('购物车')
                .fontSize(10)
                .margin({ left: 4 })
            }
          }
          .fontSize(12)
          .fontColor($r('app.color.text_primary'))
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.goToCart()
          })
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor($r('app.color.white'))
        .shadow({
          radius: 2,
          color: '#1A000000',
          offsetX: 0,
          offsetY: 1
        })
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)

        // 主内容 - 可滚动
        Scroll() {
          Column() {
            // 商品图片轮播
            Column() {
              Swiper() {
                ForEach(this.product?.images || [], (image: string, index: number) => {
                  Image(image)
                    .width('100%')
                    .height(this.imageHeight)
                    .objectFit(ImageFit.Contain)
                    .backgroundColor('#f5f5f5')
                    .alt('商品图片')
                })
              }
              .width('100%')
              .height(this.imageHeight)
              .loop(true)
              .indicator(true)
              .indicatorStyle({
                size: 8,
                color: 'rgba(255,255,255,0.5)',
                selectedColor: '#ffffff'
              })
              .onChange(this.onImageChange.bind(this))
            }
            .backgroundColor($r('app.color.white'))

            // 商品基本信息
            Column() {
              // 商品名称和价格
              Column() {
                Text(this.product?.name || '')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.text_primary'))
                  .width('100%')
                  .margin({ bottom: 12 })

                Row() {
                  Text(`¥${this.product?.price || 0}`)
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#ff4444')

                  if (this.product?.originalPrice && this.product.originalPrice > this.product.price) {
                    Text(`¥${this.product.originalPrice}`)
                      .fontSize(14)
                      .fontColor($r('app.color.text_secondary'))
                      .decoration({ type: TextDecorationType.LineThrough })
                      .margin({ left: 12, top: 4 })
                  }
                }
                .width('100%')
                .alignItems(VerticalAlign.Bottom)
                .margin({ bottom: 12 })

                // 评分、销量、库存
                Row() {
                  Row() {
                    Text('⭐')
                      .fontSize(14)
                    Text(`${this.product?.rating?.toFixed(1) || '5.0'}`)
                      .fontSize(14)
                      .fontColor($r('app.color.text_secondary'))
                    Text(`(${this.product?.reviewCount || 0}条评价)`)
                      .fontSize(12)
                      .fontColor($r('app.color.text_secondary'))
                      .margin({ left: 4 })
                  }

                  Text(`库存 ${this.product?.stock || 0}`)
                    .fontSize(12)
                    .fontColor((this.product?.stock || 0) > 50 ? '#52c41a' : '#faad14')
                    .margin({ left: 20 })
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .width('100%')
              .padding(16)
              .backgroundColor($r('app.color.white'))
              .borderRadius(12)
              .margin({ top: 8, left: 12, right: 12 })

              // 运费信息
              Row() {
                Text('⚡')
                  .fontSize(16)
                Text('免运费')
                  .fontSize(14)
                  .fontColor($r('app.color.primary'))
                  .margin({ left: 4 })
                Text('预计24小时内发货')
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ left: 8 })
              }
              .width('100%')
              .padding(16)
              .backgroundColor($r('app.color.white'))
              .borderRadius(12)
              .margin({ top: 8, left: 12, right: 12 })
              .justifyContent(FlexAlign.Start)

              // 商品特点标签
              Column() {
                Text('商品特点')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .width('100%')
                  .margin({ bottom: 12 })

                Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
                  ForEach(this.product?.tags || [], (tag: string) => {
                    Text(tag)
                      .fontSize(12)
                      .fontColor($r('app.color.primary'))
                      .backgroundColor('#f0f8ff')
                      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                      .borderRadius(16)
                      .margin({ right: 8, bottom: 8 })
                  })
                }
                .width('100%')
              }
              .width('100%')
              .padding(16)
              .backgroundColor($r('app.color.white'))
              .borderRadius(12)
              .margin({ top: 8, left: 12, right: 12 })

              // 商品详细描述
              Column() {
                Text('商品详情')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .width('100%')
                  .margin({ bottom: 12 })

                Text(this.product?.detailDescription || '暂无详细描述')
                  .fontSize(14)
                  .fontColor($r('app.color.text_primary'))
                  .lineHeight(24)
                  .width('100%')
              }
              .width('100%')
              .padding(16)
              .backgroundColor($r('app.color.white'))
              .borderRadius(12)
              .margin({ top: 8, left: 12, right: 12 })

              // 用户评价区域
              Column() {
                Text('用户评价')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .width('100%')
                  .margin({ bottom: 12 })

                CommentSectionNew({ productId: this.product?.id || '' })
              }
              .width('100%')
              .padding(16)
              .backgroundColor($r('app.color.white'))
              .borderRadius(12)
              .margin({ top: 8, left: 12, right: 12, bottom: 120 }) // 底部空间给购买按钮
            }
          }
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .onScroll((xOffset: number, yOffset: number) => {
          this.scrollY = yOffset
        })
      }
      .width('100%')
      .height('100%')

      // 底部购买栏 - 固定在屏幕最底部
      if (this.product) {
        Row() {
          // 数量选择器
          Column() {
            Text('数量')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .margin({ bottom: 4 })
            Row() {
              Button('-')
                .width(32)
                .height(28)
                .fontSize(14)
                .backgroundColor($r('app.color.background'))
                .fontColor(this.quantity > 1 ? $r('app.color.text_primary') : $r('app.color.text_secondary'))
                .enabled(this.quantity > 1)
                .onClick(() => this.onQuantityChange(-1))

              Text(this.quantity.toString())
                .fontSize(14)
                .fontColor($r('app.color.text_primary'))
                .width(40)
                .textAlign(TextAlign.Center)

              Button('+')
                .width(32)
                .height(28)
                .fontSize(14)
                .backgroundColor($r('app.color.background'))
                .fontColor(this.quantity < this.product.stock ? $r('app.color.text_primary') : $r('app.color.text_secondary'))
                .enabled(this.quantity < this.product.stock)
                .onClick(() => this.onQuantityChange(1))
            }
          }
          .width(80)

          Blank().layoutWeight(1)

          Button('加入购物车')
            .height(48)
            .fontSize(14)
            .backgroundColor('#ff9500')
            .fontColor(Color.White)
            .borderRadius(24)
            .layoutWeight(1)
            .margin({ right: 8 })
            .onClick(() => this.onAddToCart())

          Button('立即购买')
            .height(48)
            .fontSize(14)
            .backgroundColor($r('app.color.primary'))
            .fontColor(Color.White)
            .borderRadius(24)
            .layoutWeight(1)
            .onClick(() => this.onBuyNow())
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor($r('app.color.white'))
        .shadow({
          radius: 4,
          color: '#1A000000',
          offsetX: 0,
          offsetY: -2
        })
        .position({ x: 0, y: '100%' })
        .translate({ x: 0, y: -64 })
        .zIndex(1001)
      }

      // 加载状态
      if (this.isLoading) {
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
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.background'))
      }

      // 加入购物车成功弹窗
      if (this.showCartDialog) {
        Column() {
          // 遮罩层
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.5)')
            .onClick(() => {
              this.continueShopping()
            })

          // 弹窗内容
          Column() {
            Text('✓')
              .fontSize(48)
              .fontColor('#52c41a')
              .margin({ bottom: 16 })

            Text('加入购物车成功')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .margin({ bottom: 8 })

            Text('商品已成功添加到购物车')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ bottom: 24 })

            Row() {
              Button('继续购物')
                .height(44)
                .fontSize(16)
                .backgroundColor($r('app.color.background'))
                .fontColor($r('app.color.text_primary'))
                .layoutWeight(1)
                .margin({ right: 8 })
                .onClick(() => {
                  this.continueShopping()
                })

              Button('去购物车')
                .height(44)
                .fontSize(16)
                .backgroundColor($r('app.color.primary'))
                .fontColor(Color.White)
                .layoutWeight(1)
                .margin({ left: 8 })
                .onClick(() => {
                  this.goToCart()
                })
            }
            .width('100%')
          }
          .width(300)
          .backgroundColor($r('app.color.white'))
          .borderRadius(12)
          .padding(24)
          .position({ x: '50%', y: '50%' })
          .translate({ x: '-50%', y: '-50%' })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(9999)
      }

      // 商品已在购物车提示弹窗
      if (this.showAlreadyInCartDialog) {
        Column() {
          // 遮罩层
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.5)')
            .onClick(() => {
              this.closeAlreadyInCartDialog()
            })

          // 弹窗内容
          Column() {
            Text('🛒')
              .fontSize(48)
              .fontColor('#ff9500')
              .margin({ bottom: 16 })

            Text('商品已在购物车中')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .margin({ bottom: 8 })

            Text('该商品已经添加到购物车，可以前往购物车查看或调整数量')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ bottom: 24 })

            Row() {
              Button('继续购物')
                .height(44)
                .fontSize(16)
                .backgroundColor($r('app.color.background'))
                .fontColor($r('app.color.text_primary'))
                .layoutWeight(1)
                .margin({ right: 8 })
                .onClick(() => {
                  this.closeAlreadyInCartDialog()
                })

              Button('查看购物车')
                .height(44)
                .fontSize(16)
                .backgroundColor($r('app.color.primary'))
                .fontColor(Color.White)
                .layoutWeight(1)
                .margin({ left: 8 })
                .onClick(() => {
                  this.closeAlreadyInCartDialog()
                  this.goToCart()
                })
            }
            .width('100%')
          }
          .width(320)
          .backgroundColor($r('app.color.white'))
          .borderRadius(12)
          .padding(24)
          .position({ x: '50%', y: '50%' })
          .translate({ x: '-50%', y: '-50%' })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(9999)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}