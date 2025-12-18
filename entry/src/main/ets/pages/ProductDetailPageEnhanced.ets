import router from '@ohos.router'
import { ProductModel, MockData } from '../model/ProductModel'
import { CartService } from '../services/CartService'
import { FavoriteService } from '../services/FavoriteService'
import { CommentSectionNew } from '../components/CommentSectionNew'

interface ProductParam {
  label: string
  value: string
}

@Entry
@Component
struct ProductDetailPageEnhanced {
  @State product: ProductModel | null = null
  @State currentImageIndex: number = 0
  @State quantity: number = 1
  @State isLoading: boolean = true
  @State showCartDialog: boolean = false
  @State showAlreadyInCartDialog: boolean = false
  @State scrollY: number = 0
  @State imageHeight: number = 375
  @State isFavorite: boolean = false
  @State showSpecSelector: boolean = false
  @State selectedSpec: string = '默认规格'
  @State scrollPercent: number = 0
  @State navBgOpacity: number = 0
  private cartService: CartService = CartService.getInstance()
  private favoriteService: FavoriteService = FavoriteService.getInstance()

  aboutToAppear() {
    this.loadProductData()
  }

  private async loadProductData() {
    interface RouteParams {
      productId: string
    }
    const params = router.getParams() as RouteParams
    if (params && params.productId) {
      const products = MockData.generateProducts()
      this.product = products.find(p => p.id === params.productId) || null

      // 检查是否已收藏
      if (this.product) {
        const favResult = await this.favoriteService.isFavorite(this.product.id)
        this.isFavorite = favResult ? favResult : false
      }
    }
    this.isLoading = false
  }

  private onImageChange(index: number) {
    this.currentImageIndex = index
  }

  private onQuantityChange(change: number) {
    const newQuantity = this.quantity + change
    if (newQuantity >= 1 && newQuantity <= (this.product?.stock || 0)) {
      this.quantity = newQuantity
    }
  }

  private async onToggleFavorite() {
    if (!this.product) return

    try {
      const isFav = await this.favoriteService.isFavorite(this.product.id)
      if (isFav) {
        await this.favoriteService.removeFromFavorites(this.product.id)
        this.isFavorite = false
      } else {
        await this.favoriteService.addToFavorites(this.product)
        this.isFavorite = true
      }
    } catch (error) {
      console.error('切换收藏状态失败:', error)
    }
  }

  private onAddToCart() {
    if (!this.product) return

    if (this.quantity > this.product.stock) {
      console.error('库存不足')
      return
    }

    try {
      if (this.cartService.isProductInCart(this.product.id)) {
        this.showAlreadyInCartDialog = true
      } else {
        const success = this.cartService.addToCart(this.product, this.quantity)
        if (!success) {
          console.error('添加到购物车失败')
          return
        }
        console.log('添加到购物车成功')
        this.showCartSuccessDialog()
      }
    } catch (error) {
      console.error('添加到购物车异常:', error)
    }
  }

  private showCartSuccessDialog(): void {
    this.showCartDialog = true
  }

  private goToCart(): void {
    this.showCartDialog = false
    router.pushUrl({ url: 'pages/CartPageNew' })
  }

  private continueShopping(): void {
    this.showCartDialog = false
  }

  private closeAlreadyInCartDialog(): void {
    this.showAlreadyInCartDialog = false
  }

  private onBuyNow() {
    if (!this.product) return
    console.log('立即购买:', this.product.name, '数量:', this.quantity)
  }

  private onScroll(xOffset: number, yOffset: number, scrollHeight: number) {
    this.scrollY = yOffset
    this.scrollPercent = yOffset / (scrollHeight - 720) // 720是可视区域高度
    this.navBgOpacity = Math.min(this.scrollPercent * 2, 0.95)
  }

  @Builder
  NavigationBar() {
    Row() {
      // 返回按钮
      Button() {
        Row() {
          Text('←')
            .fontSize(20)
            .fontColor(this.navBgOpacity > 0.5 ? $r('app.color.text_primary') : Color.White)
        }
      }
      .width(40)
      .height(40)
      .backgroundColor(this.navBgOpacity > 0.5 ? 'rgba(0,0,0,0.05)' : 'rgba(0,0,0,0.3)')
      .borderRadius(20)
      .onClick(() => {
        try {
          router.back()
        } catch (error) {
          console.error('返回失败:', error)
        }
      })

      Blank()

      // 更多操作按钮
      Row() {
        // 收藏按钮
        Button() {
          Text(this.isFavorite ? '❤️' : '🤍')
            .fontSize(20)
        }
        .width(40)
        .height(40)
        .backgroundColor(this.navBgOpacity > 0.5 ? 'rgba(0,0,0,0.05)' : 'rgba(0,0,0,0.3)')
        .borderRadius(20)
        .margin({ right: 8 })
        .onClick(() => this.onToggleFavorite())

        // 分享按钮
        Button() {
          Text('↗')
            .fontSize(20)
            .fontColor(this.navBgOpacity > 0.5 ? $r('app.color.text_primary') : Color.White)
        }
        .width(40)
        .height(40)
        .backgroundColor(this.navBgOpacity > 0.5 ? 'rgba(0,0,0,0.05)' : 'rgba(0,0,0,0.3)')
        .borderRadius(20)
        .onClick(() => {
          console.log('分享商品')
        })
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(`rgba(255,255,255,${this.navBgOpacity})`)
    .backdropBlur(20)
    .justifyContent(FlexAlign.SpaceBetween)
    .position({ x: 0, y: 0 })
    .zIndex(1000)
    .transition({ type: TransitionType.All })
  }

  @Builder
  ProductImages() {
    Column() {
      Swiper() {
        ForEach(this.product?.images || [], (image: string, index: number) => {
          Image(image)
            .width('100%')
            .height(this.imageHeight)
            .objectFit(ImageFit.Contain)
            .backgroundColor('#fafafa')
            .alt('商品图片')
            .transition({ type: TransitionType.All })
        })
      }
      .width('100%')
      .height(this.imageHeight)
      .loop(true)
      .indicator(true)
      .indicatorStyle({
        size: 8,
        color: 'rgba(255,255,255,0.4)',
        selectedColor: 'rgba(255,255,255,0.9)'
      })
      .onChange(this.onImageChange.bind(this))

      // 图片指示器
      Row() {
        ForEach(this.product?.images || [], (_: string, index: number) => {
          Column()
            .width(8)
            .height(8)
            .borderRadius(4)
            .backgroundColor(this.currentImageIndex === index ? Color.White : 'rgba(255,255,255,0.4)')
            .margin({ right: 6 })
            .transition({ type: TransitionType.All })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: -30 })
      .position({ x: 0, y: 20 })
      .zIndex(100)
    }
  }

  @Builder
  ProductInfo() {
    Column() {
      // 商品名称
      Text(this.product?.name || '')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .margin({ bottom: 12 })

      // 价格和折扣
      Row() {
        Column() {
          Row() {
            Text('¥')
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.price'))
              .margin({ top: 3 })
            Text(`${this.product?.price || 0}`)
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.price'))
          }

          // 原价
          if (this.product?.originalPrice && this.product.originalPrice > this.product.price) {
            Row() {
              Text(`¥${this.product.originalPrice}`)
                .fontSize(14)
                .fontColor($r('app.color.text_tertiary'))
                .decoration({ type: TextDecorationType.LineThrough })

              Text(`省${Math.floor(((this.product.originalPrice - this.product.price) / this.product.originalPrice) * 100)}%`)
                .fontSize(12)
                .fontColor($r('app.color.error'))
                .backgroundColor($r('app.color.secondary_light'))
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .borderRadius(10)
                .margin({ left: 12 })
            }
            .margin({ top: 4 })
          }
        }
        .alignItems(HorizontalAlign.Start)

        Blank()

        // 评分
        if (this.product?.rating) {
          Column() {
            Row() {
              Text('⭐')
                .fontSize(16)
              Text(this.product.rating.toFixed(1))
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.text_primary'))
            }
            Text(`${this.product.reviewCount}条评价`)
              .fontSize(11)
              .fontColor($r('app.color.text_tertiary'))
              .margin({ top: 2 })
          }
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 16 })

      // 服务保障
      Row() {
        Row() {
          Text('✓')
            .fontSize(14)
            .fontColor($r('app.color.success'))
            .margin({ right: 4 })
          Text('正品保证')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
        }

        Row() {
          Text('✓')
            .fontSize(14)
            .fontColor($r('app.color.success'))
            .margin({ right: 4 })
          Text('极速发货')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
        }
        .margin({ left: 20 })

        Row() {
          Text('✓')
            .fontSize(14)
            .fontColor($r('app.color.success'))
            .margin({ right: 4 })
          Text('七天退换')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
        }
        .margin({ left: 20 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .padding(16)
      .backgroundColor($r('app.color.white'))
      .borderRadius(12)
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.white'))
    .borderRadius(12)
    .margin({ top: 8, left: 12, right: 12 })
  }

  build() {
    Stack() {
      Column() {
        // 自定义导航栏
        this.NavigationBar()

        // 主内容 - 可滚动
        Scroll() {
          Column() {
            // 商品图片
            this.ProductImages()

            // 商品信息
            this.ProductInfo()

            // 规格选择
            Column() {
              Row() {
                Text('选择规格')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.text_primary'))
                Text(this.selectedSpec)
                  .fontSize(14)
                  .fontColor($r('app.color.text_secondary'))
                  .margin({ left: 12 })
                Blank()
                Text('>')
                  .fontSize(16)
                  .fontColor($r('app.color.text_tertiary'))
              }
              .width('100%')
              .padding(16)
              .backgroundColor($r('app.color.white'))
              .borderRadius(12)
              .margin({ top: 8, left: 12, right: 12 })
              .onClick(() => {
                this.showSpecSelector = true
              })
            }

            // 商品详情
            Column() {
              Text('商品详情')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .width('100%')
                .margin({ bottom: 12 })

              Text(this.product?.detailDescription || '暂无详细描述')
                .fontSize(14)
                .fontColor($r('app.color.text_primary'))
                .lineHeight(24)
                .width('100%')

              // 商品参数（示例）
              Column() {
                Text('商品参数')
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.text_primary'))
                  .width('100%')
                  .margin({ top: 24, bottom: 12 })

                ForEach([
                  { label: '品牌', value: '华为' },
                  { label: '型号', value: '标准版' },
                  { label: '颜色', value: '深空灰' },
                  { label: '存储容量', value: '128GB' },
                  { label: '保修期', value: '12个月' }
                ], (param: ProductParam) => {
                  Row() {
                    Text(param.label)
                      .fontSize(14)
                      .fontColor($r('app.color.text_secondary'))
                      .width(80)
                    Text(param.value)
                      .fontSize(14)
                      .fontColor($r('app.color.text_primary'))
                      .layoutWeight(1)
                  }
                  .width('100%')
                  .padding({ top: 8, bottom: 8 })
                  .borderRadius(8)
                  .backgroundColor(param.label === '品牌' || param.label === '颜色' ? $r('app.color.background_gray') : Color.Transparent)
                  .padding({ left: 12, right: 12 })
                })
              }
              .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor($r('app.color.white'))
            .borderRadius(12)
            .margin({ top: 8, left: 12, right: 12 })

            // 用户评价
            Column() {
              Text('用户评价')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .width('100%')
                .margin({ bottom: 12 })

              CommentSectionNew({ productId: this.product?.id || '' })
            }
            .width('100%')
            .padding(16)
            .backgroundColor($r('app.color.white'))
            .borderRadius(12)
            .margin({ top: 8, left: 12, right: 12, bottom: 120 })
          }
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .onScroll((xOffset: number, yOffset: number) => {
          const scrollHeight = 800 // 预估滚动高度
          this.onScroll(xOffset, yOffset, scrollHeight)
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.background'))

      // 底部购买栏
      if (this.product) {
        Row() {
          // 联系客服
          Button() {
            Column() {
              Text('💬')
                .fontSize(20)
                .fontColor($r('app.color.text_secondary'))
              Text('客服')
                .fontSize(10)
                .fontColor($r('app.color.text_secondary'))
                .margin({ top: 2 })
            }
          }
          .width(60)
          .height(48)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            console.log('联系客服')
          })

          // 加入购物车
          Button('加入购物车')
            .height(48)
            .fontSize(15)
            .backgroundColor($r('app.color.secondary'))
            .fontColor(Color.White)
            .borderRadius(24)
            .layoutWeight(1)
            .margin({ left: 8, right: 8 })
            .onClick(() => this.onAddToCart())

          // 立即购买
          Button('立即购买')
            .height(48)
            .fontSize(15)
            .backgroundColor($r('app.color.primary'))
            .fontColor(Color.White)
            .borderRadius(24)
            .layoutWeight(1)
            .onClick(() => this.onBuyNow())
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor($r('app.color.white'))
        .backdropBlur(20)
        .shadow({
          radius: 8,
          color: $r('app.color.shadow_medium'),
          offsetX: 0,
          offsetY: -2
        })
        .position({ x: 0, y: '100%' })
        .translate({ x: 0, y: -64 })
        .zIndex(1001)
      }

      // 加载状态
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
          Text('加载中...')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 16 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.background'))
      }

      // 加入购物车成功弹窗
      if (this.showCartDialog) {
        Column() {
          // 遮罩层
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.5)')
            .onClick(() => {
              this.continueShopping()
            })

          // 弹窗内容
          Column() {
            Text('✓')
              .fontSize(48)
              .fontColor($r('app.color.success'))
              .margin({ bottom: 16 })

            Text('加入购物车成功')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .margin({ bottom: 8 })

            Text('商品已成功添加到购物车')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ bottom: 24 })

            Row() {
              Button('继续购物')
                .height(44)
                .fontSize(16)
                .backgroundColor($r('app.color.background_gray'))
                .fontColor($r('app.color.text_primary'))
                .layoutWeight(1)
                .margin({ right: 8 })
                .onClick(() => {
                  this.continueShopping()
                })

              Button('去购物车')
                .height(44)
                .fontSize(16)
                .backgroundColor($r('app.color.primary'))
                .fontColor(Color.White)
                .layoutWeight(1)
                .margin({ left: 8 })
                .onClick(() => {
                  this.goToCart()
                })
            }
            .width('100%')
          }
          .width(300)
          .backgroundColor($r('app.color.white'))
          .borderRadius(16)
          .padding(24)
          .position({ x: '50%', y: '50%' })
          .translate({ x: '-50%', y: '-50%' })
          .shadow({
            radius: 20,
            color: $r('app.color.shadow_medium'),
            offsetX: 0,
            offsetY: 10
          })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(9999)
      }

      // 商品已在购物车提示弹窗
      if (this.showAlreadyInCartDialog) {
        Column() {
          // 遮罩层
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.5)')
            .onClick(() => {
              this.closeAlreadyInCartDialog()
            })

          // 弹窗内容
          Column() {
            Text('🛒')
              .fontSize(48)
              .fontColor($r('app.color.secondary'))
              .margin({ bottom: 16 })

            Text('商品已在购物车中')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .margin({ bottom: 8 })

            Text('该商品已经添加到购物车，可以前往购物车查看或调整数量')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ bottom: 24 })

            Row() {
              Button('继续购物')
                .height(44)
                .fontSize(16)
                .backgroundColor($r('app.color.background_gray'))
                .fontColor($r('app.color.text_primary'))
                .layoutWeight(1)
                .margin({ right: 8 })
                .onClick(() => {
                  this.closeAlreadyInCartDialog()
                })

              Button('查看购物车')
                .height(44)
                .fontSize(16)
                .backgroundColor($r('app.color.primary'))
                .fontColor(Color.White)
                .layoutWeight(1)
                .margin({ left: 8 })
                .onClick(() => {
                  this.closeAlreadyInCartDialog()
                  this.goToCart()
                })
            }
            .width('100%')
          }
          .width(320)
          .backgroundColor($r('app.color.white'))
          .borderRadius(16)
          .padding(24)
          .position({ x: '50%', y: '50%' })
          .translate({ x: '-50%', y: '-50%' })
          .shadow({
            radius: 20,
            color: $r('app.color.shadow_medium'),
            offsetX: 0,
            offsetY: 10
          })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(9999)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}