import router from '@ohos.router'
import { FavoriteItem } from '../model/DataModel'
import { FavoriteService } from '../services/FavoriteService'
import { ProductModel } from '../model/ProductModel'

@Entry
@Component
struct FavoritePage {
  @State favorites: FavoriteItem[] = []
  @State isLoading: boolean = true
  @State searchText: string = ''
  @State selectedCategory: string = '全部'
  @State categories: string[] = ['全部']
  private favoriteService: FavoriteService = FavoriteService.getInstance()

  aboutToAppear() {
    this.loadFavorites()
  }

  // 页面显示时刷新
  onPageShow() {
    this.loadFavorites()
  }

  private loadFavorites(): void {
    try {
      // ✅ 修复1：将 'as any' 替换为 'as ESObject'
      // ESObject 是 ArkTS 中用于兼容动态类型的官方类型
      this.favorites = this.favoriteService.getFavorites() as ESObject

      const categorySet = new Set<string>()
      this.favorites.forEach(item => {
        categorySet.add(item.product.category)
      })
      this.categories = ['全部', ...Array.from(categorySet)]

      this.isLoading = false
    } catch (error) {
      console.error('加载收藏失败:', error)
      this.isLoading = false
    }
  }

  private onSearch(query: string): void {
    this.searchText = query
    this.filterFavorites()
  }

  private onCategoryChange(category: string): void {
    this.selectedCategory = category
    this.filterFavorites()
  }

  private filterFavorites(): void {
    // ✅ 修复2：将 'any[]' 替换为 'ESObject[]'
    let filtered: ESObject[] = this.favoriteService.getFavorites()

    if (this.selectedCategory !== '全部') {
      filtered = this.favoriteService.getFavoritesByCategory(this.selectedCategory)
    }

    if (this.searchText.trim() !== '') {
      filtered = this.favoriteService.searchFavorites(this.searchText.trim())
    }

    // ✅ 修复3：将 'as any' 替换为 'as ESObject'
    this.favorites = filtered as ESObject
  }

  private toggleFavorite(favorite: FavoriteItem): void {
    this.favoriteService.toggleFavorite(favorite.product)
    this.loadFavorites() // 重新加载刷新状态
  }

  private goToProductDetail(product: ProductModel): void {
    try {
      router.pushUrl({
        url: 'pages/ProductDetailPage',
        params: { product: product }
      })
    } catch (err) {
      console.error('路由跳转失败:', err)
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
            try {
              router.back()
            } catch (err) {
              console.error('返回失败:', err)
            }
          })

        Text('我的收藏')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text(`(${this.favorites.length})`)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .backgroundColor($r('app.color.white'))

      // 搜索栏
      Column() {
        Search({ value: this.searchText, placeholder: '搜索收藏...' })
          .searchButton('搜索')
          .width('100%')
          .height(40)
          .backgroundColor('#F5F5F5')
          .placeholderColor($r('app.color.text_secondary'))
          .onSubmit((value) => this.onSearch(value))
          .onChange((value) => {
            this.searchText = value
            this.filterFavorites()
          })
      }
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })

      // 分类筛选
      Scroll() {
        Row() {
          ForEach(this.categories, (category: string) => {
            Text(category)
              .fontSize(14)
              .fontColor(this.selectedCategory === category ?
                $r('app.color.white') : $r('app.color.text_primary'))
              .backgroundColor(this.selectedCategory === category ?
                $r('app.color.primary') : Color.Transparent)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .borderRadius(20)
              .margin({ right: 8 })
              .onClick(() => {
                this.onCategoryChange(category)
              })
          })
        }
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .backgroundColor($r('app.color.white'))
      .width('100%')

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
          Text('加载收藏中...')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.background'))
      } else if (this.favorites.length === 0) {
        Column() {
          Text('❤️')
            .fontSize(80)
            .margin({ bottom: 24 })
          Text('还没有收藏商品')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_secondary'))
            .margin({ bottom: 12 })
          Text('去发现喜欢的商品吧')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .margin({ bottom: 32 })

          Button('去逛逛')
            .height(44)
            .padding({ left: 32, right: 32 })
            .backgroundColor($r('app.color.primary'))
            .fontColor(Color.White)
            .borderRadius(22)
            .onClick(() => {
              try {
                router.replaceUrl({ url: 'pages/Index' })
              } catch (e) {}
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.background'))
      } else {
        Scroll() {
          Column() {
            ForEach(this.favorites, (favorite: FavoriteItem) => {
              Column() {
                Row() {
                  Image(favorite.product.image)
                    .width(100)
                    .height(100)
                    .borderRadius(8)
                    .objectFit(ImageFit.Cover)
                    .backgroundColor($r('app.color.background'))
                    .margin({ right: 12 })

                  Column() {
                    Text(favorite.product.name)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('app.color.text_primary'))
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .width('100%')
                      .margin({ bottom: 4 })

                    Text(favorite.product.category)
                      .fontSize(12)
                      .fontColor($r('app.color.text_secondary'))
                      .margin({ bottom: 8 })

                    Row() {
                      Text(`¥${favorite.product.price}`)
                        .fontSize(18)
                        .fontWeight(FontWeight.Bold)
                        .fontColor($r('app.color.price'))

                      if (favorite.product.originalPrice > favorite.product.price) {
                        Text(`¥${favorite.product.originalPrice}`)
                          .fontSize(14)
                          .fontColor($r('app.color.text_secondary'))
                          .decoration({ type: TextDecorationType.LineThrough })
                          .margin({ left: 8 })
                      }
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.Start)

                    Text(`收藏于 ${new Date(favorite.addedTime).toLocaleDateString()}`)
                      .fontSize(12)
                      .fontColor($r('app.color.text_secondary'))
                      .margin({ top: 4 })
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)

                  Column() {
                    Button({ type: ButtonType.Circle, stateEffect: true }) {
                      Text('❤️').fontSize(18).fontColor($r('app.color.error'))
                    }
                    .width(40)
                    .height(40)
                    .backgroundColor('#FFF0F0')
                    .onClick(() => this.toggleFavorite(favorite))

                    Text('取消')
                      .fontSize(10)
                      .fontColor($r('app.color.text_secondary'))
                      .margin({ top: 4 })
                  }
                  .alignItems(HorizontalAlign.Center)
                }
                .width('100%')
                .padding(16)

                Divider().width('100%')
              }
              .width('100%')
              .backgroundColor($r('app.color.white'))
              .borderRadius(8)
              .margin({ left: 16, right: 16, bottom: 8 })
              .onClick(() => this.goToProductDetail(favorite.product))
            })
          }
          .width('100%')
          .padding({ top: 8, bottom: 80 })
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor($r('app.color.background'))
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
  }
}