import router from '@ohos.router'
import { CartItem } from '../model/DataModel'
import { CartService } from '../services/CartService'

@Entry
@Component
struct CartPage {
  @State cartItems: CartItem[] = []
  @State allSelected: boolean = false
  @State totalAmount: number = 0
  @State selectedCount: number = 0
  @State isLoading: boolean = true
  @State editingMode: boolean = false
  @State refreshing: boolean = false
  private cartService: CartService = CartService.getInstance()

  aboutToAppear() {
    this.loadCartData()
  }

  loadCartData() {
    try {
      this.isLoading = true
      this.cartItems = this.cartService.getCartItems()
      this.updateSummary()
      this.isLoading = false
    } catch (error) {
      console.error('加载购物车数据失败:', error)
      this.isLoading = false
    }
  }

  private updateSummary() {
    this.allSelected = this.cartItems.length > 0 && this.cartItems.every(item => item.selected)
    this.selectedCount = this.cartService.getSelectedCount()
    this.totalAmount = this.cartService.getSelectedTotal()
  }

  // 切换商品选中状态
  toggleItemSelection(item: CartItem) {
    this.cartService.toggleSelected(item.id)
    this.cartItems = this.cartService.getCartItems()
    this.updateSummary()
  }

  // 全选/全不选
  toggleAllSelection() {
    this.cartService.toggleAllSelected(!this.allSelected)
    this.cartItems = this.cartService.getCartItems()
    this.updateSummary()
  }

  // 更新商品数量
  async updateItemQuantity(item: CartItem, quantity: number) {
    try {
      const success = await this.cartService.updateQuantity(item.id, quantity)
      if (success) {
        this.cartItems = this.cartService.getCartItems()
        this.updateSummary()
      } else {
        // 显示错误提示
        console.error('更新数量失败，可能库存不足')
      }
    } catch (error) {
      console.error('更新数量失败:', error)
    }
  }

  // 删除商品
  removeItem(item: CartItem) {
    // 这里可以添加确认对话框
    this.cartService.removeFromCart(item.id)
    this.cartItems = this.cartService.getCartItems()
    this.updateSummary()
  }

  // 批量删除选中商品
  removeSelectedItems() {
    // 这里可以添加确认对话框
    for (const item of this.cartItems) {
      if (item.selected) {
        this.cartService.removeFromCart(item.id)
      }
    }
    this.cartItems = this.cartService.getCartItems()
    this.updateSummary()
  }

  // 清空购物车
  clearCart() {
    this.cartService.clearCart()
    this.cartItems = []
    this.updateSummary()
  }

  // 结算
  checkout() {
    if (!this.cartService.hasSelectedItems()) {
      console.error('请选择要结算的商品')
      return
    }

    try {
      // 这里可以跳转到结算页面
      console.log('结算商品数量:', this.selectedCount)
      console.log('结算总金额:', this.totalAmount)

      // 清空选中的商品
      this.cartService.clearSelected()
      this.cartItems = this.cartService.getCartItems()
      this.updateSummary()

      console.log('结算成功')
    } catch (error) {
      console.error('结算失败:', error)
    }
  }

  // 刷新购物车
  refresh() {
    this.refreshing = true
    this.cartItems = this.cartService.getCartItems()
    this.updateSummary()
    setTimeout(() => {
      this.refreshing = false
    }, 1000)
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

        Text('购物车')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        if (this.cartItems.length > 0) {
          Button('编辑')
            .height(40)
            .backgroundColor(Color.Transparent)
            .fontColor($r('app.color.primary'))
            .onClick(() => {
              this.editingMode = !this.editingMode
            })
        } else {
          Blank().width(40)
        }
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
          Text('加载购物车中...')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.cartItems.length === 0) {
        // 空购物车状态
        Column() {
          Text('🛒')
            .fontSize(80)
            .margin({ bottom: 24 })
          Text('购物车是空的')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_secondary'))
            .margin({ bottom: 12 })
          Text('快去挑选心仪的商品吧')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ bottom: 32 })

          Button('去购物')
            .height(44)
            .padding({ left: 32, right: 32 })
            .backgroundColor($r('app.color.primary'))
            .onClick(() => {
              router.replaceUrl({ url: 'pages/Index' })
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        // 购物车商品列表
        List() {
          ForEach(this.cartItems, (item: CartItem) => {
            ListItem() {
              Row() {
                // 选择框
                Button() {
                  Circle({ width: 20, height: 20 })
                    .fill(item.selected ? $r('app.color.primary') : Color.Transparent)
                    .stroke(item.selected ? Color.Transparent : $r('app.color.text_secondary'))
                    .strokeWidth(2)
                    .margin({ right: 12 })
                }
                .backgroundColor(Color.Transparent)
                .onClick(() => this.toggleItemSelection(item))

                // 商品图片
                Image(item.product.image)
                  .width(80)
                  .height(80)
                  .borderRadius(8)
                  .objectFit(ImageFit.Cover)
                  .backgroundColor($r('app.color.background'))
                  .margin({ right: 12 })

                // 商品信息
                Column() {
                  Text(item.product.name)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.text_primary'))
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%')

                  Text(item.product.spec)
                    .fontSize(12)
                    .fontColor($r('app.color.text_secondary'))
                    .margin({ top: 4 })

                  Row() {
                    Text(`¥${item.product.price}`)
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor($r('app.color.price'))

                    if (item.product.originalPrice > item.product.price) {
                      Text(`¥${item.product.originalPrice}`)
                        .fontSize(12)
                        .fontColor($r('app.color.text_secondary'))
                        .decoration({ type: TextDecorationType.LineThrough })
                        .margin({ left: 8 })
                    }
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.Start)
                  .alignItems(VerticalAlign.Bottom)
                  .margin({ top: 8 })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                // 数量选择器
                if (!this.editingMode) {
                  Column() {
                    Row() {
                      Button('-')
                        .width(28)
                        .height(28)
                        .fontSize(14)
                        .backgroundColor($r('app.color.background'))
                        .fontColor(item.quantity > 1 ? $r('app.color.text_primary') : $r('app.color.text_secondary'))
                        .enabled(item.quantity > 1)
                        .onClick(() => this.updateItemQuantity(item, item.quantity - 1))

                      Text(item.quantity.toString())
                        .fontSize(14)
                        .fontColor($r('app.color.text_primary'))
                        .width(32)
                        .textAlign(TextAlign.Center)

                      Button('+')
                        .width(28)
                        .height(28)
                        .fontSize(14)
                        .backgroundColor($r('app.color.background'))
                        .fontColor(item.quantity < item.product.stock ? $r('app.color.text_primary') : $r('app.color.text_secondary'))
                        .enabled(item.quantity < item.product.stock)
                        .onClick(() => this.updateItemQuantity(item, item.quantity + 1))
                    }
                    .margin({ top: 8 })
                  }

                  // 删除按钮
                  if (this.editingMode) {
                    Button('删除')
                      .height(32)
                      .fontSize(12)
                      .backgroundColor($r('app.color.error'))
                      .fontColor(Color.White)
                      .margin({ top: 8 })
                      .onClick(() => this.removeItem(item))
                  }
                }
              }
              .width('100%')
              .padding(16)
              .backgroundColor($r('app.color.white'))
              .borderRadius(8)
              .margin({ left: 16, right: 16, bottom: 8 })
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor($r('app.color.background'))

        // 底部操作栏
        Column() {
          // 全选和删除
          Row() {
            Button() {
              Row() {
                Circle({ width: 20, height: 20 })
                  .fill(this.allSelected ? $r('app.color.primary') : Color.Transparent)
                  .stroke(this.allSelected ? Color.Transparent : $r('app.color.text_secondary'))
                  .strokeWidth(2)
                  .margin({ right: 8 })
                Text('全选')
                  .fontSize(14)
                  .fontColor($r('app.color.text_primary'))
              }
            }
            .backgroundColor(Color.Transparent)
            .onClick(() => this.toggleAllSelection())

            Blank()

            if (this.editingMode) {
              Button('删除选中')
                .height(36)
                .fontSize(14)
                .backgroundColor($r('app.color.error'))
                .enabled(this.selectedCount > 0)
                .onClick(() => this.removeSelectedItems())
            } else {
              Column() {
                Row() {
                  Text(`合计: `)
                    .fontSize(14)
                    .fontColor($r('app.color.text_secondary'))
                  Text(`¥${this.totalAmount.toFixed(2)}`)
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor($r('app.color.price'))
                }
                Text(`已选${this.selectedCount}件商品`)
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
              }
              .alignItems(HorizontalAlign.End)

              Button('结算')
                .height(44)
                .fontSize(16)
                .backgroundColor($r('app.color.primary'))
                .padding({ left: 24, right: 24 })
                .margin({ left: 16 })
                .enabled(this.selectedCount > 0)
                .onClick(() => this.checkout())
            }
          }
          .width('100%')
          .height(60)
          .padding({ left: 16, right: 16 })
          .backgroundColor($r('app.color.white'))
          .shadow({
            radius: 4,
            color: '#1A000000',
            offsetX: 0,
            offsetY: -2
          })
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}