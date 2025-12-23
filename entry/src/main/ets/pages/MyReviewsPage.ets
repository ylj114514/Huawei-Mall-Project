import router from '@ohos.router'

// ==========================================
// 1. 定义类模型 (解决严格模式 Object literal 报错)
// ==========================================
class User {
  username: string = ''
}

class Comment {
  id: string = ''
  userId: string = ''
  username: string = ''
  avatar: string | Resource = ''
  productId: string = ''
  content: string = ''
  rating: number = 0
  timestamp: number = 0

  // 辅助方法：格式化时间
  getFormattedTime(): string {
    const date = new Date(this.timestamp)
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')}`
  }
}

// ==========================================
// 2. 本地模拟存储服务 (解决依赖缺失报错)
// ==========================================
class LocalStorageUtils {
  // 模拟获取当前登录用户
  static async loadUser(): Promise<User> {
    return new Promise((resolve) => {
      setTimeout(() => {
        // 必须实例化类
        let user = new User()
        user.username = 'user_001'
        resolve(user)
      }, 500)
    })
  }

  // 模拟获取所有评论数据
  static async loadComments(): Promise<Comment[]> {
    return new Promise((resolve) => {
      setTimeout(() => {
        // 创建评论1
        let c1 = new Comment()
        c1.id = '1'
        c1.userId = 'user_001'
        c1.username = 'user_001'
        c1.productId = '1001'
        c1.content = '手机非常好用，运行流畅，拍照也很清晰！'
        c1.rating = 5
        c1.timestamp = 1709856000000

        // 创建评论2
        let c2 = new Comment()
        c2.id = '2'
        c2.userId = 'user_001'
        c2.username = 'user_001'
        c2.productId = '1002'
        c2.content = '物流很快，但是包装稍微有点破损，希望改进。'
        c2.rating = 4
        c2.timestamp = 1709942400000

        resolve([c1, c2])
      }, 800)
    })
  }

  // 模拟删除评论
  static async deleteComment(commentId: string): Promise<boolean> {
    return new Promise((resolve) => {
      setTimeout(() => {
        console.info(`模拟删除评论: ${commentId}`)
        resolve(true)
      }, 500)
    })
  }
}

// ==========================================
// 3. 页面组件
// ==========================================
@Entry
@Component
struct MyReviewsPage {
  @State userReviews: Comment[] = []
  @State isLoading: boolean = true
  @State currentUserId: string = ''
  @State currentUsername: string = ''

  aboutToAppear() {
    this.loadUserData()
    this.loadUserReviews()
  }

  private async loadUserData(): Promise<void> {
    try {
      const user = await LocalStorageUtils.loadUser()
      if (user) {
        this.currentUserId = user.username
        this.currentUsername = user.username
      } else {
        router.back()
      }
    } catch (error) {
      console.error('加载用户数据失败:', JSON.stringify(error))
    }
  }

  private async loadUserReviews(): Promise<void> {
    try {
      this.isLoading = true
      const allComments = await LocalStorageUtils.loadComments()
      if (allComments) {
        this.userReviews = allComments.filter((comment: Comment) => comment.userId === this.currentUserId)
      }
      this.isLoading = false
    } catch (error) {
      console.error('加载用户评价失败:', JSON.stringify(error))
      this.isLoading = false
    }
  }

  private async deleteReview(reviewId: string): Promise<void> {
    try {
      await LocalStorageUtils.deleteComment(reviewId)
      // 本地移除
      this.userReviews = this.userReviews.filter((item) => item.id !== reviewId)
      console.info('评价删除成功')
    } catch (error) {
      console.error('删除评价失败:', JSON.stringify(error))
    }
  }

  private goToProductDetail(productId: string): void {
    router.pushUrl({
      url: 'pages/ProductDetailPage',
      params: { productId: productId }
    })
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button('←')
          .width(40)
          .height(40)
          .backgroundColor(Color.Transparent)
          .fontColor(Color.White)
          .fontSize(18)
          .onClick(() => {
            router.back()
          })

        Text('我的评价')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .fontColor(Color.White)

        Blank().width(40)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor($r('app.color.primary'))
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      if (this.isLoading) {
        // 加载状态
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
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.background'))
      } else {
        if (this.userReviews.length === 0) {
          // 空状态
          Column() {
            Text('📝')
              .fontSize(60)
              .margin({ bottom: 16 })
            Text('暂无评价')
              .fontSize(16)
              .fontColor($r('app.color.text_secondary'))
              .margin({ bottom: 8 })
            Text('您还没有发表任何商品评价')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
            Button('去购物')
              .height(36)
              .fontSize(14)
              .margin({ top: 16 })
              .backgroundColor($r('app.color.primary'))
              .fontColor(Color.White)
              .onClick(() => {
                router.replaceUrl({ url: 'pages/Index' })
              })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('app.color.background'))
        } else {
          // 评价列表
          Scroll() {
            Column() {
              ForEach(this.userReviews, (review: Comment) => {
                Column() {
                  Row() {
                    Text('👤')
                      .fontSize(40)
                      .margin({ right: 12 })

                    Column() {
                      Row() {
                        Text(review.username)
                          .fontSize(14)
                          .fontWeight(FontWeight.Medium)
                          .fontColor($r('app.color.text_primary'))

                        Text(review.getFormattedTime())
                          .fontSize(12)
                          .fontColor($r('app.color.text_secondary'))
                          .margin({ left: 8 })
                      }
                      .width('100%')

                      Row() {
                        ForEach([1, 2, 3, 4, 5], (star: number) => {
                          Text(star <= review.rating ? '★' : '☆')
                            .fontSize(12)
                            .fontColor(star <= review.rating ? $r('app.color.primary') : $r('app.color.text_secondary'))
                        })
                      }
                      .width('100%')
                      .margin({ top: 4 })
                    }
                    .layoutWeight(1)
                  }
                  .width('100%')

                  // 评价内容
                  Text(review.content)
                    .fontSize(14)
                    .fontColor($r('app.color.text_primary'))
                    .lineHeight(20)
                    .width('100%')
                    .margin({ top: 12 })

                  // 商品信息
                  Row() {
                    Text('🛍️')
                      .fontSize(16)
                      .margin({ right: 8 })
                    Text('商品ID: ' + review.productId)
                      .fontSize(12)
                      .fontColor($r('app.color.text_secondary'))
                    Blank()
                    Button('查看商品')
                      .height(28)
                      .fontSize(12)
                      .backgroundColor($r('app.color.primary'))
                      .fontColor(Color.White)
                      .onClick(() => this.goToProductDetail(review.productId))
                  }
                  .width('100%')
                  .alignItems(VerticalAlign.Center)
                  .margin({ top: 12 })

                  // 底部操作栏
                  Row() {
                    Button('删除评价')
                      .height(32)
                      .fontSize(12)
                      .backgroundColor($r('app.color.error'))
                      .fontColor(Color.White)
                      .onClick(() => {
                        this.deleteReview(review.id)
                      })
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.End)
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
            }
            .width('100%')
            .padding({ top: 16, bottom: 20 })
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Auto)
          .edgeEffect(EdgeEffect.Spring)
          .backgroundColor($r('app.color.background'))
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}