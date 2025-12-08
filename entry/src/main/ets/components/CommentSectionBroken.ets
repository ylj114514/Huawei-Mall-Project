import { Comment } from '../model/DataModel'
import { CommentService } from '../services/CommentService'

@Component
export struct CommentSectionSimple {
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

  private async loadComments(): Promise<void> {
    try {
      this.isLoading = true
      this.comments = this.commentService.getProductComments(this.productId, this.currentPage)
      // 检查是否还有更多数据
      const totalCount = this.commentService.getProductCommentCount(this.productId)
      this.hasMore = this.currentPage * 10 < totalCount
      this.isLoading = false
    } catch (error) {
      console.error('加载评论失败:', error)
      this.isLoading = false
    }
  }

  private async loadMoreComments(): Promise<void> {
    if (this.isLoading || !this.hasMore) return

    try {
      this.isLoading = true
      this.currentPage++
      const moreComments = this.commentService.getProductComments(this.productId, this.currentPage)
      this.comments = [...this.comments, ...moreComments]

      const totalCount = this.commentService.getProductCommentCount(this.productId)
      this.hasMore = this.currentPage * 10 < totalCount
      this.isLoading = false
    } catch (error) {
      console.error('加载更多评论失败:', error)
      this.isLoading = false
    }
  }

  private async submitComment(): Promise<void> {
    if (this.rating === 0 || this.commentContent.trim() === '') {
      console.error('请评分并填写评论内容')
      return
    }

    try {
      const newComment = new Comment(
        this.productId,
        'current_user', // 实际项目中应该从用户服务获取
        '当前用户',
        this.rating,
        this.commentContent.trim()
      )

      const success = await this.commentService.addComment(newComment)
      if (success) {
        // 重新加载评论
        this.currentPage = 1
        this.comments = this.commentService.getProductComments(this.productId, this.currentPage)
        this.showWriteComment = false
        this.rating = 0
        this.commentContent = ''
      }
    } catch (error) {
      console.error('提交评论失败:', error)
    }
  }

  build() {
    Column() {
      // 评论统计
      CommentStats({ productId: this.productId })

      // 写评论按钮
      Button('写评论')
        .width('100%')
        .height(44)
        .fontSize(16)
        .backgroundColor($r('app.color.primary'))
        .margin({ left: 16, right: 16, top: 16, bottom: 8 })
        .onClick(() => {
          this.showWriteComment = true
        })

      // 评论列表
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
        List() {
          ForEach(this.comments, (comment: Comment) => {
            ListItem() {
              CommentCard({
                comment: comment,
                onLike: (): void => this.commentService.toggleLike(comment.id, 'current_user')
              })
            }
          })
        }
        .width('100%')
        .layoutWeight(1)

        // 加载更多
        if (this.hasMore) {
          Button('加载更多')
            .width('100%')
            .height(44)
            .fontSize(14)
            .backgroundColor(Color.Transparent)
            .fontColor($r('app.color.primary'))
            .onClick(() => this.loadMoreComments())
        }
      }
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor($r('app.color.background'))

    // 写评论弹窗
    if (this.showWriteComment) {
      WriteCommentDialog({
        visible: this.showWriteComment,
        rating: this.rating,
        content: this.commentContent,
        onRatingChange: (rating: number): void => {
          this.rating = rating
        },
        onContentChange: (content: string): void => {
          this.commentContent = content
        },
        onSubmit: (): void => this.submitComment(),
        onCancel: (): void => {
          this.showWriteComment = false
          this.rating = 0
          this.commentContent = ''
        }
      })
    }
  }
}

// 评论统计组件
@Component
struct CommentStats {
  @Prop productId: string
  private commentService: CommentService = CommentService.getInstance()

  build() {
    Column() {
      Row() {
        Column() {
          Row() {
            Text('⭐')
              .fontSize(20)
            Text('4.8')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
            Text('分')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
          }
          Text('1286条评价')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
        }

        Blank()

        // 评分分布
        Column() {
          ForEach([5, 4, 3, 2, 1], (star: number) => {
            Row() {
              Text(`${star}星`)
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
                .width(30)

              // 进度条
              Progress({
                value: this.getStarPercentage(star),
                total: 100,
                type: ProgressType.Linear
              })
                .width(100)
                .height(6)
                .color($r('app.color.primary'))
                .backgroundColor($r('app.color.background'))

              Text(`${this.getStarCount(star)}`)
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
                .width(30)
                .textAlign(TextAlign.End)
            }
            .width('100%')
            .margin({ bottom: 4 })
          })
        }
        .width(180)
      }
      .width('100%')
      .padding(16)
      .backgroundColor($r('app.color.white'))
      .borderRadius(8)
      .margin(16)
    }
  }

  private getStarCount(star: number): number {
    const result = this.commentService.calculateProductRating(this.productId)
    if (star >= 1 && star <= 5) {
      return result.distribution[star - 1] || 0
    }
    return 0
  }

  private getStarPercentage(star: number): number {
    const totalCount = this.commentService.getProductCommentCount(this.productId)
    if (totalCount === 0) return 0
    const starCount = this.getStarCount(star)
    return Math.round((starCount / totalCount) * 100)
  }
}

// 评论卡片组件
@Component
struct CommentCard {
  @Prop comment: Comment
  onLike: () => void = () => {}

  build() {
    Column() {
      Row() {
        // 用户头像
        Text('👤')
          .fontSize(40)
          .margin({ right: 12 })

        Column() {
          Row() {
            Text(this.comment.username)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))

            if (this.comment.isTopComment) {
              Text('置顶')
                .fontSize(10)
                .fontColor($r('app.color.primary'))
                .backgroundColor($r('app.color.primary_light'))
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .borderRadius(4)
                .margin({ left: 8 })
            }

            Blank()

            Text(this.comment.getFormattedTime())
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
          }
          .width('100%')

          // 评分
          Row() {
            ForEach([1, 2, 3, 4, 5], (star: number) => {
              Text(star <= this.comment.rating ? '★' : '☆')
                .fontSize(12)
                .fontColor(star <= this.comment.rating ? $r('app.color.primary') : $r('app.color.text_secondary'))
            })
          }
          .width('100%')
          .margin({ top: 4 })
        }
        .layoutWeight(1)
      }
      .width('100%')

      // 评论内容
      Text(this.comment.content)
        .fontSize(14)
        .fontColor($r('app.color.text_primary'))
        .lineHeight(20)
        .width('100%')
        .margin({ top: 12 })

      // 底部操作栏
      Row() {
        Button() {
          Row() {
            Text(this.comment.isLiked ? '❤️' : '🤍')
              .fontSize(16)
            Text(this.comment.likes.toString())
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .margin({ left: 4 })
          }
        }
        .height(32)
        .backgroundColor(Color.Transparent)
        .onClick(() => this.onLike())

        Blank()

        Button() {
          Row() {
            Text('💬')
              .fontSize(16)
            Text('回复')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .margin({ left: 4 })
          }
        }
        .height(32)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          // 回复功能
        })
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.white'))
    .borderRadius(8)
    .margin({ left: 16, right: 16, bottom: 8 })
  }
}

// 写评论弹窗组件
@Component
struct WriteCommentDialog {
  @Prop visible: boolean
  @Prop rating: number
  @Prop content: string
  onRatingChange: (rating: number) => void = () => {}
  onContentChange: (content: string) => void = () => {}
  onSubmit: () => void = () => {}
  onCancel: () => void = () => {}

  build() {
    if (this.visible) {
      Column() {
        // 遮罩层
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.5)')
          .onClick(() => this.onCancel())

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
                .onClick(() => this.onRatingChange(star))
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
            text: this.content
          })
            .width('100%')
            .height(120)
            .fontSize(14)
            .backgroundColor($r('app.color.background'))
            .borderRadius(8)
            .padding(12)
            .onChange((value: string) => this.onContentChange(value))

          // 按钮
          Row() {
            Button('取消')
              .height(44)
              .fontSize(16)
              .backgroundColor($r('app.color.background'))
              .fontColor($r('app.color.text_primary'))
              .layoutWeight(1)
              .margin({ right: 8 })
              .onClick(() => this.onCancel())

            Button('提交')
              .height(44)
              .fontSize(16)
              .backgroundColor($r('app.color.primary'))
              .fontColor(Color.White)
              .layoutWeight(1)
              .margin({ left: 8 })
              .onClick(() => this.onSubmit())
          }
          .width('100%')
          .margin({ top: 24 })
        }
        .width(320)
        .backgroundColor($r('app.color.white'))
        .borderRadius(12)
        .padding(24)
        .position({ x: '50%', y: '50%' })
        .translate({ x: '-50%', y: '-50%' })
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
    }
  }
}