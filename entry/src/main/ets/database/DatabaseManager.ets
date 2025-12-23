import relationalStore from '@ohos.data.relationalStore'
import common from '@ohos.app.ability.common'

import { User, Comment, Address, Order } from '../model/DataModel'
import { ProductModel } from '../model/ProductModel'
import { BusinessError } from '../model/BusinessError'

type UserRole = 'admin' | 'user'

export interface ProductRow {
  id: string
  name: string
  price: number
  originalPrice: number
  description: string
  detailDescription: string
  category: string
  tags: string[]
  images: ResourceStr[]
  rating: number
  reviewCount: number
  stock: number
  sales: number
  isNew: boolean
  status: string
  spec: string
}

export interface CartRow {
  id: number
  user_account: string
  product_id: string
  quantity: number
  selected: boolean
  spec: string
  addedTime: number
}

export interface CartPatch {
  quantity?: number
  selected?: boolean
}

export interface UserProfilePatch {
  username?: string
  email?: string
  phone?: string
  avatar?: string
  realName?: string
  gender?: 'male' | 'female' | 'unknown'
  birthday?: string
  lastLoginTime?: number
  totalSpent?: number
  points?: number
  level?: 'bronze' | 'silver' | 'gold' | 'platinum'
}

/**
 * 统一数据库管理器（本地 RDB）
 */
export class DatabaseManager {
  private static instance: DatabaseManager

  private store: relationalStore.RdbStore | null = null
  private context: common.UIAbilityContext | null = null

  private readonly DB_NAME: string = 'huawei_mall.db'
  private currentUserAccount: string | null = null

  private constructor() {}

  public static getInstance(): DatabaseManager {
    if (!DatabaseManager.instance) {
      DatabaseManager.instance = new DatabaseManager()
    }
    return DatabaseManager.instance
  }

  /**
   * 初始化数据库
   */
  public async init(context: common.UIAbilityContext): Promise<void> {
    if (this.store) return

    this.context = context

    const config: relationalStore.StoreConfig = {
      name: this.DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    }

    try {
      this.store = await relationalStore.getRdbStore(context, config)
      await this.createTables()
      await this.seedAdminIfNeeded()
      console.info('[DB] init ok:', this.DB_NAME)
    } catch (e) {
      console.error('[DB] init failed:', e)
      throw new BusinessError('DATABASE_INIT_ERROR', '数据库初始化失败')
    }
  }

  private ensureStore(): relationalStore.RdbStore {
    if (!this.store) {
      throw new BusinessError('DATABASE_NOT_INITIALIZED', '数据库未初始化，请先调用 init(context)')
    }
    return this.store
  }

  public setCurrentUserAccount(account: string | null): void {
    this.currentUserAccount = account
  }

  public getCurrentUserAccount(): string | null {
    return this.currentUserAccount
  }

  // -----------------------------
  // 1) 表结构
  // -----------------------------
  private async createTables(): Promise<void> {
    const db: relationalStore.RdbStore = this.ensureStore()

    await db.executeSql(`
      CREATE TABLE IF NOT EXISTS users (
        account TEXT PRIMARY KEY,
        password TEXT NOT NULL,
        username TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        avatar TEXT,
        realName TEXT,
        gender TEXT,
        birthday TEXT,
        role TEXT NOT NULL DEFAULT 'user',
        registrationTime INTEGER NOT NULL,
        lastLoginTime INTEGER,
        totalSpent REAL DEFAULT 0,
        points INTEGER DEFAULT 0,
        level TEXT DEFAULT 'bronze'
      )
    `)

    await db.executeSql(`
      CREATE TABLE IF NOT EXISTS products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        originalPrice REAL,
        description TEXT,
        detailDescription TEXT,
        category TEXT,
        tags TEXT,
        rating REAL DEFAULT 5.0,
        reviewCount INTEGER DEFAULT 0,
        stock INTEGER DEFAULT 0,
        sales INTEGER DEFAULT 0,
        isNew INTEGER DEFAULT 0,
        status TEXT DEFAULT 'active',
        spec TEXT,
        images_json TEXT DEFAULT '[]',
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        createdBy TEXT
      )
    `)

    await db.executeSql(`
      CREATE TABLE IF NOT EXISTS cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_account TEXT NOT NULL,
        product_id TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        selected INTEGER DEFAULT 1,
        spec TEXT DEFAULT '',
        addedTime INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        UNIQUE(user_account, product_id, spec)
      )
    `)

    await db.executeSql(`
      CREATE TABLE IF NOT EXISTS comments (
        id TEXT PRIMARY KEY,
        product_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        username TEXT NOT NULL,
        avatar TEXT,
        rating INTEGER NOT NULL,
        content TEXT NOT NULL,
        images_json TEXT DEFAULT '[]',
        likes INTEGER DEFAULT 0,
        isLiked INTEGER DEFAULT 0,
        replyTo TEXT,
        isTopComment INTEGER DEFAULT 0,
        createTime INTEGER NOT NULL
      )
    `)

    await db.executeSql(`
      CREATE TABLE IF NOT EXISTS addresses (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT,
        phone TEXT,
        province TEXT,
        city TEXT,
        district TEXT,
        detail TEXT,
        isDefault INTEGER DEFAULT 0,
        updatedAt INTEGER NOT NULL
      )
    `)

    await db.executeSql(`
      CREATE TABLE IF NOT EXISTS orders (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        items_json TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        status TEXT NOT NULL,
        shippingAddress_json TEXT NOT NULL,
        paymentMethod TEXT,
        orderTime INTEGER NOT NULL,
        paymentTime INTEGER,
        shippingTime INTEGER,
        deliveryTime INTEGER,
        trackingNumber TEXT
      )
    `)

    console.info('[DB] tables ensured')
  }

  private async seedAdminIfNeeded(): Promise<void> {
    const admin: User | null = await this.getUserByAccount('admin')
    if (admin) return

    const now: number = Date.now()
    const user: User = new User('admin', 'admin123')
    user.username = '管理员'
    user.registrationTime = now
    user.lastLoginTime = now
    user.level = 'platinum'
    user.points = 0
    user.totalSpent = 0

    await this.insertOrReplaceUser(user, 'admin')
    console.info('[DB] admin seeded: admin / admin123')
  }

  // ✅ 新增：初始化商品数据（解决 EntryAbility 报错）
  public async seedProducts(): Promise<void> {
    const products = await this.getAllProducts()
    if (products.length > 0) return

    // 如果没有商品，可以在这里插入一些默认数据
    // 注意：这里仅作示例，你可以根据 ProductModel 的构造函数自行调整
    console.info('[DB] seedProducts: No products found, skipping seed for now.')
  }

  // -----------------------------
  // 2) 用户（注册/登录/资料）
  // -----------------------------
  private async insertOrReplaceUser(user: User, role: UserRole): Promise<boolean> {
    const db: relationalStore.RdbStore = this.ensureStore()

    const values: (string | number)[] = [
      user.account,
      user.password,
      user.username,
      user.email || '',
      user.phone || '',
      user.avatar || '',
      user.realName || '',
      user.gender || 'unknown',
      user.birthday || '',
      role,
      user.registrationTime || Date.now(),
      user.lastLoginTime || Date.now(),
      user.totalSpent || 0,
      user.points || 0,
      user.level || 'bronze'
    ]

    try {
      await db.executeSql(`
        INSERT OR REPLACE INTO users
        (account, password, username, email, phone, avatar, realName, gender, birthday, role,
         registrationTime, lastLoginTime, totalSpent, points, level)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `, values)
      return true
    } catch (e) {
      console.error('[DB] save user failed:', e)
      return false
    }
  }

  public async registerUser(account: string, password: string): Promise<boolean> {
    if (!account.trim() || !password.trim()) {
      throw new BusinessError('INVALID_PARAM', '账号或密码不能为空')
    }

    const exists: User | null = await this.getUserByAccount(account)
    if (exists) {
      throw new BusinessError('USER_EXISTS', '账号已存在')
    }

    const u: User = new User(account, password)
    u.registrationTime = Date.now()
    u.lastLoginTime = Date.now()

    const ok: boolean = await this.insertOrReplaceUser(u, 'user')
    if (ok) this.setCurrentUserAccount(account)
    return ok
  }

  public async login(account: string, password: string): Promise<User | null> {
    const user: User | null = await this.getUserByAccount(account)
    if (!user) return null
    if (user.password !== password) return null

    user.lastLoginTime = Date.now()
    await this.updateUserProfile(user.account, { lastLoginTime: user.lastLoginTime })

    this.setCurrentUserAccount(account)
    return user
  }

  public async getUserByAccount(account: string): Promise<User | null> {
    const db: relationalStore.RdbStore = this.ensureStore()
    let rs: relationalStore.ResultSet | null = null

    try {
      rs = await db.querySql('SELECT * FROM users WHERE account = ?', [account])
      if (rs.rowCount <= 0) return null

      rs.goToFirstRow()

      const u: User = new User(rs.getString(0), rs.getString(1))
      u.username = rs.getString(2)
      u.email = rs.getString(3)
      u.phone = rs.getString(4)
      u.avatar = rs.getString(5)
      u.realName = rs.getString(6)
      u.gender = (rs.getString(7) as 'male' | 'female' | 'unknown') || 'unknown'
      u.birthday = rs.getString(8)
      u.registrationTime = rs.getLong(10)
      u.lastLoginTime = rs.getLong(11)
      u.totalSpent = rs.getDouble(12)
      u.points = rs.getLong(13)
      u.level = (rs.getString(14) as 'bronze' | 'silver' | 'gold' | 'platinum') || 'bronze'
      return u
    } catch (e) {
      console.error('[DB] getUserByAccount failed:', e)
      return null
    } finally {
      rs?.close()
    }
  }

  public async isAdmin(account?: string): Promise<boolean> {
    const a: string | null = account || this.currentUserAccount
    if (!a) return false

    const db: relationalStore.RdbStore = this.ensureStore()
    let rs: relationalStore.ResultSet | null = null

    try {
      rs = await db.querySql('SELECT role FROM users WHERE account = ?', [a])
      if (rs.rowCount <= 0) return false
      rs.goToFirstRow()
      return rs.getString(0) === 'admin'
    } catch (e) {
      console.error('[DB] isAdmin failed:', e)
      return false
    } finally {
      rs?.close()
    }
  }

  public async updateUserProfile(account: string, patch: UserProfilePatch): Promise<boolean> {
    const db: relationalStore.RdbStore = this.ensureStore()

    const sets: string[] = []
    const values: (string | number)[] = []

    if (patch.username !== undefined) { sets.push('username = ?'); values.push(patch.username) }
    if (patch.email !== undefined) { sets.push('email = ?'); values.push(patch.email) }
    if (patch.phone !== undefined) { sets.push('phone = ?'); values.push(patch.phone) }
    if (patch.avatar !== undefined) { sets.push('avatar = ?'); values.push(patch.avatar) }
    if (patch.realName !== undefined) { sets.push('realName = ?'); values.push(patch.realName) }
    if (patch.gender !== undefined) { sets.push('gender = ?'); values.push(patch.gender) }
    if (patch.birthday !== undefined) { sets.push('birthday = ?'); values.push(patch.birthday) }
    if (patch.lastLoginTime !== undefined) { sets.push('lastLoginTime = ?'); values.push(patch.lastLoginTime) }
    if (patch.totalSpent !== undefined) { sets.push('totalSpent = ?'); values.push(patch.totalSpent) }
    if (patch.points !== undefined) { sets.push('points = ?'); values.push(patch.points) }
    if (patch.level !== undefined) { sets.push('level = ?'); values.push(patch.level) }

    if (sets.length === 0) return true

    values.push(account)

    try {
      await db.executeSql(`UPDATE users SET ${sets.join(', ')} WHERE account = ?`, values)
      return true
    } catch (e) {
      console.error('[DB] updateUserProfile failed:', e)
      return false
    }
  }

  // -----------------------------
  // 3) 商品
  // -----------------------------
  public async upsertProduct(product: ProductModel, createdBy?: string): Promise<boolean> {
    const db: relationalStore.RdbStore = this.ensureStore()
    const now: number = Date.now()

    const tagsJson: string = JSON.stringify(product.tags || [])
    const imagesJson: string = JSON.stringify(product.images || [])

    try {
      await db.executeSql(`
        INSERT OR REPLACE INTO products
        (id, name, price, originalPrice, description, detailDescription, category, tags,
         rating, reviewCount, stock, sales, isNew, status, spec, images_json,
         createdAt, updatedAt, createdBy)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `, [
        product.id,
        product.name,
        product.price,
        product.originalPrice,
        product.description || '',
        product.detailDescription || '',
        product.category || '',
        tagsJson,
        product.rating || 5.0,
        product.reviewCount || 0,
        product.stock || 0,
        product.sales || 0,
        product.isNew ? 1 : 0,
        product.status || 'active',
        product.spec || '标准版',
        imagesJson,
        now,
        now,
        createdBy || this.currentUserAccount || ''
      ])
      return true
    } catch (e) {
      console.error('[DB] upsertProduct failed:', e)
      return false
    }
  }

  public async insertProduct(product: ProductModel): Promise<boolean> {
    if (!product.id || product.id === '0') product.id = `${Date.now()}`
    if (!product.status) product.status = 'active'
    return this.upsertProduct(product, this.currentUserAccount || '')
  }

  public async updateProduct(_id: number, product: ProductModel): Promise<boolean> {
    if (!product.id || product.id === '0') {
      throw new BusinessError('INVALID_PRODUCT_ID', '商品ID无效，无法更新')
    }
    return this.upsertProduct(product, this.currentUserAccount || '')
  }

  public async deleteProduct(id: number): Promise<boolean> {
    return this.setProductStatus(String(id), 'deleted')
  }

  public async setProductStatus(productId: string, status: string): Promise<boolean> {
    const db: relationalStore.RdbStore = this.ensureStore()
    try {
      await db.executeSql('UPDATE products SET status = ?, updatedAt = ? WHERE id = ?', [
        status,
        Date.now(),
        productId
      ])
      return true
    } catch (e) {
      console.error('[DB] setProductStatus failed:', e)
      return false
    }
  }

  // ✅ 新增：根据 ID 获取单个商品（解决 CartService 报错）
  public async getProductById(id: string): Promise<ProductRow | null> {
    const db: relationalStore.RdbStore = this.ensureStore()
    let rs: relationalStore.ResultSet | null = null

    try {
      rs = await db.querySql('SELECT * FROM products WHERE id = ?', [id])
      if (rs.rowCount <= 0) return null
      rs.goToFirstRow()

      const tagsStr = rs.getString(rs.getColumnIndex('tags'))
      const tags = tagsStr ? (JSON.parse(tagsStr) as string[]) : []

      const imagesStr = rs.getString(rs.getColumnIndex('images_json'))
      let images: ResourceStr[] = []
      try {
        if (imagesStr) images = JSON.parse(imagesStr)
      } catch (e) {
        console.error('[DB] parse images failed:', e)
      }

      return {
        id: rs.getString(rs.getColumnIndex('id')),
        name: rs.getString(rs.getColumnIndex('name')),
        price: rs.getDouble(rs.getColumnIndex('price')),
        originalPrice: rs.getDouble(rs.getColumnIndex('originalPrice')),
        description: rs.getString(rs.getColumnIndex('description')),
        detailDescription: rs.getString(rs.getColumnIndex('detailDescription')),
        category: rs.getString(rs.getColumnIndex('category')),
        tags,
        images,
        rating: rs.getDouble(rs.getColumnIndex('rating')),
        reviewCount: rs.getLong(rs.getColumnIndex('reviewCount')),
        stock: rs.getLong(rs.getColumnIndex('stock')),
        sales: rs.getLong(rs.getColumnIndex('sales')),
        isNew: rs.getLong(rs.getColumnIndex('isNew')) === 1,
        status: rs.getString(rs.getColumnIndex('status')),
        spec: rs.getString(rs.getColumnIndex('spec'))
      }
    } catch (e) {
      console.error('[DB] getProductById failed:', e)
      return null
    } finally {
      rs?.close()
    }
  }

  public async getAllProducts(status?: string): Promise<ProductRow[]> {
    const db: relationalStore.RdbStore = this.ensureStore()

    const sql: string = status
      ? 'SELECT id,name,price,originalPrice,description,detailDescription,category,tags,rating,reviewCount,stock,sales,isNew,status,spec,images_json FROM products WHERE status = ? ORDER BY updatedAt DESC'
      : 'SELECT id,name,price,originalPrice,description,detailDescription,category,tags,rating,reviewCount,stock,sales,isNew,status,spec,images_json FROM products ORDER BY updatedAt DESC'

    let rs: relationalStore.ResultSet | null = null
    try {
      rs = await db.querySql(sql, status ? [status] : [])
      const out: ProductRow[] = []

      while (rs.goToNextRow()) {
        const tagsStr: string = rs.getString(7)
        const tags: string[] = tagsStr ? (JSON.parse(tagsStr) as string[]) : []

        const imagesStr: string = rs.getString(15)
        let images: ResourceStr[] = []
        try {
          if (imagesStr) {
            images = JSON.parse(imagesStr)
          }
        } catch (e) {
          console.error('[DB] parse images failed:', e)
        }

        out.push({
          id: rs.getString(0),
          name: rs.getString(1),
          price: rs.getDouble(2),
          originalPrice: rs.getDouble(3),
          description: rs.getString(4),
          detailDescription: rs.getString(5),
          category: rs.getString(6),
          tags,
          rating: rs.getDouble(8),
          reviewCount: rs.getLong(9),
          stock: rs.getLong(10),
          sales: rs.getLong(11),
          isNew: rs.getLong(12) === 1,
          status: rs.getString(13),
          spec: rs.getString(14),
          images
        })
      }
      return out
    } catch (e) {
      console.error('[DB] getAllProducts failed:', e)
      return []
    } finally {
      rs?.close()
    }
  }

  // -----------------------------
  // 4) 购物车
  // -----------------------------
  public async addToCart(productId: string, quantity: number, spec: string): Promise<boolean> {
    const db: relationalStore.RdbStore = this.ensureStore()
    const account: string | null = this.currentUserAccount
    if (!account) throw new BusinessError('NOT_LOGIN', '请先登录')

    const now: number = Date.now()

    let rs: relationalStore.ResultSet | null = null
    try {
      rs = await db.querySql(
        'SELECT id, quantity FROM cart_items WHERE user_account = ? AND product_id = ? AND spec = ?',
        [account, productId, spec]
      )

      if (rs.rowCount > 0) {
        rs.goToFirstRow()
        const rowId: number = rs.getLong(0)
        const oldQty: number = rs.getLong(1)
        const newQty: number = oldQty + quantity
        await db.executeSql(
          'UPDATE cart_items SET quantity = ?, updatedAt = ? WHERE id = ?',
          [newQty, now, rowId]
        )
      } else {
        await db.executeSql(
          'INSERT INTO cart_items (user_account, product_id, quantity, selected, spec, addedTime, updatedAt) VALUES (?, ?, ?, ?, ?, ?, ?)',
          [account, productId, quantity, 1, spec, now, now]
        )
      }
      return true
    } catch (e) {
      console.error('[DB] addToCart failed:', e)
      return false
    } finally {
      rs?.close()
    }
  }

  public async updateCartItem(id: number, patch: CartPatch): Promise<boolean> {
    const db: relationalStore.RdbStore = this.ensureStore()
    const sets: string[] = []
    const values: (number)[] = []
    const now: number = Date.now()

    if (patch.quantity !== undefined) { sets.push('quantity = ?'); values.push(patch.quantity) }
    if (patch.selected !== undefined) { sets.push('selected = ?'); values.push(patch.selected ? 1 : 0) }

    if (sets.length === 0) return true

    sets.push('updatedAt = ?')
    values.push(now)
    values.push(id)

    try {
      await db.executeSql(`UPDATE cart_items SET ${sets.join(', ')} WHERE id = ?`, values)
      return true
    } catch (e) {
      console.error('[DB] updateCartItem failed:', e)
      return false
    }
  }

  public async removeCartItem(id: number): Promise<boolean> {
    const db: relationalStore.RdbStore = this.ensureStore()
    try {
      await db.executeSql('DELETE FROM cart_items WHERE id = ?', [id])
      return true
    } catch (e) {
      console.error('[DB] removeCartItem failed:', e)
      return false
    }
  }

  public async clearCart(): Promise<boolean> {
    const db: relationalStore.RdbStore = this.ensureStore()
    const account: string | null = this.currentUserAccount
    if (!account) throw new BusinessError('NOT_LOGIN', '请先登录')

    try {
      await db.executeSql('DELETE FROM cart_items WHERE user_account = ?', [account])
      return true
    } catch (e) {
      console.error('[DB] clearCart failed:', e)
      return false
    }
  }

  public async getCartRows(): Promise<CartRow[]> {
    const db: relationalStore.RdbStore = this.ensureStore()
    const account: string | null = this.currentUserAccount
    if (!account) return []

    let rs: relationalStore.ResultSet | null = null
    try {
      rs = await db.querySql(
        'SELECT id, user_account, product_id, quantity, selected, spec, addedTime FROM cart_items WHERE user_account = ? ORDER BY updatedAt DESC',
        [account]
      )
      const out: CartRow[] = []
      while (rs.goToNextRow()) {
        out.push({
          id: rs.getLong(0),
          user_account: rs.getString(1),
          product_id: rs.getString(2),
          quantity: rs.getLong(3),
          selected: rs.getLong(4) === 1,
          spec: rs.getString(5),
          addedTime: rs.getLong(6)
        })
      }
      return out
    } catch (e) {
      console.error('[DB] getCartRows failed:', e)
      return []
    } finally {
      rs?.close()
    }
  }

  // -----------------------------
  // 5) 评论
  // -----------------------------
  public async addComment(c: Comment): Promise<boolean> {
    const db: relationalStore.RdbStore = this.ensureStore()
    try {
      await db.executeSql(`
        INSERT OR REPLACE INTO comments
        (id, product_id, user_id, username, avatar, rating, content, images_json, likes, isLiked, replyTo, isTopComment, createTime)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `, [
        c.id,
        c.productId,
        c.userId,
        c.username,
        c.avatar || '',
        c.rating,
        c.content,
        JSON.stringify(c.images || []),
        c.likes || 0,
        c.isLiked ? 1 : 0,
        c.replyTo || '',
        c.isTopComment ? 1 : 0,
        c.createTime || Date.now()
      ])
      return true
    } catch (e) {
      console.error('[DB] addComment failed:', e)
      return false
    }
  }

  public async getCommentsByProduct(productId: string): Promise<Comment[]> {
    const db: relationalStore.RdbStore = this.ensureStore()
    let rs: relationalStore.ResultSet | null = null

    try {
      rs = await db.querySql(
        'SELECT id, product_id, user_id, username, avatar, rating, content, images_json, likes, isLiked, replyTo, isTopComment, createTime FROM comments WHERE product_id = ? ORDER BY createTime DESC',
        [productId]
      )

      const out: Comment[] = []
      while (rs.goToNextRow()) {
        const c: Comment = new Comment(
          rs.getString(1),
          rs.getString(2),
          rs.getString(3),
          Number(rs.getLong(5)),
          rs.getString(6)
        )
        c.id = rs.getString(0)
        c.avatar = rs.getString(4)
        c.images = rs.getString(7) ? (JSON.parse(rs.getString(7)) as string[]) : []
        c.likes = rs.getLong(8)
        c.isLiked = rs.getLong(9) === 1
        const replyToStr: string = rs.getString(10)
        c.replyTo = replyToStr ? replyToStr : undefined
        c.isTopComment = rs.getLong(11) === 1
        c.createTime = rs.getLong(12)
        out.push(c)
      }
      return out
    } catch (e) {
      console.error('[DB] getCommentsByProduct failed:', e)
      return []
    } finally {
      rs?.close()
    }
  }

  // ... 在 getCommentsByProduct 方法后面加入 ...

  // ✅ 新增：查询指定用户的所有评论
  public async getCommentsByUser(userId: string): Promise<Comment[]> {
    const db = this.ensureStore()
    // 假设 comments 表里 user_id 存的是账号
    const sql = 'SELECT * FROM comments WHERE user_id = ? ORDER BY createTime DESC'
    let rs: relationalStore.ResultSet | null = null
    const out: Comment[] = []

    try {
      rs = await db.querySql(sql, [userId])
      while (rs.goToNextRow()) {
        // id, product_id, user_id, username, avatar, rating, content, images_json, likes, isLiked, replyTo, isTopComment, createTime
        const c = new Comment(
          rs.getString(1), // product_id
          rs.getString(2), // user_id
          rs.getString(3), // username
          Number(rs.getLong(5)), // rating
          rs.getString(6)  // content
        )
        c.id = rs.getString(0)
        c.avatar = rs.getString(4)
        const imagesStr = rs.getString(7)
        c.images = imagesStr ? JSON.parse(imagesStr) : []
        c.likes = rs.getLong(8)
        c.isLiked = rs.getLong(9) === 1
        c.createTime = rs.getLong(12)
        out.push(c)
      }
    } catch (e) {
      console.error('[DB] getCommentsByUser failed:', e)
    } finally {
      rs?.close()
    }
    return out
  }

  // ... 后面是 deleteReview 等方法 ...


  public async likeComment(commentId: string): Promise<boolean> {
    const db: relationalStore.RdbStore = this.ensureStore()
    try {
      await db.executeSql('UPDATE comments SET likes = likes + 1 WHERE id = ?', [commentId])
      return true
    } catch (e) {
      console.error('[DB] likeComment failed:', e)
      return false
    }
  }

  // -----------------------------
  // 6) 地址/订单
  // -----------------------------
  public async upsertAddress(addr: Address, userId: string): Promise<boolean> {
    const db: relationalStore.RdbStore = this.ensureStore()
    const now: number = Date.now()

    try {
      await db.executeSql(`
        INSERT OR REPLACE INTO addresses
        (id, user_id, name, phone, province, city, district, detail, isDefault, updatedAt)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `, [
        addr.id,
        userId,
        addr.name || '',
        addr.phone || '',
        addr.province || '',
        addr.city || '',
        addr.district || '',
        addr.detail || '',
        addr.isDefault ? 1 : 0,
        now
      ])
      return true
    } catch (e) {
      console.error('[DB] upsertAddress failed:', e)
      return false
    }
  }

  public async createOrder(order: Order): Promise<boolean> {
    const db: relationalStore.RdbStore = this.ensureStore()
    try {
      await db.executeSql(`
        INSERT OR REPLACE INTO orders
        (id, user_id, items_json, totalAmount, status, shippingAddress_json, paymentMethod, orderTime,
         paymentTime, shippingTime, deliveryTime, trackingNumber)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `, [
        order.id,
        order.userId,
        JSON.stringify(order.items || []),
        order.totalAmount,
        order.status,
        JSON.stringify(order.shippingAddress || {}),
        order.paymentMethod || '',
        order.orderTime || Date.now(),
        order.paymentTime || 0,
        order.shippingTime || 0,
        order.deliveryTime || 0,
        order.trackingNumber || ''
      ])
      return true
    } catch (e) {
      console.error('[DB] createOrder failed:', e)
      return false
    }
  }

  public async close(): Promise<void> {
    if (this.store) {
      await this.store.close()
      this.store = null
    }
  }
}