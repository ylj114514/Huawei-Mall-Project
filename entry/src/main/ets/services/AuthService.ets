import { router } from '@kit.ArkUI';
import { User } from '../model/DataModel';
import { BusinessError } from '@kit.BasicServicesKit';
// ✅ 核心修复：直接引入 cloud 统一包，不再使用 @hw-agconnect/auth
import cloud, { AuthUser, VerifyCodeAction } from '@hw-agconnect/cloud';

/**
 * 认证服务单例类 (Cloud SDK 版本)
 */
export class AuthService {
  private static instance: AuthService;
  private currentUser: User | null = null;

  private constructor() {}

  public static getInstance(): AuthService {
    if (!AuthService.instance) {
      AuthService.instance = new AuthService();
    }
    return AuthService.instance;
  }

  public async init(): Promise<void> {
    await this.getCurrentUser();
  }

  /**
   * 1. 发送验证码 (新版 API)
   */
  public async requestVerifyCode(countryCode: string, phoneNumber: string): Promise<void> {
    try {
      // ✅ 修复：使用 cloud.auth().requestVerifyCode 传入对象参数
      await cloud.auth().requestVerifyCode({
        action: VerifyCodeAction.REGISTER_LOGIN, // 使用正确的枚举 REGISTER_LOGIN
        lang: 'zh_CN',
        sendInterval: 60,
        verifyCodeType: {
          kind: 'phone',
          phoneNumber: phoneNumber,
          countryCode: countryCode
        }
      });
      console.info('[AuthService] 验证码发送成功');
    } catch (e) {
      // ✅ 修复 ArkTS 抛出错误限制
      const error = e as BusinessError;
      console.error(`[AuthService] 验证码发送失败: ${JSON.stringify(error)}`);
      throw new Error(error.message || '验证码发送失败');
    }
  }

  /**
   * 2. 手机号登录 (新版 API)
   */
  public async loginWithPhone(countryCode: string, phoneNumber: string, verifyCode: string): Promise<boolean> {
    try {
      // ✅ 修复：使用 cloud.auth().signIn 传入 credentialInfo 对象
      const result = await cloud.auth().signIn({
        credentialInfo: {
          kind: 'phone',
          phoneNumber: phoneNumber,
          countryCode: countryCode,
          verifyCode: verifyCode
        }
      });

      const agcUser = result.getUser();
      if (agcUser) {
        this.updateCurrentUser(agcUser, phoneNumber);
        console.info('[AuthService] 登录成功');
        return true;
      }
      return false;
    } catch (e) {
      const error = e as BusinessError;
      console.error(`[AuthService] 登录失败: ${JSON.stringify(error)}`);
      throw new Error(error.message || '登录失败');
    }
  }

  /**
   * 3. 获取当前用户
   */
  public async getCurrentUser(): Promise<User | null> {
    if (this.currentUser) return this.currentUser;

    try {
      // ✅ 修复：cloud.auth().getCurrentUser()
      const agcUser = await cloud.auth().getCurrentUser();
      if (agcUser) {
        this.updateCurrentUser(agcUser);
        return this.currentUser;
      }
    } catch (e) {
      console.info('[AuthService] 当前未登录');
    }
    return null;
  }

  /**
   * 4. 退出登录
   */
  public async logout(): Promise<void> {
    try {
      await cloud.auth().signOut();
      this.currentUser = null;
      router.replaceUrl({ url: 'pages/LoginPage' });
    } catch (e) {
      console.error('[AuthService] 退出失败');
    }
  }

  /**
   * 更新用户信息
   */
  private updateCurrentUser(agcUser: AuthUser, inputPhone?: string): void {
    const rawPhone = agcUser.getPhone() || inputPhone || '';
    const uid = agcUser.getUid();

    let displayName = '新用户';
    if (rawPhone.length >= 4) {
      displayName = `用户${rawPhone.slice(-4)}`;
    }

    // 这里需要配合你之前修改好的 DataModel (支持多参数构造)
    this.currentUser = new User(
      uid,                    // id
      rawPhone,               // phone
      displayName,            // username
      $r('app.media.app_icon'), // avatar
      'platinum',             // level
      ''                      // token
    );
  }

  /**
   * 获取当前账号
   */
  public getCurrentAccount(): string {
    return this.currentUser?.phone || '';
  }

  /**
   * 检查当前用户是否为管理员
   */
  public async isAdmin(): Promise<boolean> {
    const account = this.getCurrentAccount();
    if (!account) return false;
    
    // 这里需要根据实际业务逻辑判断是否为管理员
    // 暂时返回false，需要根据实际需求实现
    return account === 'admin';
  }
}