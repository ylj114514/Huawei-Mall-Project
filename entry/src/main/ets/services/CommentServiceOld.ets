import { Comment, User } from '../model/DataModel'
import { StorageManager } from '../utils/StorageManager'

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
        new Comment('1', 'user1', '张三', 5, '质量非常好，物流很快，商品包装精美，物超所值！'),
        new Comment('1', 'user2', '李四', 4, '产品不错，功能齐全，就是价格稍微有点贵'),
        new Comment('1', 'user3', '王五', 5, '华为的品质没得说，用了半个月了，非常满意'),
        new Comment('2', 'user4', '赵六', 4, '外观很漂亮，功能强大，续航能力强，推荐购买'),
        new Comment('2', 'user5', '孙七', 5, '给父亲买的，他很喜欢，操作简单，功能实用'),
      ]

      // 设置创建时间
      const now = Date.now()
      mockComments.forEach((comment, index) => {
        comment.createTime = now - (index * 86400000) // 每条评论间隔一天
      })

      this.comments = mockComments
      this.saveCommentsToStorage()
    }
  }

  // 获取商品评论
  getProductComments(productId: string, page: number = 1, pageSize: number = 10): Comment[] {
    const productComments = this.comments
      .filter(comment => comment.productId === productId)
      .sort((a, b) => {
        // 置顶评论优先
        if (a.isTopComment && !b.isTopComment) return -1
        if (!a.isTopComment && b.isTopComment) return 1
        // 按时间倒序
        return b.createTime - a.createTime
      })

    const start = (page - 1) * pageSize
    const end = start + pageSize
    return productComments.slice(start, end)
  }

  // 获取商品评论总数
  getProductCommentCount(productId: string): number {
    return this.comments.filter(comment => comment.productId === productId).length
  }

  // 添加评论
  async addComment(comment: Comment): Promise<boolean> {
    try {
      this.comments.push(comment)
      await this.saveCommentsToStorage()
      return true
    } catch (error) {
      console.error('添加评论失败:', error)
      return false
    }
  }

  // 点赞/取消点赞
  async toggleLike(commentId: string, userId: string): Promise<boolean> {
    try {
      const comment = this.comments.find(c => c.id === commentId)
      if (comment && comment.userId !== userId) {
        comment.like()
        await this.saveCommentsToStorage()
        return true
      }
      return false
    } catch (error) {
      console.error('点赞失败:', error)
      return false
    }
  }

  // 删除评论（仅用户本人或管理员）
  async deleteComment(commentId: string, userId: string): Promise<boolean> {
    try {
      const index = this.comments.findIndex(c => c.id === commentId && c.userId === userId)
      if (index > -1) {
        this.comments.splice(index, 1)
        await this.saveCommentsToStorage()
        return true
      }
      return false
    } catch (error) {
      console.error('删除评论失败:', error)
      return false
    }
  }

  // 获取用户评论
  getUserComments(userId: string, page: number = 1, pageSize: number = 10): Comment[] {
    const userComments = this.comments
      .filter(comment => comment.userId === userId)
      .sort((a, b) => b.createTime - a.createTime)

    const start = (page - 1) * pageSize
    const end = start + pageSize
    return userComments.slice(start, end)
  }

  // 评分结果接口
interface RatingResult {
  rating: number
  distribution: number[]
}

// 计算商品评分
  calculateProductRating(productId: string): RatingResult {
    const productComments = this.comments.filter(comment => comment.productId === productId)

    if (productComments.length === 0) {
      return { rating: 0, distribution: [0, 0, 0, 0, 0] }
    }

    const totalRating = productComments.reduce((sum, comment) => sum + comment.rating, 0)
    const averageRating = totalRating / productComments.length

    // 统计评分分布（1-5星）
    const distribution = [0, 0, 0, 0, 0]
    productComments.forEach(comment => {
      if (comment.rating >= 1 && comment.rating <= 5) {
        distribution[comment.rating - 1]++
      }
    })

    return {
      rating: Math.round(averageRating * 10) / 10,
      distribution
    }
  }

  // 获取热门关键词
  getHotKeywords(productId: string, limit: number = 10): string[] {
    const productComments = this.comments.filter(comment => comment.productId === productId)
    const wordCount = new Map<string, number>()

    productComments.forEach(comment => {
      // 简单的分词逻辑（实际项目中可以使用更复杂的分词算法）
      const words = comment.content.split(/[\s，。！？；：]+/)
      words.forEach(word => {
        if (word.length >= 2) { // 只统计长度>=2的词
          wordCount.set(word, (wordCount.get(word) || 0) + 1)
        }
      })
    })

    // 排序并返回热门词
    return Array.from(wordCount.entries())
      .sort((a, b) => b[1] - a[1])
      .slice(0, limit)
      .map(entry => entry[0])
  }

  // 搜索评论
  searchComments(productId: string, keyword: string, page: number = 1, pageSize: number = 10): Comment[] {
    const productComments = this.comments
      .filter(comment =>
        comment.productId === productId &&
        (comment.content.includes(keyword) || comment.username.includes(keyword))
      )
      .sort((a, b) => b.createTime - a.createTime)

    const start = (page - 1) * pageSize
    const end = start + pageSize
    return productComments.slice(start, end)
  }
}