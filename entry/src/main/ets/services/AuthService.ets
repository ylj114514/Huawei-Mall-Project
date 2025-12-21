// entry/src/main/ets/services/AuthService.ets
import { DatabaseManager } from '../database/DatabaseManager'

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

  public isLoggedIn(): boolean {
    return !!this.getCurrentAccount()
  }

  public async isAdmin(): Promise<boolean> {
    const account = this.getCurrentAccount()
    if (!account) return false
    return this.db.isAdmin(account)
  }
}
