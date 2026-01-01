import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';
import common from '@ohos.app.ability.common';
import { DatabaseManager } from '../database/DatabaseManager';
import { AuthService } from '../services/AuthService';
import { CartService } from '../services/CartService';
// ✅ 引入华为 AGC 初始化模块
// ✅ 引入华为 AGC 初始化模块
// ✅ 正确写法
import { initialize } from '@hw-agconnect/hmcore';

import buffer from '@ohos.buffer';

export default class EntryAbility extends UIAbility {
  onCreate(want: Object, launchParam: Object): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');

    // ✅ 核心逻辑：初始化华为 AGC 服务
    try {
      this.context.resourceManager.getRawFileContent('agconnect-services.json').then((value) => {
        let jsonString = buffer.from(value).toString('utf8');
        initialize(this.context, JSON.parse(jsonString));
        hilog.info(0x0000, 'AGC', '华为 AGC SDK 初始化成功！');
      }).catch((error: Error) => {
        hilog.error(0x0000, 'AGC', '配置文件读取失败，请检查 rawfile 目录: ' + JSON.stringify(error));
      });
    } catch (err) {
      hilog.error(0x0000, 'AGC', 'AGC 初始化异常: ' + JSON.stringify(err));
    }
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // 初始化其他本地服务 (数据库、购物车)
    this.initServices().catch((err: Error) => {
      hilog.error(0x0000, 'testTag', 'Init services failed: %{public}s', JSON.stringify(err) ?? '');
    });

    // 加载启动页
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
      await DatabaseManager.getInstance().init(context);
      await DatabaseManager.getInstance().seedProducts();
      // AuthService 的初始化现在主要依赖 AGC，这里保留调用以防万一
      // await AuthService.getInstance().init();
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