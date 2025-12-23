import { ProductModel } from '../model/ProductModel'

// 定义带高度属性的包装对象接口
interface WaterfallItemData {
  product: ProductModel;
  cardHeight: number; // 对应修改变量名
}

@Component
export struct WaterfallFlow {
  @Prop products: ProductModel[]
  @State leftItems: WaterfallItemData[] = []
  @State rightItems: WaterfallItemData[] = []

  aboutToAppear() {
    this.calculateLayout()
  }

  onPageShow() {
    this.calculateLayout()
  }

  private calculateHeight(product: ProductModel): number {
    let h = 300
    if (product.images && product.images.length > 0) {
      h += product.images.length * 80
    }
    if (product.name && product.name.length > 10) {
      h += Math.floor(product.name.length / 15) * 20
    }
    h += Math.floor(Math.random() * 100)
    return h
  }

  private calculateLayout() {
    if (!this.products || this.products.length === 0) return

    const tempLeft: WaterfallItemData[] = []
    const tempRight: WaterfallItemData[] = []
    let leftHeight = 0
    let rightHeight = 0

    for (const product of this.products) {
      const itemHeight = this.calculateHeight(product)

      if (leftHeight <= rightHeight) {
        tempLeft.push({ product: product, cardHeight: itemHeight })
        leftHeight += itemHeight + 12
      } else {
        tempRight.push({ product: product, cardHeight: itemHeight })
        rightHeight += itemHeight + 12
      }
    }

    this.leftItems = tempLeft
    this.rightItems = tempRight
  }

  build() {
    Row({ space: 10 }) {
      // 左侧列
      Column() {
        ForEach(this.leftItems, (item: WaterfallItemData) => {
          Column() {
            // 这里传参改为 tileHeight
            WaterfallItem({ product: item.product, tileHeight: item.cardHeight })
          }
          .width('100%')
          .margin({ bottom: 12 })
          .backgroundColor($r('app.color.white'))
          .borderRadius(8)
          .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
        }, (item: WaterfallItemData) => item.product.id)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)

      // 右侧列
      Column() {
        ForEach(this.rightItems, (item: WaterfallItemData) => {
          Column() {
            // 这里传参改为 tileHeight
            WaterfallItem({ product: item.product, tileHeight: item.cardHeight })
          }
          .width('100%')
          .margin({ bottom: 12 })
          .backgroundColor($r('app.color.white'))
          .borderRadius(8)
          .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
        }, (item: WaterfallItemData) => item.product.id)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .padding(16)
    .alignItems(VerticalAlign.Top)
  }
}

@Component
struct WaterfallItem {
  @Prop product: ProductModel
  // 核心修改：重命名变量，解决 "Property 'height' ... is not assignable" 报错
  @Prop tileHeight: number

  build() {
    Column() {
      Image(this.product.image)
        .width('100%')
        // 核心修改：删除 this.product.height，因为它在 Model 中不存在
        .height(200)
        .borderRadius({ topLeft: 8, topRight: 8 })
        .objectFit(ImageFit.Cover)
        .backgroundColor($r('app.color.background'))

      Column() {
        Text(this.product.name)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ top: 8, bottom: 4 })

        Text(this.product.description || '')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ bottom: 8 })

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
        .alignItems(VerticalAlign.Bottom)
      }
      .width('100%')
      .padding(12)
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Button('加入购物车')
          .height(32)
          .fontSize(12)
          .backgroundColor($r('app.color.primary'))
          .fontColor(Color.White)
          .borderRadius(16)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            console.log('加入购物车:', this.product.name)
          })
      }
      .width('100%')
      .padding({ left: 12, right: 12, bottom: 12 })
      .justifyContent(FlexAlign.End)
    }
    // 使用传入的高度，或者让内容自适应。如果需要强制高度，这里使用 .height(this.tileHeight)
  }
}