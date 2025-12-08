import { Comment } from '../model/DataModel'
import { CommentService } from '../services/CommentService'
import { StorageManager } from '../utils/StorageManager'

@Component
export struct CommentSectionNew {
  @Prop productId: string
  @State comments: Comment[] = []
  @State isLoading: boolean = true
  @State currentPage: number = 1
  @State hasMore: boolean = true
  @State showWriteComment: boolean = false
  @State rating: number = 0
  @State commentContent: string = ''
  @State currentUserId: string = ''
  @State currentUsername: string = ''
  @State showReplyDialog: boolean = false
  @State replyingToComment: Comment | null = null
  @State replyContent: string = ''
  private commentService: CommentService = CommentService.getInstance()
  private storage: StorageManager = StorageManager.getInstance()

  aboutToAppear() {
    this.loadCurrentUser()
    this.loadComments()
  }

  private async loadCurrentUser(): Promise<void> {
    try {
      const user = await this.storage.loadUser()
      if (user) {
        this.currentUserId = user.username
        this.currentUsername = user.username
      } else {
        // 没有用户数据，使用默认值
        this.currentUserId = 'current_user'
        this.currentUsername = '当前用户'
      }
    } catch (error) {
      console.error('加载当前用户失败:', error)
      // 使用默认值作为当前用户
      this.currentUserId = 'current_user'
      this.currentUsername = '当前用户'
    }
  }

  private async loadComments(): Promise<void> {
    this.isLoading = true
    try {
      // 总是优先从存储加载评论
      const savedComments = await this.storage.loadComments()
      const filteredComments = savedComments.filter(comment => comment.productId === this.productId)

      console.log('加载评论 - 存储中的评论数量:', filteredComments.length, '商品ID:', this.productId)

      // 如果存储中有评论，就使用存储的
      if (filteredComments.length > 0) {
        this.comments = filteredComments
        console.log('使用存储的评论:', this.comments.length, '条')
      } else {
        // 只有存储中没有评论时，才使用模拟数据
        this.comments = this.commentService.getProductComments(this.productId, this.currentPage)
        console.log('使用模拟数据评论:', this.comments.length, '条')
      }

      const totalCount = this.comments.length
      this.hasMore = false // 存储的评论不分页，所以没有更多
    } catch (error) {
      console.error('加载评论失败:', error)
      // 使用模拟数据作为后备
      this.comments = this.commentService.getProductComments(this.productId, this.currentPage)
    }
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

  private async submitComment(): Promise<void> {
    if (this.rating === 0 || this.commentContent.trim() === '') {
      console.error('请评分并填写评论内容')
      return
    }

    try {
      console.log('开始提交评论...')

      const newComment = new Comment(
        this.productId,
        this.currentUserId,
        this.currentUsername,
        this.rating,
        this.commentContent.trim()
      )

      // 直接保存到存储，不使用commentService
      const allComments = await this.storage.loadComments()
      allComments.push(newComment)
      await this.storage.saveComments(allComments)

      console.log('评论已保存到存储')

      // 重新加载评论
      await this.loadComments()

      // 关闭弹窗和重置表单
      this.showWriteComment = false
      this.rating = 0
      this.commentContent = ''
      console.log('评论发表成功，弹窗已关闭')
    } catch (error) {
      console.error('发表评论失败:', error)
    }
  }

  private async deleteComment(commentId: string): Promise<void> {
    try {
      // 从评论服务中删除
      this.commentService.deleteComment(commentId)

      // 从存储中删除
      const allComments = await this.storage.loadComments()
      const filteredComments = allComments.filter(comment => comment.id !== commentId)
      await this.storage.saveComments(filteredComments)

      // 重新加载评论
      await this.loadComments()

      console.log('评论删除成功')
    } catch (error) {
      console.error('删除评论失败:', error)
    }
  }

  // 显示回复对话框
  private openReplyDialog(comment: Comment): void {
    this.replyingToComment = comment
    this.replyContent = ''
    this.showReplyDialog = true
  }

  // 关闭回复对话框
  private closeReplyDialog(): void {
    this.showReplyDialog = false
    this.replyingToComment = null
    this.replyContent = ''
  }

  // 提交回复
  private async submitReply(): Promise<void> {
    if (!this.replyContent.trim() || !this.replyingToComment) {
      console.error('请输入回复内容')
      return
    }

    try {
      // 创建回复评论
      const replyComment = new Comment(
        this.productId,
        this.currentUserId,
        this.currentUsername,
        5, // 回复默认给5星
        `回复 ${this.replyingToComment.username}: ${this.replyContent.trim()}`
      )

      // 保存到存储
      const allComments = await this.storage.loadComments()
      allComments.push(replyComment)
      await this.storage.saveComments(allComments)

      // 重新加载评论
      await this.loadComments()
      this.closeReplyDialog()
      console.log('回复发表成功')
    } catch (error) {
      console.error('回复发表失败:', error)
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

      // 评论列表 - 使用Scroll确保可以滚动
      Scroll() {
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
            // 评论列表
            Column() {
              ForEach(this.comments, (comment: Comment) => {
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
                      this.commentService.toggleLike(comment.id, this.currentUserId)
                    })

                    Blank()

                    // 删除按钮 - 只对当前用户自己的评论显示
                    if (comment.userId === this.currentUserId) {
                      Button('删除')
                        .height(28)
                        .fontSize(12)
                        .backgroundColor($r('app.color.error'))
                        .fontColor(Color.White)
                        .margin({ right: 8 })
                        .onClick(() => {
                          this.deleteComment(comment.id)
                        })
                    }

                    Button('回复')
                      .height(32)
                      .fontSize(12)
                      .backgroundColor($r('app.color.primary'))
                      .fontColor(Color.White)
                      .borderRadius(16)
                      .onClick(() => {
                        console.log('点击回复评论:', comment.id)
                        // 简单的回复功能示例
                        this.openReplyDialog(comment)
                      })
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)
                  .alignItems(VerticalAlign.Center)
                  .margin({ top: 8, bottom: 12 })
                }
                .width('100%')
                .padding(16)
                .backgroundColor($r('app.color.white'))
                .borderRadius(8)
                .margin({ left: 16, right: 16, bottom: 12 })
                .border({
                  width: 1,
                  color: '#F0F0F0'
                })
              })

              // 加载更多按钮
              if (this.hasMore) {
                Button('加载更多')
                  .width('100%')
                  .height(44)
                  .fontSize(14)
                  .backgroundColor(Color.Transparent)
                  .fontColor($r('app.color.primary'))
                  .margin({ left: 16, right: 16, bottom: 20 })
                  .onClick(() => this.loadMoreComments())
              }
            }
            .width('100%')
            .padding({ bottom: 20 })
          }

          if (this.isLoading) {
            LoadingProgress()
              .width(40)
              .height(40)
            Text('加载中...')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ top: 16 })
          }
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)

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
                Button() {
                  Text(star <= this.rating ? '★' : '☆')
                    .fontSize(32)
                    .fontColor(star <= this.rating ? $r('app.color.primary') : $r('app.color.text_secondary'))
                }
                .backgroundColor(Color.Transparent)
                .onClick(() => {
                  this.rating = star
                })
                .margin({ right: 8 })
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
                console.log('评论内容变化:', value)
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

      // 回复对话框
      if (this.showReplyDialog && this.replyingToComment) {
        Column() {
          // 遮罩层
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.5)')
            .onClick(() => {
              this.closeReplyDialog()
            })

          // 弹窗内容
          Column() {
            Text('回复评论')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .textAlign(TextAlign.Center)
              .margin({ bottom: 16 })

            // 被回复的评论信息
            Column() {
              Text(`回复 ${this.replyingToComment.username}`)
                .fontSize(14)
                .fontColor($r('app.color.text_secondary'))
                .width('100%')
                .margin({ bottom: 8 })

              Text(this.replyingToComment.content)
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
                .width('100%')
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .backgroundColor($r('app.color.background'))
                .padding(8)
                .borderRadius(4)
            }
            .width('100%')
            .margin({ bottom: 16 })

            // 回复内容输入
            TextArea({
              placeholder: '请输入您的回复...',
              text: this.replyContent
            })
              .width('100%')
              .height(100)
              .fontSize(14)
              .backgroundColor($r('app.color.background'))
              .borderRadius(8)
              .padding(12)
              .onChange((value: string) => {
                this.replyContent = value
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
                  this.closeReplyDialog()
                })

              Button('回复')
                .height(44)
                .fontSize(16)
                .backgroundColor($r('app.color.primary'))
                .fontColor(Color.White)
                .layoutWeight(1)
                .margin({ left: 8 })
                .onClick(() => {
                  this.submitReply()
                })
            }
            .width('100%')
            .margin({ top: 16 })
          }
          .width(300)
          .backgroundColor($r('app.color.white'))
          .borderRadius(12)
          .padding(24)
          .position({ x: '50%', y: '50%' })
          .translate({ x: '-50%', y: '-50%' })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(1000)
      }
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor($r('app.color.background'))
  }
}