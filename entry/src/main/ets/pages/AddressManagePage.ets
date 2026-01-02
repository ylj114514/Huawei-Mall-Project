import router from '@ohos.router'

// ==========================================
// 1. 本地定义地址模型 (解决依赖缺失问题)
// ==========================================
class AddressModel {
  id: string = ''
  name: string = ''
  phone: string = ''
  province: string = ''
  city: string = ''
  area: string = ''
  detail: string = ''
  isDefault: boolean = false
  fullAddress: string = ''
}

@Entry
@Component
struct AddressManagePage {
  @State addressList: AddressModel[] = []
  @State isLoading: boolean = true

  aboutToAppear() {
    this.loadAddresses()
  }

  // 模拟加载数据，替代原本的 StorageManager 调用
  loadAddresses() {
    this.isLoading = true
    // 模拟网络延迟
    setTimeout(() => {
      // 模拟数据 1
      let addr1 = new AddressModel()
      addr1.id = '1'
      addr1.name = '于粮嘉'
      addr1.phone = '13800138000'
      addr1.province = '北京市'
      addr1.city = '北京市'
      addr1.area = '海淀区'
      addr1.detail = '西土城路10号北京邮电大学'
      addr1.isDefault = true
      addr1.fullAddress = '北京市北京市海淀区西土城路10号北京邮电大学'

      // 模拟数据 2
      let addr2 = new AddressModel()
      addr2.id = '2'
      addr2.name = '测试用户'
      addr2.phone = '13900139000'
      addr2.province = '北京市'
      addr2.city = '北京市'
      addr2.area = '朝阳区'
      addr2.detail = '建国路88号'
      addr2.isDefault = false
      addr2.fullAddress = '北京市北京市朝阳区建国路88号'

      this.addressList = [addr1, addr2]
      this.isLoading = false
    }, 500)
  }

  // 跳转逻辑
  navigateToEdit(addressId?: string) {
    router.pushUrl({
      url: 'pages/AddressEditPage',
      params: {
        addressId: addressId || ''
      }
    })
  }

  build() {
    Column() {
      // Top Navigation
      Row() {
        Button('←')
          .width(40)
          .height(40)
          .backgroundColor(Color.Transparent)
          .fontColor(Color.Black)
          .fontSize(18)
          .onClick(() => {
            router.back()
          })

        Text('收货地址')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Blank().width(40)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Color.White)

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 12 }) {
          ForEach(this.addressList, (item: AddressModel) => {
            ListItem() {
              Row() {
                Column() {
                  Row() {
                    if (item.isDefault) {
                      Text('默认')
                        .fontSize(10)
                        .fontColor(Color.White)
                        .backgroundColor($r('app.color.primary'))
                        .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                        .borderRadius(4)
                        .margin({ right: 8 })
                    }
                    Text(item.province + ' ' + item.city + ' ' + item.area)
                      .fontSize(12)
                      .fontColor($r('app.color.text_secondary'))
                  }
                  .margin({ bottom: 4 })

                  Text(item.detail)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor($r('app.color.text_primary'))
                    .margin({ bottom: 8 })

                  Row() {
                    Text(item.name)
                      .fontSize(14)
                      .fontColor($r('app.color.text_secondary'))
                      .margin({ right: 12 })
                    Text(item.phone)
                      .fontSize(14)
                      .fontColor($r('app.color.text_secondary'))
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                Button('编辑')
                  .type(ButtonType.Normal)
                  .backgroundColor(Color.Transparent)
                  .fontColor($r('app.color.text_secondary'))
                  .fontSize(14)
                  .onClick(() => {
                    this.navigateToEdit(item.id)
                  })
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(8)
            }
          }, (item: AddressModel) => item.id)
        }
        .width('100%')
        .layoutWeight(1)
        .padding(16)
      }

      Button('新建收货地址')
        .width('90%')
        .height(44)
        .backgroundColor($r('app.color.primary'))
        .fontColor(Color.White)
        .margin({ bottom: 20 })
        .onClick(() => {
          this.navigateToEdit()
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}