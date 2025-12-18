@Component
export struct SearchBarSimpleV2 {
  @State searchText: string = ''
  onSearch: (query: string) => void = () => {}

  build() {
    Row() {
      TextInput({
        placeholder: '搜索商品',
        text: this.searchText
      })
        .width('100%')
        .height(36)
        .fontSize(14)
        .backgroundColor(Color.White)
        .borderRadius(18)
        .padding({ left: 16, right: 16 })
        .onChange((value: string) => {
          this.searchText = value
        })
        .onSubmit(() => {
          this.onSearch(this.searchText)
        })

      Button('搜索')
        .height(36)
        .fontSize(14)
        .backgroundColor(Color.Transparent)
        .fontColor('#333333')
        .margin({ left: 12 })
        .onClick(() => {
          this.onSearch(this.searchText)
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
    .justifyContent(FlexAlign.SpaceBetween)
  }
}