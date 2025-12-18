import router from '@ohos.router'
import { SimpleDatabaseManager } from '../model/SimpleDatabaseManager'
import { ProductModel, MockData } from '../model/ProductModel'

@Entry
@Component
struct ProductEditPage {
  @State product: ProductModel = new ProductModel(
    '0',
    '',
    0,
    0,
    '',
    '',
    [],
    '',
    [],
    0,
    0,
    100
  )
  @State isLoading: boolean = false
  @State isEditing: boolean = false
  @State categories: string[] = ['手机', '平板', '电脑', '耳机', '智能手表', '其他']
  @State selectedCategoryIndex: number = 0

  private dbManager: SimpleDatabaseManager = SimpleDatabaseManager.getInstance()

  aboutToAppear() {
    const params = router.getParams() as Record<string, Object>
    if (params?.product) {
      this.product = params.product as ProductModel
      this.isEditing = true
    }
    this.selectedCategoryIndex = this.categories.findIndex(c => c === this.product.category) || 0
  }

  private async onSave() {
    if (this.validateInput()) {
      this.isLoading = true
      try {
        this.product.category = this.categories[this.selectedCategoryIndex]

        if (this.isEditing) {
          await this.dbManager.updateProduct(parseInt(this.product.id), this.product)
          console.log('商品更新成功')
        } else {
          await this.dbManager.insertProduct(this.product)
          console.log('商品创建成功')
        }

        router.back()
      } catch (error) {
        console.error('保存失败:', error)
      } finally {
        this.isLoading = false
      }
    }
  }

  private async onDelete() {
    if (this.isEditing && parseInt(this.product.id) > 0) {
      try {
        AlertDialog.show({
          title: '确认删除',
          message: `确定要删除商品"${this.product.name}"吗？`,
          primaryButton: {
            value: '取消',
            action: () => {}
          },
          secondaryButton: {
            value: '删除',
            fontColor: '#ff4444',
            action: async () => {
              this.isLoading = true
              try {
                await this.dbManager.deleteProduct(parseInt(this.product.id))
                console.log('商品删除成功')
                router.back()
              } catch (error) {
                console.error('删除失败:', error)
              } finally {
                this.isLoading = false
              }
            }
          }
        })
      } catch (error) {
        console.error('删除操作失败:', error)
      }
    }
  }

  private validateInput(): boolean {
    if (!this.product.name.trim()) {
      // 显示错误提示：商品名称不能为空
      return false
    }
    if (this.product.price <= 0) {
      // 显示错误提示：价格必须大于0
      return false
    }
    if (this.product.stock < 0) {
      // 显示错误提示：库存不能为负数
      return false
    }
    return true
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button() {
          Row() {
            Text('←')
              .fontSize(24)
              .fontColor('#1a1a1a')
          }
        }
        .width(48)
        .height(48)
        .backgroundColor(Color.Transparent)
        .onClick(() => router.back())

        Blank()

        Text(this.isEditing ? '编辑商品' : '新增商品')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1a1a1a')

        Blank()

        if (this.isEditing) {
          Button('删除')
            .fontSize(16)
            .fontColor('#ff4444')
            .backgroundColor(Color.Transparent)
            .onClick(() => this.onDelete())
        }
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })

      // 表单内容
      Scroll() {
        Column() {
          // 基本信息
          Column() {
            Text('基本信息')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1a1a1a')
              .width('100%')
              .margin({ bottom: 20 })

            // 商品名称
            Column() {
              Text('商品名称')
                .fontSize(14)
                .fontColor('#666666')
                .margin({ bottom: 8 })

              TextInput({
                placeholder: '请输入商品名称',
                text: this.product.name
              })
                .fontSize(16)
                .width('100%')
                .height(48)
                .backgroundColor('#f5f5f7')
                .borderRadius(8)
                .padding({ left: 16, right: 16 })
                .onChange((value: string) => {
                  this.product.name = value
                })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .margin({ bottom: 20 })

            // 商品分类
            Column() {
              Text('商品分类')
                .fontSize(14)
                .fontColor('#666666')
                .margin({ bottom: 8 })

              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.categories, (category: string, index: number) => {
                  Button(category)
                    .fontSize(14)
                    .fontColor(this.selectedCategoryIndex === index ? Color.White : '#1a1a1a')
                    .backgroundColor(this.selectedCategoryIndex === index ? '#007aff' : '#f0f0f0')
                    .borderRadius(20)
                    .padding({ left: 20, right: 20, top: 10, bottom: 10 })
                    .margin({ right: 12, bottom: 8 })
                    .onClick(() => {
                      this.selectedCategoryIndex = index
                    })
                })
              }
              .width('100%')
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .margin({ bottom: 20 })

            // 商品描述
            Column() {
              Text('商品描述')
                .fontSize(14)
                .fontColor('#666666')
                .margin({ bottom: 8 })

              TextArea({
                placeholder: '请输入商品描述',
                text: this.product.description
              })
                .fontSize(16)
                .width('100%')
                .height(100)
                .backgroundColor('#f5f5f7')
                .borderRadius(8)
                .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                .onChange((value: string) => {
                  this.product.description = value
                })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .margin({ bottom: 20 })
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(20)
          .shadow({
            radius: 8,
            color: '#00000010',
            offsetX: 0,
            offsetY: 2
          })

          // 价格库存
          Column() {
            Text('价格库存')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1a1a1a')
              .width('100%')
              .margin({ bottom: 20 })

            Row() {
              Column() {
                Text('销售价格')
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ bottom: 8 })

                TextInput({
                  placeholder: '0.00',
                  text: this.product.price.toString()
                })
                  .fontSize(16)
                  .width('100%')
                  .height(48)
                  .backgroundColor('#f5f5f7')
                  .borderRadius(8)
                  .padding({ left: 16, right: 16 })
                  .type(InputType.Number)
                  .onChange((value: string) => {
                    this.product.price = parseFloat(value) || 0
                  })
              }
              .layoutWeight(1)
              .margin({ right: 12 })

              Column() {
                Text('原价')
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ bottom: 8 })

                TextInput({
                  placeholder: '0.00',
                  text: this.product.originalPrice.toString()
                })
                  .fontSize(16)
                  .width('100%')
                  .height(48)
                  .backgroundColor('#f5f5f7')
                  .borderRadius(8)
                  .padding({ left: 16, right: 16 })
                  .type(InputType.Number)
                  .onChange((value: string) => {
                    this.product.originalPrice = parseFloat(value) || 0
                  })
              }
              .layoutWeight(1)
            }
            .width('100%')
            .margin({ bottom: 20 })

            Column() {
              Text('库存数量')
                .fontSize(14)
                .fontColor('#666666')
                .margin({ bottom: 8 })

              TextInput({
                placeholder: '0',
                text: this.product.stock.toString()
              })
                .fontSize(16)
                .width('100%')
                .height(48)
                .backgroundColor('#f5f5f7')
                .borderRadius(8)
                .padding({ left: 16, right: 16 })
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.product.stock = parseInt(value) || 0
                })
            }
            .width('100%')
            .margin({ bottom: 20 })
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(20)
          .shadow({
            radius: 8,
            color: '#00000010',
            offsetX: 0,
            offsetY: 2
          })
          .margin({ top: 12 })

          // 商品图片
          Column() {
            Text('商品图片')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1a1a1a')
              .width('100%')
              .margin({ bottom: 20 })

            TextInput({
              placeholder: '请输入图片URL',
              text: this.product.image
            })
              .fontSize(16)
              .width('100%')
              .height(48)
              .backgroundColor('#f5f5f7')
              .borderRadius(8)
              .padding({ left: 16, right: 16 })
              .onChange((value: string) => {
                this.product.image = value
              })

            if (this.product.image) {
              Image(this.product.image)
                .width('100%')
                .height(200)
                .objectFit(ImageFit.Contain)
                .backgroundColor('#f0f0f0')
                .borderRadius(8)
                .margin({ top: 16 })
            }
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(20)
          .shadow({
            radius: 8,
            color: '#00000010',
            offsetX: 0,
            offsetY: 2
          })
          .margin({ top: 12 })

          // 详细信息
          Column() {
            Text('详细信息')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1a1a1a')
              .width('100%')
              .margin({ bottom: 20 })

            TextArea({
              placeholder: '请输入商品详细描述',
              text: this.product.detailDescription
            })
              .fontSize(16)
              .width('100%')
              .height(150)
              .backgroundColor('#f5f5f7')
              .borderRadius(8)
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .onChange((value: string) => {
                this.product.detailDescription = value
              })
          }
          .width('100%')
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(20)
          .shadow({
            radius: 8,
            color: '#00000010',
            offsetX: 0,
            offsetY: 2
          })
          .margin({ top: 12 })

          // 底部间距
          Column()
            .width('100%')
            .height(100)
        }
        .width('100%')
        .padding({ bottom: 20 })
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#f5f5f7')

      // 底部操作栏
      Column() {
        Button(this.isLoading ? '保存中...' : '保存')
          .width('100%')
          .height(50)
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor('#007aff')
          .borderRadius(25)
          .enabled(!this.isLoading)
          .onClick(() => this.onSave())
      }
      .width('100%')
      .padding(20)
      .backgroundColor('rgba(255,255,255,0.98)')
      .backdropBlur(20)
      .border({ width: { top: 0.5 }, color: '#e5e5e5' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f7')
  }
}