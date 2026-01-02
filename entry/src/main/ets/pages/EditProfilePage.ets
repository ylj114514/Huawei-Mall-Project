import router from '@ohos.router'
import promptAction from '@ohos.promptAction'
import { User } from '../model/DataModel'
// ✅ 核心修复：引入 DatabaseManager 中定义的类型
import { DatabaseManager, UserProfilePatch } from '../database/DatabaseManager'
import { AuthService } from '../services/AuthService'
import { ImageUploadComponent, ImageUploadItem } from '../components/ImageUploadComponent'
import common from '@ohos.app.ability.common'

// 配色方案 (保持不变)
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

  private db: DatabaseManager = DatabaseManager.getInstance()
  private authService: AuthService = AuthService.getInstance()
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  aboutToAppear() {
    this.loadUserData()
  }

  private async loadUserData() {
    try {
      this.user = await this.authService.getCurrentUser()

      if (this.user) {
        this.nickname = this.user.username || ''
        this.email = this.user.email || ''
        this.phone = this.user.phone || ''
        this.realName = this.user.realName || ''
        this.birthday = this.user.birthday || ''
        this.gender = (this.user.gender as 'male' | 'female' | 'unknown') || 'unknown'

        if (this.user.avatar) {
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

  // ✅ 逻辑修正：加入同步内存用户信息逻辑
  private async saveProfile() {
    const currentUser = this.user
    if (!this.validateForm() || !currentUser) return

    this.isLoading = true

    try {
      // 1. 确定新头像
      let newAvatar = currentUser.avatar
      if (this.avatarImages.length > 0) {
        const uri = this.avatarImages[0].uri
        if (typeof uri === 'string') {
          newAvatar = uri
        }
      }

      // 2. 构建更新对象 (使用导入的接口，防止红字)
      const patch: UserProfilePatch = {
        username: this.nickname.trim(),
        email: this.email,
        phone: this.phone,
        realName: this.realName,
        birthday: this.birthday,
        gender: this.gender,
        avatar: newAvatar ? newAvatar.toString() : ''
      }

      // 3. 调用数据库更新
      const success = await this.db.updateUserProfile(currentUser.account, patch)

      if (success) {
        // ✅ 核心修正：保存成功后重新获取用户，同步 AuthService 的内存状态
        await this.authService.getCurrentUser()

        promptAction.showToast({ message: '保存成功' })
        setTimeout(() => {
          router.back()
        }, 500)
      } else {
        this.errorMessage = '保存失败，请重试'
      }
    } catch (error) {
      console.error('保存用户信息失败:', JSON.stringify(error))
      this.errorMessage = '保存异常，请稍后重试'
    } finally {
      this.isLoading = false
    }
  }

  private onImagesChange(images: ImageUploadItem[]) {
    this.avatarImages = images
  }

  // --- UI 代码保持完全不变 ---
  @Builder
  Header() {
    Row() {
      Button() {
        Text('取消').fontSize(16).fontColor(COLORS.text)
      }
      .width(60).height(48).backgroundColor(Color.Transparent).onClick(() => router.back())

      Text('编辑资料').fontSize(18).fontWeight(FontWeight.Medium).fontColor(COLORS.text).layoutWeight(1).textAlign(TextAlign.Center)

      Button('保存')
        .fontSize(16).fontColor(COLORS.primary).backgroundColor(Color.Transparent)
        .enabled(!this.isLoading && this.validateForm())
        .onClick(() => this.saveProfile())
    }
    .width('100%').height(56).padding({ left: 20, right: 20 }).backgroundColor(COLORS.surface)
  }

  @Builder
  AvatarSection() {
    Column() {
      Text('头像').fontSize(16).fontColor(COLORS.text).width('100%').margin({ bottom: 16 })
      Row() {
        ImageUploadComponent({
          images: this.avatarImages,
          maxCount: 1,
          onImagesChange: (images: ImageUploadItem[]) => { this.onImagesChange(images) }
        })
          .width(120).height(120)

        Column() {
          Text('点击上传头像').fontSize(12).fontColor(COLORS.textSecondary).margin({ top: 8 })
          Text('支持JPG、PNG格式').fontSize(12).fontColor(COLORS.textSecondary)
        }
        .width('100%').height(120).justifyContent(FlexAlign.Center).layoutWeight(1).margin({ left: 20 })
      }
      .width('100%')
    }
    .width('100%').padding(20).backgroundColor(COLORS.surface).margin({ top: 12 })
  }

  @Builder
  BasicInfoSection() {
    Column() {
      Text('基本信息').fontSize(16).fontColor(COLORS.text).width('100%').margin({ bottom: 16 })

      Column() {
        Text('昵称').fontSize(14).fontColor(COLORS.text).width('100%').margin({ bottom: 8 })
        TextInput({ placeholder: '请输入昵称', text: this.nickname })
          .width('100%').height(48).fontSize(16).fontColor(COLORS.text).backgroundColor(COLORS.background).borderRadius(8).padding({ left: 16, right: 16 })
          .onChange((value: string) => { this.nickname = value; this.errorMessage = '' })
      }.width('100%').margin({ bottom: 20 })

      Column() {
        Text('邮箱').fontSize(14).fontColor(COLORS.text).width('100%').margin({ bottom: 8 })
        TextInput({ placeholder: '请输入邮箱', text: this.email })
          .width('100%').height(48).fontSize(16).fontColor(COLORS.text).backgroundColor(COLORS.background).borderRadius(8).padding({ left: 16, right: 16 }).type(InputType.Email)
          .onChange((value: string) => { this.email = value; this.errorMessage = '' })
      }.width('100%').margin({ bottom: 20 })

      Column() {
        Text('手机号').fontSize(14).fontColor(COLORS.text).width('100%').margin({ bottom: 8 })
        TextInput({ placeholder: '请输入手机号', text: this.phone })
          .width('100%').height(48).fontSize(16).fontColor(COLORS.text).backgroundColor(COLORS.background).borderRadius(8).padding({ left: 16, right: 16 }).type(InputType.Number).maxLength(11)
          .onChange((value: string) => { this.phone = value; this.errorMessage = '' })
      }.width('100%')
    }
    .width('100%').padding(20).backgroundColor(COLORS.surface).margin({ top: 12 })
  }

  @Builder
  PersonalInfoSection() {
    Column() {
      Text('个人信息').fontSize(16).fontColor(COLORS.text).width('100%').margin({ bottom: 16 })

      Column() {
        Text('真实姓名').fontSize(14).fontColor(COLORS.text).width('100%').margin({ bottom: 8 })
        TextInput({ placeholder: '请输入真实姓名', text: this.realName })
          .width('100%').height(48).fontSize(16).fontColor(COLORS.text).backgroundColor(COLORS.background).borderRadius(8).padding({ left: 16, right: 16 })
          .onChange((value: string) => { this.realName = value })
      }.width('100%').margin({ bottom: 20 })

      Column() {
        Text('性别').fontSize(14).fontColor(COLORS.text).width('100%').margin({ bottom: 8 })
        Row() {
          Row() { Radio({ value: 'male', group: 'gender' }).checked(this.gender === 'male').onChange(() => { this.gender = 'male' }); Text('男').fontSize(16).fontColor(COLORS.text) }.width('33%')
          Row() { Radio({ value: 'female', group: 'gender' }).checked(this.gender === 'female').onChange(() => { this.gender = 'female' }); Text('女').fontSize(16).fontColor(COLORS.text) }.width('33%')
          Row() { Radio({ value: 'unknown', group: 'gender' }).checked(this.gender === 'unknown').onChange(() => { this.gender = 'unknown' }); Text('保密').fontSize(16).fontColor(COLORS.text) }.width('33%')
        }.width('100%')
      }.width('100%').margin({ bottom: 20 })

      Column() {
        Text('生日').fontSize(14).fontColor(COLORS.text).width('100%').margin({ bottom: 8 })
        TextInput({ placeholder: '请输入生日', text: this.birthday })
          .width('100%').height(48).fontSize(16).fontColor(COLORS.text).backgroundColor(COLORS.background).borderRadius(8).padding({ left: 16, right: 16 }).type(InputType.Normal)
          .onChange((value: string) => { this.birthday = value })
      }.width('100%')
    }
    .width('100%').padding(20).backgroundColor(COLORS.surface).margin({ top: 12 })
  }

  build() {
    Column() {
      this.Header()
      Scroll() {
        Column() {
          this.AvatarSection()
          this.BasicInfoSection()
          this.PersonalInfoSection()
          if (this.errorMessage) {
            Text(this.errorMessage).fontSize(14).fontColor(COLORS.accent).width('100%').textAlign(TextAlign.Center).padding(12).backgroundColor('#FFE5E5').borderRadius(8).margin({ top: 20, left: 20, right: 20 })
          }
        }.width('100%').padding({ bottom: 80 })
      }.width('100%').layoutWeight(1).backgroundColor(COLORS.background)

      if (this.isLoading) {
        Column() {
          LoadingProgress().width(40).height(40)
          Text('保存中...').fontSize(14).fontColor(COLORS.textSecondary).margin({ top: 16 })
        }.width('100%').height('100%').justifyContent(FlexAlign.Center).backgroundColor('rgba(0,0,0,0.5)').position({ x: 0, y: 0 })
      }
    }.width('100%').height('100%').backgroundColor(COLORS.background)
  }
}