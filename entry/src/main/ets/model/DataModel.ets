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

  // 获取小计金额
  getSubtotal(): number {
    return this.product.price * this.quantity
  }

  // 增加数量
  increaseQuantity(): void {
    if (this.quantity < this.product.stock) {
      this.quantity++
    }
  }

  // 减少数量
  decreaseQuantity(): void {
    if (this.quantity > 1) {
      this.quantity--
    }
  }

  // 是否有效（库存足够）
  isValid(): boolean {
    return this.quantity <= this.product.stock && this.product.stock > 0
  }
}

// 用户信息
export class User {
  id: string
  account: string  // 账号
  password: string // 密码
  username: string
  email: string
  phone: string
  avatar: string
  realName: string
  gender: 'male' | 'female' | 'unknown'
  birthday: string
  registrationTime: number
  lastLoginTime: number
  level: 'bronze' | 'silver' | 'gold' | 'platinum'
  totalSpent: number
  points: number

  constructor(account: string, password: string) {
    this.id = `user_${Date.now()}`
    this.account = account
    this.password = password
    this.username = account // 默认用户名为账号
    this.email = ''
    this.phone = ''
    this.avatar = 'https://via.placeholder.com/100x100'
    this.realName = ''
    this.gender = 'unknown'
    this.birthday = ''
    this.registrationTime = Date.now()
    this.lastLoginTime = Date.now()
    this.level = 'bronze'
    this.totalSpent = 0
    this.points = 0
  }

  // 获取用户等级显示文本
  getLevelText(): string {
    switch (this.level) {
      case 'bronze': return '青铜会员'
      case 'silver': return '白银会员'
      case 'gold': return '黄金会员'
      case 'platinum': return '铂金会员'
      default: return '普通用户'
    }
  }

  // 获取等级颜色
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

  // 格式化时间
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

  // 点赞
  like(): void {
    this.isLiked = !this.isLiked
    this.likes += this.isLiked ? 1 : -1
  }

  // 切换点赞状态（支持指定用户）
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

  // 获取状态文本
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

  // 获取状态颜色
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
  productImage: string
  price: number
  quantity: number

  constructor(product: ProductModel, quantity: number) {
    this.productId = product.id
    this.productName = product.name
    this.productImage = product.images[0]
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

  // 获取完整地址
  getFullAddress(): string {
    return `${this.province}${this.city}${this.district}${this.detail}`
  }

  // 验证地址有效性
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