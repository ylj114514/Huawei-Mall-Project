import router from '@ohos.router'
import { DatabaseManager } from '../database/DatabaseManager'
import { User } from '../model/DataModel'

/**
 * 认证服务类 (单例模式)
 * 职责：
 * 1. 管理当前登录用户的会话状态 (Session) - 使用 AppStorage 持久化
 * 2. 作为 DatabaseManager 的上层封装，提供简便的用户数据获取接口
 */
export class AuthService {
  private static instance: AuthService
  // 定义 AppStorage 中存储 Key 的常量
  private static readonly KEY_CURRENT_ACCOUNT: string = 'currentAccount'

  // 引用数据库管理器实例
  private db: DatabaseManager = DatabaseManager.getInstance()

  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): AuthService {
    if (!AuthService.instance) {
      AuthService.instance = new AuthService()
    }
    return AuthService.instance
  }

  /**
   * ✅ 核心修复：初始化方法
   * 作用：EntryAbility 启动时调用，用于恢复上次的应用会话状态
   */
  public async init(): Promise<void> {
    // 尝试从全局内存存储中恢复上次登录的账号
    const account = AppStorage.Get<string>(AuthService.KEY_CURRENT_ACCOUNT)
    if (account) {
      // 如果有缓存账号，同步设置到数据库管理器的当前用户状态中
      this.db.setCurrentUserAccount(account)
      console.info('[AuthService] Init: Session restored for account:', account)
    } else {
      console.info('[AuthService] Init: No active session found')
    }
  }

  /**
   * 设置当前登录账号 (登录/注册成功后调用)
   */
  public setCurrentAccount(account: string): void {
    // 1. 保存到全局 AppStorage，确保页面刷新或跳转后状态不丢失
    AppStorage.SetOrCreate<string>(AuthService.KEY_CURRENT_ACCOUNT, account)
    // 2. 同步设置数据库上下文
    this.db.setCurrentUserAccount(account)
  }

  /**
   * 清除当前账号 (退出登录时调用)
   */
  public clearCurrentAccount(): void {
    AppStorage.SetOrCreate<string>(AuthService.KEY_CURRENT_ACCOUNT, '')
    this.db.setCurrentUserAccount(null)
  }

  /**
   * 获取当前登录的账号字符串
   */
  public getCurrentAccount(): string {
    return AppStorage.Get<string>(AuthService.KEY_CURRENT_ACCOUNT) || ''
  }

  /**
   * ✅ 核心修复：获取完整的当前用户对象
   * 作用：UserCenterPage 等页面调用，用于显示头像、昵称等详细信息
   */
  public async getCurrentUser(): Promise<User | null> {
    const account = this.getCurrentAccount()
    if (!account) return null
    // 委托给 DatabaseManager 从数据库查询完整信息
    return await this.db.getUserByAccount(account)
  }

  /**
   * ✅ 核心修复：退出登录
   */
  public logout(): void {
    this.clearCurrentAccount()
    // 强制跳转回登录页
    router.replaceUrl({ url: 'pages/LoginPage' })
  }

  /**
   * 检查是否已登录 (用于路由守卫或UI判断)
   */
  public isLoggedIn(): boolean {
    return !!this.getCurrentAccount()
  }

  /**
   * 检查当前用户是否为管理员 (用于显示后台入口)
   */
  public async isAdmin(): Promise<boolean> {
    const account = this.getCurrentAccount()
    if (!account) return false
    return this.db.isAdmin(account)
  }
}