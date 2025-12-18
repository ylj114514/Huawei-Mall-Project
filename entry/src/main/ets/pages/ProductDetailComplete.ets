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

interface ProductParams {
  productId: string
}



@Entry
@Component
struct ProductDetailComplete {
  @State product: ProductModel | null = null
  @State selectedSpec: string = '12GB+512GB'
  @State selectedColor: string = '雅川青'
  @State quantity: number = 1
  @State isLoading: boolean = true
  @State isSubmittingComment: boolean = false
  @State isFavorite: boolean = false
  @State comments: IComment[] = []
  @State currentImageIndex: number = 0
  @State user: User | null = null
  @State showCommentDialog: boolean = false
  @State commentRating: number = 5
  @State commentContent: string = ''
  @State showAllComments: boolean = false
  @State commentImages: string[] = []

  private specs: string[] = ['12GB+256GB', '12GB+512GB', '16GB+512GB', '16GB+1TB']
  private colors: string[] = ['雅川青', '雅黑', '雅白', '雅丹霞']
  private storage: StorageManager = StorageManager.getInstance()
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  aboutToAppear() {
    this.initStorage()
    this.loadProductData()
    this.loadUserData()
  }

  private async initStorage() {
    try {
      await this.storage.init(this.context)
      console.log('ProductDetailComplete: StorageManager初始化成功')
    } catch (error) {
      console.error('ProductDetailComplete: StorageManager初始化失败:', error)
    }
  }

  private async loadUserData() {
    try {
      this.user = await this.storage.loadUser()
      console.log('ProductDetail - 用户状态:', this.user ? this.user.username : '未登录')
    } catch (error) {
      console.error('加载用户数据失败:', error)
    }
  }

  private async loadProductData() {
    const params = router.getParams() as ProductParams
    if (params?.productId) {
      const products = MockData.generateProducts()
      this.product = products.find(p => p.id === params.productId) || null

      if (this.product) {
        // 收藏功能已移除
        this.isFavorite = false
        // 从数据库加载评论
        await this.loadComments()
      }
    }
    this.isLoading = false
  }

  private async loadComments() {
    if (!this.product) return
    try {
      const comments = await this.storage.getProductComments(this.product.id)
      this.comments = comments as IComment[]
      console.log('加载评论完成，数量：', this.comments.length)
    } catch (error) {
      console.error('加载评论失败:', error)
      this.comments = []
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
    // 实际立即购买的逻辑
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

    // 防止重复提交
    if (this.isSubmittingComment) {
      console.log('评论正在提交中，请勿重复点击')
      return
    }

    this.isSubmittingComment = true

    try {
      // 创建评论数据对象
      const commentData = new CommentData(
        this.product.id,
        this.commentRating,
        this.commentContent.trim(),
        '',
        this.selectedSpec
      )

      await this.storage.addComment(commentData)

      // 重新加载评论
      await this.loadComments()

      // 关闭对话框并重置表单
      this.showCommentDialog = false
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

  private async onLikeComment(commentId: number) {
    try {
      await this.storage.likeComment(commentId.toString())
      // 重新加载评论以更新点赞数
      await this.loadComments()
    } catch (error) {
      console.error('点赞评论失败:', error)
    }
  }

  @Builder
  NavigationBar() {
    Row() {
      // 返回按钮
      Button() {
        Text('←')
          .fontSize(24)
          .fontColor('#FFFFFF')
      }
      .width(48)
      .height(48)
      .backgroundColor(Color.Transparent)
      .onClick(() => router.back())

      Blank()

      Text('商品详情')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')

      Blank()

      // 分享按钮
      Button() {
        Text('↗')
          .fontSize(24)
          .fontColor('#FFFFFF')
      }
      .width(48)
      .height(48)
      .backgroundColor(Color.Transparent)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .position({ x: 0, y: 0 })
    .zIndex(1000)
  }

  @Builder
  HeroSection() {
    Column() {
      Swiper() {
        ForEach(this.product?.images || [this.product?.image], (image: string, index?: number) => {
          Image(image)
            .width('100%')
            .height(450)
            .objectFit(ImageFit.Contain)
            .backgroundColor('#0A0A0A')
            .borderRadius(0)
        })
      }
      .width('100%')
      .height(450)
      .loop(true)
      .autoPlay(true)
      .interval(3000)
      .indicatorStyle({
        size: 8,
        left: 0,
        right: 0,
        top: 400,
        color: 'rgba(255,255,255,0.3)',
        selectedColor: '#FFFFFF'
      })
      .onChange((index: number) => {
        this.currentImageIndex = index
      })
    }
    .width('100%')
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [
        ['#0A0A0A', 0.0],
        ['#1A1A1A', 0.3],
        ['#0A0A0A', 1.0]
      ]
    })
  }

  @Builder
  CommentInputArea() {
    Row() {
      Row() {
          Text(this.user ? this.user.username[0] : '未')
          .fontSize(16)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .width(36)
          .height(36)
          .backgroundColor('#FF3B30')
          .borderRadius(18)
          .textAlign(TextAlign.Center)

        TextInput({
          placeholder: '说说你的使用感受...',
          text: ''
        })
          .fontSize(14)
          .fontColor('#1A1A1A')
          .backgroundColor('#F5F5F5')
          .borderRadius(20)
          .padding({ left: 16, right: 16 })
          .layoutWeight(1)
          .margin({ left: 12 })
      }
      .width('100%')
      .layoutWeight(1)

      Button('发表')
        .fontSize(14)
        .fontColor('#FFFFFF')
        .backgroundColor('#FF3B30')
        .borderRadius(20)
        .padding({ left: 20, right: 20 })
        .height(36)
        .margin({ left: 12 })
        .onClick(() => {
          this.showCommentDialog = true
        })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ top: 12 })
  }
}

  @Builder
  CommentDialog() {
    if (this.showCommentDialog) {
      Stack() {
        // 遮罩层
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.5)')
          .onClick(() => {
            this.showCommentDialog = false
          })

        // 对话框内容
        Column() {
          Text('发表评论')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .textAlign(TextAlign.Center)
            .margin({ bottom: 20 })

          // 评分
          Text('评分')
            .fontSize(14)
            .fontColor('#666666')
            .width('100%')
            .margin({ bottom: 8 })

          Row() {
            ForEach([1, 2, 3, 4, 5], (star: number) => {
              Text('★')
                .fontSize(32)
                .fontColor(star <= this.commentRating ? '#FFD700' : '#E0E0E0')
                .onClick(() => {
                  this.commentRating = star
                })
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: 20 })

          // 评论内容
          TextArea({
            placeholder: '分享你的使用心得，帮助更多人了解这款产品...',
            text: this.commentContent
          })
            .fontSize(14)
            .fontColor('#1A1A1A')
            .backgroundColor('#F5F5F7')
            .borderRadius(12)
            .padding(16)
            .width('100%')
            .height(150)
            .onChange((value: string) => {
              this.commentContent = value
            })
            .margin({ bottom: 16 })

          // 图片上传区域（简化版）
          Column() {
            Text('添加图片')
              .fontSize(14)
              .fontColor('#666666')
              .width('100%')
              .margin({ bottom: 8 })

            Button() {
              Text('+ 点击上传图片（功能开发中）')
                .fontSize(14)
                .fontColor('#999999')
            }
            .width('100%')
            .height(80)
            .backgroundColor('#F5F5F7')
            .borderRadius(8)
            .onClick(() => {
              console.log('图片上传功能开发中')
            })

            Text('图片功能正在开发中，暂时无法上传')
              .fontSize(12)
              .fontColor('#999999')
              .width('100%')
              .margin({ top: 8 })
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .margin({ bottom: 16 })

          // 操作按钮
          Row() {
            Button('取消')
              .fontSize(16)
              .fontColor('#666666')
              .backgroundColor('#F5F5F7')
              .borderRadius(8)
              .width(100)
              .height(44)
              .onClick(() => {
                this.showCommentDialog = false
              })

            Blank()

            Button(this.isSubmittingComment ? '发表中...' : '发表')
              .fontSize(16)
              .fontColor('#FFFFFF')
              .backgroundColor(this.isSubmittingComment ? '#CCCCCC' : '#FF3B30')
              .borderRadius(8)
              .width(100)
              .height(44)
              .enabled(this.commentContent.trim().length > 0 && !this.isSubmittingComment)
              .onClick(() => {
                this.onSubmitComment()
              })
          }
          .width('100%')
          .margin({ top: 20 })
        }
        .width('90%')
        .padding(24)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .justifyContent(FlexAlign.Center)
        .shadow({
          radius: 24,
          color: '#00000030',
          offsetX: 0,
          offsetY: 8
        })
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(2000)
    }
  }

  @Builder
  CommentList() {
    Column() {
      Row() {
        Text('用户评价')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1A1A1A')
          .layoutWeight(1)

        Text(`${this.comments.length}条`)
          .fontSize(14)
          .fontColor('#666666')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 20 })

      // 评论输入区
      this.CommentInputArea()

      // 评论列表
      if (this.comments.length > 0) {
        ForEach(this.showAllComments ? this.comments : this.comments.slice(0, 3), (comment: IComment, index?: number) => {
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
                  .fontColor('#1A1A1A')
                  .fontWeight(FontWeight.Medium)
                Text(comment.spec || '默认规格')
                  .fontSize(12)
                  .fontColor('#999999')
                  .margin({ top: 4 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              .margin({ left: 12 })

              Text(new Date(comment.createTime).toLocaleDateString())
                .fontSize(12)
                .fontColor('#999999')
            }
            .width('100%')
            .alignItems(VerticalAlign.Top)
            .margin({ bottom: 12 })

            // 评分
            Row() {
              ForEach([1, 2, 3, 4, 5], (star: number) => {
                Text('★')
                  .fontSize(14)
                  .fontColor(star <= comment.rating ? '#FFD700' : '#E0E0E0')
              })
            }
            .margin({ bottom: 12 })

            Text(comment.content)
              .fontSize(14)
              .fontColor('#333333')
              .lineHeight(22)
              .width('100%')
              .margin({ bottom: 12 })

            // 显示评论图片（简化版）
            if (comment.images && comment.images !== '') {
              Text('图片：' + comment.images)
                .fontSize(12)
                .fontColor('#999999')
                .margin({ bottom: 8 })
            }

            Row() {
              Button(`有用 (${comment.helpfulCount})`)
                .fontSize(12)
                .fontColor('#666666')
                .backgroundColor('#F5F5F5')
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .borderRadius(4)
                .onClick(() => {
                  this.onLikeComment(comment.id)
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.End)
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .margin({ bottom: 12 })
        })

        // 查看更多按钮
        if (this.comments.length > 3 && !this.showAllComments) {
          Button('查看全部评论')
            .fontSize(14)
            .fontColor('#666666')
            .backgroundColor('#F5F5F7')
            .width('100%')
            .height(44)
            .borderRadius(8)
            .margin({ top: 12 })
            .onClick(() => {
              this.showAllComments = true
            })
        }
      } else {
        // 暂无评论
        Column() {
          Text('暂无评论')
            .fontSize(14)
            .fontColor('#999999')
            .margin({ top: 40, bottom: 40 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .padding({ left: 20, right: 20 })
    .margin({ top: 12 })
  }

  build() {
    Stack() {
      Scroll() {
        Column() {
          // Hero 区域
          this.HeroSection()

          // 商品信息
          Column() {
            // 价格和标题
            Column() {
              Row() {
                Text(`¥${this.product?.price || 0}`)
                  .fontSize(32)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')

                if (this.product?.originalPrice && this.product.originalPrice > this.product.price) {
                  Text(`¥${this.product.originalPrice}`)
                    .fontSize(20)
                    .fontColor('rgba(255,255,255,0.5)')
                    .decoration({ type: TextDecorationType.LineThrough })
                    .margin({ left: 16 })
                }
              }
              .width('100%')
              .margin({ bottom: 16 })

              Text(this.product?.name || '')
                .fontSize(24)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .width('100%')
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('100%')
            .padding(24)
            .backgroundColor('#1A1A1A')
            .borderRadius(24)
            .margin({ top: -40 })
            .zIndex(10)

            // 商品详情
            Column() {
              Text('商品详情')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1A1A1A')
                .width('100%')
                .margin({ bottom: 20 })

              Text(this.product?.detailDescription || '')
                .fontSize(14)
                .fontColor('#666666')
                .lineHeight(24)
                .width('100%')
            }
            .width('100%')
            .padding(20)
            .backgroundColor('#FFFFFF')
            .borderRadius(24)
            .margin({ top: 12 })
          }
          .width('100%')

          // 评论列表
          this.CommentList()
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F7')

      // 导航栏
      this.NavigationBar()

      // 底部操作栏
      Row() {
        // 购物车按钮
        Column() {
          Text('🛒')
            .fontSize(28)
            .fontColor('#1A1A1A')

          Text('购物车')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .width(48)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          router.pushUrl({ url: 'pages/CartPage' })
        })

        Button('加入购物车')
          .height(50)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor('#1A1A1A')
          .borderRadius(25)
          .layoutWeight(1)
          .margin({ left: 20, right: 12 })
          .onClick(() => this.onAddToCart())

        Button('立即购买')
          .height(50)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor('#FF3B30')
          .borderRadius(25)
          .layoutWeight(1)
          .onClick(() => this.onBuyNow())
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20, top: 12 })
      .backgroundColor('rgba(255,255,255,0.98)')
      .backdropBlur(20)
      .border({ width: { top: 0.5 }, color: '#E5E5E5' })
      .position({ x: 0, y: '100%' })
      .translate({ x: 0, y: -110 })

      // 评论弹窗
      this.CommentDialog()

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
        .backgroundColor('#F5F5F7')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F7')
  }
}