import { ProductModel } from '../model/ProductModel'

// 本地定义收藏项模型
export class FavoriteItem {
  productId: string
  product: ProductModel
  addedTime: number

  constructor(product: ProductModel) {
    this.productId = product.id
    this.product = product
    this.addedTime = Date.now()
  }
}

/**
 * 收藏服务类
 */
export class FavoriteService {
  private static instance: FavoriteService
  private favorites: FavoriteItem[] = []
  private initialized: boolean = false

  private constructor() {
    this.init()
  }

  public static getInstance(): FavoriteService {
    if (!FavoriteService.instance) {
      FavoriteService.instance = new FavoriteService()
    }
    return FavoriteService.instance
  }

  public async init(): Promise<void> {
    if (!this.initialized) {
      this.initMockData()
      this.initialized = true
    }
  }

  /**
   * 初始化模拟数据
   * ✅ 已修复：参数顺序严格对应 ProductModel 构造函数
   */
  private initMockData() {
    if (this.favorites.length === 0) {
      // 模拟商品 1: Mate 60 Pro
      let p1 = new ProductModel(
        'huawei-mate60-pro',           // 1. id
        'HUAWEI Mate 60 Pro',          // 2. name
        6999,                          // 3. price
        7999,                          // 4. originalPrice
        '遥遥领先，超强续航',            // 5. description
        '详细描述内容...',               // 6. detailDescription
        [],                            // 7. images (ResourceStr[])
        '手机',                         // 8. category
        ['热销', '新品'],               // 9. tags (string[])
        5,                             // 10. rating (number)
        1000,                          // 11. reviewCount (number)
        100                            // 12. stock (number)
      )

      // 模拟商品 2: FreeBuds Pro 3
      let p2 = new ProductModel(
        'huawei-freebuds-pro-3',       // 1. id
        'HUAWEI FreeBuds Pro 3',       // 2. name
        1499,                          // 3. price
        1499,                          // 4. originalPrice
        '超强降噪，无损音质',            // 5. description
        '详细描述内容...',               // 6. detailDescription
        [],                            // 7. images
        '耳机',                         // 8. category
        ['降噪', '音质'],               // 9. tags
        4.8,                           // 10. rating
        500,                           // 11. reviewCount
        200                            // 12. stock
      )

      this.favorites.push(new FavoriteItem(p1))
      this.favorites.push(new FavoriteItem(p2))

      console.info('已加载模拟收藏数据:', this.favorites.length, '条')
    }
  }

  private async ensureInitialized(): Promise<void> {
    if (!this.initialized) {
      await this.init()
    }
  }

  // ================= 业务方法 =================

  public async addToFavorites(product: ProductModel): Promise<boolean> {
    await this.ensureInitialized()
    try {
      if (this.isFavorite(product.id)) {
        return false
      }
      const favoriteItem = new FavoriteItem(product)
      this.favorites.unshift(favoriteItem)
      return true
    } catch (error) {
      console.error('添加收藏失败:', JSON.stringify(error))
      return false
    }
  }

  public async removeFromFavorites(productId: string): Promise<boolean> {
    await this.ensureInitialized()
    try {
      const index = this.favorites.findIndex(item => item.productId === productId)
      if (index > -1) {
        this.favorites.splice(index, 1)
        return true
      }
      return false
    } catch (error) {
      console.error('取消收藏失败:', JSON.stringify(error))
      return false
    }
  }

  public async toggleFavorite(product: ProductModel): Promise<boolean> {
    await this.ensureInitialized()
    if (this.isFavorite(product.id)) {
      return this.removeFromFavorites(product.id)
    } else {
      return this.addToFavorites(product)
    }
  }

  public isFavorite(productId: string): boolean {
    return this.favorites.some(item => item.productId === productId)
  }

  public getFavorites(): FavoriteItem[] {
    return [...this.favorites]
  }

  public getFavoriteCount(): number {
    return this.favorites.length
  }

  public async clearFavorites(): Promise<void> {
    await this.ensureInitialized()
    this.favorites = []
  }

  public searchFavorites(query: string): FavoriteItem[] {
    if (!query) return this.favorites
    const lowerQuery = query.toLowerCase()
    return this.favorites.filter(item =>
    (item.product.name && item.product.name.toLowerCase().includes(lowerQuery)) ||
      (item.product.category && item.product.category.toLowerCase().includes(lowerQuery))
    )
  }

  public getFavoritesByCategory(category: string): FavoriteItem[] {
    return this.favorites.filter(item => item.product.category === category)
  }

  // 兼容性方法
  addToFavoritesSync(product: ProductModel): boolean {
    this.addToFavorites(product)
    return true
  }

  removeFromFavoritesSync(productId: string): boolean {
    this.removeFromFavorites(productId)
    return true
  }

  toggleFavoriteSync(product: ProductModel): boolean {
    this.toggleFavorite(product)
    return true
  }

  clearFavoritesSync(): void {
    this.favorites = []
  }
}