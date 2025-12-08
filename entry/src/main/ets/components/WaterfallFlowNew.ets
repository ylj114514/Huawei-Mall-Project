import { ProductModel } from '../model/ProductModel'

@Component
export struct WaterfallFlowNew {
  @Prop products: ProductModel[]
  @State leftColumnProducts: ProductModel[] = []
  @State rightColumnProducts: ProductModel[] = []
  @State leftColumnHeight: number = 0
  @State rightColumnHeight: number = 0

  aboutToAppear() {
    this.distributeProducts()
  }

  private calculateProductHeight(product: ProductModel): number {
    // 基础高度：图片+信息+按钮
    let height = 200

    // 根据图片数量调整（减少增加的高度）
    if (product.images && product.images.length > 0) {
      height += Math.min(product.images.length * 30, 60) // 最多增加60px
    }

    // 根据标题长度调整（优化计算）
    if (product.name && product.name.length > 15) {
      height += Math.floor((product.name.length - 15) / 8) * 12 // 每8个字符增加12px
    }

    // 根据描述长度调整
    if (product.description && product.description.length > 30) {
      height += Math.floor((product.description.length - 30) / 15) * 8 // 每15个字符增加8px
    }

    // 添加小幅随机变化（减少变化范围）
    height += Math.floor(Math.random() * 40) // 减少到40px变化

    return Math.max(height, 180) // 最小高度减少到180px
  }

  private distributeProducts() {
    this.leftColumnProducts = []
    this.rightColumnProducts = []
    this.leftColumnHeight = 0
    this.rightColumnHeight = 0

    this.products.forEach(product => {
      const productHeight = this.calculateProductHeight(product)

      if (this.leftColumnHeight <= this.rightColumnHeight) {
        this.leftColumnProducts.push(product)
        this.leftColumnHeight += productHeight
      } else {
        this.rightColumnProducts.push(product)
        this.rightColumnHeight += productHeight
      }
    })
  }

  private addToCart(product: ProductModel) {
    // 这里添加购物车逻辑
    console.log('加入购物车:', product.name)
  }

  build() {
    Scroll() {
      Row() {
        // 左列
        Column() {
          ForEach(this.leftColumnProducts, (product: ProductModel) => {
            WaterfallProductCard({
              product: product,
              onAddToCart: this.addToCart.bind(this)
            })
          }, (product: ProductModel) => product.id)
        }
        .width('49%')
        .margin({ right: '1%' })

        // 右列
        Column() {
          ForEach(this.rightColumnProducts, (product: ProductModel) => {
            WaterfallProductCard({
              product: product,
              onAddToCart: this.addToCart.bind(this)
            })
          }, (product: ProductModel) => product.id)
        }
        .width('49%')
        .margin({ left: '1%' })
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
    .edgeEffect(EdgeEffect.Spring)
  }
}

@Component
struct WaterfallProductCard {
  @Prop product: ProductModel
  onAddToCart: (product: ProductModel) => void = () => {}

  build() {
    Column() {
      // 商品图片
      Image(this.product.image)
        .width('100%')
        .height(this.calculateImageHeight())
        .borderRadius({ topLeft: 8, topRight: 8 })
        .objectFit(ImageFit.Cover)
        .backgroundColor($r('app.color.background'))
        .margin({ bottom: 8 })

      // 商品信息
      Column() {
        Text(this.product.name)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ bottom: 3 })

        Text(this.product.description || '商品描述')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ bottom: 6 })

        Row() {
          Text(`¥${this.product.price}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.price'))

          if (this.product.originalPrice > this.product.price) {
            Text(`¥${this.product.originalPrice}`)
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .decoration({ type: TextDecorationType.LineThrough })
              .margin({ left: 8 })
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
        .margin({ top: 3 })
      }
      .width('100%')
      .padding(10)
      .layoutWeight(1)

      // 操作按钮
      Button('加入购物车')
        .width('100%')
        .height(28)
        .fontSize(12)
        .backgroundColor($r('app.color.primary'))
        .fontColor(Color.White)
        .borderRadius(14)
        .onClick(() => {
          this.onAddToCart(this.product)
        })
        .margin({ top: 6 })
    }
    .width('100%')
    .backgroundColor($r('app.color.white'))
    .borderRadius(8)
    .shadow({
      radius: 3,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 1
    })
    .margin({ bottom: 12 })
  }

  private calculateImageHeight(): number {
    // 优化图片高度生成，减少过大的差异
    const baseHeight = 140
    const variation = Math.floor(Math.random() * 60) // 减少变化范围
    return baseHeight + variation
  }
}