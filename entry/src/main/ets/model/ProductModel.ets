export class ProductModel {
  id: string
  name: string
  price: number
  originalPrice: number
  description: string
  detailDescription: string
  images: string[]
  image: string // 主图，用于购物车等场景
  spec: string // 商品规格
  category: string
  tags: string[]
  rating: number
  reviewCount: number
  stock: number
  width: number = 0 // 用于瀑布流布局计算

  constructor(id: string, name: string, price: number, originalPrice: number,
              description: string, detailDescription: string, images: string[],
              category: string, tags: string[], rating: number, reviewCount: number, stock: number) {
    this.id = id
    this.name = name
    this.price = price
    this.originalPrice = originalPrice
    this.description = description
    this.detailDescription = detailDescription
    this.images = images
    this.image = images.length > 0 ? images[0] : '' // 默认使用第一张图作为主图
    this.spec = '标准版' // 默认规格
    this.category = category
    this.tags = tags
    this.rating = rating
    this.reviewCount = reviewCount
    this.stock = stock
  }
}

export class MockData {
  static generateProducts(): ProductModel[] {
    return [
      new ProductModel(
        '1',
        '华为Mate 60 Pro',
        6999,
        7999,
        '华为Mate 60 Pro 5G手机，搭载麒麟芯片',
        '华为Mate 60 Pro是一款旗舰级5G智能手机，搭载华为自主研发的麒麟9000S芯片，支持5G网络。采用6.82英寸OLED曲面屏，分辨率为2720×1260，支持120Hz刷新率。后置三摄像头系统，包括5000万像素主摄、1200万像素超广角和1200万像素长焦镜头，支持5倍光学变焦。内置5000mAh电池，支持88W快充和50W无线充电。运行HarmonyOS 4.0系统，提供流畅的使用体验。',
        ['https://consumer-img.huawei.com/content/dam/huawei-cbg-site/cn/market/mobiles-phones/mate-60-pro/img/kv/mate-60-pro-kv-black.png'],
        '手机',
        ['5G', '旗舰', '拍照'],
        4.8,
        2156,
        100
      ),
      new ProductModel(
        '2',
        '华为Watch GT 4',
        1488,
        1688,
        '华为Watch GT 4智能手表，健康监测专家',
        '华为Watch GT 4是一款旗舰级智能手表，配备1.43英寸AMOLED圆形屏幕，分辨率为466×466。支持心率、血氧、睡眠监测等多种健康功能，内置GPS定位系统。续航可达14天，支持无线充电。提供100+种运动模式，包括跑步、游泳、骑行等。支持蓝牙通话、消息提醒、NFC支付等功能。防水等级为5ATM，适合游泳佩戴。',
        ['https://consumer-img.huawei.com/content/dam/huawei-cbg-site/cn/market/wearables/watch-gt-4/img/kv/watch-gt-4-kv-black.png'],
        '智能穿戴',
        ['健康', '运动', '长续航'],
        4.6,
        892,
        200
      ),
      new ProductModel(
        '3',
        '华为MatePad Pro',
        3799,
        4299,
        '华为MatePad Pro平板电脑，生产力工具',
        '华为MatePad Pro是一款11英寸平板电脑，采用OLED屏幕，分辨率为2560×1600，支持120Hz刷新率。搭载麒麟9000芯片，支持HarmonyOS多设备协同。配备8300mAh电池，支持66W快充。后置1300万像素摄像头，前置800万像素摄像头。支持M-Pencil手写笔和智能磁吸键盘，是理想的办公和学习伴侣。',
        ['https://consumer-img.huawei.com/content/dam/huawei-cbg-site/cn/market/tablets/matepad-pro/img/kv/matepad-pro-kv-gray.png'],
        '平板',
        ['办公', '学习', '创作'],
        4.7,
        1203,
        150
      ),
      new ProductModel(
        '4',
        '华为FreeBuds Pro 3',
        1199,
        1399,
        '华为FreeBuds Pro 3真无线耳机，静谧通话',
        '华为FreeBuds Pro 3是一款高端真无线蓝牙耳机，支持主动降噪功能，降噪深度可达47dB。搭载华为自研音频芯片，支持L2HC和LDAC高清音频编码。单次续航可达4小时（开启降噪），配合充电盒可达18小时。支持智能动态降噪、透传模式、智慧动态调频等功能。IP54级防水防尘，适合运动佩戴。',
        ['https://consumer-img.huawei.com/content/dam/huawei-cbg-site/cn/market/audio/freebuds-pro-3/img/kv/freebuds-pro-3-kv-white.png'],
        '音频',
        ['降噪', '高音质', '通话'],
        4.5,
        567,
        300
      ),
      new ProductModel(
        '5',
        '华为Vision智慧屏',
        5999,
        6999,
        '华为Vision智慧屏，家庭娱乐中心',
        '华为Vision智慧屏是一款75英寸4K智能电视，采用量子点技术，支持120Hz MEMC运动补偿。搭载HarmonyOS系统，支持多设备协同投屏。配备60W扬声器系统，支持杜比全景声。内置AI摄像头，支持视频通话、体感游戏等功能。支持HDMI 2.1、USB 3.0等接口，兼容多种设备。',
        ['https://consumer-img.huawei.com/content/dam/huawei-cbg-site/cn/market/visions/vision-75/img/kv/vision-75-kv.png'],
        '智慧屏',
        ['4K', '智能家居', '游戏'],
        4.4,
        234,
        50
      ),
      new ProductModel(
        '6',
        '华为MateBook X Pro',
        8999,
        9999,
        '华为MateBook X Pro笔记本，轻薄高性能',
        '华为MateBook X Pro是一款14.2英寸轻薄笔记本，采用3:2比例触控屏，分辨率为3120×2080。搭载第13代Intel Core i7处理器，16GB内存，1TB SSD。支持华为多屏协同，可以与手机、平板等设备无缝连接。配备90Wh电池，续航可达12小时。重量仅为1.38kg，厚度为15.6mm，便携性出色。',
        ['https://consumer-img.huawei.com/content/dam/huawei-cbg-site/cn/market/laptops/matebook-x-pro/img/kv/matebook-x-pro-kv-silver.png'],
        '笔记本',
        ['轻薄', '高性能', '触屏'],
        4.6,
        445,
        80
      ),
      new ProductModel(
        '7',
        '华为nova 12 Pro',
        3699,
        4199,
        '华为nova 12 Pro手机，年轻潮流之选',
        '华为nova 12 Pro是一款面向年轻人的5G智能手机，采用6.78英寸OLED曲面屏，支持120Hz刷新率。后置5000万像素主摄+800万像素超广角双摄，前置6000万像素超广角自拍镜头。搭载麒麟芯片，支持66W快充。机身轻薄，重量仅193克。提供多种时尚配色，满足年轻人的个性化需求。',
        ['https://consumer-img.huawei.com/content/dam/huawei-cbg-site/cn/market/mobiles-phones/nova-12-pro/img/kv/nova-12-pro-kv-green.png'],
        '手机',
        ['拍照', '轻薄', '快充'],
        4.3,
        1567,
        120
      ),
      new ProductModel(
        '8',
        '华为Sound Joy 2',
        799,
        999,
        '华为Sound Joy 2便携音箱，音乐随行',
        '华为Sound Joy 2是一款便携式蓝牙音箱，采用双扬声器设计，输出功率20W。支持IP67级防水防尘，适合户外使用。内置8800mAh电池，续航可达26小时。支持华为自研的Histen音效技术，提供震撼的低音和清晰的高音。支持多台设备串联，打造立体声效果。',
        ['https://consumer-img.huawei.com/content/dam/huawei-cbg-site/cn/market/audio/sound-joy-2/img/kv/sound-joy-2-kv-blue.png'],
        '音频',
        ['便携', '防水', '长续航'],
        4.2,
        89,
        200
      )
    ]
  }

  static generateCategories(): string[] {
    return ['全部', '手机', '平板', '笔记本', '智能穿戴', '音频', '智慧屏']
  }

  static generateSearchSuggestions(): string[] {
    return ['华为Mate 60', '智能手表', '无线耳机', '平板电脑', '笔记本电脑', '智能音箱']
  }
}