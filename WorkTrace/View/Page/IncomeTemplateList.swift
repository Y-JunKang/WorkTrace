//
//  IncomeTemplateList.swift
//  WorkTrace
//
//  Created by 应俊康 on 2024/7/17.
//

import SwiftUI

class IncomeTemplateListViewModel: ObservableObject {
    @Published var editTemplateSheetDisplay: Bool
    var isEdit: Bool = true
    @Published var editTemplate: IncomeTemplate

    init() {
        editTemplateSheetDisplay = false
        isEdit = false
        editTemplate = IncomeTemplate(name: "", money: 0)
    }

    func showEditTemplateSheet() {
        editTemplateSheetDisplay = true
    }
}

struct IncomeTemplateList: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var vm = IncomeTemplateListViewModel()

    var body: some View {
        VStack {
            NavBar(title: "固定收入") {
            } onBackTap: {
                presentationMode.wrappedValue.dismiss()
            }

            VStack {
                ScrollView(showsIndicators: false) {
                    Text("固定收入创建后，每月会自动添加固定收入添加到月收入中，适合用于管理工资类的收入")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.purpleStyle[2])

                    templateList
                }

                SureButton(title: "添加固定收入 💰", color: .buttonGreen) {
                    vm.editTemplate = IncomeTemplate(name: "", money: 0)
                    vm.isEdit = false
                    vm.showEditTemplateSheet()
                }
            }
            .padding(.horizontal, 12)
        }
        .sheet(isPresented: $vm.editTemplateSheetDisplay, content: {
            EditTemplateSheet(vm: .init(display: $vm.editTemplateSheetDisplay,
                                        template: $vm.editTemplate,
                                        isEdit: vm.isEdit))
                .presentationDetents([.medium])
        }).background(Color.white)
        .navigationBarHidden(true)
        .onAppear {
        }
    }
}

extension IncomeTemplateList {
    var templateList: some View {
        VStack {
            if AppStore.shared.templates.count == 0 {
                StatusView(message: "点击添加固定收入") {
                    vm.editTemplate = IncomeTemplate(name: "", money: 0)
                    vm.isEdit = false
                    vm.showEditTemplateSheet()
                }
                .padding(.top, 12)
            } else {
                ForEach(Array(AppStore.shared.templates.enumerated()), id: \.offset) { index, template in
                    templateRowBuilder(template)

                    if index != AppStore.shared.templates.count - 1 {
                        Divider()
                    }
                }
            }
        }
    }

    func templateRowBuilder(_ template: IncomeTemplate) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(template.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.purpleStyle[0])
                Spacer()

                Text(template.startTimeDescription)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.greenStyle[1])

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .frame(width: 12, height: 12)
                    .foregroundColor(.purpleStyle[2])
            }
            .padding(.top, 12)

            abstractText(template)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.purpleStyle[2])
        }
        .onTapGesture {
            vm.isEdit = true
            vm.editTemplate = template
            vm.showEditTemplateSheet()
        }
    }

    func abstractText(_ template: IncomeTemplate) -> Text {
        var count = 0
        for bill in AppStore.shared.monthBills {
            let res = bill.incomes.first { income in
                income.templateId == template.id
            }

            if res != nil {
                count = count + 1
            }
        }

        if count == 0 {
            return Text("暂无记录")
        }

        var res = Text("累计获取 ")
        res = res + Text(String(count)).bold().foregroundColor(.purpleStyle[0]) + Text(" 笔收入, 共计收入 ") + Text(String(count * template.money)).bold().foregroundColor(.purpleStyle[0]) + Text(" 元")
        return res
    }
}

struct IncomeTemplateList_Previews: PreviewProvider {
    static var previews: some View {
        IncomeTemplateList()
    }
}
