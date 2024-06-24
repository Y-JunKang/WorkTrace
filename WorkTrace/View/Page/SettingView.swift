//
//  SettingView.swift
//  WorkTrace
//
//  Created by 应俊康 on 2023/10/12.
//

import SwiftUI

struct SectionTitle: View {
    var title: String
    var backgroudColor: Color
    var icon: String? = nil

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                Text(title)

                if let icon = icon {
                    Image(systemName: icon)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .foregroundColor(.white)
            .background(backgroudColor)
            .font(.system(size: 13, weight: .bold))
            .cornerRadius(4)

            Spacer()
        }
        .listRowSeparator(.hidden)
    }
}

struct SettingView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var showReportProblem = false

    var body: some View {
        VStack {
            NavBar(title: "设置") {
            } onBackTap: {
                presentationMode.wrappedValue.dismiss()
            }

            ScrollView {
                VStack {
//                    HStack {
//                        Text("升级到PRO")
//                            .font(.system(size: 16, weight: .bold))
//                            .foregroundColor(.white)
//
//                        Spacer()
//
//                        Button {
//                        } label: {
//                            HStack(spacing: 4) {
//                                Text("免费使用")
//                                    .foregroundColor(.proColor)
//                                    .font(.system(size: 14, weight: .bold))
//                            }
//                            .padding(.vertical, 8)
//                            .padding(.horizontal, 8)
//                            .background(Color.white)
//                            .cornerRadius(4)
//                        }
//                    }
//                    .padding(8)
//                    .background(Color.proColor)
//                    .cornerRadius(8)

                    SectionTitle(title: "通用", backgroudColor: .purpleStyle[1])
                        .padding(.top, 20)

                    Section {
                        NavigationLink {
                            IncomeTemplateList()
                        } label: {
                            IconTitleEmptyItem(imageName: "yensign.circle", title: "管理固定收入")
                        }
                    }

//                    SectionTitle(title: "PRO", backgroudColor: .proColor, icon: "lock")
//                        .padding(.top, 20)
//
//                    Section {
//                        TappableEmptyItem(imageName: "book", title: "iCloud 备份") {
//                            print("")
//                        }
//
//                        Divider()
//
//                        TappableEmptyItem(imageName: "alarm", title: "闹钟") {
//                            print("")
//                        }
//                    }

                    SectionTitle(title: "其他", backgroudColor: .purpleStyle[1])
                        .padding(.top, 20)

                    Section {
                        NavigationLink {
                            WebViewPage(title: "使用教程", url: "https://dg3s68vsx7.feishu.cn/docx/KMHFdwrI3oJFz0xaJTDcYuOxnrh")
                        } label: {
                            IconTitleEmptyItem(imageName: "book", title: "使用教程")
                        }

                        Divider()

                        Button {
                            showReportProblem = true
                        } label: {
                            IconTitleEmptyItem(imageName: "questionmark.circle", title: "问题反馈")
                        }.sheet(isPresented: $showReportProblem, content: {
                            VStack {
                                Text("在微信中搜索「应小白」, 关注公众号，可以直接通过公众号反馈App问题")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.purpleStyle[0])

                                SureButton(title: "点击复制「应小白」", color: .buttonGreen) {
                                    UIPasteboard.general.string = "应小白"
                                    showReportProblem = false
                                }
                                .padding(.top, 64)
                            }
                            .padding(.horizontal, 20)
                            .presentationDetents([.height(200)])
                        }).background(Color.white)

//                        Divider()
//
//                        TappableEmptyItem(imageName: "star", title: "五星好评") {
//                            print("")
//                        }
//
//                        Divider()
//
//                        TappableEmptyItem(imageName: "square.and.arrow.up", title: "推荐给朋友") {
//                            print("")
//                        }
//
//                        Divider()
//
//                        TappableEmptyItem(imageName: "arrow.up.square", title: "检查更新") {
//                            print("")
//                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .background(Color.white)
        }
        .navigationBarHidden(true)
    }
}

struct SettingPage_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
            .environmentObject(AppViewModel.preview)
    }
}
