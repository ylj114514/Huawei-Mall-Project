import { ImagePickerSimple } from '../utils/ImagePickerSimple'
import common from '@ohos.app.ability.common'

/**
 * 简单图片选择器组件
 */
@Component
export struct ImagePickerSimpleComponent {
  @Prop images: string[] = []
  @Prop maxCount: number = 3
  @Prop onImagesChange: (images: string[]) => void = () => {}
  @State internalImages: string[] = []

  private imagePicker: ImagePickerSimple = ImagePickerSimple.getInstance()
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  aboutToAppear() {
    this.internalImages = this.images
  }

  private addImage() {
    // 模拟添加图片
    console.log('添加图片功能待实现')
  }

  private removeImage(index: number) {
    this.internalImages.splice(index, 1)
    this.onImagesChange([...this.internalImages])
  }

  build() {
    Column() {
      // 图片网格
      Flex({ wrap: FlexWrap.Wrap, alignItems: ItemAlign.Start }) {
        // 显示已选择的图片
        ForEach(this.internalImages, (imageUri: string, index?: number) => {
          Stack() {
            // 图片占位符
            Image($r('app.media.icon'))
              .width(80)
              .height(80)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)

            // 删除按钮
            Button() {
              Text('✕')
                .fontSize(12)
                .fontColor('#FFFFFF')
            }
            .width(20)
            .height(20)
            .backgroundColor('rgba(0,0,0,0.5)')
            .borderRadius(10)
            .position({ x: -5, y: -5 })
            .onClick(() => {
              this.removeImage(index!)
            })
          }
          .margin({ right: 8, bottom: 8 })
        })

        // 添加按钮
        if (this.internalImages.length < this.maxCount) {
          Button() {
            Column() {
              Text('+')
                .fontSize(24)
                .fontColor('#CCCCCC')
              Text('图片')
                .fontSize(12)
                .fontColor('#CCCCCC')
                .margin({ top: 4 })
            }
          }
          .width(80)
          .height(80)
          .backgroundColor('#F5F5F7')
          .borderRadius(8)
          .margin({ right: 8, bottom: 8 })
          .onClick(() => {
            this.addImage()
          })
        }
      }
      .width('100%')

      // 图片数量提示
      Text(`${this.internalImages.length}/${this.maxCount}`)
        .fontSize(12)
        .fontColor('#999999')
        .width('100%')
        .margin({ top: 8 })
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }
}