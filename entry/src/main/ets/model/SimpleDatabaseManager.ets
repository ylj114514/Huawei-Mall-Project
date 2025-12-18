import { ProductModel, MockData } from './ProductModel'

/**
 * 简化的数据库管理器 - 使用内存存储
 */
export class SimpleDatabaseManager {
  private static instance: SimpleDatabaseManager
  private products: ProductModel[] = []
  private isInitialized: boolean = false

  private constructor() {}

  static getInstance(): SimpleDatabaseManager {
    if (!SimpleDatabaseManager.instance) {
      SimpleDatabaseManager.instance = new SimpleDatabaseManager()
    }
    return SimpleDatabaseManager.instance
  }

  /**
   * 初始化数据库
   */
  async initialize(): Promise<void> {
    if (this.isInitialized) {
      return
    }

    try {
      // 加载模拟数据
      this.products = MockData.generateProducts()
      this.isInitialized = true
      console.log('数据库初始化成功')
    } catch (error) {
      console.error('数据库初始化失败:', error)
      throw new Error('数据库初始化失败')
    }
  }

  /**
   * 获取所有商品
   */
  async getAllProducts(): Promise<ProductModel[]> {
    if (!this.isInitialized) {
      await this.initialize()
    }
    return this.products
  }

  /**
   * 根据ID获取商品
   */
  async getProductById(id: number): Promise<ProductModel | null> {
    if (!this.isInitialized) {
      await this.initialize()
    }
    return this.products.find(p => parseInt(p.id) === id) || null
  }

  /**
   * 插入商品
   */
  async insertProduct(product: ProductModel): Promise<number> {
    if (!this.isInitialized) {
      await this.initialize()
    }
    const newId = Math.max(...this.products.map(p => parseInt(p.id))) + 1
    product.id = newId.toString()
    this.products.push(product)
    return newId
  }

  /**
   * 更新商品
   */
  async updateProduct(id: number, updates: Partial<ProductModel>): Promise<void> {
    if (!this.isInitialized) {
      await this.initialize()
    }
    const index = this.products.findIndex(p => parseInt(p.id) === id)
    if (index !== -1) {
      const oldProduct = this.products[index]
      if (updates.name !== undefined) oldProduct.name = updates.name
      if (updates.description !== undefined) oldProduct.description = updates.description
      if (updates.price !== undefined) oldProduct.price = updates.price
      if (updates.originalPrice !== undefined) oldProduct.originalPrice = updates.originalPrice
      if (updates.image !== undefined) oldProduct.image = updates.image
      if (updates.images !== undefined) oldProduct.images = updates.images
      if (updates.category !== undefined) oldProduct.category = updates.category
      if (updates.stock !== undefined) oldProduct.stock = updates.stock
      if (updates.rating !== undefined) oldProduct.rating = updates.rating
      if (updates.reviewCount !== undefined) oldProduct.reviewCount = updates.reviewCount
      if (updates.detailDescription !== undefined) oldProduct.detailDescription = updates.detailDescription
    } else {
      throw new Error('商品不存在')
    }
  }

  /**
   * 删除商品
   */
  async deleteProduct(id: number): Promise<void> {
    if (!this.isInitialized) {
      await this.initialize()
    }
    const index = this.products.findIndex(p => parseInt(p.id) === id)
    if (index !== -1) {
      this.products.splice(index, 1)
    } else {
      throw new Error('商品不存在')
    }
  }

  /**
   * 关闭数据库连接
   */
  async close(): Promise<void> {
    this.isInitialized = false
  }
}