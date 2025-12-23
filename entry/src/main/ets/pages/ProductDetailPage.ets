import router from '@ohos.router'
import { ProductModel, MockData } from '../model/ProductModel'
import { CartService } from '../services/CartService'
// import { CommentSectionNew } from '../components/CommentSectionNew' // 如果你删了这个文件，请注释掉，或换成 CommentSection
import { CommentSection } from '../components/CommentSection'

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
  @State imageHeight: number = 375

  // ✅ 获取单例
  private cartService: CartService = CartService.getInstance()

  aboutToAppear() {
    this.loadProductData()
  }

  private loadProductData() {
    // 支持两种传参方式：直接传对象 或 传ID
    const params = router.getParams() as Record<string, Object>
    if (params) {
      if (params['product']) {
        this.product = params['product'] as ProductModel
      } else if (params['productId']) {
        // 如果只传了 ID，这里可以去 MockData 找 (或者去 DB 找，这里为了简单先去 MockData)
        const products = MockData.generateProducts()
        this.product = products.find(p => p.id === params['productId']) || null
      }
    }
    this.isLoading = false
  }

  private onImageChange(index: number) {
    this.currentImageIndex = index
  }

  private onQuantityChange(change: number) {
    if (!this.product) return
    const newQuantity = this.quantity + change
    if (newQuantity >= 1 && newQuantity <= (this.product.stock || 999)) {
      this.quantity = newQuantity
    }
  }

  // ✅ 核心修改：调用 CartService 写库
  private async onAddToCart() {
    if (!this.product) return

    // 调用 CartService
    // 注意：CartService.addToCart 是异步的
    const success = await this.cartService.addToCart(this.product, this.quantity)

    if (success) {
      this.showCartSuccessDialog()
    } else {
      // 这里的 false 可能是因为没登录，也可能是其他原因
      // 简单起见，我们认为它是 "已存在" 或者是 "没登录"
      // 如果你的 CartService 对于已存在是 update 数量并返回 true，那这里 false 就是没登录
      // 如果 CartService 没登录会抛异常，那这里要 catch

      // 假设 CartService 返回 false 代表失败
      // 你可以加个判断是否登录
      console.error('添加失败，可能未登录')
    }
  }

  private showCartSuccessDialog(): void {
    this.showCartDialog = true
  }

  private goToCart(): void {
    this.showCartDialog = false
    router.pushUrl({ url: 'pages/CartPage' }) // ✅ 修正跳转路径
  }

  private continueShopping(): void {
    this.showCartDialog = false
  }

  private closeAlreadyInCartDialog(): void {
    this.showAlreadyInCartDialog = false
  }

  private onBuyNow() {
    if (!this.product) return
    // 先加购物车，再跳
    this.onAddToCart().then(() => {
      this.goToCart()
    })
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航栏
        Row() {
          Button() {
            Row() {
              Text('←').fontSize(18).fontColor('#333')
              Text('返回').fontSize(16).fontColor('#333').margin({ left: 4 })
            }
          }
          .backgroundColor(Color.Transparent)
          .onClick(() => router.back())

          Blank().layoutWeight(1)
          Text(this.product?.name || '商品详情')
            .fontSize(18).fontWeight(FontWeight.Bold).fontColor('#333')
            .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis }).width('40%')
          Blank().layoutWeight(1)

          Button() {
            Row() {
              Text('🛒').fontSize(20)
              Text('购物车').fontSize(10).margin({ left: 4 })
            }
          }
          .fontSize(12).fontColor('#333').backgroundColor(Color.Transparent)
          .onClick(() => this.goToCart())
        }
        .width('100%').height(56).padding({ left: 16, right: 16 })
        .backgroundColor(Color.White)
        .shadow({ radius: 2, color: '#1A000000', offsetX: 0, offsetY: 1 })
        .justifyContent(FlexAlign.SpaceBetween)

        // 主内容
        Scroll() {
          Column() {
            // 轮播图
            if (this.product && this.product.images && this.product.images.length > 0) {
              Swiper() {
                ForEach(this.product.images, (image: Resource) => {
                  Image(image)
                    .width('100%').height(this.imageHeight).objectFit(ImageFit.Contain).backgroundColor('#f5f5f5')
                })
              }
              .width('100%').height(this.imageHeight).loop(true).indicator(true)
              .onChange((index) => this.onImageChange(index))
            } else if (this.product) {
              Image(this.product.image).width('100%').height(this.imageHeight).objectFit(ImageFit.Contain)
            }

            // 信息区
            Column() {
              Text(this.product?.name || '').fontSize(18).fontWeight(FontWeight.Bold).width('100%').margin({ bottom: 12 })

              Row() {
                Text(`¥${this.product?.price || 0}`).fontSize(24).fontWeight(FontWeight.Bold).fontColor('#ff4444')
                if (this.product?.originalPrice && this.product.originalPrice > this.product.price) {
                  Text(`¥${this.product.originalPrice}`).fontSize(14).fontColor('#999')
                    .decoration({ type: TextDecorationType.LineThrough }).margin({ left: 12, top: 4 })
                }
              }
              .width('100%').alignItems(VerticalAlign.Bottom).margin({ bottom: 12 })

              // 标签
              if (this.product?.tags) {
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.product.tags, (tag: string) => {
                    Text(tag).fontSize(12).fontColor('#007aff').backgroundColor('#f0f8ff')
                      .padding({ left: 12, right: 12, top: 6, bottom: 6 }).borderRadius(16).margin({ right: 8, bottom: 8 })
                  })
                }
              }

              // 详情
              Text('商品详情').fontSize(16).fontWeight(FontWeight.Bold).width('100%').margin({ top: 20, bottom: 12 })
              Text(this.product?.detailDescription || '暂无详细描述').fontSize(14).lineHeight(24).width('100%')

              // 评价区占位 (如果 CommentSection 可用请恢复)
              // CommentSection({ productId: this.product?.id || '' })

              Column().height(100) // 底部垫高
            }
            .padding(16).backgroundColor(Color.White).borderRadius(12).margin(12)
          }
        }
        .layoutWeight(1).backgroundColor('#f5f5f5')
      }

      // 底部操作栏
      if (this.product) {
        Row() {
          Column() {
            Text('数量').fontSize(12).fontColor('#999').margin({ bottom: 4 })
            Row() {
              Button('-').width(32).height(28).fontSize(14).backgroundColor('#f5f5f5')
                .fontColor(this.quantity > 1 ? '#333' : '#ccc').enabled(this.quantity > 1)
                .onClick(() => this.onQuantityChange(-1))
              Text(`${this.quantity}`).fontSize(14).width(40).textAlign(TextAlign.Center)
              Button('+').width(32).height(28).fontSize(14).backgroundColor('#f5f5f5')
                .onClick(() => this.onQuantityChange(1))
            }
          }.width(80)

          Blank().layoutWeight(1)
          Button('加入购物车').height(48).fontSize(14).backgroundColor('#ff9500').fontColor(Color.White)
            .borderRadius(24).layoutWeight(1).margin({ right: 8 }).onClick(() => this.onAddToCart())
          Button('立即购买').height(48).fontSize(14).backgroundColor('#cf0a2c').fontColor(Color.White)
            .borderRadius(24).layoutWeight(1).onClick(() => this.onBuyNow())
        }
        .width('100%').padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor(Color.White).position({ x: 0, y: '100%' }).translate({ x: 0, y: -64 })
      }

      // 弹窗逻辑 (保留你原本的)
      if (this.showCartDialog) {
        Column() {
          Column().width('100%').height('100%').backgroundColor('rgba(0,0,0,0.5)').onClick(() => this.continueShopping())
          Column() {
            Text('✓').fontSize(48).fontColor('#52c41a').margin({ bottom: 16 })
            Text('加入成功').fontSize(18).fontWeight(FontWeight.Bold).margin({ bottom: 24 })
            Row() {
              Button('继续购物').layoutWeight(1).margin({ right: 8 }).backgroundColor('#f5f5f5').fontColor('#333').onClick(() => this.continueShopping())
              Button('去购物车').layoutWeight(1).margin({ left: 8 }).backgroundColor('#007aff').onClick(() => this.goToCart())
            }
            .width('100%')
          }
          .width(300).backgroundColor(Color.White).borderRadius(12).padding(24)
          .position({ x: '50%', y: '50%' }).translate({ x: '-50%', y: '-50%' })
        }
        .zIndex(9999)
      }
    }
    .width('100%').height('100%').backgroundColor('#f5f5f5')
  }
}