import { ProductModel } from '../model/ProductModel'
import { FavoriteItem } from '../model/DataModel'
import { StorageManager } from '../utils/StorageManager'

// 收藏存储项接口
interface FavoriteStorageItem {
  productId: string
  addedTime: number
}

/**
 * 收藏服务类
 * 使用本地数据库实现数据持久化
 */
export class FavoriteService {
  private static instance: FavoriteService
  private favorites: FavoriteItem[] = []
  private storage: StorageManager
  private initialized: boolean = false

  private constructor() {
    this.storage = StorageManager.getInstance()
  }

  public static getInstance(): FavoriteService {
    if (!FavoriteService.instance) {
      FavoriteService.instance = new FavoriteService()
    }
    return FavoriteService.instance
  }

  /**
   * 初始化收藏服务
   */
  public async init(): Promise<void> {
    if (!this.initialized) {
      await this.loadFavoritesFromStorage()
      this.initialized = true
    }
  }

  /**
   * 从存储加载收藏
   */
  private async loadFavoritesFromStorage(): Promise<void> {
    try {
      const storedFavorites = await this.storage.loadFavorites()
      this.favorites = []

      // 需要将存储的数据重新构建为FavoriteItem对象，包含ProductModel
      const productModule = await import('../model/ProductModel')
      const allProducts = productModule.MockData.generateProducts()

      for (const storedFavorite of storedFavorites as FavoriteStorageItem[]) {
        const product = allProducts.find(p => p.id === storedFavorite.productId)
        if (product) {
          const favoriteItem = new FavoriteItem(product)
          favoriteItem.addedTime = storedFavorite.addedTime || Date.now()
          this.favorites.push(favoriteItem)
        }
      }

      console.log('收藏已从数据库加载:', this.favorites.length, '个商品')
    } catch (error) {
      console.error('加载收藏失败:', error)
      this.favorites = []
    }
  }

  /**
   * 保存收藏到存储
   */
  private async saveFavoritesToStorage(): Promise<void> {
    try {
      await this.storage.saveFavorites(this.favorites)
      console.log('收藏已保存到数据库')
    } catch (error) {
      console.error('保存收藏失败:', error)
    }
  }

  /**
   * 确保已初始化
   */
  private async ensureInitialized(): Promise<void> {
    if (!this.initialized) {
      await this.init()
    }
  }

  /**
   * 添加收藏
   */
  public async addToFavorites(product: ProductModel): Promise<boolean> {
    await this.ensureInitialized()

    try {
      // 检查是否已经收藏
      if (this.isFavorite(product.id)) {
        console.log('商品已在收藏中')
        return false
      }

      const favoriteItem = new FavoriteItem(product)
      this.favorites.unshift(favoriteItem)
      await this.saveFavoritesToStorage()
      console.log('添加收藏成功:', product.name)
      return true
    } catch (error) {
      console.error('添加收藏失败:', error)
      return false
    }
  }

  /**
   * 取消收藏
   */
  public async removeFromFavorites(productId: string): Promise<boolean> {
    await this.ensureInitialized()

    try {
      const index = this.favorites.findIndex(item => item.productId === productId)
      if (index > -1) {
        this.favorites.splice(index, 1)
        await this.saveFavoritesToStorage()
        console.log('取消收藏成功')
        return true
      }
      return false
    } catch (error) {
      console.error('取消收藏失败:', error)
      return false
    }
  }

  /**
   * 切换收藏状态
   */
  public async toggleFavorite(product: ProductModel): Promise<boolean> {
    await this.ensureInitialized()

    if (this.isFavorite(product.id)) {
      return this.removeFromFavorites(product.id)
    } else {
      return this.addToFavorites(product)
    }
  }

  /**
   * 检查是否已收藏
   */
  public isFavorite(productId: string): boolean {
    return this.favorites.some(item => item.productId === productId)
  }

  /**
   * 获取收藏列表
   */
  public getFavorites(): FavoriteItem[] {
    return [...this.favorites]
  }

  /**
   * 获取收藏数量
   */
  public getFavoriteCount(): number {
    return this.favorites.length
  }

  /**
   * 清空收藏
   */
  public async clearFavorites(): Promise<void> {
    await this.ensureInitialized()

    try {
      this.favorites = []
      await this.saveFavoritesToStorage()
      console.log('收藏已清空')
    } catch (error) {
      console.error('清空收藏失败:', error)
    }
  }

  /**
   * 按名称搜索收藏
   */
  public searchFavorites(query: string): FavoriteItem[] {
    const lowerQuery = query.toLowerCase()
    return this.favorites.filter(item =>
      item.product.name.toLowerCase().includes(lowerQuery) ||
      item.product.category.toLowerCase().includes(lowerQuery) ||
      item.product.tags.some(tag => tag.toLowerCase().includes(lowerQuery))
    )
  }

  /**
   * 按分类筛选收藏
   */
  public getFavoritesByCategory(category: string): FavoriteItem[] {
    return this.favorites.filter(item => item.product.category === category)
  }

  /**
   * 按价格范围筛选收藏
   */
  public getFavoritesByPriceRange(minPrice: number, maxPrice: number): FavoriteItem[] {
    return this.favorites.filter(item =>
      item.product.price >= minPrice && item.product.price <= maxPrice
    )
  }

  /**
   * 获取最近收藏的商品
   */
  public getRecentFavorites(limit: number = 10): FavoriteItem[] {
    return [...this.favorites]
      .sort((a, b) => b.addedTime - a.addedTime)
      .slice(0, limit)
  }

  // =================== 兼容性方法 ===================

  /**
   * 同步方法（为了向后兼容，建议使用异步版本）
   */
  addToFavoritesSync(product: ProductModel): boolean {
    this.addToFavorites(product).catch((error: Error) => {
      console.error('同步添加收藏失败:', error)
    })
    return true // 假设成功
  }

  removeFromFavoritesSync(productId: string): boolean {
    this.removeFromFavorites(productId).catch((error: Error) => {
      console.error('同步取消收藏失败:', error)
    })
    return true // 假设成功
  }

  toggleFavoriteSync(product: ProductModel): boolean {
    this.toggleFavorite(product).catch((error: Error) => {
      console.error('同步切换收藏状态失败:', error)
    })
    return true // 假设成功
  }

  clearFavoritesSync(): void {
    this.clearFavorites().catch((error: Error) => {
      console.error('同步清空收藏失败:', error)
    })
  }
}