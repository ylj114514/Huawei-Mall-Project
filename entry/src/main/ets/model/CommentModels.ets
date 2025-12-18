/**
 * 评论数据类
 */
export class CommentData {
  productId: string
  rating: number
  content: string
  images: string
  spec: string

  constructor(productId: string, rating: number, content: string, images: string, spec: string) {
    this.productId = productId
    this.rating = rating
    this.content = content
    this.images = images
    this.spec = spec
  }
}

/**
 * 地址数据类
 */
export class AddressData {
  name: string
  phone: string
  province: string
  city: string
  district: string
  detail: string
  isDefault: boolean

  constructor(name: string, phone: string, province: string, city: string, district: string, detail: string, isDefault: boolean) {
    this.name = name
    this.phone = phone
    this.province = province
    this.city = city
    this.district = district
    this.detail = detail
    this.isDefault = isDefault
  }
}