import relationalStore from '@ohos.data.relationalStore'
import { User } from '../model/DataModel'
import { ProductModel } from '../model/ProductModel'
import { Order, OrderStatus } from '../model/OrderModel'
import { CartItem } from '../model/CartModel'
import common from '@ohos.app.ability.common'

// 评论接口
export interface Comment {
  id: string
  productId: string
  userId: string
  userName: string
  userAvatar: string
  rating: number
  content: string
  images: string[]
  helpfulCount: number
  spec: string
  createdAt: number
  updatedAt: number
}

/**
 * 数据库管理器 - 管理所有数据持久化
 */
export class DatabaseManager {
  private static instance: DatabaseManager
  private store: relationalStore.RdbStore | null = null
  private dbName: string = 'huawei_mall.db'
  private context: common.UIAbilityContext | null = null
  private currentUserId: string | null = null

  static getInstance(): DatabaseManager {
    if (!DatabaseManager.instance) {
      DatabaseManager.instance = new DatabaseManager()
    }
    return DatabaseManager.instance
  }

  // 初始化数据库
  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.store) {
      return
    }

    this.context = context
    const config: relationalStore.StoreConfig = {
      name: this.dbName,
      securityLevel: relationalStore.SecurityLevel.S1
    }

    try {
      this.store = await relationalStore.getRdbStore(context, config)
      await this.createTables()
      console.log('数据库初始化成功')
    } catch (error) {
      console.error('数据库初始化失败:', error)
      throw error
    }
  }

  // 设置当前用户ID
  setCurrentUserId(userId: string): void {
    this.currentUserId = userId
  }

  // 创建所有表
  private async createTables(): Promise<void> {
    if (!this.store) return

    // 用户表
    await this.store.executeSql(`
      CREATE TABLE IF NOT EXISTS users (
        account TEXT PRIMARY KEY,
        password TEXT NOT NULL,
        username TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        avatar TEXT,
        points INTEGER DEFAULT 0,
        level INTEGER DEFAULT 1,
        registrationTime INTEGER NOT NULL,
        lastLoginTime INTEGER,
        totalSpent REAL DEFAULT 0.0
      )
    `)

    // 购物车表
    await this.store.executeSql(`
      CREATE TABLE IF NOT EXISTS cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_account TEXT NOT NULL,
        product_id TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        spec TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY(user_account) REFERENCES users(account),
        UNIQUE(user_account, product_id, spec)
      )
    `)

    // 订单表
    await this.store.executeSql(`
      CREATE TABLE IF NOT EXISTS orders (
        id TEXT PRIMARY KEY,
        order_no TEXT UNIQUE NOT NULL,
        user_account TEXT NOT NULL,
        total_amount REAL NOT NULL,
        status TEXT NOT NULL,
        payment_method TEXT,
        payment_status TEXT DEFAULT 'unpaid',
        shipping_address TEXT,
        contact_name TEXT NOT NULL,
        contact_phone TEXT NOT NULL,
        remark TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY(user_account) REFERENCES users(account)
      )
    `)

    // 订单项表
    await this.store.executeSql(`
      CREATE TABLE IF NOT EXISTS order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        product_image TEXT,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        spec TEXT,
        FOREIGN KEY(order_id) REFERENCES orders(id)
      )
    `)

    // 评论表
    await this.store.executeSql(`
      CREATE TABLE IF NOT EXISTS comments (
        id TEXT PRIMARY KEY,
        product_id TEXT NOT NULL,
        user_account TEXT NOT NULL,
        user_name TEXT NOT NULL,
        user_avatar TEXT,
        rating INTEGER NOT NULL,
        content TEXT NOT NULL,
        images TEXT,
        helpful_count INTEGER DEFAULT 0,
        spec TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY(user_account) REFERENCES users(account)
      )
    `)

    // 地址表
    await this.store.executeSql(`
      CREATE TABLE IF NOT EXISTS addresses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_account TEXT NOT NULL,
        receiver_name TEXT NOT NULL,
        phone TEXT NOT NULL,
        province TEXT NOT NULL,
        city TEXT NOT NULL,
        district TEXT NOT NULL,
        detail TEXT NOT NULL,
        is_default INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY(user_account) REFERENCES users(account)
      )
    `)

    console.log('所有表创建完成')
  }

  // =================== 用户管理 ===================

  // 保存用户
  async saveUser(user: User): Promise<boolean> {
    if (!this.store) return false

    const timestamp = Date.now()
    const values = [
      user.account,
      user.password,
      user.username,
      user.email || '',
      user.phone || '',
      user.avatar || '',
      user.points || 0,
      user.level || 1,
      user.registrationTime || timestamp,
      timestamp,
      user.totalSpent || 0
    ]

    try {
      await this.store.executeSql(`
        INSERT OR REPLACE INTO users
        (account, password, username, email, phone, avatar, points, level,
         registrationTime, lastLoginTime, totalSpent)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `, values)

      this.setCurrentUserId(user.account)
      console.log('用户保存成功:', user.account)
      return true
    } catch (error) {
      console.error('保存用户失败:', error)
      return false
    }
  }

  // 查找用户
  async findUserByAccount(account: string): Promise<User | null> {
    if (!this.store) return null

    try {
      const result = await this.store.querySql(
        'SELECT * FROM users WHERE account = ?',
        [account]
      )

      if (result.rowCount > 0) {
        const row = result.goToFirstRow()
        const user = new User(account, row.getString(1))
        user.username = row.getString(2)
        user.email = row.getString(3)
        user.phone = row.getString(4)
        user.avatar = row.getString(5)
        user.points = row.getLong(6)
        user.level = row.getLong(7)
        user.registrationTime = row.getLong(8)
        user.lastLoginTime = row.getLong(9)
        user.totalSpent = row.getDouble(10)
        return user
      }
      return null
    } catch (error) {
      console.error('查询用户失败:', error)
      return null
    }
  }

  // =================== 购物车管理 ===================

  // 添加到购物车
  async addToCart(product: ProductModel, quantity: number = 1, spec?: string): Promise<boolean> {
    if (!this.store || !this.currentUserId) return false

    try {
      // 检查是否已存在
      const existing = await this.store.querySql(
        'SELECT id, quantity FROM cart_items WHERE user_account = ? AND product_id = ? AND spec = ?',
        [this.currentUserId, product.id, spec || '']
      )

      if (existing.rowCount > 0) {
        // 更新数量
        const row = existing.goToFirstRow()
        const newQuantity = row.getLong(1) + quantity
        await this.store.executeSql(
          'UPDATE cart_items SET quantity = ?, updated_at = ? WHERE id = ?',
          [newQuantity, Date.now(), row.getLong(0)]
        )
      } else {
        // 插入新记录
        await this.store.executeSql(
          'INSERT INTO cart_items (user_account, product_id, quantity, spec, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)',
          [this.currentUserId, product.id, quantity, spec || '', Date.now(), Date.now()]
        )
      }

      console.log('添加到购物车成功:', product.name)
      return true
    } catch (error) {
      console.error('添加到购物车失败:', error)
      return false
    }
  }

  // 获取购物车列表
  async getCartItems(): Promise<CartItem[]> {
    if (!this.store || !this.currentUserId) return []

    try {
      const result = await this.store.querySql(
        'SELECT * FROM cart_items WHERE user_account = ? ORDER BY created_at DESC',
        [this.currentUserId]
      )

      const items: CartItem[] = []
      while (result.goToNextRow()) {
        const item = new CartItem(result.getString(2), result.getLong(3), result.getString(4))
        item.id = result.getLong(0)
        item.createdAt = result.getLong(5)
        items.push(item)
      }

      return items
    } catch (error) {
      console.error('获取购物车失败:', error)
      return []
    }
  }

  // 更新购物车数量
  async updateCartItem(id: number, quantity: number): Promise<boolean> {
    if (!this.store) return false

    try {
      const result = await this.store.executeSql(
        'UPDATE cart_items SET quantity = ?, updated_at = ? WHERE id = ?',
        [quantity, Date.now(), id]
      )
      return result.changedRows > 0
    } catch (error) {
      console.error('更新购物车失败:', error)
      return false
    }
  }

  // 删除购物车项
  async removeCartItem(id: number): Promise<boolean> {
    if (!this.store) return false

    try {
      const result = await this.store.executeSql(
        'DELETE FROM cart_items WHERE id = ?',
        [id]
      )
      return result.changedRows > 0
    } catch (error) {
      console.error('删除购物车项失败:', error)
      return false
    }
  }

  // 清空购物车
  async clearCart(): Promise<boolean> {
    if (!this.store || !this.currentUserId) return false

    try {
      const result = await this.store.executeSql(
        'DELETE FROM cart_items WHERE user_account = ?',
        [this.currentUserId]
      )
      return result.changedRows > 0
    } catch (error) {
      console.error('清空购物车失败:', error)
      return false
    }
  }

  // =================== 订单管理 ===================

  // 创建订单
  async createOrder(order: Order, orderItems: any[]): Promise<boolean> {
    if (!this.store || !this.currentUserId) return false

    const timestamp = Date.now()

    try {
      // 插入订单
      await this.store.executeSql(
        'INSERT INTO orders (id, order_no, user_account, total_amount, status, ' +
        'payment_method, payment_status, shipping_address, contact_name, ' +
        'contact_phone, remark, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          order.id,
          order.orderNo,
          this.currentUserId,
          order.totalAmount,
          order.status,
          order.paymentMethod,
          order.paymentStatus,
          JSON.stringify(order.shippingAddress),
          order.contactName,
          order.contactPhone,
          order.remark || '',
          timestamp,
          timestamp
        ]
      )

      // 插入订单项
      for (const item of orderItems) {
        await this.store.executeSql(
          'INSERT INTO order_items (order_id, product_id, product_name, ' +
          'product_image, price, quantity, spec) VALUES (?, ?, ?, ?, ?, ?, ?)',
          [order.id, item.productId, item.productName, item.productImage, item.price, item.quantity, item.spec || '']
        )
      }

      // 清空购物车
      await this.clearCart()

      console.log('订单创建成功:', order.orderNo)
      return true
    } catch (error) {
      console.error('创建订单失败:', error)
      return false
    }
  }

  // 获取用户订单
  async getUserOrders(): Promise<Order[]> {
    if (!this.store || !this.currentUserId) return []

    try {
      const result = await this.store.querySql(
        'SELECT * FROM orders WHERE user_account = ? ORDER BY created_at DESC',
        [this.currentUserId]
      )

      const orders: Order[] = []
      while (result.goToNextRow()) {
        const order = new Order(0, '', 0, '', '', '', '')
        order.id = result.getString(0)
        order.orderNo = result.getString(1)
        order.totalAmount = result.getDouble(3)
        order.status = result.getString(4) as OrderStatus
        order.paymentMethod = result.getString(5)
        order.paymentStatus = result.getString(6)
        order.shippingAddress = JSON.parse(result.getString(7))
        order.contactName = result.getString(8)
        order.contactPhone = result.getString(9)
        order.remark = result.getString(10)
        order.createdAt = result.getLong(11)
        order.updatedAt = result.getLong(12)
        orders.push(order)
      }

      return orders
    } catch (error) {
      console.error('获取订单失败:', error)
      return []
    }
  }

  // =================== 评论管理 ===================

  // 添加评论
  async addComment(comment: Omit<Comment, 'id' | 'createdAt' | 'updatedAt'>): Promise<boolean> {
    if (!this.store || !this.currentUserId) return false

    const timestamp = Date.now()
    const commentId = `comment_${timestamp}_${Math.random().toString(36).substr(2, 9)}`

    try {
      await this.store.executeSql(
        'INSERT INTO comments (id, product_id, user_account, user_name, ' +
        'user_avatar, rating, content, images, helpful_count, spec, ' +
        'created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          commentId,
          comment.productId,
          this.currentUserId,
          comment.userName,
          comment.userAvatar,
          comment.rating,
          comment.content,
          JSON.stringify(comment.images || []),
          comment.helpfulCount,
          comment.spec || '',
          timestamp,
          timestamp
        ]
      )

      console.log('评论添加成功:', commentId)
      return true
    } catch (error) {
      console.error('添加评论失败:', error)
      return false
    }
  }

  // 获取商品评论
  async getProductComments(productId: string): Promise<Comment[]> {
    if (!this.store) return []

    try {
      const result = await this.store.querySql(
        'SELECT * FROM comments WHERE product_id = ? ORDER BY created_at DESC',
        [productId]
      )

      const comments: Comment[] = []
      while (result.goToNextRow()) {
        const comment: Comment = {
          id: result.getString(0),
          productId: result.getString(1),
          userId: result.getString(2),
          userName: result.getString(3),
          userAvatar: result.getString(4),
          rating: result.getInt(5),
          content: result.getString(6),
          images: JSON.parse(result.getString(7) || '[]'),
          helpfulCount: result.getInt(8),
          spec: result.getString(9),
          createdAt: result.getLong(10),
          updatedAt: result.getLong(11)
        }
        comments.push(comment)
      }

      return comments
    } catch (error) {
      console.error('获取评论失败:', error)
      return []
    }
  }

  // 点赞评论
  async likeComment(commentId: string): Promise<boolean> {
    if (!this.store) return false

    try {
      const result = await this.store.executeSql(
        'UPDATE comments SET helpful_count = helpful_count + 1 WHERE id = ?',
        [commentId]
      )
      return result.changedRows > 0
    } catch (error) {
      console.error('点赞评论失败:', error)
      return false
    }
  }

  // =================== 地址管理 ===================

  // 保存地址
  async saveAddress(address: any): Promise<boolean> {
    if (!this.store || !this.currentUserId) return false

    const timestamp = Date.now()

    try {
      // 如果是默认地址，先将其他地址设为非默认
      if (address.isDefault) {
        await this.store.executeSql(
          'UPDATE addresses SET is_default = 0 WHERE user_account = ?',
          [this.currentUserId]
        )
      }

      if (address.id) {
        // 更新地址
        await this.store.executeSql(
          'UPDATE addresses SET receiver_name = ?, phone = ?, province = ?, ' +
          'city = ?, district = ?, detail = ?, is_default = ?, ' +
          'updated_at = ? WHERE id = ? AND user_account = ?',
          [
            address.receiverName,
            address.phone,
            address.province,
            address.city,
            address.district,
            address.detail,
            address.isDefault ? 1 : 0,
            timestamp,
            address.id,
            this.currentUserId
          ]
        )
      } else {
        // 新增地址
        await this.store.executeSql(
          'INSERT INTO addresses (user_account, receiver_name, phone, ' +
          'province, city, district, detail, is_default, ' +
          'created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            this.currentUserId,
            address.receiverName,
            address.phone,
            address.province,
            address.city,
            address.district,
            address.detail,
            address.isDefault ? 1 : 0,
            timestamp,
            timestamp
          ]
        )
      }

      console.log('地址保存成功')
      return true
    } catch (error) {
      console.error('保存地址失败:', error)
      return false
    }
  }

  // 获取地址列表
  async getAddresses(): Promise<any[]> {
    if (!this.store || !this.currentUserId) return []

    try {
      const result = await this.store.querySql(
        'SELECT * FROM addresses WHERE user_account = ? ORDER BY is_default DESC, created_at DESC',
        [this.currentUserId]
      )

      const addresses: any[] = []
      while (result.goToNextRow()) {
        addresses.push({
          id: result.getLong(0),
          receiverName: result.getString(2),
          phone: result.getString(3),
          province: result.getString(4),
          city: result.getString(5),
          district: result.getString(6),
          detail: result.getString(7),
          isDefault: result.getInt(8) === 1
        })
      }

      return addresses
    } catch (error) {
      console.error('获取地址失败:', error)
      return []
    }
  }

  // 删除地址
  async deleteAddress(id: number): Promise<boolean> {
    if (!this.store) return false

    try {
      const result = await this.store.executeSql(
        'DELETE FROM addresses WHERE id = ?',
        [id]
      )
      return result.changedRows > 0
    } catch (error) {
      console.error('删除地址失败:', error)
      return false
    }
  }

  // =================== 清理和关闭 ===================

  // 清空用户所有数据
  async clearUserData(): Promise<boolean> {
    if (!this.store || !this.currentUserId) return false

    try {
      // 删除用户相关的所有数据
      await this.store.executeSql('DELETE FROM cart_items WHERE user_account = ?', [this.currentUserId])
      await this.store.executeSql('DELETE FROM comments WHERE user_account = ?', [this.currentUserId])
      await this.store.executeSql('DELETE FROM addresses WHERE user_account = ?', [this.currentUserId])

      console.log('用户数据清理成功')
      return true
    } catch (error) {
      console.error('清理用户数据失败:', error)
      return false
    }
  }

  // 关闭数据库连接
  async close(): Promise<void> {
    if (this.store) {
      await this.store.close()
      this.store = null
    }
  }
}