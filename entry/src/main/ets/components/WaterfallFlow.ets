import { ProductModel } from '../model/ProductModel'

@Component
export struct WaterfallFlow {
  @Prop products: ProductModel[]
  @State columns: number = 2
  @State itemWidth: number = 0
  @State itemHeights: number[] = []
  @State items: { product: ProductModel; height: number }[] = []

  aboutToAppear() {
    this.calculateLayout()
  }

  private calculateHeight(product: ProductModel): number {
    // 基础高度
    let height = 300

    // 根据图片数量调整高度
    if (product.images && product.images.length > 0) {
      height += product.images.length * 80
    }

    // 根据标题长度调整
    if (product.name && product.name.length > 10) {
      height += Math.floor(product.name.length / 15) * 20
    }

    // 随机变化模拟不同高度
    height += Math.floor(Math.random() * 100)

    return height
  }

  private calculateLayout() {
    if (this.products.length === 0) return

    // 计算每个产品的显示高度
    this.items = this.products.map(product => ({
      product: product,
      height: this.calculateHeight(product)
    }))

    // 模拟瀑布流排列算法
    const columnHeights: number[] = [0, 0]
    const arrangedItems: { product: ProductModel; height: number; column: number; top: number }[] = []

    for (const item of this.items) {
      // 找到最短的列
      let minColumn = 0
      let minHeight = columnHeights[0]

      for (let i = 1; i < this.columns; i++) {
        if (columnHeights[i] < minHeight) {
          minColumn = i
          minHeight = columnHeights[i]
        }
      }

      // 放置到最短的列
      arrangedItems.push({
        product: item.product,
        height: item.height,
        column: minColumn,
        top: columnHeights[minColumn]
      })

      columnHeights[minColumn] += item.height + 12 // 12px为间距
    }

    this.items = arrangedItems
  }

  build() {
    Column() {
      ForEach(this.items, (item: { product: ProductModel; height: number; column: number; top: number }, index: number) => {
        Column() {
          WaterfallItem({ product: item.product, height: item.height })
        }
        .width('48%')
        .margin({
          left: item.column === 0 ? '2%' : '1%',
          right: item.column === 0 ? '1%' : '2%',
          top: index === 0 || item.top === 0 ? 0 : 0,
          bottom: 12
        })
        .backgroundColor($r('app.color.white'))
        .borderRadius(8)
        .shadow({
          radius: 4,
          color: '#1A000000',
          offsetX: 0,
          offsetY: 2
        })
      }, (item) => item.product.id)
    }
    .width('100%')
    .padding(16)
  }
}

@Component
struct WaterfallItem {
  @Prop product: ProductModel
  @Prop height: number

  build() {
    Column() {
      // 商品图片
      Image(this.product.image)
        .width('100%')
        .height(this.product.height || 200)
        .borderRadius({ topLeft: 8, topRight: 8 })
        .objectFit(ImageFit.Cover)
        .backgroundColor($r('app.color.background'))

      // 商品信息
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

      // 操作按钮
      Row() {
        Button('加入购物车')
          .height(32)
          .fontSize(12)
          .backgroundColor($r('app.color.primary'))
          .fontColor(Color.White)
          .borderRadius(16)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            // 这里添加购物车逻辑
            console.log('加入购物车:', this.product.name)
          })
      }
      .width('100%')
      .padding({ left: 12, right: 12, bottom: 12 })
      .justifyContent(FlexAlign.End)
    }
  }
}