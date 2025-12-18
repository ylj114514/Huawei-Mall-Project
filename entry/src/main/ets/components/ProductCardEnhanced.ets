import { ProductModel } from '../model/ProductModel'

@Component
export struct ProductCardEnhanced {
  @Prop product: ProductModel
  @State isPressed: boolean = false
  @State showQuickView: boolean = false
  onProductClick: (product: ProductModel) => void = () => {}
  onQuickAddToCart?: (product: ProductModel) => void

  build() {
    Column() {
      // 商品图片容器
      Stack() {
        // 商品图片
        Image(this.product.image)
          .width('100%')
          .height(200)
          .borderRadius({ topLeft: 16, topRight: 16 })
          .objectFit(ImageFit.Cover)
          .backgroundColor($r('app.color.background_gray'))
          .alt('商品图片')
          .transition({ type: TransitionType.All })

        // 渐变遮罩
        Column() {
          Blank()
          Column() {
            Blank()
            Row() {
              Blank()
              // 快速查看按钮
              if (this.showQuickView) {
                Button() {
                  Row() {
                    Text('👁')
                      .fontSize(16)
                      .fontColor(Color.White)
                    Text('快速查看')
                      .fontSize(11)
                      .fontColor(Color.White)
                      .margin({ left: 4 })
                  }
                }
                .height(32)
                .backgroundColor('rgba(0,0,0,0.5)')
                .borderRadius(16)
                .padding({ left: 12, right: 12 })
                .margin({ right: 8, bottom: 8 })
                .onClick(() => {
                  this.onProductClick(this.product)
                })
                .visibility(this.showQuickView ? Visibility.Visible : Visibility.Hidden)
                .opacity(this.showQuickView ? 1 : 0)
                .transition({ type: TransitionType.All })
              }
            }
            .width('100%')
          }
          .width('100%')
          .height(80)
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [
              ['rgba(0,0,0,0)', 0.0],
              ['rgba(0,0,0,0.3)', 1.0]
            ]
          })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })

        // 折扣标签
        if (this.product.originalPrice > this.product.price) {
          Column() {
            Text('限时优惠')
              .fontSize(10)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
            Text(`${Math.floor(((this.product.originalPrice - this.product.price) / this.product.originalPrice) * 100)}% OFF`)
              .fontSize(12)
              .fontColor(Color.White)
              .fontWeight(FontWeight.Bold)
          }
          .backgroundColor($r('app.color.error'))
          .borderRadius(8)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .position({ x: 8, y: 8 })
          .shadow({
            radius: 4,
            color: $r('app.color.shadow_medium'),
            offsetX: 0,
            offsetY: 2
          })
        }

        // 评分标签
        if (this.product.rating && this.product.rating >= 4.5) {
          Row() {
            Text('⭐')
              .fontSize(10)
              .fontColor(Color.White)
            Text(this.product.rating.toFixed(1))
              .fontSize(10)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)
          }
          .backgroundColor($r('app.color.secondary'))
          .borderRadius(12)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .position({ x: 8, y: this.product.originalPrice > this.product.price ? 60 : 8 })
        }
      }
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          this.showQuickView = true
        } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
          this.showQuickView = false
        }
      })

      // 商品信息
      Column() {
        // 商品名称
        Text(this.product.name)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ bottom: 8 })
          .lineHeight(21)

        // 商品标签
        if (this.product.tags && this.product.tags.length > 0) {
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(this.product.tags.slice(0, 2), (tag: string, index: number) => {
              Text(tag)
                .fontSize(10)
                .fontColor($r('app.color.primary'))
                .backgroundColor($r('app.color.primary_light'))
                .borderRadius(10)
                .padding({ left: 8, right: 8, top: 3, bottom: 3 })
                .margin({ right: 6, bottom: 4 })
            })
          }
          .width('100%')
          .margin({ bottom: 8 })
        }

        // 价格区域
        Row() {
          Column() {
            Row() {
              Text('¥')
                .fontSize(12)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.price'))
                .margin({ top: 3 })
              Text(`${this.product.price}`)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.price'))
            }

            // 原价
            if (this.product.originalPrice > this.product.price) {
              Text(`¥${this.product.originalPrice}`)
                .fontSize(12)
                .fontColor($r('app.color.text_tertiary'))
                .decoration({ type: TextDecorationType.LineThrough })
                .margin({ top: 2 })
            }
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          // 快速加购按钮
          if (this.onQuickAddToCart) {
            Button() {
              Text('+')
                .fontSize(18)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
            }
            .width(36)
            .height(36)
            .backgroundColor($r('app.color.primary'))
            .borderRadius(18)
            .shadow({
              radius: 4,
              color: $r('app.color.shadow_light'),
              offsetX: 0,
              offsetY: 2
            })
            .onClick(() => {
              if (this.onQuickAddToCart) {
                this.onQuickAddToCart(this.product)
              }
            })
          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)

        // 销量信息
        Row() {
          Text(`已售${Math.floor(this.product.reviewCount * 10)}+`)
            .fontSize(11)
            .fontColor($r('app.color.text_tertiary'))

          if (this.product.stock <= 10) {
            Text(`仅剩${this.product.stock}件`)
              .fontSize(11)
              .fontColor($r('app.color.error'))
              .margin({ left: 12 })
          }
        }
        .width('100%')
        .margin({ top: 6 })
      }
      .width('100%')
      .padding(16)
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height(340)
    .backgroundColor($r('app.color.white'))
    .borderRadius(16)
    .shadow({
      radius: this.isPressed ? 4 : 8,
      color: this.isPressed ? $r('app.color.shadow_light') : $r('app.color.shadow_medium'),
      offsetX: 0,
      offsetY: this.isPressed ? 1 : 3
    })
    .scale({ x: this.isPressed ? 0.98 : 1, y: this.isPressed ? 0.98 : 1 })
    .transition({ type: TransitionType.All })
    .onClick(() => {
      this.onProductClick(this.product)
    })
    .onTouch((event) => {
      if (event.type === TouchType.Down) {
        this.isPressed = true
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPressed = false
      }
    })
  }
}