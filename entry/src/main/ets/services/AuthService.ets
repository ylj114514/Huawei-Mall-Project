import { DatabaseManager } from '../database/DatabaseManager'
import { User } from '../model/DataModel'

export class AuthService {
  private static instance: AuthService
  private static readonly KEY_CURRENT_ACCOUNT: string = 'currentAccount'

  private db: DatabaseManager = DatabaseManager.getInstance()

  private constructor() {}

  public static getInstance(): AuthService {
    if (!AuthService.instance) {
      AuthService.instance = new AuthService()
    }
    return AuthService.instance
  }

  // ✅ 修复：添加缺失的 init 方法
  public async init(): Promise<void> {
    const account = AppStorage.get<string>(AuthService.KEY_CURRENT_ACCOUNT)
    if (account) {
      this.db.setCurrentUserAccount(account)
    }
  }

  public setCurrentAccount(account: string): void {
    AppStorage.setOrCreate<string>(AuthService.KEY_CURRENT_ACCOUNT, account)
    this.db.setCurrentUserAccount(account)
  }

  public clearCurrentAccount(): void {
    AppStorage.setOrCreate<string>(AuthService.KEY_CURRENT_ACCOUNT, '')
    this.db.setCurrentUserAccount(null)
  }

  public getCurrentAccount(): string {
    return AppStorage.get<string>(AuthService.KEY_CURRENT_ACCOUNT) || ''
  }

  // ✅ 修复：添加缺失的 getCurrentUser 方法
  public async getCurrentUser(): Promise<User | null> {
    const account = this.getCurrentAccount()
    if (!account) return null
    return await this.db.getUserByAccount(account)
  }

  // ✅ 修复：添加缺失的 logout 方法
  public logout(): void {
    this.clearCurrentAccount()
  }

  public isLoggedIn(): boolean {
    return !!this.getCurrentAccount()
  }

  public async isAdmin(): Promise<boolean> {
    const account = this.getCurrentAccount()
    if (!account) return false
    return this.db.isAdmin(account)
  }
}