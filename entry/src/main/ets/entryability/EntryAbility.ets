import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';
import common from '@ohos.app.ability.common';
import { DatabaseManager } from '../database/DatabaseManager';
import { AuthService } from '../services/AuthService';
import { CartService } from '../services/CartService';

// ❌ 绝对不要 import @hw-agconnect 相关的包

export default class EntryAbility extends UIAbility {
  onCreate(want: Object, launchParam: Object): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    // ✅ 纯本地模式：不需要 initialize(this.context)
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // 初始化本地服务
    this.initServices();

    windowStage.loadContent('pages/SplashScreen', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
  }

  private async initServices(): Promise<void> {
    try {
      const context = this.context as common.UIAbilityContext;

      // 1. 初始化本地数据库
      await DatabaseManager.getInstance().init(context);
      // 2. 填充测试商品数据
      await DatabaseManager.getInstance().seedProducts();
      // 3. 初始化认证状态
      await AuthService.getInstance().init();
      // 4. 初始化购物车
      await CartService.getInstance().init();

      hilog.info(0x0000, 'testTag', '所有本地服务初始化成功');
    } catch (error) {
      hilog.error(0x0000, 'testTag', '服务初始化失败: %{public}s', JSON.stringify(error));
    }
  }

  onWindowStageDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}