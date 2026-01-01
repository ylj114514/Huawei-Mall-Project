import router from '@ohos.router';
import { User } from '../model/DataModel';
// ✅ 修复引用：使用 AuthService 替代已移除的 StorageManager
import { AuthService } from '../services/AuthService';
import { CartService } from '../services/CartService';
import { AppService } from '../services/AppService';

@Entry
@Component
struct UserCenterPage {
  @State user: User | null = null;
  @State isLoading: boolean = true;
  @State cartCount: number = 0;
  @State isAdmin: boolean = false; // ✅ 适配管理员逻辑

  // 获取服务实例
  private appService: AppService = AppService.getInstance();
  private authService: AuthService = AuthService.getInstance(); // ✅ 替换 StorageManager
  private cartService: CartService = CartService.getInstance();

  aboutToAppear() {
    this.refreshData();
  }

  // 每次页面显示时刷新，确保数据最新
  onPageShow() {
    this.refreshData();
  }

  /**
   * 加载用户数据
   */
  private async loadUserData(): Promise<void> {
    try {
      // ✅ 适配逻辑：使用 AuthService 获取当前用户
      this.user = await this.authService.getCurrentUser();

      if (this.user) {
        // ✅ 适配逻辑：检查管理员权限
        this.isAdmin = await this.authService.isAdmin();
        this.isLoading = false;
      } else {
        this.isLoading = false;
        // 未登录时不强制跳转，允许显示未登录 UI
      }
    } catch (error) {
      console.error('加载用户数据失败:', error);
      this.isLoading = false;
    }
  }

  /**
   * 加载统计信息
   */
  private async loadStatistics(): Promise<void> {
    try {
      // ✅ 适配逻辑：刷新购物车
      await this.cartService.refreshCart();
      this.cartCount = this.cartService.getTotalCount();
    } catch (error) {
      console.error('加载统计信息失败:', error);
      this.cartCount = 0;
    }
  }

  /**
   * 辅助方法：获取会员等级文本
   */
  private getLevelText(level: string | undefined): string {
    switch (level) {
      case 'bronze': return '青铜会员';
      case 'silver': return '白银会员';
      case 'gold': return '黄金会员';
      case 'platinum': return '铂金会员';
      default: return '普通会员';
    }
  }

  private navigateToPage(page: string): void {
    try {
      router.pushUrl({ url: page });
    } catch (error) {
      console.error('页面导航失败:', error);
    }
  }

  private async refreshData(): Promise<void> {
    await Promise.all([
      this.loadUserData(),
      this.loadStatistics()
    ]);
  }

  build() {
    Column() {
      // ----------------------------------------------------------------
      // 1. 顶部导航栏 (保持 GitHub 原版 UI)
      // ----------------------------------------------------------------
      Row() {
        Button('←')
          .width(40)
          .height(40)
          .backgroundColor(Color.Transparent)
          .fontColor(Color.White)
          .fontSize(18)
          .onClick(() => {
            router.replaceUrl({ url: 'pages/Index' });
          })

        Text('个人中心')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .fontColor(Color.White)

        Blank().width(40)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor($r('app.color.primary'))
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      if (this.isLoading) {
        // 加载状态
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
          Text('加载中...')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.background'))
      } else if (this.user) {
        // ----------------------------------------------------------------
        // 2. 已登录状态 (保持 GitHub 原版 UI)
        // ----------------------------------------------------------------
        Scroll() {
          Column() {
            // (A) 用户信息卡片
            Row() {
              // 头像区域
              Text('👤') // 这里可以用 Image(this.user.avatar) 优化，但原版是 emoji 就先保留
                .fontSize(40)
                .margin({ right: 16 })

              Column() {
                // ✅ 适配字段：username
                Text(this.user.username)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.text_primary'))
                  .width('100%')

                Text(`${this.getLevelText(this.user.level)} | 积分: ${this.user.points || 0}`)
                  .fontSize(14)
                  .fontColor($r('app.color.text_secondary'))
                  .width('100%')
                  .margin({ top: 4 })
              }
              .layoutWeight(1)

              Text('>')
                .fontSize(16)
                .fontColor($r('app.color.text_secondary'))
            }
            .width('100%')
            .padding(16)
            .backgroundColor($r('app.color.white'))
            .borderRadius(12)
            .margin({ left: 16, right: 16, top: 16 })
            .onClick(() => {
              // ✅ 跳转到编辑资料页面
              this.navigateToPage('pages/EditProfilePage');
            })

            // (B) 统计信息栏 (购物车/订单/评价)
            Row() {
              Column() {
                Text('🛒')
                  .fontSize(24)
                  .margin({ bottom: 4 })
                Text(this.cartCount.toString())
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.text_primary'))
                  .margin({ bottom: 2 })
                Text('购物车')
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('33%')
              .justifyContent(FlexAlign.Center)
              .onClick(() => this.navigateToPage('pages/CartPage'))

              Column() {
                Text('📦')
                  .fontSize(24)
                  .margin({ bottom: 4 })
                Text('0') // 订单数暂未对接
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.text_primary'))
                  .margin({ bottom: 2 })
                Text('订单')
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('33%')
              .justifyContent(FlexAlign.Center)

              Column() {
                Text('💬')
                  .fontSize(24)
                  .margin({ bottom: 4 })
                Text('0') // 评价数暂未对接
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.text_primary'))
                  .margin({ bottom: 2 })
                Text('评价')
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('34%')
              .justifyContent(FlexAlign.Center)
            }
            .width('100%')
            .padding(16)
            .backgroundColor($r('app.color.white'))
            .borderRadius(12)
            .margin({ left: 16, right: 16, top: 12 })

            // (C) 功能菜单
            Column() {
              Text('我的服务')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.text_primary'))
                .width('100%')
                .margin({ bottom: 12 })

              // 我的评价
              Row() {
                Text('💬')
                  .fontSize(20)
                  .margin({ right: 12 })

                Column() {
                  Text('我的评价')
                    .fontSize(14)
                    .fontColor($r('app.color.text_primary'))
                    .width('100%')
                  Text('查看评价记录')
                    .fontSize(12)
                    .fontColor($r('app.color.text_secondary'))
                    .width('100%')
                    .margin({ top: 2 })
                }
                .layoutWeight(1)

                Text('>')
                  .fontSize(16)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('100%')
              .padding(16)
              .justifyContent(FlexAlign.Start)
              .onClick(() => {
                this.navigateToPage('pages/MyReviewsPage');
              })

              Divider()
                .width('100%')
                .margin({ left: 16, right: 16 })

              // 收货地址
              Row() {
                Text('📍')
                  .fontSize(20)
                  .margin({ right: 12 })

                Column() {
                  Text('收货地址')
                    .fontSize(14)
                    .fontColor($r('app.color.text_primary'))
                    .width('100%')
                  Text('管理收货地址')
                    .fontSize(12)
                    .fontColor($r('app.color.text_secondary'))
                    .width('100%')
                    .margin({ top: 2 })
                }
                .layoutWeight(1)

                Text('>')
                  .fontSize(16)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('100%')
              .padding(16)
              .justifyContent(FlexAlign.Start)
              .onClick(() => this.navigateToPage('pages/AddressManagePage'))

              // 管理员后台 (仅管理员显示)
              if (this.isAdmin) {
                Divider()
                  .width('100%')
                  .margin({ left: 16, right: 16 })

                Row() {
                  Text('⚙️')
                    .fontSize(20)
                    .margin({ right: 12 })

                  Column() {
                    Text('管理员后台')
                      .fontSize(14)
                      .fontColor($r('app.color.text_primary'))
                      .width('100%')
                    Text('商品管理')
                      .fontSize(12)
                      .fontColor($r('app.color.text_secondary'))
                      .width('100%')
                      .margin({ top: 2 })
                  }
                  .layoutWeight(1)

                  Text('>')
                    .fontSize(16)
                    .fontColor($r('app.color.text_secondary'))
                }
                .width('100%')
                .padding(16)
                .justifyContent(FlexAlign.Start)
                .onClick(() => this.navigateToPage('pages/AdminDashboard'))
              }
            }
            .width('100%')
            .backgroundColor($r('app.color.white'))
            .borderRadius(12)
            .margin({ left: 16, right: 16, bottom: 12 })

            // (D) 退出登录
            Column() {
              Row() {
                Text('🚪')
                  .fontSize(20)
                  .margin({ right: 12 })

                Text('退出登录')
                  .fontSize(14)
                  .fontColor($r('app.color.text_primary'))
                  .layoutWeight(1)

                Text('>')
                  .fontSize(16)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('100%')
              .padding(16)
              .backgroundColor($r('app.color.white'))
              .borderRadius(12)
              .margin({ left: 16, right: 16, bottom: 16 })
              .justifyContent(FlexAlign.Start)
              .onClick(async () => {
                try {
                  // ✅ 适配逻辑：调用 AuthService 退出
                  await this.authService.logout();
                  this.user = null;
                  router.replaceUrl({ url: 'pages/LoginPage' });
                } catch (error) {
                  console.error('退出登录失败:', error);
                }
              })
            }
            .width('100%')

            Column()
              .width('100%')
              .height(20)
          }
          .width('100%')
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor($r('app.color.background'))
      } else {
        // ----------------------------------------------------------------
        // 3. 未登录状态 (保持 GitHub 原版 UI)
        // ----------------------------------------------------------------
        Column() {
          Column() {
            Text('👤')
              .fontSize(80)
              .margin({ bottom: 24 })
            Text('登录后享受更多服务')
              .fontSize(16)
              .fontColor($r('app.color.text_secondary'))
              .margin({ bottom: 32 })

            Button('立即登录')
              .width(200)
              .height(44)
              .fontSize(16)
              .backgroundColor($r('app.color.primary'))
              .fontColor(Color.White)
              .borderRadius(22)
              .onClick(() => {
                router.pushUrl({ url: 'pages/LoginPage' });
              })
          }
          .width('100%')
          .padding(48)
          .justifyContent(FlexAlign.Center)

          // 快速访问栏 (未登录态)
          Row() {
            Column() {
              Text('🏠')
                .fontSize(24)
                .margin({ bottom: 4 })
              Text('首页')
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
            }
            .width('25%')
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              router.replaceUrl({ url: 'pages/Index' });
            })

            Column() {
              Text('🛒')
                .fontSize(24)
                .margin({ bottom: 4 })
              Text('购物车')
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
            }
            .width('25%')
            .justifyContent(FlexAlign.Center)
            .onClick(() => this.navigateToPage('pages/CartPage'))

            Column() {
              Text('📦')
                .fontSize(24)
                .margin({ bottom: 4 })
              Text('订单')
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
            }
            .width('25%')
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.white'))
          .borderRadius(12)
          .margin({ left: 16, right: 16, bottom: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.background'))
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}