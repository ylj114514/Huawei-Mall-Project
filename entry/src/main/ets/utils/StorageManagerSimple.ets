import { User } from '../model/DataModel'
import { CartItem } from '../model/CartModel'
import { ProductModel } from '../model/ProductModel'
import { CommentData, AddressData } from '../model/CommentModels'
import common from '@ohos.app.ability.common'

// 定义数据接口
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

interface IAddress {
  id: number
  userId: string
  name: string
  phone: string
  province: string
  city: string
  district: string
  detail: string
  isDefault: boolean
}

/**
 * 简单的存储管理器 - 使用内存模拟
 */
export class StorageManager {
  private static instance: StorageManager
  private currentUser: User | null = null
  private context: common.UIAbilityContext | null = null

  // 内存数据存储（实际应用中应使用数据库）
  private users: User[] = []
  private cartItems: CartItem[] = []
  private comments: IComment[] = []
  private addresses: IAddress[] = []

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
      console.log('StorageManager初始化成功')
    } catch (err) {
      console.error('StorageManager初始化失败:', err)
      throw new Error('StorageManager初始化失败')
    }
  }

  // =================== 用户管理 ===================

  /**
   * 保存用户信息
   */
  public async saveUser(user: User | null): Promise<void> {
    try {
      if (user) {
        // 检查是否已存在
        const existingIndex = this.users.findIndex(u => u.account === user.account)
        if (existingIndex >= 0) {
          this.users[existingIndex] = user
        } else {
          this.users.push(user)
        }
        this.currentUser = user
        console.log('用户保存成功:', user.username)
      } else {
        this.currentUser = null
        console.log('用户已清除')
      }
    } catch (err) {
      console.error('保存用户失败:', err)
      throw new Error('保存用户失败')
    }
  }

  /**
   * 加载当前用户信息
   */
  public async loadUser(): Promise<User | null> {
    try {
      return this.currentUser
    } catch (err) {
      console.error('加载用户失败:', err)
      return null
    }
  }

  /**
   * 查找用户
   */
  public async findUserByAccount(account: string): Promise<User | null> {
    try {
      return this.users.find(u => u.account === account) || null
    } catch (err) {
      console.error('查找用户失败:', err)
      return null
    }
  }

  // =================== 购物车管理 ===================

  /**
   * 添加到购物车
   */
  public async addToCart(product: ProductModel, quantity?: number, spec?: string): Promise<void> {
    try {
      if (!this.currentUser) return

      const existingItem = this.cartItems.find(item =>
        item.productId === product.id && item.spec === spec
      )

      if (existingItem) {
        existingItem.quantity = quantity || 1
      } else {
        const newItem = new CartItem(product.id, quantity || 1, spec || '')
        newItem.id = Date.now()
        newItem.price = product.price
        this.cartItems.push(newItem)
      }

      console.log('添加到购物车成功')
    } catch (err) {
      console.error('添加到购物车失败:', err)
      throw new Error('添加到购物车失败')
    }
  }

  /**
   * 获取购物车列表
   */
  public async loadCart(): Promise<CartItem[]> {
    try {
      return this.cartItems
    } catch (err) {
      console.error('加载购物车失败:', err)
      return []
    }
  }

  /**
   * 更新购物车项
   */
  public async updateCartItem(id: number, quantity: number): Promise<void> {
    try {
      const item = this.cartItems.find(item => item.id === id)
      if (item) {
        item.quantity = quantity
      }
    } catch (err) {
      console.error('更新购物车失败:', err)
    }
  }

  /**
   * 删除购物车项
   */
  public async removeCartItem(id: number): Promise<void> {
    try {
      this.cartItems = this.cartItems.filter(item => item.id !== id)
    } catch (err) {
      console.error('删除购物车项失败:', err)
    }
  }

  /**
   * 清空购物车
   */
  public async clearCart(): Promise<void> {
    try {
      this.cartItems = []
    } catch (err) {
      console.error('清空购物车失败:', err)
    }
  }

  // =================== 评论管理 ===================

  /**
   * 添加评论
   */
  public async addComment(commentData: CommentData): Promise<void> {
    try {
      if (!this.currentUser) return

      const newComment: IComment = {
        id: Date.now(),
        productId: commentData.productId,
        userId: this.currentUser.account,
        userName: this.currentUser.username,
        userAvatar: '',
        rating: commentData.rating,
        content: commentData.content,
        images: commentData.images,
        helpfulCount: 0,
        spec: commentData.spec,
        createTime: new Date().toISOString()
      }

      this.comments.unshift(newComment)
      console.log('添加评论成功')
    } catch (err) {
      console.error('添加评论失败:', err)
      throw new Error('添加评论失败')
    }
  }

  /**
   * 获取商品评论
   */
  public async getProductComments(productId: string): Promise<IComment[]> {
    try {
      return this.comments.filter(comment => comment.productId === productId)
    } catch (err) {
      console.error('获取评论失败:', err)
      return []
    }
  }

  /**
   * 点赞评论
   */
  public async likeComment(commentId: string): Promise<void> {
    try {
      const comment = this.comments.find(c => c.id.toString() === commentId)
      if (comment) {
        comment.helpfulCount++
      }
    } catch (err) {
      console.error('点赞评论失败:', err)
    }
  }

  // =================== 地址管理 ===================

  /**
   * 保存地址
   */
  public async saveAddress(addressData: AddressData): Promise<void> {
    try {
      if (!this.currentUser) return

      const newAddress: IAddress = {
        id: Date.now(),
        userId: this.currentUser.account,
        name: addressData.name,
        phone: addressData.phone,
        province: addressData.province,
        city: addressData.city,
        district: addressData.district,
        detail: addressData.detail,
        isDefault: addressData.isDefault
      }

      this.addresses.push(newAddress)
      console.log('保存地址成功')
    } catch (err) {
      console.error('保存地址失败:', err)
      throw new Error('保存地址失败')
    }
  }

  /**
   * 获取地址列表
   */
  public async getAddresses(): Promise<IAddress[]> {
    try {
      if (!this.currentUser) return []
      return this.addresses.filter(addr => addr.userId === this.currentUser!.account)
    } catch (err) {
      console.error('获取地址失败:', err)
      return []
    }
  }

  /**
   * 删除地址
   */
  public async deleteAddress(id: number): Promise<void> {
    try {
      this.addresses = this.addresses.filter(addr => addr.id !== id)
    } catch (err) {
      console.error('删除地址失败:', err)
    }
  }

  // =================== 数据清理 ===================

  /**
   * 清除用户所有数据
   */
  public async clearUserData(): Promise<void> {
    try {
      this.cartItems = []
      this.comments = this.comments.filter(c => c.userId !== this.currentUser?.account)
      this.addresses = this.addresses.filter(a => a.userId !== this.currentUser?.account)
      console.log('清除用户数据成功')
    } catch (err) {
      console.error('清除用户数据失败:', err)
    }
  }

  /**
   * 关闭存储
   */
  public async close(): Promise<void> {
    try {
      console.log('存储管理器已关闭')
    } catch (err) {
      console.error('关闭存储失败:', err)
    }
  }
}