import { MockData } from '../model/ProductModel'

@Component
export struct SearchBar {
  @State searchText: string = ''
  @State showSuggestions: boolean = false
  @State searchHistory: string[] = []
  @State suggestions: string[] = []
  onSearch: (query: string) => void = () => {}

  aboutToAppear() {
    // 初始化搜索建议
    this.suggestions = MockData.generateSearchSuggestions()
    // 从本地存储加载搜索历史
    this.loadSearchHistory()
  }

  private loadSearchHistory() {
    try {
      const history = AppStorage.get<string[]>('searchHistory')
      if (history) {
        this.searchHistory = history
      }
    } catch (error) {
      console.error('加载搜索历史失败:', error)
    }
  }

  private saveSearchHistory(query: string) {
    if (!query || query.trim() === '') return

    // 避免重复
    const index = this.searchHistory.indexOf(query)
    if (index > -1) {
      this.searchHistory.splice(index, 1)
    }

    // 添加到开头
    this.searchHistory.unshift(query)

    // 最多保存10条
    if (this.searchHistory.length > 10) {
      this.searchHistory = this.searchHistory.slice(0, 10)
    }

    // 保存到本地存储
    try {
      AppStorage.set('searchHistory', this.searchHistory)
    } catch (error) {
      console.error('保存搜索历史失败:', error)
    }
  }

  build() {
    Column() {
      // 搜索框
      Row() {
        Search({
          placeholder: '搜索商品、品牌、分类',
          value: this.searchText
        })
          .width('100%')
          .height(40)
          .backgroundColor($r('app.color.background'))
          .borderRadius(20)
          .onChange((value: string) => {
            this.searchText = value
            this.showSuggestions = value.length > 0
          })
          .onSubmit(() => {
            this.performSearch()
          })

        if (this.searchText.length > 0) {
          Button('清除')
            .height(40)
            .fontSize(12)
            .backgroundColor(Color.Transparent)
            .fontColor($r('app.color.text_secondary'))
            .onClick(() => {
              this.searchText = ''
              this.showSuggestions = false
            })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .margin({ bottom: 8 })

      // 搜索建议和历史记录
      if (this.showSuggestions && this.searchText.length > 0) {
        Column() {
          // 搜索建议
          if (this.suggestions.some(suggestion =>
            suggestion.toLowerCase().includes(this.searchText.toLowerCase()))) {
            Text('搜索建议')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
              .width('100%')
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })

            ForEach(this.suggestions.filter(suggestion =>
              suggestion.toLowerCase().includes(this.searchText.toLowerCase())
            ), (suggestion: string) => {
              Row() {
                Text('🔍')
                  .fontSize(14)
                  .margin({ right: 8 })
                Text(suggestion)
                  .fontSize(14)
                  .fontColor($r('app.color.text_primary'))
                  .layoutWeight(1)
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .backgroundColor(Color.Transparent)
              .onClick(() => {
                this.searchText = suggestion
                this.performSearch()
              })
            })
          }

          // 搜索历史
          if (this.searchHistory.length > 0) {
            Row() {
              Text('搜索历史')
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
                .layoutWeight(1)

              Button('清空')
                .height(24)
                .fontSize(10)
                .backgroundColor(Color.Transparent)
                .fontColor($r('app.color.text_secondary'))
                .onClick(() => {
                  this.searchHistory = []
                  AppStorage.set('searchHistory', [])
                })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })

            ForEach(this.searchHistory, (historyItem: string) => {
              Row() {
                Text('🕐')
                  .fontSize(14)
                  .margin({ right: 8 })
                Text(historyItem)
                  .fontSize(14)
                  .fontColor($r('app.color.text_primary'))
                  .layoutWeight(1)
                Button('×')
                  .height(20)
                  .width(20)
                  .fontSize(12)
                  .backgroundColor(Color.Transparent)
                  .fontColor($r('app.color.text_secondary'))
                  .onClick(() => {
                    const index = this.searchHistory.indexOf(historyItem)
                    if (index > -1) {
                      this.searchHistory.splice(index, 1)
                      AppStorage.set('searchHistory', this.searchHistory)
                    }
                  })
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 12, bottom: 12 })
              .onClick(() => {
                this.searchText = historyItem
                this.performSearch()
              })
            })
          }

          // 热门搜索
          Text('热门搜索')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .width('100%')
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })

          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(this.suggestions.slice(0, 6), (hotSearch: string) => {
              Text(hotSearch)
                .fontSize(12)
                .fontColor($r('app.color.text_primary'))
                .backgroundColor($r('app.color.background'))
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .borderRadius(16)
                .margin({ right: 8 })
                .margin({ bottom: 8 })
                .onClick(() => {
                  this.searchText = hotSearch
                  this.performSearch()
                })
            })
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 8 })
        }
        .width('100%')
        .backgroundColor($r('app.color.white'))
        .borderRadius(8)
        .shadow({
          radius: 4,
          color: '#0A000000',
          offsetX: 0,
          offsetY: 2
        })
      }
    }
    .width('100%')
    .onBlur(() => {
      // 延迟隐藏建议列表，避免点击事件被拦截
      setTimeout(() => {
        this.showSuggestions = false
      }, 200)
    })
  }

  private performSearch() {
    if (this.searchText.trim() === '') return

    this.saveSearchHistory(this.searchText)
    this.showSuggestions = false
    this.onSearch(this.searchText)
  }
}