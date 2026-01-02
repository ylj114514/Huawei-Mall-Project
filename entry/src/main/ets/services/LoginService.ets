import { DatabaseManager } from '../database/DatabaseManager'
import { User } from '../model/DataModel'

export class LoginService {
  private static instance: LoginService
  private db: DatabaseManager = DatabaseManager.getInstance()
  // ✅ 核心修正：定义全局状态 Key，替代已删除的 SessionManager
  private static readonly KEY_USER: string = 'currentUser'

  private constructor() {}

  public static getInstance(): LoginService {
    if (!LoginService.instance) {
      LoginService.instance = new LoginService()
    }
    return LoginService.instance
  }

  /**
   * 登录逻辑
   */
  async login(account: string, password: string): Promise<boolean> {
    const user: User | null = await this.db.login(account, password)
    if (!user) return false

    // ✅ 核心修正：使用 AppStorage 存储用户对象，供全应用使用
    AppStorage.setOrCreate<User>(LoginService.KEY_USER, user)
    return true
  }

  /**
   * 注册逻辑
   */
  async register(account: string, password: string): Promise<boolean> {
    // 1. 调用数据库注册
    const ok: boolean = await this.db.registerUser(account, password)
    if (!ok) return false

    // 2. 注册成功后立即获取最新用户信息
    const user: User | null = await this.db.getUserByAccount(account)
    if (user) {
      // ✅ 核心修正：直接同步到系统存储，不再依赖 utils
      AppStorage.setOrCreate<User>(LoginService.KEY_USER, user)
      return true
    }
    return false
  }

  /**
   * 退出逻辑
   */
  logout(): void {
    AppStorage.setOrCreate<User | null>(LoginService.KEY_USER, null)
  }
}