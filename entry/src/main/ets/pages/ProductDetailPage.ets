import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { ProductModel, MockData } from '../model/ProductModel'
import { CartService } from '../services/CartService'
import { AuthService } from '../services/AuthService'
import { CommentSection } from '../components/CommentSection'

@Entry
@Component
struct ProductDetailPage {
  @State product: ProductModel | null = null
  @State quantity: number = 1
  @State isLoading: boolean = true
  @State showCartDialog: boolean = false
  private imageHeight: number = 375

  private cartService: CartService = CartService.getInstance()
  private authService: AuthService = AuthService.getInstance()

  aboutToAppear() {
    // 只有这里会被执行，确保它只执行数据加载，绝对不包含跳转逻辑
    this.loadProductData()
  }

  private loadProductData() {
    const params = router.getParams() as Record<string, Object>
    if (params) {
      if (params['product']) {
        this.product = params['product'] as ProductModel
      } else if (params['productId']) {
        const products = MockData.generateProducts()
        this.product = products.find(p => p.id === params['productId']) || null
      }
    }
    this.isLoading = false
    // 此处绝不添加 router 跳转
  }

  // ✅ 逻辑：数量加减（增强对比度，解决看不见的问题）
  private onQuantityChange(change: number) {
    if (!this.product) return
    const newQuantity = this.quantity + change
    if (newQuantity >= 1 && newQuantity <= (this.product.stock || 999)) {
      this.quantity = newQuantity
    } else if (newQuantity > (this.product.stock || 999)) {
      promptAction.showToast({ message: '超出库存范围' })
    }
  }

  // ✅ 逻辑：登录拦截
  private async checkAuthAndExecute(action: () => Promise<void>) {
    const account = this.authService.getCurrentAccount()
    if (account && account.trim() !== '') {
      action()
    } else {
      promptAction.showToast({ message: '请先登录后操作' })
      router.pushUrl({ url: 'pages/LoginPage' })
    }
  }

  // ✅ 修正后的加入购物车逻辑
  private async onAddToCart() {
    if (!this.product) return

    // 校验登录逻辑
    const account = this.authService.getCurrentAccount()
    if (!account) {
      promptAction.showToast({ message: '请先登录' })
      router.pushUrl({ url: 'pages/LoginPage' })
      return
    }

    // 1. 异步写入数据库
    const success = await this.cartService.addToCart(this.product, this.quantity)
    if (success) {
      // 2. 核心：写入后立即触发 Service 刷新内存，保证购物车页面能读到
      await this.cartService.refreshCart()
      promptAction.showToast({ message: '已成功加入购物车' })
    }
  }

  // ✅ 立即购买逻辑
  private async onBuyNow() {
    if (!this.product) return
    const success = await this.cartService.addToCart(this.product, this.quantity)
    if (success) {
      // 只有购买才会触发跳转
      router.pushUrl({ url: 'pages/CartPage' })
    }
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航 (原封不动)
        Row() {
          Button() { Row() { Text('←').fontSize(18).fontColor('#333'); Text('返回').fontSize(16).fontColor('#333').margin({ left: 4 }) } }
          .backgroundColor(Color.Transparent).onClick(() => router.back())
          Blank().layoutWeight(1)
          Text(this.product?.name || '商品详情').fontSize(18).fontWeight(FontWeight.Bold).maxLines(1).width('40%')
          Blank().layoutWeight(1)
          Button() { Row() { Text('🛒').fontSize(20); Text('购物车').fontSize(10).margin({ left: 4 }) } }
          .backgroundColor(Color.Transparent).onClick(() => router.pushUrl({ url: 'pages/CartPage' }))
        }
        .width('100%').height(56).padding({ left: 16, right: 16 }).backgroundColor(Color.White)

        Scroll() {
          Column() {
            if (this.product) {
              Image(this.product.image).width('100%').height(this.imageHeight).objectFit(ImageFit.Contain)
              Column() {
                Text(this.product.name).fontSize(18).fontWeight(FontWeight.Bold).width('100%').margin({ bottom: 12 })
                Row() {
                  Text(`¥${this.product.price}`).fontSize(24).fontWeight(FontWeight.Bold).fontColor('#ff4444')
                }.width('100%').margin({ bottom: 12 })

                Text('商品详情').fontSize(16).fontWeight(FontWeight.Bold).width('100%').margin({ top: 20, bottom: 12 })
                Text(this.product.detailDescription || '暂无详细描述').fontSize(14).lineHeight(24).width('100%')

                CommentSection({ productId: this.product.id })
              }.padding(16).backgroundColor(Color.White).borderRadius(12).margin(12)
            }
          }
        }.layoutWeight(1)
      }

      // 底部操作栏 (样式完全保留，颜色深度加强)
      if (this.product) {
        Row() {
          Column() {
            Text('购买数量').fontSize(10).fontColor('#999').margin({ bottom: 4 })
            Row() {
              // 减号：深灰色背景，黑色文字
              Button('-').width(32).height(28).fontSize(18).fontWeight(FontWeight.Bold)
                .backgroundColor('#E8E8E8').fontColor(this.quantity > 1 ? '#333' : '#AAA')
                .onClick(() => this.onQuantityChange(-1))

              Text(`${this.quantity}`).fontSize(14).width(40).textAlign(TextAlign.Center).fontColor('#333')

              // 加号：深色显示
              Button('+').width(32).height(28).fontSize(18).fontWeight(FontWeight.Bold)
                .backgroundColor('#E8E8E8').fontColor('#333')
                .onClick(() => this.onQuantityChange(1))
            }
          }.width(110)

          Blank().layoutWeight(1)

          Button('加入购物车').height(48).fontSize(14).backgroundColor('#ff9500').fontColor(Color.White).borderRadius(24).layoutWeight(1).margin({ right: 8 })
            .onClick(() => this.onAddToCart())

          Button('立即购买').height(48).fontSize(14).backgroundColor('#cf0a2c').fontColor(Color.White).borderRadius(24).layoutWeight(1)
            .onClick(() => this.onBuyNow())
        }
        .width('100%').padding(16).backgroundColor(Color.White).position({ x: 0, y: '100%' }).translate({ y: -64 })
      }
    }.width('100%').height('100%').backgroundColor('#f5f5f5')
  }
}