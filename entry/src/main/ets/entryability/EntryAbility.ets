import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';
import common from '@ohos.app.ability.common';
import { DatabaseManager } from '../database/DatabaseManager';
import { AuthService } from '../services/AuthService';
import { CartService } from '../services/CartService';

export default class EntryAbility extends UIAbility {
  onCreate(want: Object, launchParam: Object): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  // ✅ 修复：去掉 async，保持标准签名
  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // 调用内部异步初始化
    this.initServices();

    windowStage.loadContent('pages/SplashScreen', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
  }

  // ✅ 封装异步初始化逻辑
  private async initServices(): Promise<void> {
    try {
      const context = this.context as common.UIAbilityContext;

      // 1. 初始化数据库
      await DatabaseManager.getInstance().init(context);
      // 2. 播种数据
      await DatabaseManager.getInstance().seedProducts();
      // 3. 初始化用户服务 (现在 AuthService 有 init 方法了)
      await AuthService.getInstance().init();
      // 4. 初始化购物车
      await CartService.getInstance().init();

      console.info('All services initialized successfully');
    } catch (error) {
      console.error('Service initialization failed:', JSON.stringify(error));
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