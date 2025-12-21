import { DatabaseManager } from '../database/DatabaseManager'
import { User } from '../model/DataModel'

export class SessionManager {
  private static currentUser: User | null = null

  static setUser(user: User | null): void {
    // 修改点 1: 使用类名访问静态属性
    SessionManager.currentUser = user
    DatabaseManager.getInstance().setCurrentUserAccount(user ? user.account : null)
  }

  static getUser(): User | null {
    // 修改点 2: 使用类名访问静态属性
    return SessionManager.currentUser
  }

  static isLogin(): boolean {
    // 修改点 3: 使用类名访问
    return SessionManager.currentUser !== null
  }

  static logout(): void {
    // 修改点 4: 使用类名调用静态方法
    SessionManager.setUser(null)
  }

  static getAccount(): string | null {
    // 修改点 5: 使用类名访问
    return SessionManager.currentUser ? SessionManager.currentUser.account : null
  }
}