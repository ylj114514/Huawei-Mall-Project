import { ProductModel } from '../model/ProductModel'
import { CartItem } from '../model/DataModel'
import { StorageManager } from '../utils/StorageManager'

// 购物车存储项接口
interface CartStorageItem {
  productId: string
  quantity: number
  selected: boolean
  addedTime: number
}

/**
 * 购物车服务类
 * 使用本地数据库实现数据持久化
 */
export class CartService {
  private static instance: CartService
  private cartItems: CartItem[] = []
  private storage: StorageManager
  private initialized: boolean = false

  private constructor() {
    this.storage = StorageManager.getInstance()
  }

  public static getInstance(): CartService {
    if (!CartService.instance) {
      CartService.instance = new CartService()
    }
    return CartService.instance
  }

  /**
   * 初始化购物车服务
   */
  public async init(): Promise<void> {
    if (!this.initialized) {
      await this.loadCartFromStorage()
      this.initialized = true
    }
  }

  /**
   * 从存储加载购物车
   */
  private async loadCartFromStorage(): Promise<void> {
    try {
      const storedItems = await this.storage.loadCartRawData()
      // 需要将存储的数据重新构建为CartItem对象，包含ProductModel
      this.cartItems = []

      // 这里需要根据实际的产品模型来重建完整的CartItem
      // 由于存储中只有productId和quantity，我们需要从ProductModel中获取完整信息
      const productModule = await import('../model/ProductModel')
      const allProducts = productModule.MockData.generateProducts()

      for (const storedItem of storedItems as CartStorageItem[]) {
        const product = allProducts.find(p => p.id === storedItem.productId)
        if (product) {
          const cartItem = new CartItem(product, storedItem.quantity)
          cartItem.selected = storedItem.selected || false
          cartItem.addedTime = storedItem.addedTime || Date.now()
          this.cartItems.push(cartItem)
        }
      }

      console.log('购物车已从数据库加载:', this.cartItems.length, '个商品')
    } catch (error) {
      console.error('加载购物车失败:', error)
      this.cartItems = []
    }
  }

  /**
   * 保存购物车到存储
   */
  private async saveCartToStorage(): Promise<void> {
    try {
      await this.storage.saveCart(this.cartItems)
      console.log('购物车已保存到数据库')
    } catch (error) {
      console.error('保存购物车失败:', error)
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
   * 添加商品到购物车
   */
  public async addToCart(product: ProductModel, quantity: number = 1): Promise<boolean> {
    await this.ensureInitialized()

    try {
      // 检查是否已存在相同商品
      const existingItem = this.cartItems.find(item => item.product.id === product.id)

      if (existingItem) {
        // 如果已存在，增加数量
        const newQuantity = existingItem.quantity + quantity
        if (newQuantity <= product.stock) {
          existingItem.quantity = newQuantity
        } else {
          return false // 库存不足
        }
      } else {
        // 如果不存在，添加新项
        const cartItem = new CartItem(product, quantity)
        this.cartItems.push(cartItem)
      }

      await this.saveCartToStorage()
      return true
    } catch (error) {
      console.error('添加到购物车失败:', error)
      return false
    }
  }

  /**
   * 从购物车移除商品
   */
  public async removeFromCart(cartItemId: string): Promise<void> {
    await this.ensureInitialized()

    try {
      const index = this.cartItems.findIndex(item => item.id === cartItemId)
      if (index > -1) {
        this.cartItems.splice(index, 1)
        await this.saveCartToStorage()
      }
    } catch (error) {
      console.error('从购物车移除商品失败:', error)
    }
  }

  /**
   * 更新商品数量
   */
  public async updateQuantity(cartItemId: string, quantity: number): Promise<boolean> {
    await this.ensureInitialized()

    try {
      const item = this.cartItems.find(item => item.id === cartItemId)
      if (item && quantity > 0 && quantity <= item.product.stock) {
        item.quantity = quantity
        await this.saveCartToStorage()
        return true
      }
      return false
    } catch (error) {
      console.error('更新商品数量失败:', error)
      return false
    }
  }

  /**
   * 切换选中状态
   */
  public async toggleSelected(cartItemId: string): Promise<void> {
    await this.ensureInitialized()

    try {
      const item = this.cartItems.find(item => item.id === cartItemId)
      if (item) {
        item.selected = !item.selected
        await this.saveCartToStorage()
      }
    } catch (error) {
      console.error('切换选中状态失败:', error)
    }
  }

  /**
   * 全选/全不选
   */
  public async toggleAllSelected(selected: boolean): Promise<void> {
    await this.ensureInitialized()

    try {
      this.cartItems.forEach(item => {
        item.selected = selected
      })
      await this.saveCartToStorage()
    } catch (error) {
      console.error('切换全选状态失败:', error)
    }
  }

  /**
   * 获取购物车商品列表
   */
  public getCartItems(): CartItem[] {
    return [...this.cartItems]
  }

  /**
   * 获取选中的商品
   */
  public getSelectedItems(): CartItem[] {
    return this.cartItems.filter(item => item.selected)
  }

  /**
   * 获取选中商品的数量
   */
  public getSelectedCount(): number {
    return this.cartItems.filter(item => item.selected).length
  }

  /**
   * 获取购物车总数量
   */
  public getTotalCount(): number {
    return this.cartItems.reduce((total, item) => total + item.quantity, 0)
  }

  /**
   * 计算选中商品总价
   */
  public getSelectedTotal(): number {
    return this.getSelectedItems().reduce((total, item) => total + item.getSubtotal(), 0)
  }

  /**
   * 计算购物车总价
   */
  public getTotalAmount(): number {
    return this.cartItems.reduce((total, item) => total + item.getSubtotal(), 0)
  }

  /**
   * 检查是否有选中的商品
   */
  public hasSelectedItems(): boolean {
    return this.cartItems.some(item => item.selected)
  }

  /**
   * 检查购物车是否为空
   */
  public isEmpty(): boolean {
    return this.cartItems.length === 0
  }

  /**
   * 清空购物车
   */
  public async clearCart(): Promise<void> {
    await this.ensureInitialized()

    try {
      this.cartItems = []
      await this.saveCartToStorage()
    } catch (error) {
      console.error('清空购物车失败:', error)
    }
  }

  /**
   * 清空选中的商品（结算后调用）
   */
  public async clearSelected(): Promise<void> {
    await this.ensureInitialized()

    try {
      this.cartItems = this.cartItems.filter(item => !item.selected)
      await this.saveCartToStorage()
    } catch (error) {
      console.error('清空选中商品失败:', error)
    }
  }

  /**
   * 获取无效商品（库存不足等）
   */
  public getInvalidItems(): CartItem[] {
    return this.cartItems.filter(item => !item.isValid())
  }

  /**
   * 移除无效商品
   */
  public async removeInvalidItems(): Promise<void> {
    await this.ensureInitialized()

    try {
      this.cartItems = this.cartItems.filter(item => item.isValid())
      await this.saveCartToStorage()
    } catch (error) {
      console.error('移除无效商品失败:', error)
    }
  }

  /**
   * 检查商品是否在购物车中
   */
  public isProductInCart(productId: string): boolean {
    return this.cartItems.some(item => item.product.id === productId)
  }

  /**
   * 获取购物车中的商品数量
   */
  public getProductQuantity(productId: string): number {
    const item = this.cartItems.find(item => item.product.id === productId)
    return item ? item.quantity : 0
  }

  // =================== 兼容性方法 ===================

  /**
   * 同步方法（为了向后兼容，建议使用异步版本）
   */
  addToCartSync(product: ProductModel, quantity: number = 1): boolean {
    this.addToCart(product, quantity).catch((error: Error) => {
      console.error('同步添加到购物车失败:', error)
    })
    return true // 假设成功
  }

  removeFromCartSync(cartItemId: string): void {
    this.removeFromCart(cartItemId).catch((error: Error) => {
      console.error('同步从购物车移除失败:', error)
    })
  }

  updateQuantitySync(cartItemId: string, quantity: number): boolean {
    this.updateQuantity(cartItemId, quantity).catch((error: Error) => {
      console.error('同步更新数量失败:', error)
    })
    return true // 假设成功
  }

  toggleSelectedSync(cartItemId: string): void {
    this.toggleSelected(cartItemId).catch((error: Error) => {
      console.error('同步切换选中状态失败:', error)
    })
  }

  toggleAllSelectedSync(selected: boolean): void {
    this.toggleAllSelected(selected).catch((error: Error) => {
      console.error('同步切换全选状态失败:', error)
    })
  }

  clearCartSync(): void {
    this.clearCart().catch((error: Error) => {
      console.error('同步清空购物车失败:', error)
    })
  }

  clearSelectedSync(): void {
    this.clearSelected().catch((error: Error) => {
      console.error('同步清空选中商品失败:', error)
    })
  }

  removeInvalidItemsSync(): void {
    this.removeInvalidItems().catch((error: Error) => {
      console.error('同步移除无效商品失败:', error)
    })
  }
}