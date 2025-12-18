import router from '@ohos.router'
import { ProductModel, MockData } from '../model/ProductModel'
import { StorageManager } from '../utils/StorageManagerSimple'
import { User } from '../model/DataModel'
import { CommentData } from '../model/CommentModels'
import common from '@ohos.app.ability.common'

// 从 StorageManagerSimple 导入的接口
interface IComment {
  id: number
  productId: string
  userId: string
  userName: string
  userAvatar: string
  rating: number
  content: string
  images: string
  helpfulCount: number
  spec: string
  createTime: string
}

// 路由参数接口
interface ProductParams {
  productId: string
}

@Entry
@Component
struct ProductDetailFixed {
  @State productId: string = ''
  @State product: ProductModel | null = null
  @State selectedSpec: string = '标准版'
  @State quantity: number = 1
  @State isLoading: boolean = true
  @State isSubmittingComment: boolean = false
  @State comments: IComment[] = []
  @State showAllComments: boolean = false
  @State user: User | null = null
  @State currentImageIndex: number = 0
  @State favoriteCount: number = 0
  @State commentContent: string = ''
  @State commentRating: number = 5
  @State commentImages: string[] = []

  private storage: StorageManager = StorageManager.getInstance()
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  aboutToAppear() {
    this.initStorage()
    this.loadProduct()
    this.loadUser()
    this.loadComments()
  }

  private async initStorage() {
    try {
      await this.storage.init(this.context)
    } catch (error) {
      console.error('初始化存储失败:', error)
    }
  }

  private async loadUser() {
    try {
      this.user = await this.storage.loadUser()
    } catch (error) {
      console.error('加载用户信息失败:', error)
    }
  }

  private async loadProduct() {
    try {
      const params = router.getParams() as ProductParams
      if (params && params.productId) {
        this.productId = params.productId
        this.product = MockData.generateProducts().find(p => p.id === this.productId) || null
      }
    } catch (error) {
      console.error('加载商品失败:', error)
    } finally {
      this.isLoading = false
    }
  }

  private async loadComments() {
    if (!this.product) return
    try {
      this.comments = await this.storage.getProductComments(this.productId)
    } catch (error) {
      console.error('加载评论失败:', error)
      this.comments = []
    }
  }

  private async onSubmitComment() {
    if (!this.user || !this.product) {
      router.pushUrl({ url: 'pages/LoginPageModern' })
      return
    }

    if (!this.commentContent.trim()) {
      console.error('评论内容不能为空')
      return
    }

    if (this.isSubmittingComment) {
      console.log('评论正在提交中，请勿重复点击')
      return
    }

    this.isSubmittingComment = true

    try {
      const commentData = new CommentData(
        this.product.id,
        this.commentRating,
        this.commentContent.trim(),
        '',
        this.selectedSpec
      )

      await this.storage.addComment(commentData)
      await this.loadComments()

      // 重置表单
      this.commentContent = ''
      this.commentRating = 5
      this.commentImages = []

      console.log('评论发表成功')
      AlertDialog.show({
        title: '成功',
        message: '评论发表成功',
        primaryButton: {
          value: '确定',
          action: () => {}
        }
      })
    } catch (error) {
      console.error('评论发表失败:', error)
      AlertDialog.show({
        title: '错误',
        message: '评论发表失败，请重试',
        primaryButton: {
          value: '确定',
          action: () => {}
        }
      })
    } finally {
      this.isSubmittingComment = false
    }
  }

  private async onAddToCart() {
    if (!this.product) {
      console.error('商品信息不存在')
      return
    }

    if (!this.user) {
      console.log('用户未登录，跳转到登录页')
      router.pushUrl({ url: 'pages/LoginPageModern' })
      return
    }

    try {
      console.log('准备添加到购物车:', this.product.name)
      await this.storage.addToCart(this.product, this.quantity, this.selectedSpec)

      // 显示成功提示
      AlertDialog.show({
        title: '成功',
        message: '已添加到购物车',
        primaryButton: {
          value: '去购物车',
          action: () => {
            router.pushUrl({ url: 'pages/CartPage' })
          }
        },
        secondaryButton: {
          value: '继续购物',
          action: () => {}
        }
      })
    } catch (error) {
      console.error('添加到购物车失败:', error)
      AlertDialog.show({
        title: '错误',
        message: '添加失败，请重试',
        primaryButton: {
          value: '确定',
          action: () => {}
        }
      })
    }
  }

  private onBuyNow() {
    console.log('立即购买')
  }

  @Builder
  Header() {
    Row() {
      Button() {
        Text('←')
          .fontSize(24)
      }
      .width(60)
      .height(48)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        router.back()
      })

      Text('商品详情')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Blank().width(60)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  ProductImage() {
    Column() {
      // 主图
      Image(this.product?.image || '')
        .width('100%')
        .height(375)
        .objectFit(ImageFit.Contain)
        .backgroundColor('#F8F9FA')

      // 缩略图
      Row() {
        ForEach(this.product?.images || [this.product?.image], (img: string) => {
          Image(img)
            .width(80)
            .height(80)
            .objectFit(ImageFit.Cover)
            .backgroundColor('#F8F9FA')
            .borderRadius(8)
            .margin({ right: 8 })
        })
      }
      .width('100%')
      .padding({ top: 16 })
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .margin({ top: 10 })
  }

  @Builder
  ProductInfo() {
    Column() {
      Text(this.product?.name || '')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .width('100%')
        .margin({ bottom: 16 })

      // 价格
      Row() {
        Text(`¥${this.product?.price || 0}`)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF3B30')
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 评分
      Row() {
        ForEach([1, 2, 3, 4, 5], (star: number) => {
          Text('★')
            .fontSize(20)
            .fontColor('#FFD700')
        })
        Text(' 4.8')
          .fontSize(16)
          .fontColor('#666666')
          .margin({ left: 8 })
        Text('(2k+)')
          .fontSize(14)
          .fontColor('#666666')
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 描述
      Text(this.product?.description || '')
        .fontSize(16)
        .fontColor('#666666')
        .lineHeight(24)
        .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .margin({ top: 10 })
  }

  @Builder
  SpecSelector() {
    Column() {
      Text('选择规格')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1A1A')
        .width('100%')
        .margin({ bottom: 16 })

      Row() {
        ForEach(['标准版', '高配版'], (spec: string) => {
          Button(spec)
            .fontSize(14)
            .fontColor(this.selectedSpec === spec ? Color.White : '#1A1A1A')
            .backgroundColor(this.selectedSpec === spec ? '#007AFF' : '#F0F0F0')
            .borderRadius(20)
            .padding({ left: 20, right: 20, top: 10, bottom: 10 })
            .margin({ right: 12 })
            .onClick(() => {
              this.selectedSpec = spec
            })
        })
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .margin({ top: 10 })
  }

  @Builder
  QuantitySelector() {
    Column() {
      Text('数量')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1A1A')
        .width('100%')
        .margin({ bottom: 16 })

      Row() {
        Button('-')
          .width(40)
          .height(40)
          .fontSize(20)
          .backgroundColor('#F0F0F0')
          .fontColor(this.quantity > 1 ? '#1A1A1A' : '#CCCCCC')
          .onClick(() => {
            if (this.quantity > 1) {
              this.quantity--
            }
          })

        Text(this.quantity.toString())
          .fontSize(16)
          .width(60)
          .textAlign(TextAlign.Center)

        Button('+')
          .width(40)
          .height(40)
          .fontSize(20)
          .backgroundColor('#F0F0F0')
          .fontColor('#1A1A1A')
          .onClick(() => {
            this.quantity++
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .margin({ top: 10 })
  }

  @Builder
  CommentSection() {
    Column() {
      Text('用户评价')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1A1A1A')
        .width('100%')
        .margin({ bottom: 20 })

      ForEach(this.showAllComments ? this.comments : this.comments.slice(0, 3), (comment: IComment) => {
        Column() {
          Row() {
            Text(comment.userName[0])
              .fontSize(16)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
              .width(36)
              .height(36)
              .backgroundColor('#FF3B30')
              .borderRadius(18)
              .textAlign(TextAlign.Center)

            Column() {
              Text(comment.userName)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1A1A1A')
              Text(new Date(comment.createTime).toLocaleDateString())
                .fontSize(12)
                .fontColor('#999999')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            .margin({ left: 12 })
          }
          .width('100%')
          .margin({ bottom: 12 })

          Text(comment.content)
            .fontSize(14)
            .fontColor('#333333')
            .width('100%')
            .margin({ bottom: 8 })

          Row() {
            ForEach([1, 2, 3, 4, 5], (star: number) => {
              Text('★')
                .fontSize(14)
                .fontColor(star <= comment.rating ? '#FFD700' : '#E0E0E0')
            })
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#F8F9FA')
        .borderRadius(8)
        .margin({ bottom: 12 })
      })

      if (this.comments.length > 3 && !this.showAllComments) {
        Button('查看全部评论')
          .fontSize(14)
          .width('100%')
          .height(44)
          .backgroundColor('#F5F5F7')
          .onClick(() => {
            this.showAllComments = true
          })
      }

      // 评论输入区域
      Row() {
        TextInput({
          placeholder: '说点什么...',
          text: this.commentContent
        })
          .fontSize(14)
          .backgroundColor('#F5F5F5')
          .borderRadius(20)
          .padding({ left: 16, right: 16 })
          .layoutWeight(1)
          .onChange((value: string) => {
            this.commentContent = value
          })

        Button(this.isSubmittingComment ? '发表中...' : '发表')
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor(this.isSubmittingComment ? '#CCCCCC' : '#007AFF')
          .borderRadius(20)
          .width(80)
          .height(44)
          .enabled(this.commentContent.trim().length > 0 && !this.isSubmittingComment)
          .onClick(() => {
            this.onSubmitComment()
          })
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .margin({ top: 10 })
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航
        this.Header()

        // 主内容
        Scroll() {
          Column() {
            // 商品图片
            this.ProductImage()

            // 商品信息
            this.ProductInfo()

            // 规格选择
            this.SpecSelector()

            // 数量选择
            this.QuantitySelector()

            // 评论区域
            this.CommentSection()

            // 额外空间
            Column()
              .width('100%')
              .height(80)
          }
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#F5F7FA')

        // 底部操作栏
        Row() {
          Button('加入购物车')
            .height(50)
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor('#FFA500')
            .borderRadius(25)
            .layoutWeight(1)
            .margin({ right: 10 })
            .onClick(() => {
              this.onAddToCart()
            })

          Button('立即购买')
            .height(50)
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor('#007AFF')
            .borderRadius(25)
            .layoutWeight(1)
            .onClick(() => {
              this.onBuyNow()
            })
        }
        .width('100%')
        .padding(20)
        .backgroundColor('#FFFFFF')
        .shadow({
          radius: 4,
          color: 'rgba(0,0,0,0.1)',
          offsetX: 0,
          offsetY: -2
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F7FA')

      // 加载状态
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
          Text('加载中...')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 16 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#F5F7FA')
      }
    }
    .width('100%')
    .height('100%')
  }
}