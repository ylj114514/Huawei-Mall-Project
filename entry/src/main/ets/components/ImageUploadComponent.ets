import { ImageUploadHandler } from '../utils/ImageUploadHandler'
import common from '@ohos.app.ability.common'

// 图片上传项
export class ImageUploadItem {
  id: string
  uri: string
  isUploading?: boolean
  uploadProgress?: number

  constructor(id: string, uri: string, isUploading?: boolean, uploadProgress?: number) {
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
  @Prop onImagesChange: (images: ImageUploadItem[]) => void = () => {}
  @Prop enableCamera: boolean = true
  @State internalImages: ImageUploadItem[] = []

  private imageHandler: ImageUploadHandler = ImageUploadHandler.getInstance()
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  aboutToAppear() {
    this.internalImages = this.images
  }

  private async selectImages() {
    const remainingCount = this.maxCount - this.internalImages.length
    if (remainingCount <= 0) {
      console.log('已达到最大图片数量')
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

  private async takePhoto() {
    if (this.internalImages.length >= this.maxCount) {
      console.log('已达到最大图片数量')
      return
    }

    try {
      const uri = await this.imageHandler.takePhoto(this.context)

      if (uri) {
        const newImage: ImageUploadItem = new ImageUploadItem(
          Date.now().toString(),
          uri,
          false,
          0
        )

        this.internalImages = [...this.internalImages, newImage]
        this.onImagesChange(this.internalImages)
      }
    } catch (error) {
      console.error('拍照失败:', error)
    }
  }

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
        .onClick(() => {
          // 预览图片
          console.log('预览图片:', item.uri)
        })

      // 上传进度
      if (item.isUploading) {
        Column() {
          LoadingProgress()
            .width(24)
            .height(24)
          Text(`${item.uploadProgress}%`)
            .fontSize(12)
            .fontColor(Color.White)
            .margin({ top: 4 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('rgba(0,0,0,0.5)')
        .borderRadius(8)
      }

      // 删除按钮
      Button() {
        Text('✕')
          .fontSize(14)
          .fontColor(Color.White)
      }
      .width(24)
      .height(24)
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
          secondaryButton: {
            value: '取消',
            action: () => {}
          }
        })
      })
    }
    .width(100)
    .height(100)
    .margin(4)
  }

  @Builder
  AddImageButton() {
    Column() {
      Button() {
        Column() {
          Text('+')
            .fontSize(32)
            .fontColor(COLORS.textSecondary)
          Text('添加图片')
            .fontSize(12)
            .fontColor(COLORS.textSecondary)
            .margin({ top: 4 })
        }
      }
      .width(100)
      .height(100)
      .backgroundColor('#F5F5F7')
      .borderRadius(8)
      .margin(4)
      .onClick(() => {
        // 选择添加方式
        this.showActionSheet()
      })
    }
  }

  private showActionSheet() {
    // 这里简化处理，直接调用选择图片
    // 实际应用中可以使用 ActionSheet 或其他选择器
    this.selectImages()
  }

  build() {
    Column() {
      // 图片网格
      Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Start }) {
        // 显示已选择的图片
        ForEach(this.internalImages, (item: ImageUploadItem) => {
          this.ImageItem(item)
        })

        // 添加图片按钮
        if (this.internalImages.length < this.maxCount) {
          this.AddImageButton()
        }
      }
      .width('100%')

      // 底部提示
      Row() {
        Text(`已选择 ${this.internalImages.length}/${this.maxCount} 张图片`)
          .fontSize(14)
          .fontColor('#666666')
        Blank()

        if (this.internalImages.length > 0) {
          Button('清空')
            .fontSize(14)
            .fontColor('#FF3B30')
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              AlertDialog.show({
                title: '提示',
                message: '确定要清空所有图片吗？',
                primaryButton: {
                  value: '确定',
                  action: () => {
                    this.internalImages = []
                    this.onImagesChange(this.internalImages)
                  }
                },
                secondaryButton: {
                  value: '取消',
                  action: () => {}
                }
              })
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

// 颜色常量
class ColorConstants {
  static readonly textSecondary = '#999999'
}

const COLORS = ColorConstants