import { Comment } from '../model/DataModel'
import { CommentService } from '../services/CommentService'

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
    this.comments = this.commentService.getProductComments(this.productId, this.currentPage)
    const totalCount = this.commentService.getProductCommentCount(this.productId)
    this.hasMore = this.currentPage * 10 < totalCount
    this.isLoading = false
  }

  private loadMoreComments(): void {
    if (this.isLoading || !this.hasMore) return

    this.isLoading = true
    this.currentPage++
    const moreComments = this.commentService.getProductComments(this.productId, this.currentPage)
    this.comments = [...this.comments, ...moreComments]

    const totalCount = this.commentService.getProductCommentCount(this.productId)
    this.hasMore = this.currentPage * 10 < totalCount
    this.isLoading = false
  }

  private submitComment(): void {
    if (this.rating === 0 || this.commentContent.trim() === '') {
      console.error('请评分并填写评论内容')
      return
    }

    const newComment = new Comment(
      this.productId,
      'current_user',
      '当前用户',
      this.rating,
      this.commentContent.trim()
    )

    const success = this.commentService.addComment(newComment)
    if (success) {
      this.currentPage = 1
      this.comments = this.commentService.getProductComments(this.productId, this.currentPage)
      this.showWriteComment = false
      this.rating = 0
      this.commentContent = ''
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
          Text('(1286条评价)')
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
        .width('100%')
        .height(44)
        .fontSize(16)
        .backgroundColor($r('app.color.primary'))
        .margin({ left: 16, right: 16, top: 8, bottom: 16 })
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
                        .width(60)
                        .height(60)
                        .borderRadius(4)
                        .objectFit(ImageFit.Cover)
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
                      Text(comment.likes.toString())
                        .fontSize(12)
                        .fontColor($r('app.color.text_secondary'))
                        .margin({ left: 4 })
                    }
                  }
                  .height(28)
                  .backgroundColor(Color.Transparent)
                  .onClick(() => {
                    this.commentService.toggleLike(comment.id, 'current_user')
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
          })
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring)
        .divider({ strokeWidth: 1, color: '#F0F0F0' })

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
      .constraintSize({ minHeight: 300 })

      // 写评论弹窗
      if (this.showWriteComment) {
        Column() {
          // 遮罩层
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.5)')
            .onClick(() => {
              this.showWriteComment = false
              this.rating = 0
              this.commentContent = ''
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
                  this.rating = 0
                  this.commentContent = ''
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
    .width('100%')
    .layoutWeight(1)
    .backgroundColor($r('app.color.background'))
  }
}