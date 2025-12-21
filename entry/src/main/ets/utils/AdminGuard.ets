import { DatabaseManager } from '../database/DatabaseManager'
import { SessionManager } from './SessionManager'
import { BusinessError } from '../model/BusinessError'

export class AdminGuard {
  static async ensureAdmin(): Promise<void> {
    const account = SessionManager.getAccount()
    if (!account) {
      throw new BusinessError('NOT_LOGIN', '请先登录')
    }
    const isAdmin = await DatabaseManager.getInstance().isAdmin(account)
    if (!isAdmin) {
      throw new BusinessError('NO_PERMISSION', '无管理员权限')
    }
  }
}
