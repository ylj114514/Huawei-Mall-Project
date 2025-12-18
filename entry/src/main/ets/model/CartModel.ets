/**
 * 购物车项模型
 */
export class CartItem {
  id?: number
  productId: string
  quantity: number
  spec?: string
  name?: string
  price?: number
  image?: string
  stock?: number
  userId?: number
  createdAt?: number

  constructor(
    productId: string,
    quantity: number,
    spec?: string
  ) {
    this.productId = productId
    this.quantity = quantity
    this.spec = spec
  }

  // 获取总价
  getTotalPrice(): number {
    return (this.price || 0) * this.quantity
  }

  // 获取规格文本
  getSpecText(): string {
    return this.spec || '默认规格'
  }
}

/**
 * 购物车服务类
 */
export class CartService {
  private static instance: CartService
  private cartItems: CartItem[] = []

  static getInstance(): CartService {
    if (!CartService.instance) {
      CartService.instance = new CartService()
    }
    return CartService.instance
  }

  // 添加到购物车
  addToCart(
    userId: number,
    productId: string,
    quantity: number,
    spec?: string
  ): CartItem {
    // 检查是否已存在相同规格的商品
    const existingIndex = this.cartItems.findIndex(
      item => item.userId === userId &&
              item.productId === productId &&
              item.spec === spec
    )

    if (existingIndex !== -1) {
      // 更新数量
      this.cartItems[existingIndex].quantity += quantity
      return this.cartItems[existingIndex]
    } else {
      // 创建新项
      const cartItem = new CartItem(productId, quantity, spec)
      cartItem.userId = userId
      cartItem.createdAt = Date.now()
      this.cartItems.push(cartItem)
      return cartItem
    }
  }

  // 从购物车移除
  removeFromCart(userId: number, productId: string, spec?: string): boolean {
    const index = this.cartItems.findIndex(
      item => item.userId === userId &&
              item.productId === productId &&
              item.spec === spec
    )

    if (index !== -1) {
      this.cartItems.splice(index, 1)
      return true
    }
    return false
  }

  // 更新数量
  updateQuantity(
    userId: number,
    productId: string,
    quantity: number,
    spec?: string
  ): boolean {
    const item = this.cartItems.find(
      item => item.userId === userId &&
              item.productId === productId &&
              item.spec === spec
    )

    if (item) {
      item.quantity = quantity
      return true
    }
    return false
  }

  // 获取用户购物车
  getUserCart(userId: number): CartItem[] {
    return this.cartItems.filter(item => item.userId === userId)
  }

  // 清空购物车
  clearCart(userId: number): void {
    this.cartItems = this.cartItems.filter(item => item.userId !== userId)
  }

  // 获取购物车商品总数
  getCartItemCount(userId: number): number {
    return this.cartItems
      .filter(item => item.userId === userId)
      .reduce((sum, item) => sum + item.quantity, 0)
  }

  // 获取购物车总价
  getCartTotal(userId: number): number {
    return this.cartItems
      .filter(item => item.userId === userId)
      .reduce((sum, item) => sum + item.getTotalPrice(), 0)
  }

  // 获取选中的商品总价
  getSelectedTotal(userId: number, selectedIds: string[]): number {
    return this.cartItems
      .filter(item =>
        item.userId === userId &&
        selectedIds.includes(`${item.productId}_${item.spec}`)
      )
      .reduce((sum, item) => sum + item.getTotalPrice(), 0)
  }

  // 批量删除
  batchRemove(userId: number, productIds: string[]): boolean {
    const initialLength = this.cartItems.length
    this.cartItems = this.cartItems.filter(item =>
      !(item.userId === userId &&
        productIds.includes(`${item.productId}_${item.spec}`))
    )
    return this.cartItems.length < initialLength
  }

  // 检查商品是否在购物车中
  isInCart(userId: number, productId: string, spec?: string): boolean {
    return this.cartItems.some(
      item => item.userId === userId &&
              item.productId === productId &&
              item.spec === spec
    )
  }

  // 获取购物车中商品的数量
  getItemQuantity(userId: number, productId: string, spec?: string): number {
    const item = this.cartItems.find(
      item => item.userId === userId &&
              item.productId === productId &&
              item.spec === spec
    )
    return item ? item.quantity : 0
  }
}