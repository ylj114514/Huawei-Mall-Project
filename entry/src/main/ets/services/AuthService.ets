import router from '@ohos.router';
import notificationManager from '@ohos.notificationManager';
// ✅ 关键修复：引入基础 notification 模块以解决枚举类型报错
import notification from '@ohos.notification';
import { User } from '../model/DataModel';
import { DatabaseManager } from '../database/DatabaseManager';

/**
 * 认证服务 (本地模拟版 - 最终修复)
 * 适配 Local Emulator，无云服务依赖，使用系统通知模拟验证码
 */
export class AuthService {
  private static instance: AuthService;
  private static readonly KEY_CURRENT_ACCOUNT: string = 'currentAccount';

  private currentUser: User | null = null;
  private db: DatabaseManager = DatabaseManager.getInstance();

  // 模拟验证码相关
  private mockVerifyCode: string = '';
  private lastPhone: string = '';

  private constructor() {}

  public static getInstance(): AuthService {
    if (!AuthService.instance) {
      AuthService.instance = new AuthService();
    }
    return AuthService.instance;
  }

  /**
   * 初始化：从持久化存储恢复登录态
   */
  public async init(): Promise<void> {
    const account = AppStorage.Get<string>(AuthService.KEY_CURRENT_ACCOUNT);
    if (account) {
      this.db.setCurrentUserAccount(account);
      this.currentUser = await this.db.getUserByAccount(account);
    }
  }

  /**
   * 1. 发送验证码 (本地模拟：发系统通知)
   */
  public async requestVerifyCode(countryCode: string, phoneNumber: string): Promise<void> {
    console.info(`[AuthService] 收到请求: +${countryCode} ${phoneNumber}`);

    // 生成6位随机数
    this.mockVerifyCode = Math.floor(100000 + Math.random() * 900000).toString();
    this.lastPhone = phoneNumber;

    // 模拟网络延迟
    await new Promise<void>((resolve) => setTimeout(resolve, 1000));

    console.info(`[AuthService] 生成验证码: ${this.mockVerifyCode}`);

    try {
      // ✅ 修复类型报错：使用 notification.ContentType (来自 @ohos.notification)
      const basicContent: notificationManager.NotificationContent = {
        contentType: notification.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: '【华为商城】验证码',
          text: `您的登录验证码是：${this.mockVerifyCode}，请勿泄露给他人。`,
          additionalText: '验证码'
        }
      };

      const request: notificationManager.NotificationRequest = {
        id: 1001,
        content: basicContent
      };

      // 发送通知
      await notificationManager.publish(request);
      console.info('[AuthService] 通知发送成功，请查看模拟器顶部通知栏');

    } catch (error) {
      console.error(`[AuthService] 通知发送异常: ${JSON.stringify(error || {})}`);
      // 兜底：如果通知发不出来，控制台也能看到验证码
      console.warn(`>>> 请手动输入验证码: ${this.mockVerifyCode} <<<`);
    }
  }

  /**
   * 2. 手机号登录 (本地逻辑：自动注册)
   */
  public async loginWithPhone(countryCode: string, phoneNumber: string, verifyCode: string): Promise<boolean> {
    console.info(`[AuthService] 正在登录: ${phoneNumber}, code: ${verifyCode}`);

    // 校验
    if (phoneNumber !== this.lastPhone) {
      throw new Error('手机号不匹配，请重新获取验证码');
    }
    if (verifyCode !== this.mockVerifyCode) {
      throw new Error('验证码错误');
    }

    try {
      // 查库：用户是否存在？
      let user = await this.db.getUserByAccount(phoneNumber);

      // 不存在则自动注册
      if (!user) {
        console.info('[AuthService] 新用户，自动注册中...');
        user = new User(phoneNumber, '123456'); // 默认密码
        user.phone = phoneNumber;
        user.username = `用户${phoneNumber.slice(-4)}`;
        user.avatar = 'https://via.placeholder.com/100x100'; // 使用默认图片URL
        user.level = 'gold';
        await this.db.registerUser(user.account, user.password);
      }

      // 设置登录态
      this.setCurrentAccount(user.account);
      this.currentUser = user;

      console.info('[AuthService] 登录成功:', user.username);
      return true;

    } catch (error) {
      console.error(`[AuthService] 登录失败: ${JSON.stringify(error || {})}`);
      return false;
    }
  }

  public setCurrentAccount(account: string): void {
    AppStorage.SetOrCreate<string>(AuthService.KEY_CURRENT_ACCOUNT, account);
    this.db.setCurrentUserAccount(account);
  }

  public clearCurrentAccount(): void {
    AppStorage.SetOrCreate<string>(AuthService.KEY_CURRENT_ACCOUNT, '');
    this.db.setCurrentUserAccount(null);
    this.currentUser = null;
  }

  public getCurrentAccount(): string {
    return AppStorage.Get<string>(AuthService.KEY_CURRENT_ACCOUNT) || '';
  }

  public async getCurrentUser(): Promise<User | null> {
    const account = this.getCurrentAccount();
    if (!account) return null;

    // 优先从内存返回，减少数据库查询
    if (this.currentUser && this.currentUser.account === account) {
      return this.currentUser;
    }

    this.currentUser = await this.db.getUserByAccount(account);
    return this.currentUser;
  }

  public logout(): void {
    this.clearCurrentAccount();
    // 退出后跳转登录页
    router.replaceUrl({ url: 'pages/LoginPage' });
  }

  public async isAdmin(): Promise<boolean> {
    const account = this.getCurrentAccount();
    if (!account) return false;
    // 简单判定：尾号 0000 或者是 admin 账号
    return account === 'admin' || account.endsWith('0000');
  }
}