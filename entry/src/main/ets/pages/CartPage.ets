import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
// ✅ 核心修正：引入正确的 Model 和 Service
import { CartService } from '../services/CartService'
import { CartItem } from '../model/DataModel'

// 颜色常量 (保留你的设计)
class ColorPalette {
  static primary: string = '#1A1A1A'
  static text_primary: string = '#2C3E50'
  static text_secondary: string = '#7F8C8D'
  static white: string = '#FFFFFF'
  static background: string = '#F5F7FA'
  static price: string = '#FF3B30'
}

@Entry
@Component
struct CartPage {
  @State cartItems: CartItem[] = []
  @State isLoading: boolean = true
  @State totalAmount: number = 0
  @State isAllSelected: boolean = false

  // ✅ 使用你上传文件中定义的 Service 实例
  private cartService: CartService = CartService.getInstance()

  async aboutToAppear() {
    this.isLoading = true
    try {
      // ✅ 核心修正：必须先异步初始化 Service，否则内存数组为空
      await this.cartService.init()
      await this.refreshData()
    } catch (e) {
      console.error('购物车初始化失败')
    } finally {
      this.isLoading = false
    }
  }

  onPageShow() {
    this.refreshData()
  }

  private async refreshData() {
    // ✅ 逻辑修正：强制 Service 从 RDB 数据库重新同步数据
    await this.cartService.refreshCart()

    // 获取 Service 同步后的数据
    this.cartItems = [...this.cartService.getCartItems()]
    this.totalAmount = this.cartService.getTotalAmount()

    // 更新全选状态
    const selectedItems = this.cartService.getSelectedItems()
    this.isAllSelected = this.cartItems.length > 0 && selectedItems.length === this.cartItems.length
  }

  build() {
    Column() {
      // 顶部导航 (保留原 UI)
      Row() {
        Button('←').fontSize(24).fontColor(ColorPalette.text_primary).backgroundColor(Color.Transparent)
          .onClick(() => router.back())
        Text('购物车').fontSize(20).fontWeight(FontWeight.Medium).layoutWeight(1).textAlign(TextAlign.Center)
        Blank().width(60)
      }.width('100%').height(56).padding({ left: 16, right: 16 }).backgroundColor(ColorPalette.white)

      if (this.isLoading) {
        LoadingProgress().width(40).height(40).margin({ top: 100 })
      } else if (this.cartItems.length === 0) {
        // 空状态 (保留原 UI)
        Column() {
          Text('🛒').fontSize(80).margin({ bottom: 20 })
          Text('购物车空空如也').fontSize(16).fontColor(ColorPalette.text_secondary)
          Button('去逛逛').margin({ top: 20 }).backgroundColor(ColorPalette.primary)
            .onClick(() => router.back())
        }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            ForEach(this.cartItems, (item: CartItem) => {
              Row() {
                // ✅ 补全：复选框逻辑
                Toggle({ type: ToggleType.Checkbox, isOn: item.selected })
                  .selectedColor(ColorPalette.primary)
                  .onChange(async () => {
                    await this.cartService.toggleSelected(item.id)
                    this.refreshData()
                  })

                Image(item.product.image).width(90).height(90).borderRadius(8).margin({ left: 12, right: 12 })

                Column() {
                  Text(item.product.name).fontSize(15).maxLines(2).fontColor(ColorPalette.text_primary)

                  // ✅ 修正：CartItem 没定义 spec，读取 product 里的属性
                  Text(`规格: ${item.product.spec || '标准版'}`).fontSize(12).fontColor(ColorPalette.text_secondary).margin({ top: 4 })

                  Row() {
                    Text(`¥${item.product.price}`).fontSize(18).fontWeight(FontWeight.Bold).fontColor(ColorPalette.price)
                    Blank()
                    // ✅ 修正：加减号颜色增强
                    Row() {
                      Button('-').width(28).height(24).backgroundColor('#F0F0F0').fontColor('#333')
                        .onClick(async () => {
                          if (item.quantity > 1) {
                            await this.cartService.updateQuantity(item.id, item.quantity - 1)
                            this.refreshData()
                          }
                        })
                      Text(`${item.quantity}`).width(30).textAlign(TextAlign.Center).fontSize(14)
                      Button('+').width(28).height(24).backgroundColor('#F0F0F0').fontColor('#333')
                        .onClick(async () => {
                          await this.cartService.updateQuantity(item.id, item.quantity + 1)
                          this.refreshData()
                        })
                    }
                  }.width('100%').margin({ top: 8 })
                }.layoutWeight(1).alignItems(HorizontalAlign.Start)
              }
              .padding(16).backgroundColor(ColorPalette.white).borderRadius(12).margin({ bottom: 12, left: 16, right: 16 })
            })
          }.padding({ top: 16, bottom: 100 })
        }.layoutWeight(1).backgroundColor(ColorPalette.background)

        // 底栏
        Row() {
          Toggle({ type: ToggleType.Checkbox, isOn: this.isAllSelected }).onChange(() => {
            this.cartService.toggleAllSelected(!this.isAllSelected) // ✅ 使用兼容方法
            this.refreshData()
          })
          Text('全选').fontSize(14).margin({ left: 8 })
          Blank()
          Text(`合计: ¥${this.totalAmount.toFixed(2)}`).fontSize(18).fontWeight(FontWeight.Bold).fontColor(ColorPalette.price)
          Button('结算').width(100).height(40).backgroundColor(ColorPalette.primary).margin({ left: 16 }).borderRadius(20)
            .onClick(() => { if(this.totalAmount > 0) router.pushUrl({ url: 'pages/OrderConfirmPage' }) })
        }.width('100%').padding(16).backgroundColor(ColorPalette.white).shadow({ radius: 8, color: '#10000000', offsetY: -4 })
      }
    }.width('100%').height('100%').backgroundColor(ColorPalette.background)
  }
}