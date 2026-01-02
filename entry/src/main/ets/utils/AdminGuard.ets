import { DatabaseManager } from '../database/DatabaseManager'
// ✅ 修改点1：删除对不存在的 SessionManager 的引用
// import { SessionManager } from './SessionManager'

// ✅ 修改点2：引入我们已经写好的 AuthService
import { AuthService } from '../services/AuthService'
import { BusinessError } from '../model/BusinessError'

export class AdminGuard {
  /**
   * 确保当前用户是管理员，否则抛出异常
   * 供 ProductEditPage 等页面调用
   */
  static async ensureAdmin(): Promise<void> {
    // 1. 获取当前登录账号
    // ✅ 修改点3：使用 AuthService 获取，并显式声明类型为 string，消除类型报错
    const account: string = AuthService.getInstance().getCurrentAccount()

    // 如果账号为空字符串，说明未登录
    if (!account) {
      throw new BusinessError('NOT_LOGIN', '请先登录')
    }

    // 2. 查询数据库确认是否为管理员
    // ✅ 修改点4：调用 DatabaseManager 的 isAdmin 方法
    const isAdmin: boolean = await DatabaseManager.getInstance().isAdmin(account)

    if (!isAdmin) {
      throw new BusinessError('NO_PERMISSION', '无管理员权限')
    }
  }
}