import { AuthService } from './AuthService'
import { CartService } from './CartService'

/**
 * AppService: 全局应用服务协调者
 * 作用：统一初始化所有服务，提供全局退出登录等功能
 */
export class AppService {
  private static instance: AppService
  private authService: AuthService = AuthService.getInstance()
  private cartService: CartService = CartService.getInstance()

  private constructor() {}

  public static getInstance(): AppService {
    if (!AppService.instance) {
      AppService.instance = new AppService()
    }
    return AppService.instance
  }

  // 初始化所有业务服务
  public async init(): Promise<void> {
    await this.authService.init()
    await this.cartService.init()
  }

  // 统一退出登录
  public logout(): void {
    this.authService.logout()
  }
}