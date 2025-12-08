import router from '@ohos.router'
import { Comment } from '../model/DataModel'
import { StorageManager } from '../utils/StorageManager'

@Entry
@Component
struct MyReviewsPage {
  @State userReviews: Comment[] = []
  @State isLoading: boolean = true
  @State currentUserId: string = ''
  @State currentUsername: string = ''
  private storage: StorageManager = StorageManager.getInstance()

  aboutToAppear() {
    this.loadUserData()
    this.loadUserReviews()
  }

  private async loadUserData(): Promise<void> {
    try {
      const user = await this.storage.loadUser()
      if (user) {
        this.currentUserId = user.username
        this.currentUsername = user.username
      } else {
        // 没有用户数据，返回上一页
        router.back()
      }
    } catch (error) {
      console.error('加载用户数据失败:', error)
    }
  }

  private async loadUserReviews(): Promise<void> {
    try {
      this.isLoading = true
      const allComments = await this.storage.loadComments()
      this.userReviews = allComments.filter(comment => comment.userId === this.currentUserId)
      this.isLoading = false
    } catch (error) {
      console.error('加载用户评价失败:', error)
      this.isLoading = false
    }
  }

  private async deleteReview(reviewId: string): Promise<void> {
    try {
      // 从存储中删除
      const allComments = await this.storage.loadComments()
      const filteredComments = allComments.filter(comment => comment.id !== reviewId)
      await this.storage.saveComments(filteredComments)

      // 重新加载评价
      await this.loadUserReviews()

      console.log('评价删除成功')
    } catch (error) {
      console.error('删除评价失败:', error)
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