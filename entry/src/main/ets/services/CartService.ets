import { CartItem } from '../model/DataModel' // 确保引用正确的 Model
import { ProductModel, MockData } from '../model/ProductModel'
import { DatabaseManager, CartRow, ProductRow } from '../database/DatabaseManager'

export class CartService {
  private static instance: CartService
  private db: DatabaseManager = DatabaseManager.getInstance()

  // 内存缓存，用于 UI 渲染
  private cartItems: CartItem[] = []

  private constructor() {}

  public static getInstance(): CartService {
    if (!CartService.instance) {
      CartService.instance = new CartService()
    }
    return CartService.instance
  }

  /**
   * 初始化：从数据库加载购物车数据
   */
  public async init(): Promise<void> {
    await this.refreshCart()
  }

  /**
   * 核心方法：从 DB 读取数据并刷新内存
   */
  public async refreshCart(): Promise<void> {
    try {
      const account = this.db.getCurrentUserAccount()
      // 如果没登录，购物车为空
      if (!account) {
        this.cartItems = []
        return
      }

      // 1. 获取数据库里的购物车数据
      const rows: CartRow[] = await this.db.getCartRows()
      const newItems: CartItem[] = []

      // 2. 准备 Mock 数据用于恢复图片资源 (因为数据库存不了 Resource)
      const mockProducts = MockData.generateProducts()

      for (const row of rows) {
        let productModel: ProductModel | null = null

        // 尝试从 DB 获取最新商品信息
        const dbP = await this.db.getProductById(row.product_id)

        if (dbP) {
          // 将 DB 行转为 Model
          productModel = this.mapRowToProductModel(dbP)

          // 尝试从 MockData 找回 Resource 类型的图片
          const mockP = mockProducts.find(m => m.id === row.product_id)
          if (mockP && mockP.images) {
            productModel.images = mockP.images
            productModel.image = mockP.image
          }
        }

        if (productModel) {
          const item = new CartItem(productModel, row.quantity)
          item.id = row.id.toString()
          item.selected = row.selected
          item.addedTime = row.addedTime
          newItems.push(item)
        }
      }

      this.cartItems = newItems
      console.info('[CartService] Refreshed count:', this.cartItems.length)

    } catch (e) {
      console.error('[CartService] refreshCart failed:', e)
    }
  }

  // 辅助：DB行转对象
  private mapRowToProductModel(row: ProductRow): ProductModel {
    const p = new ProductModel(
      row.id, row.name, row.price, row.originalPrice,
      row.description, row.detailDescription,
      [], // images 暂空
      row.category, row.tags,
      row.rating, row.reviewCount, row.stock
    )
    p.sales = row.sales
    p.isNew = row.isNew
    return p
  }

  // ================= 业务操作 (直接写库) =================

  // ✅ 请确保你的 addToCart 是这样的逻辑
  public async addToCart(product: ProductModel, quantity: number = 1): Promise<boolean> {
    try {
      // 1. 写入 RDB 数据库
      const success = await this.db.addToCart(product.id, quantity, product.spec || '标准版')
      if (success) {
        // 2. 关键：必须立即调用 refreshCart 使得内存中的 cartItems 数组得到更新
        await this.refreshCart()
      }
      return success
    } catch (e) {
      console.error('addToCart Error', e)
      return false
    }
  }
  public async removeFromCart(cartItemId: string): Promise<boolean> {
    try {
      const id = parseInt(cartItemId)
      const success = await this.db.removeCartItem(id)
      if (success) await this.refreshCart()
      return success
    } catch (e) {
      return false
    }
  }

  public async updateQuantity(cartItemId: string, quantity: number): Promise<boolean> {
    try {
      const id = parseInt(cartItemId)
      const success = await this.db.updateCartItem(id, { quantity })
      if (success) await this.refreshCart()
      return success
    } catch (e) {
      return false
    }
  }

  public async toggleSelected(cartItemId: string): Promise<boolean> {
    const item = this.cartItems.find(i => i.id === cartItemId)
    if (!item) return false
    try {
      const id = parseInt(cartItemId)
      const success = await this.db.updateCartItem(id, { selected: !item.selected })
      if (success) await this.refreshCart()
      return success
    } catch (e) {
      return false
    }
  }

  public async toggleAllSelected(selected: boolean): Promise<boolean> {
    // 简单循环更新
    for (const item of this.cartItems) {
      if (item.selected !== selected) {
        await this.toggleSelected(item.id)
      }
    }
    return true
  }

  public async clearCart(): Promise<boolean> {
    const success = await this.db.clearCart()
    if (success) await this.refreshCart()
    return success
  }

  // ================= 获取数据 =================

  public getCartItems(): CartItem[] {
    return this.cartItems
  }

  public getSelectedItems(): CartItem[] {
    return this.cartItems.filter(i => i.selected)
  }

  public getTotalAmount(): number {
    return this.cartItems
      .filter(item => item.selected)
      .reduce((sum, item) => sum + (item.product.price * item.quantity), 0)
  }

  public getTotalCount(): number {
    return this.cartItems.reduce((sum, item) => sum + item.quantity, 0)
  }
}