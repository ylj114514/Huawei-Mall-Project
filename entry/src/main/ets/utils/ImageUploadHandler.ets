import common from '@ohos.app.ability.common';
import picker from '@ohos.file.picker'; // ✅ 核心：引入文件选择器模块

/**
 * 图片上传处理器 (已修复真实相册调用)
 */
export class ImageUploadHandler {
  private static instance: ImageUploadHandler;

  private constructor() {}

  public static getInstance(): ImageUploadHandler {
    if (!ImageUploadHandler.instance) {
      ImageUploadHandler.instance = new ImageUploadHandler();
    }
    return ImageUploadHandler.instance;
  }

  /**
   * 选择多张图片 (调用系统相册)
   * @param context 上下文
   * @param maxCount 最大选择数量
   */
  public async selectMultipleImages(context: common.UIAbilityContext, maxCount: number = 9): Promise<string[]> {
    try {
      // 1. 创建图库选择选项
      const photoSelectOptions = new picker.PhotoSelectOptions();
      // 设置选择类型为图片
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      // 设置最大选择数量
      photoSelectOptions.maxSelectNumber = maxCount;

      // 2. 创建图库选择器实例
      const photoViewPicker = new picker.PhotoViewPicker();

      // 3. 拉起系统图库，用户选择图片
      const photoSelectResult = await photoViewPicker.select(photoSelectOptions);

      // 4. 处理返回结果
      if (photoSelectResult && photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
        // 返回真实的图片 URI 数组
        return photoSelectResult.photoUris;
      }

      return [];
    } catch (error) {
      console.error('ImageUploadHandler: 选择图片失败', JSON.stringify(error));
      return [];
    }
  }

  /**
   * 选择单张图片 (复用多选逻辑，限制数量为1)
   */
  public async selectSingleImage(context: common.UIAbilityContext): Promise<string | null> {
    const uris = await this.selectMultipleImages(context, 1);
    return uris.length > 0 ? uris[0] : null;
  }

  /**
   * 拍照 (暂未实现，可留空或后续集成 CameraKit)
   */
  public async takePhoto(context: common.UIAbilityContext): Promise<string | null> {
    console.log('拍照功能待后续集成');
    // 提示：实际上 PhotoViewPicker 界面里通常自带“拍照”按钮，
    // 所以 selectMultipleImages 往往已经能满足基本的拍照上传需求。
    return null;
  }
}