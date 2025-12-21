// entry/src/main/ets/pages/ProductEditPage.ets
import router from '@ohos.router'
import common from '@ohos.app.ability.common'
import { DatabaseManager } from '../database/DatabaseManager'
import { AuthService } from '../services/AuthService'
import { ProductModel } from '../model/ProductModel'
import { AdminGuard } from '../utils/AdminGuard'

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
    5.0,
    0,
    100
  )
  @State isLoading: boolean = false
  @State isEditing: boolean = false
  @State categories: string[] = ['手机', '平板', '笔记本', '智能穿戴', '音频', '智慧屏', '其他']
  @State selectedCategoryIndex: number = 0
  @State isReady: boolean = false

  private dbManager: DatabaseManager = DatabaseManager.getInstance()
  private auth: AuthService = AuthService.getInstance()

  aboutToAppear() {
    this.initPage()
  }

  private async initPage() {
    try {
      // 1) init DB
      const ctx = getContext(this) as common.UIAbilityContext
      await this.dbManager.init(ctx)

      // 2) 把 AppStorage 当前账号同步到 DB
      const account = this.auth.getCurrentAccount()
      if (account) {
        this.dbManager.setCurrentUserAccount(account)
      }

      // 3) 管理员校验 (使用 AdminGuard)
      try {
        await AdminGuard.ensureAdmin()
      } catch (e) {
        console.error('No admin permission:', e)
        router.back()
        return
      }

      // 4) 读取路由参数
      const params = router.getParams() as Record<string, Object>
      if (params?.product) {
        this.product = params.product as ProductModel
        this.isEditing = true
      } else {
        this.isEditing = false
      }

      // 5) 设置分类索引
      const idx = this.categories.findIndex(c => c === this.product.category)
      this.selectedCategoryIndex = idx >= 0 ? idx : 0

      this.isReady = true
    } catch (e) {
      console.error('[ProductEditPage] init failed:', e)
      AlertDialog.show({
        title: '初始化失败',
        message: '数据库/权限初始化失败，请查看控制台日志。',
        primaryButton: { value: '返回', action: () => router.back() }
      })
    }
  }

  private validateInput(): boolean {
    if (!this.product.name.trim()) {
      AlertDialog.show({
        title: '输入错误',
        message: '商品名称不能为空',
        primaryButton: { value: '知道了', action: () => {} }
      })
      return false
    }
    if (this.product.price <= 0) {
      AlertDialog.show({
        title: '输入错误',
        message: '价格必须大于0',
        primaryButton: { value: '知道了', action: () => {} }
      })
      return false
    }
    if (this.product.stock < 0) {
      AlertDialog.show({
        title: '输入错误',
        message: '库存不能为负数',
        primaryButton: { value: '知道了', action: () => {} }
      })
      return false
    }
    return true
  }

  private async onSave() {
    if (!this.isReady) return
    if (!this.validateInput()) return

    this.isLoading = true
    try {
      this.product.category = this.categories[this.selectedCategoryIndex] || this.categories[0]

      if (this.isEditing) {
        await this.dbManager.updateProduct(parseInt(this.product.id) || 0, this.product)
        console.info('[ProductEditPage] 商品更新成功')
      } else {
        await this.dbManager.insertProduct(this.product)
        console.info('[ProductEditPage] 商品创建成功')
      }

      router.back()
    } catch (e) {
      console.error('[ProductEditPage] save failed:', e)
      AlertDialog.show({
        title: '保存失败',
        message: '保存失败，请查看日志。',
        primaryButton: { value: '知道了', action: () => {} }
      })
    } finally {
      this.isLoading = false
    }
  }

  private async onDelete() {
    if (!this.isReady || !this.isEditing) return

    AlertDialog.show({
      title: '确认删除',
      message: `确定要删除商品 "${this.product.name}" 吗？（将标记为下架/删除）`,
      primaryButton: { value: '取消', action: () => {} },
      secondaryButton: {
        value: '删除',
        fontColor: '#ff4444',
        action: async () => {
          this.isLoading = true
          try {
            await this.dbManager.deleteProduct(parseInt(this.product.id) || 0)
            console.info('[ProductEditPage] 商品删除成功')
            router.back()
          } catch (e) {
            console.error('[ProductEditPage] delete failed:', e)
            AlertDialog.show({
              title: '删除失败',
              message: '删除失败，请查看日志。',
              primaryButton: { value: '知道了', action: () => {} }
            })
          } finally {
            this.isLoading = false
          }
        }
      }
    })
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button() {
          Text('←')
            .fontSize(24)
            .fontColor('#1a1a1a')
        }
        .width(48)
        .height(48)
        .backgroundColor(Color.Transparent)
        .onClick(() => router.back())

        Blank()

        Text(this.isEditing ? '编辑商品（管理员）' : '新增商品（管理员）')
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

      if (!this.isReady) {
        Column() {
          LoadingProgress().width(40).height(40)
          Text('初始化中（数据库 + 管理员校验）...')
            .fontSize(14)
            .fontColor('#666')
            .margin({ top: 12 })
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#f5f5f7')
      } else {
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

              Column() {
                Text('商品名称')
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ bottom: 8 })

                TextInput({ placeholder: '请输入商品名称', text: this.product.name })
                  .fontSize(16)
                  .width('100%')
                  .height(48)
                  .backgroundColor('#f5f5f7')
                  .borderRadius(8)
                  .padding({ left: 16, right: 16 })
                  .onChange((value: string) => { this.product.name = value })
              }
              .width('100%')
              .margin({ bottom: 20 })

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
                      .onClick(() => { this.selectedCategoryIndex = index })
                  })
                }
                .width('100%')
              }
              .width('100%')
              .margin({ bottom: 20 })

              Column() {
                Text('商品描述')
                  .fontSize(14)
                  .fontColor('#666666')
                  .margin({ bottom: 8 })

                TextArea({ placeholder: '请输入商品描述', text: this.product.description })
                  .fontSize(16)
                  .width('100%')
                  .height(100)
                  .backgroundColor('#f5f5f7')
                  .borderRadius(8)
                  .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                  .onChange((value: string) => { this.product.description = value })
              }
              .width('100%')
              .margin({ bottom: 20 })
            }
            .width('100%')
            .padding(20)
            .backgroundColor(Color.White)
            .borderRadius(20)
            .shadow({ radius: 8, color: '#00000010', offsetX: 0, offsetY: 2 })

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

                  TextInput({ placeholder: '0.00', text: this.product.price.toString() })
                    .fontSize(16)
                    .width('100%')
                    .height(48)
                    .backgroundColor('#f5f5f7')
                    .borderRadius(8)
                    .padding({ left: 16, right: 16 })
                    .type(InputType.Number)
                    .onChange((value: string) => { this.product.price = parseFloat(value) || 0 })
                }
                .layoutWeight(1)
                .margin({ right: 12 })

                Column() {
                  Text('原价')
                    .fontSize(14)
                    .fontColor('#666666')
                    .margin({ bottom: 8 })

                  TextInput({ placeholder: '0.00', text: this.product.originalPrice.toString() })
                    .fontSize(16)
                    .width('100%')
                    .height(48)
                    .backgroundColor('#f5f5f7')
                    .borderRadius(8)
                    .padding({ left: 16, right: 16 })
                    .type(InputType.Number)
                    .onChange((value: string) => { this.product.originalPrice = parseFloat(value) || 0 })
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

                TextInput({ placeholder: '0', text: this.product.stock.toString() })
                  .fontSize(16)
                  .width('100%')
                  .height(48)
                  .backgroundColor('#f5f5f7')
                  .borderRadius(8)
                  .padding({ left: 16, right: 16 })
                  .type(InputType.Number)
                  .onChange((value: string) => { this.product.stock = parseInt(value) || 0 })
              }
              .width('100%')
              .margin({ bottom: 20 })
            }
            .width('100%')
            .padding(20)
            .backgroundColor(Color.White)
            .borderRadius(20)
            .shadow({ radius: 8, color: '#00000010', offsetX: 0, offsetY: 2 })
            .margin({ top: 12 })

            // 图片（暂不让你输入URL，避免 Resource/string 类型炸）
            Column() {
              Text('商品图片（暂不支持手动输入URL）')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1a1a1a')
                .width('100%')
                .margin({ bottom: 12 })

              Image(this.product.image)
                .width('100%')
                .height(200)
                .objectFit(ImageFit.Contain)
                .backgroundColor('#f0f0f0')
                .borderRadius(8)

              Text('提示：ProductModel.image 是 Resource 类型，后面我们用 ImagePicker 选图再入库。')
                .fontSize(12)
                .fontColor('#888')
                .margin({ top: 10 })
            }
            .width('100%')
            .padding(20)
            .backgroundColor(Color.White)
            .borderRadius(20)
            .shadow({ radius: 8, color: '#00000010', offsetX: 0, offsetY: 2 })
            .margin({ top: 12 })

            // 详细描述
            Column() {
              Text('详细信息')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1a1a1a')
                .width('100%')
                .margin({ bottom: 12 })

              TextArea({ placeholder: '请输入商品详细描述', text: this.product.detailDescription })
                .fontSize(16)
                .width('100%')
                .height(150)
                .backgroundColor('#f5f5f7')
                .borderRadius(8)
                .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                .onChange((value: string) => { this.product.detailDescription = value })
            }
            .width('100%')
            .padding(20)
            .backgroundColor(Color.White)
            .borderRadius(20)
            .shadow({ radius: 8, color: '#00000010', offsetX: 0, offsetY: 2 })
            .margin({ top: 12 })

            Column().width('100%').height(100)
          }
          .width('100%')
          .padding({ bottom: 20 })
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#f5f5f7')
      }

      // 底部按钮
      Column() {
        Button(this.isLoading ? '保存中...' : '保存')
          .width('100%')
          .height(50)
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor('#007aff')
          .borderRadius(25)
          .enabled(!this.isLoading && this.isReady)
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