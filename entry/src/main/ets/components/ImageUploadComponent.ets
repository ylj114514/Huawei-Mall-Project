import { ImageUploadHandler } from '../utils/ImageUploadHandler'
import common from '@ohos.app.ability.common'

// ✅ 修复 1：修改类定义，使 uri 支持 Resource 类型 (Mock图片) 和 string (上传图片)
export class ImageUploadItem {
  id: string
  uri: ResourceStr  // 这里改为 ResourceStr
  isUploading?: boolean
  uploadProgress?: number

  constructor(id: string, uri: ResourceStr, isUploading?: boolean, uploadProgress?: number) {
    this.id = id
    this.uri = uri
    this.isUploading = isUploading
    this.uploadProgress = uploadProgress
  }
}

@Component
export struct ImageUploadComponent {
  @Prop images: ImageUploadItem[] = []
  @Prop maxCount: number = 9

  // ✅ 修复 2：删除了 @Prop，函数不能用 @Prop 装饰
  onImagesChange: (images: ImageUploadItem[]) => void = () => {}

  @Prop enableCamera: boolean = true
  @State internalImages: ImageUploadItem[] = []

  private imageHandler: ImageUploadHandler = ImageUploadHandler.getInstance()
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  aboutToAppear() {
    this.internalImages = this.images
  }

  // 监听外部数据变化
  aboutToRender() {
    if (this.images.length !== this.internalImages.length) {
      this.internalImages = this.images
    }
  }

  private async selectImages() {
    const remainingCount = this.maxCount - this.internalImages.length
    if (remainingCount <= 0) {
      console.info('已达到最大图片数量')
      return
    }

    try {
      const uris = await this.imageHandler.selectMultipleImages(this.context, remainingCount)

      if (uris && uris.length > 0) {
        const newImages: ImageUploadItem[] = uris.map(uri => {
          return new ImageUploadItem(
            Date.now().toString() + Math.random().toString(),
            uri,
            false,
            0
          )
        })

        this.internalImages = [...this.internalImages, ...newImages]
        this.onImagesChange(this.internalImages)
      }
    } catch (error) {
      console.error('选择图片失败:', error)
    }
  }

  // 拍照功能（如有需要可取消注释并实现 ImageUploadHandler.takePhoto）
  /*
  private async takePhoto() {
    if (this.internalImages.length >= this.maxCount) return
    try {
      const uri = await this.imageHandler.takePhoto(this.context)
      if (uri) {
        const newImage = new ImageUploadItem(Date.now().toString(), uri, false, 0)
        this.internalImages = [...this.internalImages, newImage]
        this.onImagesChange(this.internalImages)
      }
    } catch (error) {
      console.error('拍照失败:', error)
    }
  }
  */

  private removeImage(id: string) {
    this.internalImages = this.internalImages.filter(img => img.id !== id)
    this.onImagesChange(this.internalImages)
  }

  @Builder
  ImageItem(item: ImageUploadItem) {
    Stack() {
      // 图片显示
      Image(item.uri)
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .borderRadius(8)

      // 删除按钮
      Button('✕')
        .width(24)
        .height(24)
        .fontSize(14)
        .fontColor(Color.White)
        .backgroundColor('rgba(0,0,0,0.6)')
        .borderRadius(12)
        .position({ x: -8, y: -8 })
        .onClick(() => {
          AlertDialog.show({
            title: '提示',
            message: '确定要删除这张图片吗？',
            primaryButton: {
              value: '确定',
              action: () => this.removeImage(item.id)
            },
            secondaryButton: { value: '取消', action: () => {} }
          })
        })
    }
    .width(100)
    .height(100)
    .margin(4)
  }

  @Builder
  AddImageButton() {
    Button() {
      Column() {
        Text('+').fontSize(32).fontColor('#999')
        Text('添加图片').fontSize(12).fontColor('#999').margin({ top: 4 })
      }
    }
    .width(100)
    .height(100)
    .backgroundColor('#F5F5F7')
    .borderRadius(8)
    .margin(4)
    .onClick(() => {
      this.selectImages()
    })
  }

  build() {
    Column() {
      Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Start }) {
        ForEach(this.internalImages, (item: ImageUploadItem) => {
          this.ImageItem(item)
        })
        if (this.internalImages.length < this.maxCount) {
          this.AddImageButton()
        }
      }
      .width('100%')

      Row() {
        Text(`已选择 ${this.internalImages.length}/${this.maxCount} 张图片`)
          .fontSize(14)
          .fontColor('#666')
        Blank()
        if (this.internalImages.length > 0) {
          Button('清空')
            .fontSize(14)
            .fontColor('#FF3B30')
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.internalImages = []
              this.onImagesChange(this.internalImages)
            })
        }
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }
}