/**
 * 页面相关模型类
 */

// 轮播图数据类
export class BannerData {
  id: string
  title: string
  subtitle: string
  image: string
  backgroundColor: string

  constructor(id: string, title: string, subtitle: string, image: string, backgroundColor: string) {
    this.id = id
    this.title = title
    this.subtitle = subtitle
    this.image = image
    this.backgroundColor = backgroundColor
  }
}

// 统计数据类
export class OrderStats {
  title: string
  count: number
  icon: string
  color: string

  constructor(title: string, count: number, icon: string, color: string) {
    this.title = title
    this.count = count
    this.icon = icon
    this.color = color
  }
}

// 功能项类
export class FunctionItem {
  id: string
  title: string
  icon: string
  badge?: string

  constructor(id: string, title: string, icon: string, badge?: string) {
    this.id = id
    this.title = title
    this.icon = icon
    this.badge = badge
  }
}