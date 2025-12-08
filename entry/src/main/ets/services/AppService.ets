import { CartItem, Comment, User, FavoriteItem, Address } from '../model/DataModel'
import { StorageManager } from '../utils/StorageManager'
import { CartService } from './CartService'
import { FavoriteService } from './FavoriteService'
import Context from '@ohos.app.ability.common'

// 导入BackupData类型
interface BackupData {
  user: User | null
  cart: CartItem[]
  favorites: FavoriteItem[]
  comments: Comment[]
  addresses: Address[]
  searchHistory: string[]
  settings: Record<string, Object>
  backupTime: number
}

// 临时类型用于数据转换
interface BackupDataTemp {
  user: User | null
  cart: CartItem[]
  favorites: FavoriteItem[]
  comments: Comment[]
  addresses: Address[]
  searchHistory: string[]
  settings: Record<string, Object>
  backupTime: number
}

/**
 * 应用服务类
 * 负责初始化和管理所有应用级别的服务
 */
export class AppService {
  private static instance: AppService
  private storageManager: StorageManager
  private cartService: CartService
  private favoriteService: FavoriteService
  private initialized: boolean = false

  private constructor() {
    this.storageManager = StorageManager.getInstance()
    this.cartService = CartService.getInstance()
    this.favoriteService = FavoriteService.getInstance()
  }

  public static getInstance(): AppService {
    if (!AppService.instance) {
      AppService.instance = new AppService()
    }
    return AppService.instance
  }

  /**
   * 初始化应用服务
   * 在应用启动时调用
   */
  public async init(context: Context): Promise<void> {
    if (this.initialized) {
      console.log('AppService已初始化')
      return
    }

    try {
      console.log('开始初始化AppService...')

      // 1. 初始化存储管理器
      await this.storageManager.init(context)
      console.log('存储管理器初始化完成')

      // 2. 初始化购物车服务
      await this.cartService.init()
      console.log('购物车服务初始化完成')

      // 3. 初始化收藏服务
      await this.favoriteService.init()
      console.log('收藏服务初始化完成')

      this.initialized = true
      console.log('AppService初始化成功')

      // 4. 打印存储统计信息
      await this.storageManager.getStorageStats()
      console.log('AppService初始化成功，存储统计已输出到控制台')

    } catch (error) {
      console.error('AppService初始化失败:', error)
      throw new Error('AppService初始化失败')
    }
  }

  /**
   * 检查是否已初始化
   */
  public isInitialized(): boolean {
    return this.initialized
  }

  /**
   * 获取存储管理器
   */
  public getStorageManager(): StorageManager {
    this.ensureInitialized()
    return this.storageManager
  }

  /**
   * 获取购物车服务
   */
  public getCartService(): CartService {
    this.ensureInitialized()
    return this.cartService
  }

  /**
   * 获取收藏服务
   */
  public getFavoriteService(): FavoriteService {
    this.ensureInitialized()
    return this.favoriteService
  }

  /**
   * 确保已初始化
   */
  private ensureInitialized(): void {
    if (!this.initialized) {
      throw new Error('AppService未初始化，请先调用init()方法')
    }
  }

  /**
   * 备份所有数据
   */
  public async backupAllData(): Promise<void> {
    this.ensureInitialized()
    await this.storageManager.backupData()
  }

  /**
   * 恢复所有数据
   */
  public async restoreAllData(backup: Object): Promise<void> {
    this.ensureInitialized()
    await this.storageManager.restoreData(backup)

    // 重新加载服务数据
    await this.cartService.init()
    await this.favoriteService.init()
  }

  /**
   * 清除所有数据
   */
  public async clearAllData(): Promise<void> {
    this.ensureInitialized()
    await this.storageManager.clearAllData()

    // 清除服务数据
    await this.cartService.clearCart()
    await this.favoriteService.clearFavorites()
  }

  /**
   * 获取存储统计信息
   */
  public async getStorageStats(): Promise<void> {
    this.ensureInitialized()
    await this.storageManager.getStorageStats()
  }
}