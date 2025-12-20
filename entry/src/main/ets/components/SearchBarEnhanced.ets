import { StorageManager } from '../utils/StorageManager'

@Component
export struct SearchBarEnhanced {
  @Link searchText: string
  @State showHistory: boolean = false
  @State searchHistory: string[] = []
  @State hotSearches: string[] = ['华为Mate 60', 'iPhone 15', 'MacBook Pro', 'AirPods Pro', '小米14']
  @State isFocused: boolean = false
  private storageManager: StorageManager = StorageManager.getInstance()

  onSearch: (query: string) => void = () => {}
  onTextChange?: (value: string) => void

  aboutToAppear() {
    this.loadSearchHistory()
  }

  private async loadSearchHistory() {
    try {
      this.searchHistory = await this.storageManager.getSearchHistory() || []
    } catch (error) {
      console.error('加载搜索历史失败:', error)
    }
  }

  private async saveSearchHistory(query: string) {
    if (!query.trim()) return

    try {
      // 去重并添加到开头
      const newHistory = [query, ...this.searchHistory.filter(item => item !== query)].slice(0, 10)
      this.searchHistory = newHistory
      await this.storageManager.saveSearchHistory(newHistory)
    } catch (error) {
      console.error('保存搜索历史失败:', error)
    }
  }

  private handleSearch(query: string) {
    if (query.trim()) {
      this.saveSearchHistory(query)
    }
    this.showHistory = false
    this.onSearch(query)
  }

  private clearHistory() {
    this.searchHistory = []
    this.storageManager.saveSearchHistory([])
  }

  private selectHistoryItem(item: string) {
    this.searchText = item
    this.handleSearch(item)
  }

  build() {
    Column() {
      // 搜索栏主体
      Row() {
        // 搜索图标
        Text('🔍')
          .fontSize(18)
          .fontColor($r('app.color.text_tertiary'))
          .margin({ left: 12 })

        // 输入框
        TextInput({
          placeholder: '搜索商品、品牌、型号',
          text: this.searchText
        })
          .width('100%')
          .height(44)
          .fontSize(15)
          .fontColor($r('app.color.text_primary'))
          .backgroundColor(Color.Transparent)
          .placeholderColor($r('app.color.text_tertiary'))
          .layoutWeight(1)
          .onChange((value: string) => {
            this.searchText = value
            this.onTextChange?.(value)
          })
          .onFocus(() => {
            this.isFocused = true
            this.showHistory = true
          })
          .onBlur(() => {
            // 延迟隐藏，以便点击历史项
            setTimeout(() => {
              this.showHistory = false
              this.isFocused = false
            }, 200)
          })
          .onSubmit(() => {
            this.handleSearch(this.searchText)
          })

        // 清除按钮
        if (this.searchText) {
          Button() {
            Text('✕')
              .fontSize(16)
              .fontColor($r('app.color.text_tertiary'))
          }
          .width(32)
          .height(32)
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.searchText = ''
            this.onTextChange?.('')
            this.handleSearch('')
          })
        }

        // 搜索按钮
        Button('搜索')
          .height(36)
          .fontSize(14)
          .fontColor($r('app.color.primary'))
          .fontWeight(FontWeight.Medium)
          .backgroundColor(Color.Transparent)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            this.handleSearch(this.searchText)
          })
      }
      .width('100%')
      .height(52)
      .backgroundColor($r('app.color.white'))
      .borderRadius(26)
      .shadow({
        radius: 8,
        color: $r('app.color.shadow_light'),
        offsetX: 0,
        offsetY: 2
      })
      .padding({ right: 4 })

      // 搜索历史和热门搜索
      if (this.showHistory) {
        Column() {
          // 搜索历史
          if (this.searchHistory.length > 0) {
            Column() {
              Row() {
                Text('搜索历史')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.text_primary'))
                  .layoutWeight(1)

                Button('清空')
                  .fontSize(13)
                  .fontColor($r('app.color.text_tertiary'))
                  .backgroundColor(Color.Transparent)
                  .height(32)
                  .onClick(() => this.clearHistory())
              }
              .width('100%')
              .padding({ bottom: 12 })

              Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
                ForEach(this.searchHistory, (item: string, index: number) => {
                  Button(item)
                    .height(32)
                    .fontSize(13)
                    .fontColor($r('app.color.text_secondary'))
                    .backgroundColor($r('app.color.background_gray'))
                    .borderRadius(16)
                    .padding({ left: 16, right: 16 })
                    .margin({ right: 8, bottom: 8 })
                    .onClick(() => this.selectHistoryItem(item))
                })
              }
              .width('100%')
            }
            .width('100%')
            .padding(16)
            .backgroundColor($r('app.color.white'))
            .borderRadius({ topLeft: 0, topRight: 0, bottomLeft: 12, bottomRight: 12 })
            .margin({ top: 8 })
          }

          // 热门搜索
          Column() {
            Row() {
              Text('🔥')
                .fontSize(16)
                .margin({ right: 6 })

              Text('热门搜索')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary'))
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)
            .padding({ bottom: 12 })

            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
              ForEach(this.hotSearches, (item: string, index: number) => {
                Button(item)
                  .height(32)
                  .fontSize(13)
                  .fontColor(index < 3 ? $r('app.color.error') : $r('app.color.text_secondary'))
                  .backgroundColor(index < 3 ? $r('app.color.secondary_light') : $r('app.color.background_gray'))
                  .borderRadius(16)
                  .padding({ left: 16, right: 16 })
                  .margin({ right: 8, bottom: 8 })
                  .onClick(() => this.selectHistoryItem(item))
              })
            }
            .width('100%')
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.white'))
          .borderRadius(12)
          .margin({ top: 8 })
        }
        .width('100%')
        .backgroundColor($r('app.color.background'))
        .margin({ top: 12 })
        .shadow({
          radius: 12,
          color: $r('app.color.shadow_medium'),
          offsetX: 0,
          offsetY: 4
        })
        .zIndex(1000)
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .backgroundColor($r('app.color.background'))
  }
}