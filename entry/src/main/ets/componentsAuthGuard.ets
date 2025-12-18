import router from '@ohos.router'
import { StorageManager } from '../utils/StorageManager'
import { User } from '../model/DataModel'

/**
 * 权限守卫组件 - 保护需要登录的功能
 */
@Component
export struct AuthGuard {
  @BuilderParam content: () => void
  @Prop required: boolean = false // 是否需要登录

  @State user: User | null = null
  @State isLoading: boolean = true
  private storage: StorageManager = StorageManager.getInstance()

  aboutToAppear() {
    this.checkAuthStatus()
  }

  private async checkAuthStatus() {
    try {
      this.user = await this.storage.loadUser()
    } catch (error) {
      console.error('检查登录状态失败:', error)
    } finally {
      this.isLoading = false
    }
  }

  private redirectToLogin() {
    router.pushUrl({
      url: 'pages/LoginPage'
    })
  }

  build() {
    if (this.isLoading) {
      // 加载状态
      Column() {
        LoadingProgress()
          .width(40)
          .height(40)
        Text('检查权限中...')
          .fontSize(14)
          .margin({ top: 16 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    } else if (this.required && !this.user) {
      // 需要登录但未登录
      Column() {
        Text('🔒')
          .fontSize(48)
          .margin({ bottom: 16 })
        Text('请先登录')
          .fontSize(16)
          .fontColor('#666666')
          .margin({ bottom: 24 })

        Button('立即登录')
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor('#FF0000')
          .borderRadius(24)
          .padding({ left: 32, right: 32, top: 12, bottom: 12 })
          .height(48)
          .onClick(() => {
            this.redirectToLogin()
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#FFFFFF')
    } else {
      // 已登录或不需要登录，显示内容
      this.content()
    }
  }
}

/**
 * 购物车守卫组件
 */
@Component
export struct CartGuard {
  @BuilderParam content: () => void
  @Prop cartCount: number = 0

  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .onClick(() => {
      if (this.cartCount === 0) {
        // 购物车为空时的提示
        console.log('购物车是空的')
      }
    })
  }
}

/**
 * 评论守卫组件
 */
@Component
export struct CommentGuard {
  @BuilderParam content: () => void
  @BuilderParam prompt: () => void

  build() {
    Column() {
      this.prompt()
    }
    .width('100%')
    .onClick(() => {
      // 点击评论区域时检查登录状态
      this.checkAndNavigate()
    })
  }

  private async checkAndNavigate() {
    const storage = StorageManager.getInstance()
    const user = await storage.loadUser()
    if (!user) {
      router.pushUrl({ url: 'pages/LoginPage' })
    }
  }
}