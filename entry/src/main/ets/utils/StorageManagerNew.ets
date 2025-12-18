import { User } from '../model/DataModel'
import { DatabaseManager } from './DatabaseManager'
import common from '@ohos.app.ability.common'
import { CartItem } from '../model/CartModel'

/**
 * 存储管理器 - 统一的存储接口，内部使用DatabaseManager
 */
export class StorageManager {
  private static instance: StorageManager
  private dbManager: DatabaseManager = DatabaseManager.getInstance()
  private context: common.UIAbilityContext | null = null
  private currentUser: User | null = null

  private constructor() {}

  public static getInstance(): StorageManager {
    if (!StorageManager.instance) {
      StorageManager.instance = new StorageManager()
    }
    return StorageManager.instance
  }

  /**
   * 初始化存储
   */
  public async init(context: common.UIAbilityContext): Promise<void> {
    try {
      this.context = context
      await this.dbManager.init(context)
      console.log('StorageManager初始化成功')
    } catch (error) {
      console.error('StorageManager初始化失败:', error)
      throw error
    }
  }

  // =================== 用户管理 ===================

  /**
   * 保存用户信息
   */
  public async saveUser(user: User | null): Promise<void> {
    try {
      if (user) {
        await this.dbManager.saveUser(user)
        this.currentUser = user
        this.dbManager.setCurrentUserId(user.account)
        console.log('用户保存成功:', user.username)
      } else {
        this.currentUser = null
        this.dbManager.setCurrentUserId('')
        console.log('用户已清除')
      }
    } catch (error) {
      console.error('保存用户失败:', error)
      throw error
    }
  }

  /**
   * 加载当前用户信息
   */
  public async loadUser(): Promise<User | null> {
    try {
      if (this.currentUser) {
        return this.currentUser
      }

      // 从Preferences加载最后登录的用户
      // 这里简化处理，实际应用中可以保存最后登录用户
      return null
    } catch (error) {
      console.error('加载用户失败:', error)
      return null
    }
  }

  /**
   * 查找用户
   */
  public async findUserByAccount(account: string): Promise<User | null> {
    try {
      return await this.dbManager.findUserByAccount(account)
    } catch (error) {
      console.error('查找用户失败:', error)
      return null
    }
  }

  /**
   * 清除当前用户
   */
  public async clearCurrentUser(): Promise<void> {
    this.currentUser = null
    this.dbManager.setCurrentUserId('')
    console.log('当前用户已清除')
  }

  // =================== 购物车管理 ===================

  /**
   * 添加到购物车
   */
  public async addToCart(product: any, quantity?: number): Promise<void> {
    try {
      if (this.currentUser) {
        await this.dbManager.addToCart(product, quantity)
      }
    } catch (error) {
      console.error('添加到购物车失败:', error)
      throw error
    }
  }

  /**
   * 获取购物车列表
   */
  public async loadCart(): Promise<CartItem[]> {
    try {
      return await this.dbManager.getCartItems()
    } catch (error) {
      console.error('加载购物车失败:', error)
      return []
    }
  }

  /**
   * 更新购物车项
   */
  public async updateCartItem(id: number, quantity: number): Promise<void> {
    try {
      await this.dbManager.updateCartItem(id, quantity)
    } catch (error) {
      console.error('更新购物车失败:', error)
    }
  }

  /**
   * 删除购物车项
   */
  public async removeCartItem(id: number): Promise<void> {
    try {
      await this.dbManager.removeCartItem(id)
    } catch (error) {
      console.error('删除购物车项失败:', error)
    }
  }

  /**
   * 清空购物车
   */
  public async clearCart(): Promise<void> {
    try {
      await this.dbManager.clearCart()
    } catch (error) {
      console.error('清空购物车失败:', error)
    }
  }

  // =================== 订单管理 ===================

  /**
   * 创建订单
   */
  public async createOrder(order: any, orderItems: any[]): Promise<void> {
    try {
      await this.dbManager.createOrder(order, orderItems)
    } catch (error) {
      console.error('创建订单失败:', error)
      throw error
    }
  }

  /**
   * 获取用户订单
   */
  public async getUserOrders(): Promise<any[]> {
    try {
      return await this.dbManager.getUserOrders()
    } catch (error) {
      console.error('获取订单失败:', error)
      return []
    }
  }

  // =================== 评论管理 ===================

  /**
   * 添加评论
   */
  public async addComment(comment: any): Promise<void> {
    try {
      // 添加用户信息
      if (this.currentUser) {
        comment.userId = this.currentUser.account
        comment.userName = this.currentUser.username
        comment.userAvatar = this.currentUser.avatar || ''
      }
      await this.dbManager.addComment(comment)
    } catch (error) {
      console.error('添加评论失败:', error)
      throw error
    }
  }

  /**
   * 获取商品评论
   */
  public async getProductComments(productId: string): Promise<any[]> {
    try {
      return await this.dbManager.getProductComments(productId)
    } catch (error) {
      console.error('获取评论失败:', error)
      return []
    }
  }

  /**
   * 点赞评论
   */
  public async likeComment(commentId: string): Promise<void> {
    try {
      await this.dbManager.likeComment(commentId)
    } catch (error) {
      console.error('点赞评论失败:', error)
    }
  }

  // =================== 收藏管理 ===================

  /**
   * 添加到收藏（已废弃，由购物车功能替代）
   */
  public async addToFavorites(productId: string): Promise<void> {
    console.log('收藏功能已整合到购物车中')
  }

  /**
   * 从收藏中移除
   */
  public async removeFromFavorites(productId: string): Promise<void> {
    console.log('收藏功能已整合到购物车中')
  }

  /**
   * 检查是否已收藏
   */
  public async isFavorite(productId: string): Promise<boolean> {
    console.log('收藏功能已整合到购物车中')
    return false
  }

  /**
   * 获取收藏列表
   */
  public async getFavorites(): Promise<string[]> {
    console.log('收藏功能已整合到购物车中')
    return []
  }

  // =================== 地址管理 ===================

  /**
   * 保存地址
   */
  public async saveAddress(address: any): Promise<void> {
    try {
      await this.dbManager.saveAddress(address)
    } catch (error) {
      console.error('保存地址失败:', error)
      throw error
    }
  }

  /**
   * 获取地址列表
   */
  public async getAddresses(): Promise<any[]> {
    try {
      return await this.dbManager.getAddresses()
    } catch (error) {
      console.error('获取地址失败:', error)
      return []
    }
  }

  /**
   * 删除地址
   */
  public async deleteAddress(id: number): Promise<void> {
    try {
      await this.dbManager.deleteAddress(id)
    } catch (error) {
      console.error('删除地址失败:', error)
    }
  }

  // =================== 数据清理 ===================

  /**
   * 清除用户所有数据
   */
  public async clearUserData(): Promise<void> {
    try {
      await this.dbManager.clearUserData()
    } catch (error) {
      console.error('清除用户数据失败:', error)
    }
  }

  /**
   * 关闭数据库连接
   */
  public async close(): Promise<void> {
    try {
      await this.dbManager.close()
    } catch (error) {
      console.error('关闭数据库失败:', error)
    }
  }
}