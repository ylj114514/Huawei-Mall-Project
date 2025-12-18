import router from '@ohos.router'
import { StorageManager } from '../utils/StorageManagerSimple'
import { User } from '../model/DataModel'
import { ImageUploadHandler } from '../utils/ImageUploadHandler'
import { ImageUploadComponent } from '../components/ImageUploadComponent'
import { ImageUploadItem } from '../components/ImageUploadComponent'
import common from '@ohos.app.ability.common'

interface ColorScheme {
  background: string
  surface: string
  primary: string
  secondary: string
  text: string
  textSecondary: string
  accent: string
  success: string
}

const COLORS: ColorScheme = {
  background: '#F5F7FA',
  surface: '#FFFFFF',
  primary: '#007AFF',
  secondary: '#6C757D',
  text: '#2C3E50',
  textSecondary: '#7F8C8D',
  accent: '#FF6B6B',
  success: '#27AE60'
}

@Entry
@Component
struct EditProfilePage {
  @State user: User | null = null
  @State isLoading: boolean = false
  @State avatarImages: ImageUploadItem[] = []
  @State nickname: string = ''
  @State email: string = ''
  @State phone: string = ''
  @State realName: string = ''
  @State birthday: string = ''
  @State gender: 'male' | 'female' | 'unknown' = 'unknown'
  @State errorMessage: string = ''

  private storage: StorageManager = StorageManager.getInstance()
  private imageHandler: ImageUploadHandler = ImageUploadHandler.getInstance()
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  aboutToAppear() {
    this.loadUserData()
  }

  private async loadUserData() {
    try {
      this.user = await this.storage.loadUser()
      if (this.user) {
        this.nickname = this.user.username
        this.email = this.user.email || ''
        this.phone = this.user.phone || ''
        this.realName = this.user.realName || ''
        this.birthday = this.user.birthday || ''
        this.gender = this.user.gender || 'unknown'

        // 设置头像
        if (this.user.avatar && this.user.avatar !== 'https://via.placeholder.com/100x100') {
          this.avatarImages = [new ImageUploadItem('current-avatar', this.user.avatar)]
        }
      }
    } catch (error) {
      console.error('加载用户数据失败:', error)
    }
  }

  private validateForm(): boolean {
    this.errorMessage = ''

    if (!this.nickname.trim()) {
      this.errorMessage = '昵称不能为空'
      return false
    }

    if (this.nickname.length < 2 || this.nickname.length > 20) {
      this.errorMessage = '昵称长度应为2-20个字符'
      return false
    }

    if (this.email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(this.email)) {
      this.errorMessage = '请输入有效的邮箱地址'
      return false
    }

    if (this.phone && !/^1[3-9]\d{9}$/.test(this.phone)) {
      this.errorMessage = '请输入有效的手机号码'
      return false
    }

    return true
  }

  private async saveProfile() {
    if (!this.validateForm() || !this.user) return

    this.isLoading = true

    try {
      // 更新用户信息
      this.user.username = this.nickname.trim()
      this.user.email = this.email
      this.user.phone = this.phone
      this.user.realName = this.realName
      this.user.birthday = this.birthday
      this.user.gender = this.gender

      // 更新头像
      if (this.avatarImages.length > 0) {
        // 使用第一张图片作为头像
        this.user.avatar = this.avatarImages[0].uri
      }

      await this.storage.saveUser(this.user)

      router.back()
    } catch (error) {
      console.error('保存用户信息失败:', error)
      this.errorMessage = '保存失败，请稍后重试'
    } finally {
      this.isLoading = false
    }
  }

  private onImagesChange(images: ImageUploadItem[]) {
    this.avatarImages = images
  }

  @Builder
  Header() {
    Row() {
      Button() {
        Text('取消')
          .fontSize(16)
          .fontColor(COLORS.text)
      }
      .width(60)
      .height(48)
      .backgroundColor(Color.Transparent)
      .onClick(() => router.back())

      Text('编辑资料')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(COLORS.text)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Button('保存')
        .fontSize(16)
        .fontColor(COLORS.primary)
        .backgroundColor(Color.Transparent)
        .enabled(!this.isLoading && this.validateForm())
        .onClick(() => this.saveProfile())
    }
    .width('100%')
    .height(56)
    .padding({ left: 20, right: 20 })
    .backgroundColor(COLORS.surface)
  }

  @Builder
  AvatarSection() {
    Column() {
      Text('头像')
        .fontSize(16)
        .fontColor(COLORS.text)
        .width('100%')
        .margin({ bottom: 16 })

      // 头像上传组件
      Row() {
        ImageUploadComponent({
          images: this.avatarImages,
          maxCount: 1,
          onImagesChange: (images: ImageUploadItem[]) => {
            this.onImagesChange(images)
          }
        })
        .width(120)
        .height(120)

        Column() {
          Text('点击上传头像')
            .fontSize(12)
            .fontColor(COLORS.textSecondary)
            .margin({ top: 8 })
          Text('支持JPG、PNG格式')
            .fontSize(12)
            .fontColor(COLORS.textSecondary)
        }
        .width('100%')
        .height(120)
        .justifyContent(FlexAlign.Center)
        .layoutWeight(1)
        .margin({ left: 20 })
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(COLORS.surface)
    .margin({ top: 12 })
  }

  @Builder
  BasicInfoSection() {
    Column() {
      Text('基本信息')
        .fontSize(16)
        .fontColor(COLORS.text)
        .width('100%')
        .margin({ bottom: 16 })

      // 昵称
      Column() {
        Text('昵称')
          .fontSize(14)
          .fontColor(COLORS.text)
          .width('100%')
          .margin({ bottom: 8 })

        TextInput({ placeholder: '请输入昵称', text: this.nickname })
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontColor(COLORS.text)
          .backgroundColor(COLORS.background)
          .borderRadius(8)
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.nickname = value
            this.errorMessage = ''
          })
      }
      .width('100%')
      .margin({ bottom: 20 })

      // 邮箱
      Column() {
        Text('邮箱')
          .fontSize(14)
          .fontColor(COLORS.text)
          .width('100%')
          .margin({ bottom: 8 })

        TextInput({ placeholder: '请输入邮箱', text: this.email })
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontColor(COLORS.text)
          .backgroundColor(COLORS.background)
          .borderRadius(8)
          .padding({ left: 16, right: 16 })
          .type(InputType.Email)
          .onChange((value: string) => {
            this.email = value
            this.errorMessage = ''
          })
      }
      .width('100%')
      .margin({ bottom: 20 })

      // 手机号
      Column() {
        Text('手机号')
          .fontSize(14)
          .fontColor(COLORS.text)
          .width('100%')
          .margin({ bottom: 8 })

        TextInput({ placeholder: '请输入手机号', text: this.phone })
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontColor(COLORS.text)
          .backgroundColor(COLORS.background)
          .borderRadius(8)
          .padding({ left: 16, right: 16 })
          .type(InputType.Number)
          .maxLength(11)
          .onChange((value: string) => {
            this.phone = value
            this.errorMessage = ''
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(COLORS.surface)
    .margin({ top: 12 })
  }

  @Builder
  PersonalInfoSection() {
    Column() {
      Text('个人信息')
        .fontSize(16)
        .fontColor(COLORS.text)
        .width('100%')
        .margin({ bottom: 16 })

      // 真实姓名
      Column() {
        Text('真实姓名')
          .fontSize(14)
          .fontColor(COLORS.text)
          .width('100%')
          .margin({ bottom: 8 })

        TextInput({ placeholder: '请输入真实姓名', text: this.realName })
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontColor(COLORS.text)
          .backgroundColor(COLORS.background)
          .borderRadius(8)
          .padding({ left: 16, right: 16 })
          .onChange((value: string) => {
            this.realName = value
          })
      }
      .width('100%')
      .margin({ bottom: 20 })

      // 性别
      Column() {
        Text('性别')
          .fontSize(14)
          .fontColor(COLORS.text)
          .width('100%')
          .margin({ bottom: 8 })

        Row() {
          Row() {
            Radio({ value: 'male', group: 'gender' })
              .checked(this.gender === 'male')
              .onChange(() => {
                this.gender = 'male'
              })
            Text('男')
              .fontSize(16)
              .fontColor(COLORS.text)
          }
          .width('33%')

          Row() {
            Radio({ value: 'female', group: 'gender' })
              .checked(this.gender === 'female')
              .onChange(() => {
                this.gender = 'female'
              })
            Text('女')
              .fontSize(16)
              .fontColor(COLORS.text)
          }
          .width('33%')

          Row() {
            Radio({ value: 'unknown', group: 'gender' })
              .checked(this.gender === 'unknown')
              .onChange(() => {
                this.gender = 'unknown'
              })
            Text('保密')
              .fontSize(16)
              .fontColor(COLORS.text)
          }
          .width('33%')
        }
        .width('100%')
      }
      .width('100%')
      .margin({ bottom: 20 })

      // 生日
      Column() {
        Text('生日')
          .fontSize(14)
          .fontColor(COLORS.text)
          .width('100%')
          .margin({ bottom: 8 })

        TextInput({ placeholder: '请输入生日', text: this.birthday })
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontColor(COLORS.text)
          .backgroundColor(COLORS.background)
          .borderRadius(8)
          .padding({ left: 16, right: 16 })
          .type(InputType.Normal)
          .onChange((value: string) => {
            this.birthday = value
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(COLORS.surface)
    .margin({ top: 12 })
  }

  build() {
    Column() {
      // 顶部导航
      this.Header()

      // 主内容
      Scroll() {
        Column() {
          // 头像部分
          this.AvatarSection()

          // 基本信息
          this.BasicInfoSection()

          // 个人信息
          this.PersonalInfoSection()

          // 错误提示
          if (this.errorMessage) {
            Text(this.errorMessage)
              .fontSize(14)
              .fontColor(COLORS.accent)
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding(12)
              .backgroundColor('#FFE5E5')
              .borderRadius(8)
              .margin({ top: 20, left: 20, right: 20 })
          }
        }
        .width('100%')
        .padding({ bottom: 80 })
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(COLORS.background)

      // 加载遮罩
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
          Text('保存中...')
            .fontSize(14)
            .fontColor(COLORS.textSecondary)
            .margin({ top: 16 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('rgba(0,0,0,0.5)')
        .position({ x: 0, y: 0 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLORS.background)
  }
}