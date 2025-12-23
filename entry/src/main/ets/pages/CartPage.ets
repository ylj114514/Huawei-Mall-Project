import router from '@ohos.router'
import { CartService } from '../services/CartService' // ✅ 换成 Service
import { CartItem } from '../model/DataModel' // ✅ 换成统一 Model
// import { ProductModel } from '../model/ProductModel'

// 颜色常量 (保留你的设计)
class ColorPalette {
  static primary: string = '#1A1A1A'
  static text_primary: string = '#2C3E50'
  static text_secondary: string = '#7F8C8D'
  static white: string = '#FFFFFF'
  static background: string = '#F5F7FA'
  static price: string = '#FF3B30'
  static error: string = '#E74C3C'
}

@Entry
@Component
struct CartPage {
  @State cartItems: CartItem[] = []
  @State isLoading: boolean = true
  @State totalAmount: number = 0

  // ✅ 获取 Service 实例
  private cartService: CartService = CartService.getInstance()

  // 页面显示时刷新，保证数据最新
  onPageShow() {
    this.refreshData()
  }

  // ✅ 核心修改：从 Service 拉取数据
  private async refreshData() {
    this.isLoading = true
    try {
      await this.cartService.refreshCart()
      this.cartItems = this.cartService.getCartItems()
      this.calculateTotal()
    } catch (error) {
      console.error('加载购物车失败:', error)
    } finally {
      this.isLoading = false
    }
  }

  private calculateTotal() {
    // 简单计算：选中商品的总价 (如果没有选中状态，就计算全部)
    // 你的 Service 里可能有 getSelectedItems，这里简单累加
    this.totalAmount = this.cartItems.reduce((sum, item) => {
      // 假设 item.selected 为 true 才算，或者全算
      return sum + (item.product.price * item.quantity)
    }, 0)
  }

  private async updateQuantity(item: CartItem, newQuantity: number) {
    if (newQuantity <= 0) return
    await this.cartService.updateQuantity(item.id, newQuantity)
    this.refreshData() // 刷新 UI
  }

  private async removeItem(item: CartItem) {
    await this.cartService.removeFromCart(item.id)
    this.refreshData()
  }

  build() {
    Column() {
      // 顶部导航栏 (保留)
      Row() {
        Button() {
          Text('←').fontSize(24).fontColor(ColorPalette.text_primary)
        }
        .width(60).height(48).backgroundColor(Color.Transparent)
        .onClick(() => router.back())

        Text('购物车')
          .fontSize(20).fontWeight(FontWeight.Medium).fontColor(ColorPalette.text_primary)
          .layoutWeight(1).textAlign(TextAlign.Center)

        Text('管理').fontSize(16).fontColor(ColorPalette.primary).width(60).textAlign(TextAlign.End)
          .visibility(this.cartItems.length > 0 ? Visibility.Visible : Visibility.Hidden)
      }
      .width('100%').padding({ left: 16, right: 16 }).height(56).backgroundColor(ColorPalette.white)

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40)
          Text('加载中...').fontSize(14).fontColor(ColorPalette.text_secondary).margin({ top: 16 })
        }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else if (this.cartItems.length === 0) {
        // 空状态 (保留)
        Column() {
          Text('🛒').fontSize(80).margin({ bottom: 24 })
          Text('购物车是空的').fontSize(18).fontWeight(FontWeight.Medium).fontColor(ColorPalette.text_secondary).margin({ bottom: 12 })
          Button('去购物').fontSize(16).fontColor(Color.White).backgroundColor(ColorPalette.primary)
            .padding({ left: 32, right: 32, top: 12, bottom: 12 }).borderRadius(24)
            .onClick(() => router.back())
        }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center).backgroundColor(ColorPalette.background)
      } else {
        // 列表 (保留样式)
        Scroll() {
          Column() {
            ForEach(this.cartItems, (item: CartItem) => {
              Row() {
                // 图片
                Image(item.product.image).width(100).height(100).borderRadius(8).objectFit(ImageFit.Contain)
                  .backgroundColor('#F8F9FA').margin({ right: 16 })

                // 信息
                Column() {
                  Text(item.product.name).fontSize(16).fontColor(ColorPalette.text_primary).maxLines(2).width('100%')
                  Text(`规格：${item.product.spec || '标准版'}`).fontSize(14).fontColor(ColorPalette.text_secondary).margin({ top: 4 })
                  Row() {
                    Text(`¥${item.product.price}`).fontSize(18).fontWeight(FontWeight.Bold).fontColor(ColorPalette.price)
                  }
                  .width('100%').margin({ top: 8 })
                }
                .layoutWeight(1).alignItems(HorizontalAlign.Start)

                // 操作
                Column() {
                  Row() {
                    Button('-').width(32).height(32).fontSize(16).backgroundColor('#F0F0F0')
                      .fontColor(item.quantity > 1 ? ColorPalette.text_primary : ColorPalette.text_secondary)
                      .enabled(item.quantity > 1)
                      .onClick(() => this.updateQuantity(item, item.quantity - 1))

                    Text(item.quantity.toString()).fontSize(16).fontColor(ColorPalette.text_primary).width(40).textAlign(TextAlign.Center)

                    Button('+').width(32).height(32).fontSize(16).backgroundColor('#F0F0F0').fontColor(ColorPalette.text_primary)
                      .onClick(() => this.updateQuantity(item, item.quantity + 1))
                  }
                  .margin({ bottom: 12 })

                  Button('删除').fontSize(12).fontColor(ColorPalette.error).backgroundColor(Color.Transparent)
                    .border({ width: 1, color: ColorPalette.error })
                    .onClick(() => this.removeItem(item))
                }
                .justifyContent(FlexAlign.SpaceBetween).height('100%')
              }
              .width('100%').padding(16).backgroundColor(ColorPalette.white).borderRadius(8)
              .margin({ left: 16, right: 16, bottom: 8 })
            })
          }
          .width('100%').padding({ top: 16, bottom: 120 })
        }
        .width('100%').layoutWeight(1).backgroundColor(ColorPalette.background)
      }

      // 底栏 (保留)
      if (this.cartItems.length > 0) {
        Row() {
          Column() {
            Row() {
              Text('合计：').fontSize(14).fontColor(ColorPalette.text_secondary)
              Text(`¥${this.totalAmount.toFixed(2)}`).fontSize(20).fontWeight(FontWeight.Bold).fontColor(ColorPalette.price)
            }
            Text(`共${this.cartItems.reduce((a,b)=>a+b.quantity,0)}件商品`).fontSize(12).fontColor(ColorPalette.text_secondary).margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.End)

          Button('结算').fontSize(16).fontColor(Color.White).backgroundColor(ColorPalette.primary)
            .width(100).height(44).borderRadius(22).margin({ left: 20 })
            .onClick(() => {
              // 结算逻辑
            })
        }
        .width('100%').padding({ left: 20, right: 20 }).height(80).backgroundColor(ColorPalette.white)
        .justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)
        .shadow({ radius: 4, color: 'rgba(0,0,0,0.1)', offsetX: 0, offsetY: -2 })
        .position({ x: 0, y: '100%' }).translate({ y: -80 })
      }
    }
    .width('100%').height('100%').backgroundColor(ColorPalette.background)
  }
}