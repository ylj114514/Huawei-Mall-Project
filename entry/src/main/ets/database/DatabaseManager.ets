import relationalStore from '@ohos.data.relationalStore'
import { Context } from '@ohos.app.ability.common'
import {
  UserSchema,
  ProductSchema,
  CartSchema,
  OrderSchema,
  UserRole,
  UserStatus,
  ProductStatus,
  OrderStatus,
  PaymentMethod,
  TABLE_NAMES,
  DB_NAME,
  DB_VERSION
} from '../model/DatabaseSchema'
import { BusinessError } from '../model/BusinessError'

/**
 * RDB 数据库管理器
 */
export class DatabaseManager {
  private static instance: DatabaseManager
  private store: relationalStore.RdbStore | null = null
  private context: Context | null = null

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
  public async init(context: Context): Promise<void> {
    this.context = context

    const config: relationalStore.StoreConfig = {
      name: DB_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    }

    try {
      this.store = await relationalStore.getRdbStore(context, config)
      console.info('Database initialized successfully')
      await this.createTables()
    } catch (error) {
      console.error('Failed to initialize database:', error)
      throw new BusinessError('DATABASE_INIT_ERROR', '数据库初始化失败')
    }
  }

  /**
   * 确保数据库已初始化
   */
  private ensureInitialized(): void {
    if (!this.store) {
      throw new BusinessError('DATABASE_NOT_INITIALIZED', '数据库未初始化')
    }
  }

  /**
   * 创建数据表
   */
  private async createTables(): Promise<void> {
    this.ensureInitialized()

    // 创建用户表
    await this.store.executeSql(`
      CREATE TABLE IF NOT EXISTS ${TABLE_NAMES.USER} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        username TEXT NOT NULL,
        role TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        avatar TEXT,
        status TEXT NOT NULL,
        createTime INTEGER NOT NULL,
        updateTime INTEGER NOT NULL
      )
    `)

    // 创建商品表
    await this.store.executeSql(`
      CREATE TABLE IF NOT EXISTS ${TABLE_NAMES.PRODUCT} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        detailDescription TEXT,
        price REAL NOT NULL,
        originalPrice REAL,
        stock INTEGER NOT NULL,
        images TEXT,
        category TEXT NOT NULL,
        brand TEXT,
        model TEXT,
        color TEXT,
        storage TEXT,
        spec TEXT,
        tags TEXT,
        rating REAL DEFAULT 5.0,
        reviewCount INTEGER DEFAULT 0,
        status TEXT NOT NULL,
        createTime INTEGER NOT NULL,
        updateTime INTEGER NOT NULL,
        createdBy INTEGER
      )
    `)

    // 创建购物车表
    await this.store.executeSql(`
      CREATE TABLE IF NOT EXISTS ${TABLE_NAMES.CART} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        productId INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        selected INTEGER DEFAULT 1,
        spec TEXT,
        createTime INTEGER NOT NULL,
        updateTime INTEGER NOT NULL,
        FOREIGN KEY (userId) REFERENCES ${TABLE_NAMES.USER}(id),
        FOREIGN KEY (productId) REFERENCES ${TABLE_NAMES.PRODUCT}(id),
        UNIQUE(userId, productId)
      )
    `)

    // 创建订单表
    await this.store.executeSql(`
      CREATE TABLE IF NOT EXISTS ${TABLE_NAMES.ORDER} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderNo TEXT UNIQUE NOT NULL,
        userId INTEGER NOT NULL,
        totalAmount REAL NOT NULL,
        status TEXT NOT NULL,
        paymentMethod TEXT,
        address TEXT,
        items TEXT,
        createTime INTEGER NOT NULL,
        updateTime INTEGER NOT NULL,
        payTime INTEGER,
        deliveryTime INTEGER,
        completeTime INTEGER,
        FOREIGN KEY (userId) REFERENCES ${TABLE_NAMES.USER}(id)
      )
    `)

    // 创建索引
    await this.createIndexes()
  }

  /**
   * 创建索引
   */
  private async createIndexes(): Promise<void> {
    this.ensureInitialized()

    // 用户表索引
    await this.store.executeSql(`CREATE INDEX IF NOT EXISTS idx_user_account ON ${TABLE_NAMES.USER}(account)`)
    await this.store.executeSql(`CREATE INDEX IF NOT EXISTS idx_user_role ON ${TABLE_NAMES.USER}(role)`)

    // 商品表索引
    await this.store.executeSql(`CREATE INDEX IF NOT EXISTS idx_product_category ON ${TABLE_NAMES.PRODUCT}(category)`)
    await this.store.executeSql(`CREATE INDEX IF NOT EXISTS idx_product_status ON ${TABLE_NAMES.PRODUCT}(status)`)

    // 购物车表索引
    await this.store.executeSql(`CREATE INDEX IF NOT EXISTS idx_cart_userId ON ${TABLE_NAMES.CART}(userId)`)

    // 订单表索引
    await this.store.executeSql(`CREATE INDEX IF NOT EXISTS idx_order_userId ON ${TABLE_NAMES.ORDER}(userId)`)
    await this.store.executeSql(`CREATE INDEX IF NOT EXISTS idx_order_status ON ${TABLE_NAMES.ORDER}(status)`)
  }

  // =================== 用户管理 ===================

  /**
   * 创建用户
   */
  public async createUser(user: Omit<UserSchema, 'id' | 'createTime' | 'updateTime'>): Promise<number> {
    this.ensureInitialized()

    const now = Date.now()
    const values: relationalStore.ValuesBucket = {
      account: user.account,
      password: user.password,
      username: user.username,
      role: user.role,
      phone: user.phone,
      email: user.email,
      avatar: user.avatar,
      status: user.status,
      createTime: now,
      updateTime: now
    }

    try {
      const rowId = await this.store.insert(TABLE_NAMES.USER, values)
      return rowId
    } catch (error) {
      console.error('Failed to create user:', error)
      throw new BusinessError('CREATE_USER_ERROR', '创建用户失败')
    }
  }

  /**
   * 根据账号查询用户
   */
  public async getUserByAccount(account: string): Promise<UserSchema | null> {
    this.ensureInitialized()

    const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.USER)
    predicates.equalTo('account', account)

    try {
      const result = await this.store.query(predicates, ['*'])
      if (result.rowCount > 0) {
        result.goToFirstRow()
        const user = this.resultToUser(result)
        result.close()
        return user
      }
      result.close()
      return null
    } catch (error) {
      console.error('Failed to query user:', error)
      throw new BusinessError('QUERY_USER_ERROR', '查询用户失败')
    }
  }

  /**
   * 查询所有管理员用户
   */
  public async getAdminUsers(): Promise<UserSchema[]> {
    this.ensureInitialized()

    const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.USER)
    predicates.equalTo('role', UserRole.ADMIN)

    try {
      const result = await this.store.query(predicates, ['*'])
      const users: UserSchema[] = []

      if (result.rowCount > 0) {
        result.goToFirstRow()
        do {
          users.push(this.resultToUser(result))
        } while (result.goToNextRow())
      }

      result.close()
      return users
    } catch (error) {
      console.error('Failed to query admin users:', error)
      throw new BusinessError('QUERY_ADMIN_USERS_ERROR', '查询管理员用户失败')
    }
  }

  // =================== 商品管理 ===================

  /**
   * 创建商品
   */
  public async createProduct(product: Omit<ProductSchema, 'id' | 'createTime' | 'updateTime'>): Promise<number> {
    this.ensureInitialized()

    const now = Date.now()
    const values: relationalStore.ValuesBucket = {
      name: product.name,
      description: product.description,
      detailDescription: product.detailDescription,
      price: product.price,
      originalPrice: product.originalPrice,
      stock: product.stock,
      images: JSON.stringify(product.images || []),
      category: product.category,
      brand: product.brand,
      model: product.model,
      color: product.color,
      storage: product.storage,
      spec: product.spec,
      tags: JSON.stringify(product.tags || []),
      rating: product.rating,
      reviewCount: product.reviewCount,
      status: product.status,
      createTime: now,
      updateTime: now,
      createdBy: product.createdBy
    }

    try {
      const rowId = await this.store.insert(TABLE_NAMES.PRODUCT, values)
      return rowId
    } catch (error) {
      console.error('Failed to create product:', error)
      throw new BusinessError('CREATE_PRODUCT_ERROR', '创建商品失败')
    }
  }

  /**
   * 查询所有商品
   */
  public async getAllProducts(status?: ProductStatus): Promise<ProductSchema[]> {
    this.ensureInitialized()

    const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.PRODUCT)
    if (status) {
      predicates.equalTo('status', status)
    }
    predicates.orderByDesc('createTime')

    try {
      const result = await this.store.query(predicates, ['*'])
      const products: ProductSchema[] = []

      if (result.rowCount > 0) {
        result.goToFirstRow()
        do {
          products.push(this.resultToProduct(result))
        } while (result.goToNextRow())
      }

      result.close()
      return products
    } catch (error) {
      console.error('Failed to query products:', error)
      throw new BusinessError('QUERY_PRODUCTS_ERROR', '查询商品失败')
    }
  }

  /**
   * 更新商品
   */
  public async updateProduct(id: number, updates: Partial<ProductSchema>): Promise<boolean> {
    this.ensureInitialized()

    const predicates = new relationalStore.RdbPredicates(TABLE_NAMES.PRODUCT)
    predicates.equalTo('id', id)

    const values: relationalStore.ValuesBucket = {
      ...updates,
      updateTime: Date.now()
    }

    // 处理数组和JSON字段
    if (updates.images) {
      values.images = JSON.stringify(updates.images)
    }
    if (updates.tags) {
      values.tags = JSON.stringify(updates.tags)
    }

    try {
      const rowsAffected = await this.store.update(values, predicates)
      return rowsAffected > 0
    } catch (error) {
      console.error('Failed to update product:', error)
      throw new BusinessError('UPDATE_PRODUCT_ERROR', '更新商品失败')
    }
  }

  /**
   * 删除商品（软删除）
   */
  public async deleteProduct(id: number): Promise<boolean> {
    this.ensureInitialized()

    return this.updateProduct(id, { status: ProductStatus.DELETED })
  }

  // =================== 工具方法 ===================

  /**
   * 将查询结果转换为用户对象
   */
  private resultToUser(result: relationalStore.ResultSet): UserSchema {
    return {
      id: result.getLong(0),
      account: result.getString(1),
      password: result.getString(2),
      username: result.getString(3),
      role: result.getString(4) as UserRole,
      phone: result.getString(5),
      email: result.getString(6),
      avatar: result.getString(7),
      status: result.getString(8) as UserStatus,
      createTime: result.getLong(9),
      updateTime: result.getLong(10)
    }
  }

  /**
   * 将查询结果转换为商品对象
   */
  private resultToProduct(result: relationalStore.ResultSet): ProductSchema {
    return {
      id: result.getLong(0),
      name: result.getString(1),
      description: result.getString(2),
      detailDescription: result.getString(3),
      price: result.getDouble(4),
      originalPrice: result.getDouble(5),
      stock: result.getLong(6),
      images: result.getString(7) ? JSON.parse(result.getString(7)) : [],
      category: result.getString(8),
      brand: result.getString(9),
      model: result.getString(10),
      color: result.getString(11),
      storage: result.getString(12),
      spec: result.getString(13),
      tags: result.getString(14) ? JSON.parse(result.getString(14)) : [],
      rating: result.getDouble(15),
      reviewCount: result.getLong(16),
      status: result.getString(17) as ProductStatus,
      createTime: result.getLong(18),
      updateTime: result.getLong(19),
      createdBy: result.getLong(20)
    }
  }

  /**
   * 关闭数据库连接
   */
  public async close(): Promise<void> {
    if (this.store) {
      await this.store.close()
      this.store = null
    }
  }
}