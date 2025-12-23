import router from '@ohos.router'

/**
 * 认证服务类 (单例模式)
 * 职责：管理当前登录用户的会话状态 (Session)
 * 说明：具体的登录/注册/数据存储逻辑已迁移至 DatabaseManager
 */
export class AuthService {
  private static instance: AuthService
  private currentAccount: string = ''
  private isLogin: boolean = false

  private constructor() { }

  public static getInstance(): AuthService {
    if (!AuthService.instance) {
      AuthService.instance = new AuthService()
    }
    return AuthService.instance
  }

  /**
   * 设置当前登录账号
   * 在 DatabaseManager 验证通过后调用此方法保存会话
   */
  public setCurrentAccount(account: string) {
    this.currentAccount = account
    this.isLogin = true
    // 将账号保存到全局 AppStorage，方便其他页面（如个人中心）获取
    AppStorage.SetOrCreate('currentAccount', account)
  }

  /**
   * 获取当前登录账号
   */
  public getCurrentAccount(): string {
    // 优先从内存获取，如果内存为空尝试从 AppStorage 恢复 (应对页面刷新)
    if (!this.currentAccount) {
      this.currentAccount = AppStorage.Get('currentAccount') || ''
      this.isLogin = !!this.currentAccount
    }
    return this.currentAccount
  }

  /**
   * 检查是否已登录
   */
  public isLoggedIn(): boolean {
    return !!this.getCurrentAccount()
  }

  /**
   * 退出登录
   */
  public logout() {
    this.currentAccount = ''
    this.isLogin = false
    AppStorage.SetOrCreate('currentAccount', '')
    // 跳转回登录页
    router.replaceUrl({ url: 'pages/LoginPage' })
  }

  /**
   * 检查是否是管理员 (根据账号名判断的简单逻辑，可扩展)
   */
  public isAdmin(): boolean {
    return this.getCurrentAccount() === 'admin'
  }
}