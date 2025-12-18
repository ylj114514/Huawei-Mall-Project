import relationalStore from '@ohos.data.relationalStore'
import { User } from '../model/DataModel'
import { ProductModel } from '../model/ProductModel'
import { Order } from '../model/OrderModel'
import { CartItem } from '../model/CartModel'

// 数据库表定义
export interface TableSchema {
  name: string
  columns: Array<{ name: string, type: string, nullable?: boolean, primary?: boolean }>
}

export class RDBManager {
  private static instance: RDBManager
  private store: relationalStore.RdbStore | null = null
  private dbName: string = 'huawei_mall.db'
  private isInitialized: boolean = false

  // 表定义
  private readonly TABLES: TableSchema[] = [
    {
      name: 'users',
      columns: [
        { name: 'id', type: 'INTEGER PRIMARY KEY AUTOINCREMENT' },
        { name: 'account', type: 'TEXT UNIQUE NOT NULL' },
        { name: 'password', type: 'TEXT NOT NULL' },
        { name: 'username', type: 'TEXT NOT NULL' },
        { name: 'email', type: 'TEXT' },
        { name: 'phone', type: 'TEXT' },
        { name: 'avatar', type: 'TEXT' },
        { name: 'role', type: 'TEXT DEFAULT "customer"' },
        { name: 'created_at', type: 'INTEGER NOT NULL' },
        { name: 'updated_at', type: 'INTEGER NOT NULL' }
      ]
    },
    {
      name: 'products',
      columns: [
        { name: 'id', type: 'TEXT PRIMARY KEY' },
        { name: 'name', type: 'TEXT NOT NULL' },
        { name: 'description', type: 'TEXT' },
        { name: 'detailDescription', type: 'TEXT' },
        { name: 'price', type: 'REAL NOT NULL' },
        { name: 'originalPrice', type: 'REAL' },
        { name: 'image', type: 'TEXT' },
        { name: 'images', type: 'TEXT' }, // JSON array
        { name: 'category', type: 'TEXT NOT NULL' },
        { name: 'tags', type: 'TEXT' }, // JSON array
        { name: 'stock', type: 'INTEGER DEFAULT 0' },
        { name: 'sales', type: 'INTEGER DEFAULT 0' },
        { name: 'rating', type: 'REAL DEFAULT 0' },
        { name: 'reviewCount', type: 'INTEGER DEFAULT 0' },
        { name: 'isNew', type: 'INTEGER DEFAULT 0' },
        { name: 'status', type: 'TEXT DEFAULT "active"' },
        { name: 'created_at', type: 'INTEGER NOT NULL' },
        { name: 'updated_at', type: 'INTEGER NOT NULL' }
      ]
    },
    {
      name: 'cart_items',
      columns: [
        { name: 'id', type: 'INTEGER PRIMARY KEY AUTOINCREMENT' },
        { name: 'user_id', type: 'INTEGER NOT NULL' },
        { name: 'product_id', type: 'TEXT NOT NULL' },
        { name: 'quantity', type: 'INTEGER NOT NULL' },
        { name: 'spec', type: 'TEXT' }, // 规格，如 "12GB+512GB"
        { name: 'created_at', type: 'INTEGER NOT NULL' },
        { name: 'FOREIGN KEY(user_id)', type: 'REFERENCES users(id)' },
        { name: 'FOREIGN KEY(product_id)', type: 'REFERENCES products(id)' }
      ]
    },
    {
      name: 'orders',
      columns: [
        { name: 'id', type: 'TEXT PRIMARY KEY' },
        { name: 'user_id', type: 'INTEGER NOT NULL' },
        { name: 'order_no', type: 'TEXT UNIQUE NOT NULL' },
        { name: 'total_amount', type: 'REAL NOT NULL' },
        { name: 'status', type: 'TEXT NOT NULL' }, // pending, paid, shipped, delivered, cancelled
        { name: 'payment_method', type: 'TEXT' },
        { name: 'payment_status', type: 'TEXT DEFAULT "unpaid"' },
        { name: 'shipping_address', type: 'TEXT' }, // JSON object
        { name: 'contact_name', type: 'TEXT NOT NULL' },
        { name: 'contact_phone', type: 'TEXT NOT NULL' },
        { name: 'remark', type: 'TEXT' },
        { name: 'created_at', type: 'INTEGER NOT NULL' },
        { name: 'updated_at', type: 'INTEGER NOT NULL' },
        { name: 'FOREIGN KEY(user_id)', type: 'REFERENCES users(id)' }
      ]
    },
    {
      name: 'order_items',
      columns: [
        { name: 'id', type: 'INTEGER PRIMARY KEY AUTOINCREMENT' },
        { name: 'order_id', type: 'TEXT NOT NULL' },
        { name: 'product_id', type: 'TEXT NOT NULL' },
        { name: 'product_name', type: 'TEXT NOT NULL' },
        { name: 'product_image', type: 'TEXT' },
        { name: 'price', type: 'REAL NOT NULL' },
        { name: 'quantity', type: 'INTEGER NOT NULL' },
        { name: 'spec', type: 'TEXT' },
        { name: 'FOREIGN KEY(order_id)', type: 'REFERENCES orders(id)' },
        { name: 'FOREIGN KEY(product_id)', type: 'REFERENCES products(id)' }
      ]
    },
    {
      name: 'favorites',
      columns: [
        { name: 'id', type: 'INTEGER PRIMARY KEY AUTOINCREMENT' },
        { name: 'user_id', type: 'INTEGER NOT NULL' },
        { name: 'product_id', type: 'TEXT NOT NULL' },
        { name: 'created_at', type: 'INTEGER NOT NULL' },
        { name: 'UNIQUE(user_id, product_id)', type: '' },
        { name: 'FOREIGN KEY(user_id)', type: 'REFERENCES users(id)' },
        { name: 'FOREIGN KEY(product_id)', type: 'REFERENCES products(id)' }
      ]
    },
    {
      name: 'addresses',
      columns: [
        { name: 'id', type: 'INTEGER PRIMARY KEY AUTOINCREMENT' },
        { name: 'user_id', type: 'INTEGER NOT NULL' },
        { name: 'receiver_name', type: 'TEXT NOT NULL' },
        { name: 'phone', type: 'TEXT NOT NULL' },
        { name: 'province', type: 'TEXT NOT NULL' },
        { name: 'city', type: 'TEXT NOT NULL' },
        { name: 'district', type: 'TEXT NOT NULL' },
        { name: 'detail', type: 'TEXT NOT NULL' },
        { name: 'is_default', type: 'INTEGER DEFAULT 0' },
        { name: 'created_at', type: 'INTEGER NOT NULL' },
        { name: 'updated_at', type: 'INTEGER NOT NULL' },
        { name: 'FOREIGN KEY(user_id)', type: 'REFERENCES users(id)' }
      ]
    },
    {
      name: 'comments',
      columns: [
        { name: 'id', type: 'TEXT PRIMARY KEY' },
        { name: 'product_id', type: 'TEXT NOT NULL' },
        { name: 'user_id', type: 'INTEGER NOT NULL' },
        { name: 'user_name', type: 'TEXT NOT NULL' },
        { name: 'rating', type: 'INTEGER NOT NULL' },
        { name: 'content', type: 'TEXT NOT NULL' },
        { name: 'images', type: 'TEXT' }, // JSON array
        { name: 'helpful_count', type: 'INTEGER DEFAULT 0' },
        { name: 'spec', type: 'TEXT' },
        { name: 'created_at', type: 'INTEGER NOT NULL' },
        { name: 'updated_at', type: 'INTEGER NOT NULL' },
        { name: 'FOREIGN KEY(product_id)', type: 'REFERENCES products(id)' },
        { name: 'FOREIGN KEY(user_id)', type: 'REFERENCES users(id)' }
      ]
    }
  ]

  static getInstance(): RDBManager {
    if (!RDBManager.instance) {
      RDBManager.instance = new RDBManager()
    }
    return RDBManager.instance
  }

  // 初始化数据库
  async init(): Promise<void> {
    if (this.isInitialized && this.store) {
      return
    }

    const config: relationalStore.StoreConfig = {
      name: this.dbName,
      securityLevel: relationalStore.SecurityLevel.S1
    }

    try {
      this.store = await relationalStore.getRdbStore(getContext(this), config)

      // 创建所有表
      for (const table of this.TABLES) {
        await this.createTable(table)
      }

      // 创建索引
      await this.createIndexes()

      this.isInitialized = true
      console.log('RDB数据库初始化成功')
    } catch (error) {
      console.error('RDB数据库初始化失败:', error)
      throw error
    }
  }

  // 创建表
  private async createTable(schema: TableSchema): Promise<void> {
    if (!this.store) return

    const columns = schema.columns.map(col => {
      let colDef = `${col.name} ${col.type}`
      if (col.primary) colDef += ' PRIMARY KEY'
      if (!col.nullable) colDef += ' NOT NULL'
      return colDef
    })

    const sql = `CREATE TABLE IF NOT EXISTS ${schema.name} (${columns.join(', ')})`
    try {
      await this.store.executeSql(sql)
      console.log(`创建表 ${schema.name} 成功`)
    } catch (error) {
      console.error(`创建表 ${schema.name} 失败:`, error)
      throw error
    }
  }

  // 创建索引
  private async createIndexes(): Promise<void> {
    if (!this.store) return

    const indexes = [
      'CREATE INDEX IF NOT EXISTS idx_users_account ON users(account)',
      'CREATE INDEX IF NOT EXISTS idx_cart_user_id ON cart_items(user_id)',
      'CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id)',
      'CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status)',
      'CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON favorites(user_id)',
      'CREATE INDEX IF NOT EXISTS idx_addresses_user_id ON addresses(user_id)',
      'CREATE INDEX IF NOT EXISTS idx_comments_product_id ON comments(product_id)',
      'CREATE INDEX IF NOT EXISTS idx_products_category ON products(category)',
      'CREATE INDEX IF NOT EXISTS idx_products_status ON products(status)'
    ]

    for (const sql of indexes) {
      try {
        await this.store.executeSql(sql)
      } catch (error) {
        console.error('创建索引失败:', error)
      }
    }
  }

  // 插入用户
  async insertUser(user: User): Promise<number> {
    if (!this.store) await this.init()
    if (!this.store) throw new Error('数据库未初始化')

    const values = [
      user.account,
      user.password,
      user.username,
      user.email || '',
      user.phone || '',
      user.avatar || '',
      user.role || 'customer',
      Date.now(),
      Date.now()
    ]

    const sql = `INSERT INTO users (account, password, username, email, phone, avatar, role, created_at, updated_at)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`

    try {
      const result = await this.store.executeSql(sql, values)
      return result.insertId || -1
    } catch (error) {
      console.error('插入用户失败:', error)
      throw error
    }
  }

  // 查询用户
  async findUserByAccount(account: string): Promise<User | null> {
    if (!this.store) await this.init()
    if (!this.store) throw new Error('数据库未初始化')

    const sql = 'SELECT * FROM users WHERE account = ?'
    const result = await this.store.querySql(sql, [account])

    if (result.rowCount > 0) {
      const row = result.goToFirstRow()
      const user: User = new User(
        row.getString(1), // account
        row.getString(2), // password
      )
      user.username = row.getString(3)
      user.email = row.getString(4)
      user.phone = row.getString(5)
      user.avatar = row.getString(6)
      user.role = row.getString(7)
      return user
    }

    return null
  }

  // 更新用户信息
  async updateUser(user: User): Promise<boolean> {
    if (!this.store) await this.init()
    if (!this.store) throw new Error('数据库未初始化')

    const sql = `UPDATE users SET username = ?, email = ?, phone = ?, avatar = ?, updated_at = ?
                 WHERE account = ?`
    const values = [
      user.username,
      user.email || '',
      user.phone || '',
      user.avatar || '',
      Date.now(),
      user.account
    ]

    try {
      const result = await this.store.executeSql(sql, values)
      return result.changedRows > 0
    } catch (error) {
      console.error('更新用户失败:', error)
      throw error
    }
  }

  // 插入商品
  async insertProduct(product: ProductModel): Promise<void> {
    if (!this.store) await this.init()
    if (!this.store) throw new Error('数据库未初始化')

    const values = [
      product.id,
      product.name,
      product.description,
      product.detailDescription || '',
      product.price,
      product.originalPrice,
      product.image,
      JSON.stringify(product.images || []),
      product.category,
      JSON.stringify(product.tags || []),
      product.stock || 0,
      product.sales || 0,
      product.rating || 0,
      product.reviewCount || 0,
      product.isNew ? 1 : 0,
      product.status || 'active',
      Date.now(),
      Date.now()
    ]

    const sql = `INSERT OR REPLACE INTO products
                 (id, name, description, detailDescription, price, originalPrice, image, images,
                  category, tags, stock, sales, rating, reviewCount, isNew, status, created_at, updated_at)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`

    try {
      await this.store.executeSql(sql, values)
    } catch (error) {
      console.error('插入商品失败:', error)
      throw error
    }
  }

  // 获取商品列表
  async getProducts(category?: string, limit?: number): Promise<ProductModel[]> {
    if (!this.store) await this.init()
    if (!this.store) throw new Error('数据库未初始化')

    let sql = 'SELECT * FROM products WHERE status = "active"'
    const params: string[] = []

    if (category && category !== '全部') {
      sql += ' AND category = ?'
      params.push(category)
    }

    sql += ' ORDER BY created_at DESC'

    if (limit) {
      sql += ' LIMIT ?'
      params.push(limit.toString())
    }

    const result = await this.store.querySql(sql, params)
    const products: ProductModel[] = []

    while (result.goToNextRow()) {
      const product = new ProductModel(
        result.getString(0), // id
        result.getString(1), // name
        result.getDouble(4), // price
        result.getString(7), // image
        result.getString(8)  // category
      )
      product.description = result.getString(2)
      product.detailDescription = result.getString(3)
      product.originalPrice = result.getDouble(5)
      product.images = JSON.parse(result.getString(6) || '[]')
      product.tags = JSON.parse(result.getString(9) || '[]')
      product.stock = result.getLong(10)
      product.sales = result.getLong(11)
      product.rating = result.getDouble(12)
      product.reviewCount = result.getLong(13)
      product.isNew = result.getLong(14) === 1
      product.status = result.getString(15)
      products.push(product)
    }

    return products
  }

  // 添加到购物车
  async addToCart(userId: number, productId: string, quantity: number, spec?: string): Promise<void> {
    if (!this.store) await this.init()
    if (!this.store) throw new Error('数据库未初始化')

    // 先检查是否已存在
    const checkSql = 'SELECT id, quantity FROM cart_items WHERE user_id = ? AND product_id = ?'
    const result = await this.store.querySql(checkSql, [userId, productId])

    if (result.rowCount > 0) {
      // 更新数量
      const row = result.goToFirstRow()
      const existingQuantity = row.getLong(1)
      const updateSql = 'UPDATE cart_items SET quantity = ?, updated_at = ? WHERE id = ?'
      await this.store.executeSql(updateSql, [existingQuantity + quantity, Date.now(), row.getLong(0)])
    } else {
      // 插入新记录
      const insertSql = 'INSERT INTO cart_items (user_id, product_id, quantity, spec, created_at) VALUES (?, ?, ?, ?, ?)'
      await this.store.executeSql(insertSql, [userId, productId, quantity, spec || '', Date.now()])
    }
  }

  // 获取购物车商品
  async getCartItems(userId: number): Promise<CartItem[]> {
    if (!this.store) await this.init()
    if (!this.store) throw new Error('数据库未初始化')

    const sql = `SELECT ci.*, p.name, p.price, p.image, p.stock
                 FROM cart_items ci
                 INNER JOIN products p ON ci.product_id = p.id
                 WHERE ci.user_id = ?`

    const result = await this.store.querySql(sql, [userId])
    const items: CartItem[] = []

    while (result.goToNextRow()) {
      const item = new CartItem(
        result.getString(1), // product_id
        result.getLong(2),   // quantity
        result.getString(3)  // spec
      )
      item.id = result.getLong(0)
      item.name = result.getString(4)
      item.price = result.getDouble(5)
      item.image = result.getString(6)
      item.stock = result.getLong(7)
      items.push(item)
    }

    return items
  }

  // 关闭数据库
  async close(): Promise<void> {
    if (this.store) {
      await this.store.close()
      this.store = null
      this.isInitialized = false
    }
  }
}