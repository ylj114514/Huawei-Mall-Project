import promptAction from '@ohos.promptAction'

// ==========================================
// 1. 本地定义数据模型 (确保包含 images 和 isLiked)
// ==========================================
class Comment {
  id: string
  productId: string
  userId: string
  username: string
  rating: number
  content: string
  timestamp: number
  likes: number
  isLiked: boolean // UI需要的字段
  images: string[] // UI需要的字段

  constructor(productId: string, userId: string, username: string, rating: number, content: string, images: string[] = []) {
    this.id = Date.now().toString() + Math.floor(Math.random() * 1000)
    this.productId = productId
    this.userId = userId
    this.username = username
    this.rating = rating
    this.content = content
    this.timestamp = Date.now()
    this.likes = 0
    this.isLiked = false
    this.images = images
  }

  getFormattedTime(): string {
    const date = new Date(this.timestamp)
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')}`
  }
}

// ==========================================
// 2. 本地模拟服务 (包含图片数据的 Mock)
// ==========================================
class CommentService {
  private static instance: CommentService
  private comments: Comment[] = []

  private constructor() {
    this.initMockData()
  }

  public static getInstance(): CommentService {
    if (!CommentService.instance) {
      CommentService.instance = new CommentService()
    }
    return CommentService.instance
  }

  private initMockData() {
    // 模拟带图片和不带图片的数据
    this.comments = [
      new Comment('1', 'u1', '张三', 5, '手机非常好用，拍照清晰！', [
        'https://img.alicdn.com/imgextra/i2/O1CN015k5k5k1k5k5k5k5k5_!!0-item_pic.jpg_468x468q75.jpg_.webp',
        'https://img.alicdn.com/imgextra/i4/O1CN015k5k5k1k5k5k5k5k5_!!0-item_pic.jpg_468x468q75.jpg_.webp'
      ]),
      new Comment('1', 'u2', '李四', 4, '物流很快，包装完好。', []),
      new Comment('1', 'u3', '王五', 5, '遥遥领先！鸿蒙系统很流畅。', []),
      new Comment('1', 'u4', '赵六', 3, '感觉一般般吧，没有想象中那么惊艳。', []),
      new Comment('1', 'u5', '用户888', 5, '强烈推荐，性价比很高。', []),
      new Comment('1', 'u6', '测试号', 4, '还不错，给个好评。', [])
    ]
    // 模拟一些初始点赞数
    this.comments[0].likes = 12
    this.comments[2].likes = 5
  }

  // 分页获取评论
  getProductComments(productId: string, page: number = 1): Comment[] {
    const pageSize = 10
    const startIndex = (page - 1) * pageSize
    // 简单模拟：实际应根据 productId 筛选
    return this.comments.slice(startIndex, startIndex + pageSize)
  }

  getProductCommentCount(productId: string): number {
    return this.comments.length
  }

  addComment(comment: Comment): boolean {
    this.comments.unshift(comment)
    return true
  }

  toggleLike(commentId: string): void {
    const comment = this.comments.find(c => c.id === commentId)
    if (comment) {
      comment.isLiked = !comment.isLiked
      comment.likes = comment.isLiked ? comment.likes + 1 : comment.likes - 1
    }
  }
}

// ==========================================
// 3. 组件 UI
// ==========================================
@Component
export struct CommentSection {
  @Prop productId: string
  @State comments: Comment[] = []
  @State isLoading: boolean = true
  @State currentPage: number = 1
  @State hasMore: boolean = true
  @State showWriteComment: boolean = false
  @State rating: number = 0
  @State commentContent: string = ''
  private commentService: CommentService = CommentService.getInstance()

  aboutToAppear() {
    this.loadComments()
  }

  private loadComments(): void {
    this.isLoading = true
    // 模拟网络延迟
    setTimeout(() => {
      this.comments = this.commentService.getProductComments(this.productId, this.currentPage)
      const totalCount = this.commentService.getProductCommentCount(this.productId)
      this.hasMore = this.comments.length < totalCount
      this.isLoading = false
    }, 500)
  }

  private loadMoreComments(): void {
    if (this.isLoading || !this.hasMore) return

    this.isLoading = true
    setTimeout(() => {
      this.currentPage++
      const moreComments = this.commentService.getProductComments(this.productId, this.currentPage)
      this.comments = [...this.comments, ...moreComments]

      const totalCount = this.commentService.getProductCommentCount(this.productId)
      this.hasMore = this.comments.length < totalCount
      this.isLoading = false
    }, 500)
  }

  private submitComment(): void {
    if (this.rating === 0 || this.commentContent.trim() === '') {
      promptAction.showToast({ message: '请评分并填写评论内容' })
      return
    }

    const newComment = new Comment(
      this.productId,
      'current_user',
      '我', // 当前用户
      this.rating,
      this.commentContent.trim()
    )

    const success = this.commentService.addComment(newComment)
    if (success) {
      this.currentPage = 1
      // 重新加载第一页
      this.comments = this.commentService.getProductComments(this.productId, 1)
      this.showWriteComment = false
      this.rating = 0
      this.commentContent = ''
      promptAction.showToast({ message: '评论发布成功' })
    }
  }

  // 切换点赞状态
  private handleToggleLike(comment: Comment) {
    this.commentService.toggleLike(comment.id)
    // 强制刷新列表状态 (ArkUI State 更新机制)
    const index = this.comments.findIndex(c => c.id === comment.id)
    if (index !== -1) {
      // 创建新对象触发 UI 更新
      let updatedComment = this.comments[index]
      this.comments[index] = new Comment(
        updatedComment.productId,
        updatedComment.userId,
        updatedComment.username,
        updatedComment.rating,
        updatedComment.content,
        updatedComment.images
      )
      // 恢复属性
      this.comments[index].id = updatedComment.id
      this.comments[index].timestamp = updatedComment.timestamp
      this.comments[index].likes = updatedComment.likes
      this.comments[index].isLiked = updatedComment.isLiked
    }
  }

  build() {
    Column() {
      // 评论统计
      Column() {
        Text('商品评价')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .margin({ bottom: 12 })

        Row() {
          Text('⭐ 4.8分')
            .fontSize(16)
            .fontColor($r('app.color.text_primary'))
          Text(`(${this.commentService.getProductCommentCount(this.productId)}条评价)`)
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .margin({ left: 8 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }
      .width('100%')
      .padding(16)
      .backgroundColor($r('app.color.white'))
      .borderRadius(8)
      .margin({ left: 16, right: 16, top: 16, bottom: 8 })

      // 写评论按钮
      Button('写评论')
        .width('90%')
        .height(44)
        .fontSize(16)
        .backgroundColor($r('app.color.primary'))
        .margin({ bottom: 16 })
        .onClick(() => {
          this.showWriteComment = true
        })

      // 评论列表容器
      Column() {
        if (this.comments.length === 0 && !this.isLoading) {
          Column() {
            Text('💬')
              .fontSize(60)
              .margin({ bottom: 16 })
            Text('暂无评论')
              .fontSize(16)
              .fontColor($r('app.color.text_secondary'))
              .margin({ bottom: 8 })
            Text('快来发表第一条评论吧')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
          }
          .width('100%')
          .padding(32)
          .justifyContent(FlexAlign.Center)
        } else {
          List({ space: 8 }) {
            ForEach(this.comments, (comment: Comment) => {
              ListItem() {
                Column() {
                  Row() {
                    Text('👤')
                      .fontSize(40)
                      .margin({ right: 12 })

                    Column() {
                      Row() {
                        Text(comment.username)
                          .fontSize(14)
                          .fontWeight(FontWeight.Medium)
                          .fontColor($r('app.color.text_primary'))

                        Text(comment.getFormattedTime())
                          .fontSize(12)
                          .fontColor($r('app.color.text_secondary'))
                          .margin({ left: 8 })
                      }
                      .width('100%')

                      Row() {
                        ForEach([1, 2, 3, 4, 5], (star: number) => {
                          Text(star <= comment.rating ? '★' : '☆')
                            .fontSize(12)
                            .fontColor(star <= comment.rating ? $r('app.color.primary') : $r('app.color.text_secondary'))
                        })
                      }
                      .width('100%')
                      .margin({ top: 4 })
                    }
                    .layoutWeight(1)
                  }
                  .width('100%')

                  // 评论内容
                  Text(comment.content)
                    .fontSize(14)
                    .fontColor($r('app.color.text_primary'))
                    .lineHeight(20)
                    .width('100%')
                    .margin({ top: 12 })

                  // 评论图片（如果有）
                  if (comment.images && comment.images.length > 0) {
                    Row() {
                      ForEach(comment.images.slice(0, 3), (image: string) => {
                        Image(image)
                          .width(80)
                          .height(80)
                          .borderRadius(4)
                          .objectFit(ImageFit.Cover)
                          .backgroundColor('#F5F5F5') // 占位背景色
                          .margin({ right: 8 })
                      })
                    }
                    .width('100%')
                    .margin({ top: 8 })
                  }

                  // 底部操作栏
                  Row() {
                    Button() {
                      Row() {
                        Text(comment.isLiked ? '❤️' : '🤍')
                          .fontSize(14)
                        Text(comment.likes > 0 ? comment.likes.toString() : '点赞')
                          .fontSize(12)
                          .fontColor($r('app.color.text_secondary'))
                          .margin({ left: 4 })
                      }
                    }
                    .height(28)
                    .backgroundColor(Color.Transparent)
                    .onClick(() => {
                      this.handleToggleLike(comment)
                    })

                    Blank()

                    Text('回复')
                      .fontSize(12)
                      .fontColor($r('app.color.text_secondary'))
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)
                  .alignItems(VerticalAlign.Center)
                  .margin({ top: 8, bottom: 4 })
                }
                .width('100%')
                .padding(16)
                .backgroundColor($r('app.color.white'))
                .borderRadius(8)
                .margin({ left: 16, right: 16, bottom: 12 })
              }
            }, (item: Comment) => item.id) // 添加 Key 生成器优化性能
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Auto)
          .edgeEffect(EdgeEffect.Spring)
          .divider({ strokeWidth: 1, color: '#F0F0F0' })

          // 加载更多按钮
          if (this.hasMore) {
            Button('加载更多')
              .width('100%')
              .height(44)
              .fontSize(14)
              .backgroundColor(Color.Transparent)
              .fontColor($r('app.color.primary'))
              .onClick(() => this.loadMoreComments())
              .margin({ bottom: 20 })
          } else if (this.comments.length > 0) {
            Text('没有更多评论了')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 10, bottom: 20 })
          }
        }
      }
      .width('100%')
      .layoutWeight(1)
      // 设置最小高度，防止内容少时塌陷
      .constraintSize({ minHeight: 300 })

      // 写评论弹窗 (模态层)
      if (this.showWriteComment) {
        Stack() {
          // 遮罩层
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.5)')
            .onClick(() => {
              this.showWriteComment = false
            })

          // 弹窗内容
          Column() {
            Text('写评论')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .textAlign(TextAlign.Center)
              .margin({ bottom: 24 })

            // 评分选择
            Text('评分')
              .fontSize(14)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .margin({ bottom: 12 })

            Row() {
              ForEach([1, 2, 3, 4, 5], (star: number) => {
                Text(star <= this.rating ? '★' : '☆')
                  .fontSize(32)
                  .fontColor(star <= this.rating ? $r('app.color.primary') : $r('app.color.text_secondary'))
                  .margin({ right: 8 })
                  .onClick(() => {
                    this.rating = star
                  })
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .margin({ bottom: 24 })

            // 评论内容
            Text('评论内容')
              .fontSize(14)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .margin({ bottom: 12 })

            TextArea({
              placeholder: '分享您的使用感受...',
              text: this.commentContent
            })
              .width('100%')
              .height(120)
              .fontSize(14)
              .backgroundColor($r('app.color.background'))
              .borderRadius(8)
              .padding(12)
              .onChange((value: string) => {
                this.commentContent = value
              })

            // 按钮
            Row() {
              Button('取消')
                .height(44)
                .fontSize(16)
                .backgroundColor($r('app.color.background'))
                .fontColor($r('app.color.text_primary'))
                .layoutWeight(1)
                .margin({ right: 8 })
                .onClick(() => {
                  this.showWriteComment = false
                })

              Button('提交')
                .height(44)
                .fontSize(16)
                .backgroundColor($r('app.color.primary'))
                .fontColor(Color.White)
                .layoutWeight(1)
                .margin({ left: 8 })
                .onClick(() => {
                  this.submitComment()
                })
            }
            .width('100%')
            .margin({ top: 24 })
          }
          .width('85%')
          .backgroundColor($r('app.color.white'))
          .borderRadius(12)
          .padding(24)
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(999) // 确保在最上层
        .alignContent(Alignment.Center)
      }
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor($r('app.color.background'))
  }
}