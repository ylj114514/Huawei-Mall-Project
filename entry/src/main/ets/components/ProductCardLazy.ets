import router from '@ohos.router'
import { ProductModel } from '../model/ProductModel'

// 可复用的商品卡片组件，支持懒加载
@Reusable
@Component
export struct ProductCardLazy {
  @Prop product: ProductModel
  @State imageLoaded: boolean = false
  @State imageError: boolean = false
  @State isLiked: boolean = false

  build() {
    Column() {
      // 商品图片容器 - 懒加载实现
      Stack() {
        // 加载占位图
        if (!this.imageLoaded) {
          Column() {
            LoadingProgress()
              .width(24)
              .height(24)
              .color($r('app.color.primary'))
            Text('加载中...')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 8 })
          }
          .width('100%')
          .height(200)
          .backgroundColor($r('app.color.background'))
          .justifyContent(FlexAlign.Center)
        }

        // 错误状态
        if (this.imageError) {
          Column() {
            Text('📷')
              .fontSize(40)
            Text('图片加载失败')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 8 })
          }
          .width('100%')
          .height(200)
          .backgroundColor($r('app.color.background'))
          .justifyContent(FlexAlign.Center)
        }

        // 实际图片
        Image(this.product.images[0])
          .width('100%')
          .height(200)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: 12, topRight: 12 })
          .alt('商品图片')
          .onComplete(() => {
            this.imageLoaded = true
          })
          .onError(() => {
            this.imageError = true
          })
          .opacity(this.imageLoaded ? 1 : 0)
          .animation({
            duration: 300,
            curve: Curve.EaseInOut
          })
      }
      .width('100%')
      .height(200)
      .borderRadius({ topLeft: 12, topRight: 12 })

      // 收藏按钮
      if (this.imageLoaded && !this.imageError) {
        Button(this.isLiked ? '❤️' : '🤍')
          .width(32)
          .height(32)
          .backgroundColor('rgba(0,0,0,0.3)')
          .fontSize(16)
          .position({ x: '85%', y: 8 })
          .borderRadius(16)
          .onClick(() => {
            this.isLiked = !this.isLiked
            // 这里可以添加收藏逻辑
          })
      }

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

        // 评分和销量
        Row() {
          Row() {
            Text('⭐')
              .fontSize(12)
            Text(this.product.rating.toFixed(1))
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
            Text(`(${this.product.reviewCount})`)
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .margin({ left: 4 })
          }
          .layoutWeight(1)

          // 库存状态
          Text(this.getStockText())
            .fontSize(10)
            .fontColor(this.getStockColor())
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
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

          if (this.product.originalPrice > this.product.price) {
            Text(`¥${this.product.originalPrice}`)
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .decoration({ type: TextDecorationType.LineThrough })
              .margin({ left: 8 })
          }

          Blank()

          // 销量标签
          if (this.product.reviewCount > 1000) {
            Text('热销')
              .fontSize(10)
              .fontColor(Color.White)
              .backgroundColor($r('app.color.secondary'))
              .padding({ left: 4, right: 4, top: 2, bottom: 2 })
              .borderRadius(4)
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Bottom)
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

  private getStockText(): string {
    if (this.product.stock <= 0) return '已售罄'
    if (this.product.stock <= 10) return `仅剩${this.product.stock}件`
    return `库存${this.product.stock}`
  }

  private getStockColor(): Resource {
    if (this.product.stock <= 0) return $r('app.color.text_secondary')
    if (this.product.stock <= 10) return $r('app.color.warning')
    return $r('app.color.success')
  }
}