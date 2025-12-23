import router from '@ohos.router'
import { RegionPicker } from '../components/RegionPicker'

// ==========================================
// 1. 本地定义地址模型
// ==========================================
class Address {
  id: string = ''
  name: string = ''
  phone: string = ''
  province: string = ''
  city: string = ''
  district: string = ''
  detail: string = ''
  isDefault: boolean = false

  constructor(name: string, phone: string, province: string, city: string, district: string, detail: string, isDefault: boolean) {
    this.id = new Date().getTime().toString()
    this.name = name
    this.phone = phone
    this.province = province
    this.city = city
    this.district = district
    this.detail = detail
    this.isDefault = isDefault
  }

  getFullAddress(): string {
    return `${this.province}${this.city}${this.district}${this.detail}`
  }
}

@Entry
@Component
struct AddressEditPage {
  @State name: string = ''
  @State phone: string = ''
  @State province: string = ''
  @State city: string = ''
  @State district: string = ''
  @State detail: string = ''
  @State isDefault: boolean = false
  @State isEdit: boolean = false
  @State addressId: string = ''
  @State isLoading: boolean = false

  aboutToAppear() {
    // 获取传入的地址参数
    const params = router.getParams()

    // 【核心修改】解决 arkts-no-any-unknown 报错
    // 不再使用 "as unknown"，而是直接将 Object 断言为 Address
    if (params) {
      // 1. 先断言为 Record<string, Object> 以便能通过字符串索引访问
      const paramsMap = params as Record<string, Object>

      // 2. 检查是否存在 address 字段
      if (paramsMap['address']) {
        // 3. 直接将 Object 类型断言为 Address 类
        // 注意：这里去掉了 "as unknown"，直接转换，符合您的严格模式配置
        const address = paramsMap['address'] as Address

        if (address) {
          this.isEdit = true
          this.addressId = address.id
          this.name = address.name
          this.phone = address.phone
          this.province = address.province
          this.city = address.city
          this.district = address.district
          this.detail = address.detail
          this.isDefault = address.isDefault
        }
      }
    }
  }

  // 验证表单
  private validateForm(): boolean {
    if (!this.name.trim()) {
      console.error('请输入收货人姓名')
      return false
    }

    if (!/^1[3-9]\d{9}$/.test(this.phone)) {
      console.error('请输入正确的手机号')
      return false
    }

    if (!this.province || !this.city || !this.district) {
      console.error('请选择完整的省市区')
      return false
    }

    if (!this.detail.trim()) {
      console.error('请输入详细地址')
      return false
    }

    return true
  }

  // 保存地址 (模拟逻辑)
  private async saveAddress(): Promise<void> {
    if (!this.validateForm()) {
      return
    }

    this.isLoading = true

    try {
      // 模拟网络请求延迟
      await new Promise<void>((resolve) => setTimeout(resolve, 500))

      const newAddress = new Address(
        this.name,
        this.phone,
        this.province,
        this.city,
        this.district,
        this.detail,
        this.isDefault
      )

      if (this.isEdit) {
        newAddress.id = this.addressId
      }

      console.info('地址保存成功:', newAddress.getFullAddress())

      this.isLoading = false
      router.back()
    } catch (error) {
      console.error('保存地址失败:', JSON.stringify(error))
      this.isLoading = false
    }
  }

  // 删除地址 (模拟逻辑)
  private async deleteAddress(): Promise<void> {
    if (!this.isEdit) return

    try {
      // 模拟网络请求延迟
      await new Promise<void>((resolve) => setTimeout(resolve, 500))

      console.info('地址删除成功:', this.addressId)
      router.back()
    } catch (error) {
      console.error('删除地址失败:', JSON.stringify(error))
    }
  }

  // 选择地区回调
  private onRegionChange(province: string, city: string, district: string): void {
    this.province = province
    this.city = city
    this.district = district
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button('←')
          .width(40)
          .height(40)
          .backgroundColor(Color.Transparent)
          .fontColor($r('app.color.text_primary'))
          .onClick(() => {
            router.back()
          })

        Text(this.isEdit ? '编辑地址' : '新增地址')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        if (this.isEdit) {
          Button('删除')
            .height(40)
            .backgroundColor(Color.Transparent)
            .fontColor($r('app.color.error'))
            .onClick(() => this.deleteAddress())
        } else {
          Blank().width(40)
        }
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .backgroundColor($r('app.color.white'))

      Scroll() {
        Column() {
          // 收货人信息卡片
          Column() {
            Text('收货人信息')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .margin({ bottom: 16 })

            // 姓名输入
            Column() {
              Text('收货人姓名')
                .fontSize(14)
                .fontColor($r('app.color.text_primary'))
                .width('100%')
                .margin({ bottom: 8 })

              TextInput({ placeholder: '请输入收货人姓名', text: this.name })
                .width('100%')
                .height(48)
                .fontSize(16)
                .backgroundColor($r('app.color.background'))
                .borderRadius(8)
                .padding({ left: 16 })
                .onChange((value: string) => {
                  this.name = value
                })
            }
            .width('100%')
            .margin({ bottom: 16 })

            // 手机号输入
            Column() {
              Text('手机号码')
                .fontSize(14)
                .fontColor($r('app.color.text_primary'))
                .width('100%')
                .margin({ bottom: 8 })

              TextInput({ placeholder: '请输入手机号码', text: this.phone })
                .width('100%')
                .height(48)
                .fontSize(16)
                .backgroundColor($r('app.color.background'))
                .borderRadius(8)
                .padding({ left: 16 })
                .maxLength(11)
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.phone = value
                })
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.white'))
          .borderRadius(8)
          .margin({ left: 16, right: 16, top: 12 })

          // 收货地址卡片
          Column() {
            Text('收货地址')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
              .margin({ bottom: 16 })

            // 省市区选择
            Column() {
              Text('所在地区')
                .fontSize(14)
                .fontColor($r('app.color.text_primary'))
                .width('100%')
                .margin({ bottom: 8 })

              // 确保 components 目录下有 RegionPicker 组件
              RegionPicker({
                selectedProvince: this.province,
                selectedCity: this.city,
                selectedDistrict: this.district,
                onRegionChange: (province: string, city: string, district: string) => {
                  this.onRegionChange(province, city, district)
                }
              })
            }
            .width('100%')
            .margin({ bottom: 16 })

            // 详细地址输入
            Column() {
              Text('详细地址')
                .fontSize(14)
                .fontColor($r('app.color.text_primary'))
                .width('100%')
                .margin({ bottom: 8 })

              TextArea({
                placeholder: '请输入详细地址，如道路、门牌号、小区、楼栋号、单元等',
                text: this.detail
              })
                .width('100%')
                .height(80)
                .fontSize(16)
                .backgroundColor($r('app.color.background'))
                .borderRadius(8)
                .padding(16)
                .onChange((value: string) => {
                  this.detail = value
                })
            }
            .width('100%')
            .margin({ bottom: 16 })

          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.white'))
          .borderRadius(8)
          .margin({ left: 16, right: 16, top: 12 })

          // 默认地址设置
          Row() {
            Column() {
              Text('设为默认地址')
                .fontSize(16)
                .fontColor($r('app.color.text_primary'))
                .width('100%')

              Text('下次下单时会优先使用该地址')
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
                .width('100%')
                .margin({ top: 4 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            Button() {
              Circle({ width: 20, height: 20 })
                .fill(this.isDefault ? $r('app.color.primary') : Color.Transparent)
                .stroke(this.isDefault ? Color.Transparent : $r('app.color.text_secondary'))
                .strokeWidth(2)
            }
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.isDefault = !this.isDefault
            })
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.white'))
          .borderRadius(8)
          .margin({ left: 16, right: 16, top: 12 })

          // 底部保存按钮
          Button('保存地址')
            .width('100%')
            .height(48)
            .fontSize(16)
            .backgroundColor($r('app.color.primary'))
            .fontColor(Color.White)
            .borderRadius(8)
            .margin({ left: 16, right: 16, top: 24 })
            .enabled(!this.isLoading && this.name.length > 0 && this.phone.length > 0 && this.province.length > 0 && this.city.length > 0 && this.district.length > 0 && this.detail.length > 0)
            .onClick(() => this.saveAddress())

          if (this.isLoading) {
            LoadingProgress()
              .width(20)
              .height(20)
              .margin({ top: 16 })
          }

          // 底部占位
          Column()
            .width('100%')
            .height(100)
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}