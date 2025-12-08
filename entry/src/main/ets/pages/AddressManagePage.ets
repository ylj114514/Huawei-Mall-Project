import router from '@ohos.router'
import { Address } from '../model/DataModel'
import { StorageManager } from '../utils/StorageManager'

@Entry
@Component
struct AddressManagePage {
  @State addresses: Address[] = []
  @State isLoading: boolean = true
  @State showAddDialog: boolean = false
  @State editingAddress: Address | null = null
  @State selectedAddressId: string = ''
  private storage: StorageManager = StorageManager.getInstance()

  aboutToAppear() {
    this.loadAddresses()
  }

  aboutToDisappear() {
    // 页面销毁时的清理工作
  }

  onPageShow() {
    // 页面显示时重新加载地址（从编辑页面返回时会触发）
    this.loadAddresses()
  }

  private async loadAddresses(): Promise<void> {
    try {
      this.addresses = await this.storage.loadAddresses()
      this.isLoading = false
    } catch (error) {
      console.error('加载地址失败:', error)
      this.isLoading = false
    }
  }

  private onAddAddress(): void {
    router.pushUrl({ url: 'pages/AddressEditPage' })
  }

  private onEditAddress(address: Address): void {
    router.pushUrl({ url: 'pages/AddressEditPage', params: { address: address } })
  }

  private async onSetDefault(addressId: string): Promise<void> {
    try {
      this.addresses.forEach(address => {
        address.isDefault = address.id === addressId
      })
      await this.storage.saveAddresses(this.addresses)
      console.log('默认地址设置成功')
    } catch (error) {
      console.error('设置默认地址失败:', error)
    }
  }

  private async onDeleteAddress(addressId: string): Promise<void> {
    try {
      const index = this.addresses.findIndex(addr => addr.id === addressId)
      if (index > -1) {
        this.addresses.splice(index, 1)
        await this.storage.saveAddresses(this.addresses)
        console.log('地址删除成功')
      }
    } catch (error) {
      console.error('删除地址失败:', error)
    }
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

        Text('收货地址')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Button()
          .width(40)
          .height(40)
          .backgroundColor(Color.Transparent)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .backgroundColor($r('app.color.white'))

      if (this.isLoading) {
        // 加载状态
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
          Text('加载中...')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.background'))
      } else {
        Scroll() {
          Column() {
            // 地址列表
            ForEach(this.addresses, (address: Address) => {
              Column() {
                Row() {
                  // 默认地址标签
                  if (address.isDefault) {
                    Text('默认')
                      .fontSize(10)
                      .fontColor(Color.White)
                      .backgroundColor($r('app.color.primary'))
                      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                      .borderRadius(2)
                      .margin({ right: 8 })
                  }

                  Column() {
                    Row() {
                      Text(address.name)
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor($r('app.color.text_primary'))
                      Text(address.phone)
                        .fontSize(14)
                        .fontColor($r('app.color.text_secondary'))
                        .margin({ left: 12 })
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.Start)

                    Text(`${address.province} ${address.city} ${address.district} ${address.detail}`)
                      .fontSize(14)
                      .fontColor($r('app.color.text_primary'))
                      .width('100%')
                      .margin({ top: 8 })
                      .lineHeight(20)
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)

                  // 编辑按钮
                  Button('编辑')
                    .height(32)
                    .fontSize(12)
                    .backgroundColor($r('app.color.background'))
                    .fontColor($r('app.color.text_primary'))
                    .margin({ left: 8 })
                    .onClick(() => this.onEditAddress(address))
                }
                .width('100%')

                Divider()
                  .width('100%')
                  .margin({ top: 12 })

                Row() {
                  Button() {
                    Row() {
                      Circle({ width: 16, height: 16 })
                        .fill(address.isDefault ? $r('app.color.primary') : Color.Transparent)
                        .stroke(address.isDefault ? Color.Transparent : $r('app.color.text_secondary'))
                        .strokeWidth(2)
                        .margin({ right: 8 })
                      Text('设为默认地址')
                        .fontSize(14)
                        .fontColor($r('app.color.text_primary'))
                    }
                  }
                  .backgroundColor(Color.Transparent)
                  .onClick(() => this.onSetDefault(address.id))

                  Blank()

                  Button('删除')
                    .height(32)
                    .fontSize(12)
                    .backgroundColor($r('app.color.error'))
                    .fontColor(Color.White)
                    .onClick(() => this.onDeleteAddress(address.id))
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                .margin({ top: 8 })
              }
              .width('100%')
              .padding(16)
              .backgroundColor($r('app.color.white'))
              .borderRadius(8)
              .margin({ left: 16, right: 16, bottom: 12 })
              .border({
                width: this.selectedAddressId === address.id ? 2 : 1,
                color: this.selectedAddressId === address.id ? $r('app.color.primary') : '#E0E0E0'
              })
              .onClick(() => {
                this.selectedAddressId = address.id
                // 如果是从其他页面进入选择地址的，可以在这里处理选择逻辑
                console.log('选择地址:', address.id)
              })
            })

            // 添加地址按钮
            Button() {
              Row() {
                Text('+')
                  .fontSize(16)
                  .fontColor($r('app.color.primary'))
                  .margin({ right: 8 })
                Text('添加新地址')
                  .fontSize(16)
                  .fontColor($r('app.color.primary'))
              }
            }
            .width('100%')
            .height(50)
            .backgroundColor(Color.Transparent)
            .border({ width: 1, color: $r('app.color.primary') })
            .borderRadius(8)
            .margin({ left: 16, right: 16, bottom: 24 })
            .onClick(() => this.onAddAddress())
          }
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor($r('app.color.background'))
      }

      // 确认选择按钮（仅在选择了地址时显示）
      if (this.selectedAddressId) {
        Button('确认选择')
          .width('100%')
          .height(50)
          .fontSize(16)
          .backgroundColor($r('app.color.primary'))
          .fontColor(Color.White)
          .margin({ left: 16, right: 16, bottom: 24 })
          .onClick(() => {
            const selectedAddress: Address | undefined = this.addresses.find((addr: Address) => addr.id === this.selectedAddressId)
            if (selectedAddress) {
              console.log('确认选择地址:', selectedAddress.getFullAddress())
              // 可以在这里返回选中的地址给上一个页面
              router.back()
            }
          })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}