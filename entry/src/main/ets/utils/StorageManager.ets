import { CartItem, Comment, User, FavoriteItem, Address } from '../model/DataModel'
import { ProductModel } from '../model/ProductModel'
import dataStorage from '@ohos.data.preferences'
import Context from '@ohos.app.ability.common'

// 数据接口定义
interface AppSettings {
  theme?: string
  language?: string
  notifications?: boolean
}

interface BackupData {
  user: User | null
  cart: CartItem[]
  favorites: FavoriteItem[]
  comments: Comment[]
  addresses: Address[]
  searchHistory: string[]
  settings: AppSettings
  backupTime: number
}

interface StorageStats {
  user: number
  cart: number
  favorites: number
  comments: number
  addresses: number
  searchHistory: number
  settings: number
}

interface CartStorageItem {
  productId: string
  quantity: number
  selected: boolean
  addedTime: number
}

interface FavoriteStorageItem {
  productId: string
  addedTime: number
}

interface CommentStorageItem {
  id: string
  productId: string
  userId: string
  username: string
  rating: number
  content: string
  images: string[]
  likes: number
  isLiked: boolean
  createTime: number
}

interface AddressStorageItem {
  id: string
  name: string
  phone: string
  province: string
  city: string
  district: string
  detail: string
  isDefault: boolean
}

interface UserStorageItem {
  id: string
  account: string
  password: string
  username: string
  phone: string
  points: number
  level: 'bronze' | 'silver' | 'gold' | 'platinum'
  registrationTime: number
  lastLoginTime: number
  totalSpent: number
}

/**
 * HarmonyOS本地数据存储管理器
 * 使用preferences数据库实现数据持久化
 */
export class StorageManager {
  private static instance: StorageManager
  private preferences: dataStorage.Preferences | null = null
  private context: Context | null = null
  private readonly STORE_NAME = 'mall_app_data'

  private constructor() {}

  public static getInstance(): StorageManager {
    if (!StorageManager.instance) {
      StorageManager.instance = new StorageManager()
    }
    return StorageManager.instance
  }

  /**
   * 初始化数据库连接
   */
  public async init(context: Context): Promise<void> {
    try {
      this.context = context
      this.preferences = await dataStorage.getPreferences(context, this.STORE_NAME)
      console.log('StorageManager初始化成功')
    } catch (error) {
      console.error('StorageManager初始化失败:', error)
      throw new Error('StorageManager初始化失败')
    }
  }

  /**
   * 确保数据库已初始化
   */
  private ensureInitialized(): void {
    if (!this.preferences) {
      throw new Error('StorageManager未初始化，请先调用init()方法')
    }
  }

  // =================== 用户信息管理 ===================

  /**
   * 保存用户信息（支持多用户）
   */
  public async saveUser(user: User | null): Promise<void> {
    this.ensureInitialized()
    try {
      if (user) {
        console.log('StorageManager: 开始保存用户', user.account)
        // 将用户保存到用户列表中
        await this.addUserToList(user)
        // 同时设置为当前登录用户
        const userJson = JSON.stringify({
          id: user.id,
          account: user.account,
          password: user.password,
          username: user.username,
          phone: user.phone,
          points: user.points,
          level: user.level
        })
        await this.preferences!.put('current_user', userJson)
        await this.preferences!.flush()
        console.log('StorageManager: 用户信息已保存到数据库', user.account)
      } else {
        await this.preferences!.delete('current_user')
        await this.preferences!.flush()
        console.log('用户信息已从数据库删除')
      }
    } catch (error) {
      console.error('StorageManager: 保存用户信息失败:', error)
      throw new Error('保存用户信息失败')
    }
  }

  /**
   * 添加用户到用户列表
   */
  private async addUserToList(user: User): Promise<void> {
    try {
      const usersJson = await this.preferences!.get('users', '{}') as string
      const users: Record<string, Object> = JSON.parse(usersJson)

      const userStorageItem: UserStorageItem = {
        id: user.id,
        account: user.account,
        password: user.password,
        username: user.username,
        phone: user.phone,
        points: user.points,
        level: user.level,
        registrationTime: user.registrationTime,
        lastLoginTime: user.lastLoginTime,
        totalSpent: user.totalSpent
      }

      users[user.account] = userStorageItem
      await this.preferences!.put('users', JSON.stringify(users))
      await this.preferences!.flush()
      console.log('用户已添加到用户列表')
    } catch (error) {
      console.error('添加用户到列表失败:', error)
      throw new Error('添加用户到列表失败')
    }
  }

  /**
   * 从用户列表中查找用户
   */
  public async findUserByAccount(account: string): Promise<User | null> {
    try {
      const usersJson = await this.preferences!.get('users', '{}') as string
      const users: Record<string, UserStorageItem> = JSON.parse(usersJson)
      const userData = users[account]

      if (userData) {
        const user = new User(userData.account, userData.password)
        user.id = userData.id
        user.username = userData.username
        user.phone = userData.phone
        user.points = userData.points
        user.level = userData.level
        user.registrationTime = userData.registrationTime
        user.lastLoginTime = userData.lastLoginTime
        user.totalSpent = userData.totalSpent
        return user
      }
      return null
    } catch (error) {
      console.error('查找用户失败:', error)
      return null
    }
  }

  /**
   * 加载当前用户信息
   */
  public async loadUser(): Promise<User | null> {
    this.ensureInitialized()
    try {
      const userJson = await this.preferences!.get('current_user', '') as string
      if (userJson) {
        const userData: Record<string, Object> = JSON.parse(userJson)
        const user = new User(userData.account as string, userData.password as string)
        user.id = userData.id as string
        user.username = userData.username as string
        user.phone = userData.phone as string
        user.points = userData.points as number
        const level = userData.level as string
        user.level = ['bronze', 'silver', 'gold', 'platinum'].includes(level) ? level as 'bronze' | 'silver' | 'gold' | 'platinum' : 'bronze'
        console.log('当前用户信息已从数据库加载')
        return user
      }
      return null
    } catch (error) {
      console.error('加载用户信息失败:', error)
      return null
    }
  }

  // =================== 购物车管理 ===================

  /**
   * 保存购物车数据
   */
  public async saveCart(cartItems: CartItem[]): Promise<void> {
    this.ensureInitialized()
    try {
      const cartJson = JSON.stringify(cartItems.map(item => {
        const cartItem: CartStorageItem = {
          productId: item.product.id,
          quantity: item.quantity,
          selected: item.selected,
          addedTime: item.addedTime
        }
        return cartItem
      }))
      await this.preferences!.put('cart', cartJson)
      await this.preferences!.flush()
      console.log('购物车已保存到数据库:', cartItems.length, '个商品')
    } catch (error) {
      console.error('保存购物车失败:', error)
      throw new Error('保存购物车失败')
    }
  }

  /**
   * 加载购物车数据（仅返回存储的原始数据，不包含ProductModel）
   */
  public async loadCartRawData(): Promise<CartStorageItem[]> {
    this.ensureInitialized()
    try {
      const cartJson = await this.preferences!.get('cart', '') as string
      if (cartJson) {
        const cartData: CartStorageItem[] = JSON.parse(cartJson)
        console.log('购物车原始数据已从数据库加载:', cartData.length, '个商品')
        return cartData
      }
      return []
    } catch (error) {
      console.error('加载购物车原始数据失败:', error)
      return []
    }
  }

  /**
   * 加载购物车数据（向后兼容）
   */
  public async loadCart(): Promise<CartItem[]> {
    console.warn('loadCart方法已废弃，请在CartService中使用loadCartRawData')
    return []
  }

  // =================== 收藏管理 ===================

  /**
   * 保存收藏数据
   */
  public async saveFavorites(favorites: FavoriteItem[]): Promise<void> {
    this.ensureInitialized()
    try {
      const favoritesJson = JSON.stringify(favorites.map(item => {
        const favoriteItem: FavoriteStorageItem = {
          productId: item.productId,
          addedTime: item.addedTime
        }
        return favoriteItem
      }))
      await this.preferences!.put('favorites', favoritesJson)
      await this.preferences!.flush()
      console.log('收藏已保存到数据库:', favorites.length, '个商品')
    } catch (error) {
      console.error('保存收藏失败:', error)
      throw new Error('保存收藏失败')
    }
  }

  /**
   * 加载收藏数据
   */
  public async loadFavorites(): Promise<FavoriteStorageItem[]> {
    this.ensureInitialized()
    try {
      const favoritesJson = await this.preferences!.get('favorites', '') as string
      if (favoritesJson) {
        const favoritesData: FavoriteStorageItem[] = JSON.parse(favoritesJson)
        console.log('收藏已从数据库加载:', favoritesData.length, '个商品')
        return favoritesData
      }
      return []
    } catch (error) {
      console.error('加载收藏失败:', error)
      return []
    }
  }

  // =================== 评论管理 ===================

  /**
   * 保存评论数据
   */
  public async saveComments(comments: Comment[]): Promise<void> {
    this.ensureInitialized()
    try {
      const commentsJson = JSON.stringify(comments.map(comment => {
        const commentItem: CommentStorageItem = {
          id: comment.id,
          productId: comment.productId,
          userId: comment.userId,
          username: comment.username,
          rating: comment.rating,
          content: comment.content,
          images: comment.images,
          likes: comment.likes,
          isLiked: comment.isLiked,
          createTime: comment.createTime
        }
        return commentItem
      }))
      await this.preferences!.put('comments', commentsJson)
      await this.preferences!.flush()
      console.log('评论已保存到数据库:', comments.length, '条评论')
    } catch (error) {
      console.error('保存评论失败:', error)
      throw new Error('保存评论失败')
    }
  }

  /**
   * 加载评论数据
   */
  public async loadComments(): Promise<Comment[]> {
    this.ensureInitialized()
    try {
      const commentsJson = await this.preferences!.get('comments', '') as string
      if (commentsJson) {
        const commentsData: CommentStorageItem[] = JSON.parse(commentsJson)
        const comments = commentsData.map((data: CommentStorageItem) => {
          const comment = new Comment(
            data.productId,
            data.userId,
            data.username,
            data.rating,
            data.content
          )
          comment.id = data.id
          comment.images = data.images || []
          comment.likes = data.likes || 0
          comment.isLiked = data.isLiked || false
          comment.createTime = data.createTime || Date.now()
          return comment
        })
        console.log('评论已从数据库加载:', comments.length, '条评论')
        return comments
      }
      return []
    } catch (error) {
      console.error('加载评论失败:', error)
      return []
    }
  }

  // =================== 地址管理 ===================

  /**
   * 保存地址数据
   */
  public async saveAddresses(addresses: Address[]): Promise<void> {
    this.ensureInitialized()
    try {
      const addressesJson = JSON.stringify(addresses.map(address => {
        const addressItem: AddressStorageItem = {
          id: address.id,
          name: address.name,
          phone: address.phone,
          province: address.province,
          city: address.city,
          district: address.district,
          detail: address.detail,
          isDefault: address.isDefault
        }
        return addressItem
      }))
      await this.preferences!.put('addresses', addressesJson)
      await this.preferences!.flush()
      console.log('地址已保存到数据库:', addresses.length, '个地址')
    } catch (error) {
      console.error('保存地址失败:', error)
      throw new Error('保存地址失败')
    }
  }

  /**
   * 加载地址数据
   */
  public async loadAddresses(): Promise<Address[]> {
    this.ensureInitialized()
    try {
      const addressesJson = await this.preferences!.get('addresses', '') as string
      if (addressesJson) {
        const addressesData: AddressStorageItem[] = JSON.parse(addressesJson)
        const addresses = addressesData.map((data: AddressStorageItem) => {
          const address = new Address(
            data.name,
            data.phone,
            data.province,
            data.city,
            data.district,
            data.detail
          )
          address.id = data.id
          address.isDefault = data.isDefault || false
          return address
        })
        console.log('地址已从数据库加载:', addresses.length, '个地址')
        return addresses
      }
      return []
    } catch (error) {
      console.error('加载地址失败:', error)
      return []
    }
  }

  // =================== 搜索历史管理 ===================

  /**
   * 保存搜索历史
   */
  public async saveSearchHistory(history: string[]): Promise<void> {
    this.ensureInitialized()
    try {
      const historyJson = JSON.stringify(history)
      await this.preferences!.put('searchHistory', historyJson)
      await this.preferences!.flush()
      console.log('搜索历史已保存到数据库:', history.length, '条记录')
    } catch (error) {
      console.error('保存搜索历史失败:', error)
      throw new Error('保存搜索历史失败')
    }
  }

  /**
   * 加载搜索历史
   */
  public async loadSearchHistory(): Promise<string[]> {
    this.ensureInitialized()
    try {
      const historyJson = await this.preferences!.get('searchHistory', '') as string
      if (historyJson) {
        const history: string[] = JSON.parse(historyJson)
        console.log('搜索历史已从数据库加载:', history.length, '条记录')
        return history
      }
      return []
    } catch (error) {
      console.error('加载搜索历史失败:', error)
      return []
    }
  }

  /**
   * 获取搜索历史（同步方法，用于组件初始化）
   */
  public async getSearchHistory(): Promise<string[]> {
    return await this.loadSearchHistory()
  }

  // =================== 应用设置管理 ===================

  /**
   * 保存应用设置
   */
  public async saveSettings(settings: AppSettings): Promise<void> {
    this.ensureInitialized()
    try {
      const settingsJson = JSON.stringify(settings)
      await this.preferences!.put('settings', settingsJson)
      await this.preferences!.flush()
      console.log('应用设置已保存到数据库')
    } catch (error) {
      console.error('保存应用设置失败:', error)
      throw new Error('保存应用设置失败')
    }
  }

  /**
   * 加载应用设置
   */
  public async loadSettings(): Promise<AppSettings> {
    this.ensureInitialized()
    try {
      const settingsJson = await this.preferences!.get('settings', '') as string
      if (settingsJson) {
        const settings = JSON.parse(settingsJson) as AppSettings
        console.log('应用设置已从数据库加载')
        return settings
      }
      return {}
    } catch (error) {
      console.error('加载应用设置失败:', error)
      return {}
    }
  }

  // =================== 数据备份和恢复 ===================

  /**
   * 备份所有数据
   */
  public async backupData(): Promise<BackupData> {
    this.ensureInitialized()
    try {
      const backup: BackupData = {
        user: await this.loadUser(),
        cart: await this.loadCart(),
        favorites: [],
        comments: await this.loadComments(),
        addresses: await this.loadAddresses(),
        searchHistory: await this.loadSearchHistory(),
        settings: await this.loadSettings(),
        backupTime: Date.now()
      }
      console.log('数据备份完成')
      return backup
    } catch (error) {
      console.error('数据备份失败:', error)
      throw new Error('数据备份失败')
    }
  }

  /**
   * 恢复数据
   */
  public async restoreData(backup: BackupData | Object): Promise<void> {
    this.ensureInitialized()
    try {
      // 如果是Object类型，需要转换为BackupData
      const backupData = backup as BackupData

      if (backupData.user) {
        await this.saveUser(backupData.user)
      }
      if (backupData.cart) {
        await this.saveCart(backupData.cart)
      }
      if (backupData.favorites) {
        await this.saveFavorites(backupData.favorites)
      }
      if (backupData.comments) {
        await this.saveComments(backupData.comments)
      }
      if (backupData.addresses) {
        await this.saveAddresses(backupData.addresses)
      }
      if (backupData.searchHistory) {
        await this.saveSearchHistory(backupData.searchHistory)
      }
      if (backupData.settings) {
        await this.saveSettings(backupData.settings)
      }
      console.log('数据恢复完成')
    } catch (error) {
      console.error('数据恢复失败:', error)
      throw new Error('数据恢复失败')
    }
  }

  // =================== 存储统计 ===================

  /**
   * 获取存储统计信息
   */
  public async getStorageStats(): Promise<StorageStats> {
    this.ensureInitialized()
    try {
      const user = await this.loadUser()
      const cart = await this.loadCart()
      const favorites = await this.loadFavorites()
      const comments = await this.loadComments()
      const addresses = await this.loadAddresses()
      const searchHistory = await this.loadSearchHistory()
      const settings = await this.loadSettings()

      const stats: StorageStats = {
        user: user ? 1 : 0,
        cart: cart.length,
        favorites: favorites.length,
        comments: comments.length,
        addresses: addresses.length,
        searchHistory: searchHistory.length,
        settings: Object.keys(settings).length
      }
      console.log('存储统计:', stats)
      return stats
    } catch (error) {
      console.error('获取存储统计失败:', error)
      return {
        user: 0,
        cart: 0,
        favorites: 0,
        comments: 0,
        addresses: 0,
        searchHistory: 0,
        settings: 0
      }
    }
  }

  // =================== 数据清理 ===================

  /**
   * 清除所有数据
   */
  public async clearAllData(): Promise<void> {
    this.ensureInitialized()
    try {
      await this.preferences!.clear()
      await this.preferences!.flush()
      console.log('所有数据库数据已清除')
    } catch (error) {
      console.error('清除数据失败:', error)
      throw new Error('清除数据失败')
    }
  }

  /**
   * 清除特定类型的数据
   */
  public async clearDataByType(type: string): Promise<void> {
    this.ensureInitialized()
    try {
      await this.preferences!.delete(type)
      await this.preferences!.flush()
      console.log(type + '数据已清除')
    } catch (error) {
      console.error('清除' + type + '数据失败:', error)
      throw new Error('清除' + type + '数据失败')
    }
  }

  // =================== 兼容性方法 ===================

  /**
   * 同步方法包装器（为了向后兼容）
   * 注意：这些方法仍然是异步的，但使用try-catch来处理错误
   */
  saveUserSync(userParam: User | null): void {
    this.saveUser(userParam).catch((error: Error) => {
      console.error('同步保存用户失败:', error)
    })
  }

  loadUserSync(): User | null {
    try {
      // 在同步环境中无法返回异步结果，这里返回null
      // 调用者应该使用异步版本
      console.warn('loadUserSync已废弃，请使用loadUser异步方法')
      return null
    } catch (error) {
      console.error('同步加载用户失败:', error)
      return null
    }
  }

  saveCartSync(cartItemsParam: CartItem[]): void {
    this.saveCart(cartItemsParam).catch((error: Error) => {
      console.error('同步保存购物车失败:', error)
    })
  }

  loadCartSync(): CartItem[] {
    try {
      console.warn('loadCartSync已废弃，请使用loadCart异步方法')
      return []
    } catch (error) {
      console.error('同步加载购物车失败:', error)
      return []
    }
  }
}