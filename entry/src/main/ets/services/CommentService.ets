import { Comment } from '../model/DataModel'
import { StorageManager } from '../utils/StorageManager'

// 评分结果接口
interface RatingResult {
  rating: number
  distribution: number[]
}

export class CommentService {
  private static instance: CommentService
  private comments: Comment[] = []
  private storage: StorageManager

  private constructor() {
    this.storage = StorageManager.getInstance()
    this.loadCommentsFromStorage()
    this.initMockData()
  }

  public static getInstance(): CommentService {
    if (!CommentService.instance) {
      CommentService.instance = new CommentService()
    }
    return CommentService.instance
  }

  // 从存储加载评论
  private async loadCommentsFromStorage(): Promise<void> {
    try {
      this.comments = await this.storage.loadComments()
    } catch (error) {
      console.error('加载评论失败:', error)
      this.comments = []
    }
  }

  // 保存评论到存储
  private async saveCommentsToStorage(): Promise<void> {
    try {
      await this.storage.saveComments(this.comments)
    } catch (error) {
      console.error('保存评论失败:', error)
    }
  }

  // 初始化模拟数据
  private initMockData(): void {
    if (this.comments.length === 0) {
      const mockComments = [
        new Comment(
          'huawei-mate60-pro',
          'user001',
          '张三',
          5,
          '非常满意！手机很棒，拍照效果特别好，鸿蒙系统也很流畅。充电速度快，电池续航能力强。'
        ),
        new Comment(
          'huawei-mate60-pro',
          'user002',
          '李四',
          4,
          '整体不错，就是价格稍微有点贵。但是品质确实很好，值得推荐。'
        ),
        new Comment(
          'huawei-p60-pro',
          'user003',
          '王五',
          5,
          '拍照功能太强了！徕卡相机果然名不虚传，夜景拍摄效果特别棒。'
        ),
        new Comment(
          'huawei-p60-pro',
          'user004',
          '赵六',
          3,
          '手机挺好的，但是感觉有点重，拿在手里不太舒服。其他方面都还不错。'
        ),
        new Comment(
          'huawei-watch-gt4',
          'user005',
          '钱七',
          5,
          '运动功能很全面，心率监测准确，续航时间也很长，外观设计很时尚。'
        ),
        new Comment(
          'huawei-watch-gt4',
          'user006',
          '孙八',
          4,
          '功能丰富，就是表带材质一般，不过整体性价比还是很高的。'
        ),
        new Comment(
          'huawei-freebuds-pro-3',
          'user007',
          '周九',
          5,
          '音质很好，降噪效果出色，佩戴舒适，通话清晰，非常满意！'
        ),
        new Comment(
          'huawei-freebuds-pro-3',
          'user008',
          '吴十',
          4,
          '音质不错，就是价格有点小贵。不过降噪效果确实很好。'
        )
      ]
      this.comments = mockComments
      this.saveCommentsToStorage()
    }
  }

  // 获取商品评论
  getProductComments(productId: string, page: number = 1, pageSize: number = 10): Comment[] {
    const productComments = this.comments.filter(comment => comment.productId === productId)
    const startIndex = (page - 1) * pageSize
    const endIndex = startIndex + pageSize
    return productComments.slice(startIndex, endIndex)
  }

  // 获取商品评论总数
  getProductCommentCount(productId: string): number {
    return this.comments.filter(comment => comment.productId === productId).length
  }

  // 添加评论
  addComment(comment: Comment): boolean {
    try {
      this.comments.unshift(comment) // 新评论放在最前面
      this.saveCommentsToStorage()
      return true
    } catch (error) {
      console.error('添加评论失败:', error)
      return false
    }
  }

  // 删除评论
  deleteComment(commentId: string): boolean {
    try {
      const index = this.comments.findIndex(comment => comment.id === commentId)
      if (index > -1) {
        this.comments.splice(index, 1)
        this.saveCommentsToStorage()
        return true
      }
      return false
    } catch (error) {
      console.error('删除评论失败:', error)
      return false
    }
  }

  // 点赞评论
  toggleLike(commentId: string, userId: string): boolean {
    try {
      const comment = this.comments.find(c => c.id === commentId)
      if (comment) {
        comment.toggleLike(userId)
        this.saveCommentsToStorage()
        return true
      }
      return false
    } catch (error) {
      console.error('点赞评论失败:', error)
      return false
    }
  }

  // 获取商品评分统计
  getProductRating(productId: string): RatingResult {
    const productComments = this.comments.filter(comment => comment.productId === productId)

    if (productComments.length === 0) {
      return {
        rating: 0,
        distribution: [0, 0, 0, 0, 0]
      }
    }

    const totalRating = productComments.reduce((sum, comment) => sum + comment.rating, 0)
    const averageRating = totalRating / productComments.length

    // 统计各星级分布
    const distribution = [0, 0, 0, 0, 0]
    productComments.forEach(comment => {
      distribution[comment.rating - 1]++
    })

    return {
      rating: Math.round(averageRating * 10) / 10, // 保留一位小数
      distribution: distribution
    }
  }

  // 获取所有评论
  getAllComments(): Comment[] {
    return [...this.comments]
  }

  // 按用户获取评论
  getUserComments(userId: string): Comment[] {
    return this.comments.filter(comment => comment.userId === userId)
  }

  // 搜索评论
  searchComments(query: string): Comment[] {
    const lowerQuery = query.toLowerCase()
    return this.comments.filter(comment =>
      comment.content.toLowerCase().includes(lowerQuery) ||
      comment.username.toLowerCase().includes(lowerQuery) ||
      comment.productId.toLowerCase().includes(lowerQuery)
    )
  }

  // 获取热门评论（点赞数最多的）
  getPopularComments(limit: number = 5): Comment[] {
    return [...this.comments]
      .sort((a, b) => b.likes - a.likes)
      .slice(0, limit)
  }
}