import { DatabaseManager } from '../database/DatabaseManager'
import { SessionManager } from '../utils/SessionManager'
import { User } from '../model/DataModel'

export class LoginService {
  private db: DatabaseManager = DatabaseManager.getInstance()

  async login(account: string, password: string): Promise<boolean> {
    const user: User | null = await this.db.login(account, password)
    if (!user) return false
    SessionManager.setUser(user)
    return true
  }

  async register(account: string, password: string): Promise<boolean> {
    const ok: boolean = await this.db.registerUser(account, password)
    if (!ok) return false
    // 注册成功后顺便登录
    const user: User | null = await this.db.getUserByAccount(account)
    SessionManager.setUser(user)
    return true
  }

  logout(): void {
    SessionManager.logout()
  }
}
