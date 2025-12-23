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

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // 调用内部异步初始化，并捕获可能的错误
    this.initServices().catch((err: Error) => {
      hilog.error(0x0000, 'testTag', 'Init services failed: %{public}s', JSON.stringify(err) ?? '');
    });

    // 这里加载 SplashScreen 是正确的，SplashScreen 会负责跳转到 Index
    windowStage.loadContent('pages/SplashScreen', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
  }

  // 封装异步初始化逻辑
  private async initServices(): Promise<void> {
    try {
      const context = this.context as common.UIAbilityContext;

      // 1. 初始化数据库
      await DatabaseManager.getInstance().init(context);
      // 2. 播种数据
      await DatabaseManager.getInstance().seedProducts();
      // 3. 初始化用户服务
      await AuthService.getInstance().init();
      // 4. 初始化购物车
      await CartService.getInstance().init();

      hilog.info(0x0000, 'testTag', 'All services initialized successfully');
    } catch (error) {
      hilog.error(0x0000, 'testTag', 'Service initialization failed: %{public}s', JSON.stringify(error));
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