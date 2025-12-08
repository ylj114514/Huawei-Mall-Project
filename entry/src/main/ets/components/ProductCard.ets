import router from '@ohos.router'
import { ProductModel } from '../model/ProductModel'

@Component
export struct ProductCard {
  @Prop product: ProductModel

  build() {
    Column() {
      // 商品图片
      Image(this.product.images[0])
        .width('100%')
        .height(200)
        .objectFit(ImageFit.Cover)
        .borderRadius({ topLeft: 12, topRight: 12 })
        .alt('商品图片')

      // 商品信息
      Column() {
        // 商品名称
        Text(this.product.name)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ bottom: 4 })

        // 商品描述
        Text(this.product.description)
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ bottom: 8 })

        // 评分
        Row() {
          Text('⭐')
            .fontSize(12)
          Text(this.product.rating.toFixed(1))
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
          Text(`(${this.product.reviewCount})`)
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .margin({ bottom: 8 })

        // 标签
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
          ForEach(this.product.tags, (tag: string) => {
            Text(tag)
              .fontSize(10)
              .fontColor($r('app.color.primary'))
              .backgroundColor($r('app.color.primary_light'))
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(4)
              .margin({ right: 4 })
              .margin({ bottom: 4 })
          })
        }
        .width('100%')
        .margin({ bottom: 8 })

        // 价格区域
        Row() {
          Text(`¥${this.product.price}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.price'))

          Text(`¥${this.product.originalPrice}`)
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .decoration({ type: TextDecorationType.LineThrough })
            .margin({ left: 8 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Bottom)

        // 库存状态
        Text(`库存 ${this.product.stock}`)
          .fontSize(10)
          .fontColor(this.product.stock > 50 ? $r('app.color.success') : $r('app.color.warning'))
          .margin({ top: 4 })
      }
      .padding(12)
      .width('100%')
      .layoutWeight(1)
    }
    .backgroundColor($r('app.color.white'))
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      // 跳转到商品详情页
      router.pushUrl({
        url: 'pages/ProductDetailPage',
        params: {
          productId: this.product.id
        }
      }).catch((error: Error) => {
        console.error('跳转商品详情页失败:', error.message)
      })
    })
  }
}