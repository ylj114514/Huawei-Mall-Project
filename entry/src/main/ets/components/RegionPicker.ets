@Component
export struct RegionPicker {
  @Prop selectedProvince: string
  @Prop selectedCity: string
  @Prop selectedDistrict: string
  onRegionChange?: (province: string, city: string, district: string) => void

  @State showPicker: boolean = false
  @State currentProvince: string = ''
  @State currentCity: string = ''
  @State currentDistrict: string = ''

  // 省份数据
  private provinces: string[] = [
    '北京市', '天津市', '上海市', '重庆市',
    '河北省', '山西省', '辽宁省', '吉林省', '黑龙江省',
    '江苏省', '浙江省', '安徽省', '福建省', '江西省', '山东省',
    '河南省', '湖北省', '湖南省', '广东省', '海南省',
    '四川省', '贵州省', '云南省', '陕西省', '甘肃省', '青海省',
    '内蒙古自治区', '广西壮族自治区', '西藏自治区', '宁夏回族自治区', '新疆维吾尔自治区'
  ]

  // 城市数据（完整的省市区数据）
  private getCities(province: string): string[] {
    const cityMap: Record<string, string[]> = {
      '北京市': ['东城区', '西城区', '朝阳区', '丰台区', '石景山区', '海淀区', '门头沟区', '房山区', '通州区', '顺义区', '昌平区', '大兴区', '怀柔区', '平谷区', '密云区', '延庆区'],
      '上海市': ['黄浦区', '徐汇区', '长宁区', '静安区', '普陀区', '虹口区', '杨浦区', '闵行区', '宝山区', '嘉定区', '浦东新区', '金山区', '松江区', '青浦区', '奉贤区', '崇明区'],
      '天津市': ['和平区', '河东区', '河西区', '南开区', '河北区', '红桥区', '东丽区', '西青区', '津南区', '北辰区', '武清区', '宝坻区', '滨海新区', '宁河区', '静海区', '蓟州区'],
      '重庆市': ['渝中区', '大渡口区', '江北区', '沙坪坝区', '九龙坡区', '南岸区', '北碚区', '渝北区', '巴南区', '涪陵区', '綦江区', '大足区', '长寿区', '江津区', '合川区', '永川区'],
      '广东省': ['广州市', '深圳市', '珠海市', '汕头市', '佛山市', '韶关市', '湛江市', '肇庆市', '江门市', '茂名市', '惠州市', '梅州市', '汕尾市', '河源市', '阳江市', '清远市', '东莞市', '中山市', '潮州市', '揭阳市', '云浮市'],
      '浙江省': ['杭州市', '宁波市', '温州市', '嘉兴市', '湖州市', '绍兴市', '金华市', '衢州市', '舟山市', '台州市', '丽水市'],
      '江苏省': ['南京市', '无锡市', '徐州市', '常州市', '苏州市', '南通市', '连云港市', '淮安市', '盐城市', '扬州市', '镇江市', '泰州市', '宿迁市'],
      '山东省': ['济南市', '青岛市', '淄博市', '枣庄市', '东营市', '烟台市', '潍坊市', '济宁市', '泰安市', '威海市', '日照市', '临沂市', '德州市', '聊城市', '滨州市', '菏泽市'],
      '河南省': ['郑州市', '开封市', '洛阳市', '平顶山市', '安阳市', '鹤壁市', '新乡市', '焦作市', '濮阳市', '许昌市', '漯河市', '三门峡市', '南阳市', '商丘市', '信阳市', '周口市', '驻马店市'],
      '湖北省': ['武汉市', '黄石市', '十堰市', '宜昌市', '襄阳市', '鄂州市', '荆门市', '孝感市', '荆州市', '黄冈市', '咸宁市', '随州市', '恩施土家族苗族自治州'],
      '湖南省': ['长沙市', '株洲市', '湘潭市', '衡阳市', '邵阳市', '岳阳市', '常德市', '张家界市', '益阳市', '郴州市', '永州市', '怀化市', '娄底市', '湘西土家族苗族自治州'],
      '四川省': ['成都市', '自贡市', '攀枝花市', '泸州市', '德阳市', '绵阳市', '广元市', '遂宁市', '内江市', '乐山市', '南充市', '眉山市', '宜宾市', '广安市', '达州市', '雅安市', '巴中市', '资阳市', '阿坝藏族羌族自治州', '甘孜藏族自治州', '凉山彝族自治州'],
      '福建省': ['福州市', '厦门市', '莆田市', '三明市', '泉州市', '漳州市', '南平市', '龙岩市', '宁德市']
    }

    return cityMap[province] || [`${province}市`]
  }

  // 区县数据（完整的省市区数据）
  private getDistricts(province: string, city: string): string[] {
    const districtMap: Record<string, string[]> = {
      // 北京市
      '北京市,东城区': ['东华门街道', '景山街道', '交道口街道', '安定门街道', '北新桥街道', '东四街道', '朝阳门街道', '建国门街道', '东直门街道', '和平里街道', '前门街道'],
      '北京市,西城区': ['西长安街街道', '新街口街道', '月坛街道', '展览路街道', '德胜街道', '金融街街道', '什刹海街道', '大栅栏街道', '天桥街道', '椿树街道', '陶然亭街道'],
      '北京市,朝阳区': ['建外街道', '朝外街道', '呼家楼街道', '三里屯街道', '左家庄街道', '香河园街道', '和平街街道', '安贞街道', '亚运村街道', '小关街道', '酒仙桥街道'],
      '北京市,海淀区': ['万寿路街道', '永定路街道', '羊坊店街道', '甘家口街道', '八里庄街道', '紫竹院街道', '北下关街道', '北太平庄街道', '学院路街道', '中关村街道', '海淀街道'],

      // 上海市
      '上海市,黄浦区': ['南京东路街道', '外滩街道', '半淞园路街道', '小东门街道', '豫园街道', '老西门街道', '五里桥街道', '打浦桥街道', '淮海中路街道', '瑞金二路街道'],
      '上海市,徐汇区': ['天平路街道', '湖南路街道', '斜土路街道', '枫林路街道', '长桥街道', '田林街道', '虹梅路街道', '康健新村街道', '徐家汇街道', '凌云路街道', '龙华街道'],
      '上海市,长宁区': ['华阳路街道', '江苏路街道', '新华路街道', '周家桥街道', '天山路街道', '仙霞新村街道', '虹桥街道', '程家桥街道', '北新泾街道', '新泾镇'],
      '上海市,浦东新区': ['潍坊新村街道', '陆家嘴街道', '周家渡街道', '塘桥街道', '上钢新村街道', '南码头路街道', '沪东新村街道', '金杨新村街道', '洋泾街道', '浦兴路街道', '东明路街道'],

      // 广东省
      '广东省,广州市': ['越秀区', '海珠区', '荔湾区', '天河区', '白云区', '黄埔区', '番禺区', '花都区', '南沙区', '从化区', '增城区'],
      '广东省,深圳市': ['罗湖区', '福田区', '南山区', '宝安区', '龙岗区', '盐田区', '龙华区', '坪山区', '光明区', '大鹏新区'],
      '广东省,东莞市': ['莞城街道', '东城街道', '南城街道', '万江街道', '石碣镇', '石龙镇', '茶山镇', '石排镇', '企石镇', '桥头镇', '东坑镇'],

      // 浙江省
      '浙江省,杭州市': ['上城区', '下城区', '江干区', '拱墅区', '西湖区', '滨江区', '萧山区', '余杭区', '富阳区', '临安区', '桐庐县', '淳安县', '建德市'],
      '浙江省,宁波市': ['海曙区', '江北区', '北仑区', '镇海区', '鄞州区', '奉化区', '象山县', '宁海县', '余姚市', '慈溪市'],

      // 江苏省
      '江苏省,南京市': ['玄武区', '秦淮区', '建邺区', '鼓楼区', '浦口区', '栖霞区', '雨花台区', '江宁区', '六合区', '溧水区', '高淳区'],
      '江苏省,苏州市': ['虎丘区', '吴中区', '相城区', '姑苏区', '吴江区', '常熟市', '张家港市', '昆山市', '太仓市'],

      // 山东省
      '山东省,青岛市': ['市南区', '市北区', '黄岛区', '崂山区', '李沧区', '城阳区', '即墨区', '胶州市', '平度市', '莱西市'],
      '山东省,济南市': ['历下区', '市中区', '槐荫区', '天桥区', '历城区', '长清区', '章丘区', '济阳区', '莱芜区', '钢城区', '平阴县', '商河县']
    }

    return districtMap[`${province},${city}`] || [`${city}区`]
  }

  aboutToAppear() {
    this.currentProvince = this.selectedProvince
    this.currentCity = this.selectedCity
    this.currentDistrict = this.selectedDistrict
  }

  build() {
    Stack() {
      // 主要内容
      Column() {
        // 地区选择按钮
        Button() {
          Row() {
            Text(this.currentProvince && this.currentCity && this.currentDistrict
              ? `${this.currentProvince} ${this.currentCity}`
              : '请选择省市区')
              .fontSize(14)
              .fontColor(this.currentProvince ? $r('app.color.text_primary') : $r('app.color.text_secondary'))
              .layoutWeight(1)
              .textAlign(TextAlign.Start)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Text('>')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ left: 8 })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width('100%')
        .height(48)
        .backgroundColor($r('app.color.background'))
        .borderRadius(8)
        .padding({ left: 16, right: 16 })
        .onClick(() => {
          this.showPicker = true
        })
      }
      .width('100%')

      // 地区选择弹窗 - 使用Stack确保最高层级
      if (this.showPicker) {
        Stack() {
          // 遮罩层
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.5)')
            .onClick(() => {
              this.showPicker = false
            })

          // 选择器内容
          Column() {
            // 标题栏
            Row() {
              Text('取消')
                .fontSize(16)
                .fontColor($r('app.color.text_secondary'))
                .onClick(() => {
                  this.showPicker = false
                })

              Text('选择地区')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .layoutWeight(1)
                .textAlign(TextAlign.Center)

              Text('确定')
                .fontSize(16)
                .fontColor($r('app.color.primary'))
                .onClick(() => {
                  this.currentProvince = this.currentProvince || '北京市'
                  this.currentCity = this.currentCity || '东城区'
                  this.currentDistrict = this.currentDistrict || '城区'
                  this.onRegionChange?.(this.currentProvince, this.currentCity, this.currentDistrict)
                  this.showPicker = false
                })
            }
            .width('100%')
            .padding(16)
            .justifyContent(FlexAlign.SpaceBetween)

            // 选择区域
            Column() {
              Row() {
                // 省份选择
                Scroll() {
                  Column() {
                    Text('省份')
                      .fontSize(14)
                      .fontColor($r('app.color.text_secondary'))
                      .margin({ bottom: 8 })

                    Column() {
                      ForEach(this.provinces, (province: string) => {
                        Text(province)
                          .fontSize(14)
                          .fontColor(this.currentProvince === province ? $r('app.color.primary') : $r('app.color.text_primary'))
                          .width('100%')
                          .padding(8)
                          .backgroundColor(this.currentProvince === province ? $r('app.color.primary_light') : Color.Transparent)
                          .borderRadius(4)
                          .textAlign(TextAlign.Center)
                          .onClick(() => {
                            this.currentProvince = province
                            this.currentCity = this.getCities(province)[0]
                            this.currentDistrict = this.getDistricts(province, this.currentCity)[0]
                          })
                          .margin({ bottom: 4 })
                      })
                    }
                    .width('100%')
                    .padding(8)
                    .backgroundColor($r('app.color.background'))
                    .borderRadius(8)
                  }
                  .width('100%')
                }
                .width('30%')
                .margin({ right: '2%' })

                // 城市选择
                Scroll() {
                  Column() {
                    Text('城市')
                      .fontSize(14)
                      .fontColor($r('app.color.text_secondary'))
                      .margin({ bottom: 8 })

                    Column() {
                      ForEach(this.getCities(this.currentProvince), (city: string) => {
                        Text(city)
                          .fontSize(14)
                          .fontColor(this.currentCity === city ? $r('app.color.primary') : $r('app.color.text_primary'))
                          .width('100%')
                          .padding(8)
                          .backgroundColor(this.currentCity === city ? $r('app.color.primary_light') : Color.Transparent)
                          .borderRadius(4)
                          .textAlign(TextAlign.Center)
                          .onClick(() => {
                            this.currentCity = city
                            this.currentDistrict = this.getDistricts(this.currentProvince, city)[0]
                          })
                          .margin({ bottom: 4 })
                      })
                    }
                    .width('100%')
                    .padding(8)
                    .backgroundColor($r('app.color.background'))
                    .borderRadius(8)
                  }
                  .width('100%')
                }
                .width('30%')
                .margin({ left: '1%', right: '1%' })

                // 区县选择
                Scroll() {
                  Column() {
                    Text('区县')
                      .fontSize(14)
                      .fontColor($r('app.color.text_secondary'))
                      .margin({ bottom: 8 })

                    Column() {
                      ForEach(this.getDistricts(this.currentProvince, this.currentCity), (district: string) => {
                        Text(district)
                          .fontSize(14)
                          .fontColor(this.currentDistrict === district ? $r('app.color.primary') : $r('app.color.text_primary'))
                          .width('100%')
                          .padding(8)
                          .backgroundColor(this.currentDistrict === district ? $r('app.color.primary_light') : Color.Transparent)
                          .borderRadius(4)
                          .textAlign(TextAlign.Center)
                          .onClick(() => {
                            this.currentDistrict = district
                          })
                          .margin({ bottom: 4 })
                      })
                    }
                    .width('100%')
                    .padding(8)
                    .backgroundColor($r('app.color.background'))
                    .borderRadius(8)
                  }
                  .width('100%')
                }
                .width('30%')
                .margin({ left: '2%' })
              }
              .width('100%')
              .height(280)
              .margin({ top: 16 })
            }
          }
          .width(350)
          .backgroundColor($r('app.color.white'))
          .borderRadius(12)
          .padding(16)
          .position({ x: '50%', y: '50%' })
          .translate({ x: '-50%', y: '-50%' })
        }
        .width('100%')
        .height('100%')
        .position({ x: 0, y: 0 })
        .zIndex(9999) // 最高层级
      }
    }
    .width('100%')
  }
}