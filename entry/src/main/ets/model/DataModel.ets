import { ProductModel } from './ProductModel'

// 购物车商品项
export class CartItem {
  id: string
  product: ProductModel
  quantity: number
  selected: boolean
  addedTime: number

  constructor(product: ProductModel, quantity: number = 1) {
    this.id = `cart_${product.id}_${Date.now()}`
    this.product = product
    this.quantity = quantity
    this.selected = true
    this.addedTime = Date.now()
  }

  getSubtotal(): number {
    return this.product.price * this.quantity
  }

  increaseQuantity(): void {
    if (this.quantity < this.product.stock) {
      this.quantity++
    }
  }

  decreaseQuantity(): void {
    if (this.quantity > 1) {
      this.quantity--
    }
  }

  isValid(): boolean {
    return this.quantity <= this.product.stock && this.product.stock > 0
  }
}

// ✅ 核心修改：User 类深度适配 AGC 登录
export class User {
  id: string
  account: string
  password: string
  username: string
  email: string
  phone: string
  avatar: ResourceStr // 兼容 string URL 或 Resource
  realName: string
  gender: 'male' | 'female' | 'unknown'
  birthday: string
  registrationTime: number
  lastLoginTime: number
  level: 'bronze' | 'silver' | 'gold' | 'platinum'
  totalSpent: number
  points: number
  token: string // 新增 token 字段

  // ✅ 修改构造函数：兼容 2个参数（旧代码）和 6个参数（AuthService）
  // 参数使用了默认值，这样既能 new User('acc', 'pwd') 也能传更多参数
  constructor(
    idOrAccount: string,
    arg2: string,
    username: string = '',
    avatar: ResourceStr = '',
    level: string = 'bronze',
    token: string = ''
  ) {
    // 判断第一个参数是 ID 还是 Account (简单判断：如果 arg2 是 'password' 格式或很短，可能是密码)
    // 这里为了兼容 AuthService 的调用：new User(uid, phone, name, avatar, level, token)

    // 默认初始化
    this.id = `user_${Date.now()}`
    this.account = ''
    this.password = ''
    this.username = username || '华为用户'
    this.phone = ''
    this.avatar = avatar || $r('app.media.app_icon') // 默认给个头像防止空
    this.level = (level as 'bronze' | 'silver' | 'gold' | 'platinum') || 'bronze'
    this.token = token

    // 其他字段初始化
    this.email = ''
    this.realName = ''
    this.gender = 'unknown'
    this.birthday = ''
    this.registrationTime = Date.now()
    this.lastLoginTime = Date.now()
    this.totalSpent = 0
    this.points = 0

    // ✅ 智能识别参数逻辑
    if (username === '' && level === 'bronze' && token === '') {
      // 场景 A: 旧代码 new User(account, password)
      this.account = idOrAccount
      this.password = arg2
      this.username = idOrAccount
    } else {
      // 场景 B: AuthService 调用 new User(uid, phone, name, avatar, level, token)
      this.id = idOrAccount
      this.phone = arg2
      this.account = arg2 // 手机号作为账号
      this.password = ''  // 验证码登录没有密码
    }
  }

  getLevelText(): string {
    switch (this.level) {
      case 'bronze': return '青铜会员'
      case 'silver': return '白银会员'
      case 'gold': return '黄金会员'
      case 'platinum': return '铂金会员'
      default: return '普通用户'
    }
  }

  getLevelColor(): string {
    switch (this.level) {
      case 'bronze': return '#CD7F32'
      case 'silver': return '#C0C0C0'
      case 'gold': return '#FFD700'
      case 'platinum': return '#E5E4E2'
      default: return '#666666'
    }
  }
}

// 商品评论
export class Comment {
  id: string
  productId: string
  userId: string
  username: string
  avatar: string
  rating: number
  content: string
  images: string[]
  likes: number
  isLiked: boolean
  createTime: number
  replyTo?: string
  isTopComment: boolean

  constructor(productId: string, userId: string, username: string, rating: number, content: string) {
    this.id = `comment_${Date.now()}_${Math.random()}`
    this.productId = productId
    this.userId = userId
    this.username = username
    this.avatar = 'https://via.placeholder.com/40x40'
    this.rating = rating
    this.content = content
    this.images = []
    this.likes = 0
    this.isLiked = false
    this.createTime = Date.now()
    this.isTopComment = false
  }

  getFormattedTime(): string {
    const now = Date.now()
    const diff = now - this.createTime
    const minutes = Math.floor(diff / (1000 * 60))
    const hours = Math.floor(diff / (1000 * 60 * 60))
    const days = Math.floor(diff / (1000 * 60 * 60 * 24))

    if (minutes < 1) return '刚刚'
    if (minutes < 60) return `${minutes}分钟前`
    if (hours < 24) return `${hours}小时前`
    if (days < 30) return `${days}天前`

    const date = new Date(this.createTime)
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')}`
  }

  like(): void {
    this.isLiked = !this.isLiked
    this.likes += this.isLiked ? 1 : -1
  }

  toggleLike(userId: string): void {
    if (this.isLiked) {
      this.isLiked = false
      this.likes = Math.max(0, this.likes - 1)
    } else {
      this.isLiked = true
      this.likes++
    }
  }
}

// 订单信息
export class Order {
  id: string
  userId: string
  items: OrderItem[]
  totalAmount: number
  status: 'pending' | 'paid' | 'shipped' | 'delivered' | 'cancelled' | 'refunded'
  shippingAddress: Address
  paymentMethod: string
  orderTime: number
  paymentTime?: number
  shippingTime?: number
  deliveryTime?: number
  trackingNumber?: string

  constructor(userId: string, items: OrderItem[], totalAmount: number, shippingAddress: Address) {
    this.id = `order_${Date.now()}`
    this.userId = userId
    this.items = items
    this.totalAmount = totalAmount
    this.status = 'pending'
    this.shippingAddress = shippingAddress
    this.paymentMethod = 'alipay'
    this.orderTime = Date.now()
  }

  getStatusText(): string {
    switch (this.status) {
      case 'pending': return '待付款'
      case 'paid': return '已付款'
      case 'shipped': return '已发货'
      case 'delivered': return '已送达'
      case 'cancelled': return '已取消'
      case 'refunded': return '已退款'
      default: return '未知状态'
    }
  }

  getStatusColor(): string {
    switch (this.status) {
      case 'pending': return '#FF6B35'
      case 'paid': return '#007DFF'
      case 'shipped': return '#52C41A'
      case 'delivered': return '#52C41A'
      case 'cancelled': return '#999999'
      case 'refunded': return '#FF4444'
      default: return '#666666'
    }
  }
}

// 订单项
export class OrderItem {
  productId: string
  productName: string
  productImage: ResourceStr
  price: number
  quantity: number

  constructor(product: ProductModel, quantity: number) {
    this.productId = product.id
    this.productName = product.name
    this.productImage = product.images.length > 0 ? product.images[0] : $r('app.media.APP')
    this.price = product.price
    this.quantity = quantity
  }
}

// 地址信息
export class Address {
  id: string
  name: string
  phone: string
  province: string
  city: string
  district: string
  detail: string
  isDefault: boolean

  constructor(name: string = '', phone: string = '', province: string = '', city: string = '',
    district: string = '', detail: string = '', isDefault: boolean = false) {
    this.id = `address_${Date.now()}`
    this.name = name
    this.phone = phone
    this.province = province
    this.city = city
    this.district = district
    this.detail = detail
    this.isDefault = isDefault
  }

  getFullAddress(): string {
    return `${this.province}${this.city}${this.district}${this.detail}`
  }

  isValid(): boolean {
    return this.name && this.phone && this.province && this.city && this.detail ? true : false
  }
}

// 收藏商品
export class FavoriteItem {
  id: string
  productId: string
  product: ProductModel
  addedTime: number

  constructor(product: ProductModel) {
    this.id = `favorite_${product.id}_${Date.now()}`
    this.productId = product.id
    this.product = product
    this.addedTime = Date.now()
  }
}