//
//  NewIncomSheet.swift
//  Hourly Wage Calculator
//
//  Created by 应俊康 on 2024/6/23.
//

import SwiftUI

class EditTemplateSheetModel: ObservableObject {
    @Binding var display: Bool
    @Binding var template: IncomeTemplate
    var isEdit = true

    @Published var conformAlertDisplay: Bool
    @Published var name: String
    @Published var incomeNum: String
    @Published var year: Int
    @Published var month: Int

    var appViewModel: AppViewModel?

    init(display: Binding<Bool>, template: Binding<IncomeTemplate>, isEdit: Bool) {
        _display = display
        _template = template
        self.isEdit = isEdit

        conformAlertDisplay = false
        name = template.wrappedValue.name
        incomeNum = String(template.wrappedValue.money)
        year = Date.now.year
        month = Date.now.month
    }

    var errorMessage: String {
        if name.isEmpty {
            return "❌ 请输入描述"
        }

        if incomeNum.isEmpty {
            return "❌ 请输入金额"
        }

        return "❌ 未知错误"
    }

    func setup(_ appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
    }

    func editComplete() -> Bool {
        if name.isEmpty || incomeNum.isEmpty {
            appViewModel?.globalToast = .error(title: errorMessage)
            return false
        }

        template.name = name
        if let money = Int(incomeNum) {
            template.money = money
        }

        AppStore.shared.editTemplate(template)
        appViewModel?.globalToast = .success(title: isEdit ? "✅ 修改成功" : "✅ 成功添加一笔收入")
        return true
    }

    func deleteTemplate() {
        AppStore.shared.deleteTemplate(template.id)
    }
}

class MonthPickerViewModel: ObservableObject {
    @Binding var year: Int
    @Binding var month: Int

    @Published var newYear: Int
    @Published var newMonth: Int

    init(year: Binding<Int>, month: Binding<Int>) {
        _year = year
        _month = month

        newYear = year.wrappedValue
        newMonth = month.wrappedValue
    }

    func editComplete() {
        year = newYear
        month = newMonth
    }
}

struct MonthPickerView : View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject var vm: MonthPickerViewModel

    var body: some View {
        VStack {
            NavBar(title: "") {
            } onBackTap: {
                presentationMode.wrappedValue.dismiss()
            }
            .padding(.top, 12)

            MonthPicker(year: vm.year, month: vm.month) { year, month, _ in
                vm.year = year
                vm.month = month
                presentationMode.wrappedValue.dismiss()
            } onCancel: {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationBarHidden(true)
    }
}

struct EditTemplateSheet: View {
    @EnvironmentObject var appViewModel: AppViewModel

    @StateObject var vm: EditTemplateSheetModel

    var body: some View {
        NavigationStack {
            VStack {
                form

                HStack {
                    if vm.isEdit {
                        SureButton(title: "删除", color: Color.redStyle[1]) {
                            withAnimation {
                                vm.conformAlertDisplay.toggle()
                            }
                        }
                        .customAlert(display: $vm.conformAlertDisplay,
                                     message: String(format: "删除收入 名称：%@ 金额：%d", vm.template.name, vm.template.money)) {
                            vm.deleteTemplate()
                            vm.display.toggle()
                        }
                    }

                    SureButton(title: "确定", color: Color.buttonGreen) {
                        if vm.editComplete() {
                            withAnimation {
                                vm.display.toggle()
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 18)
        }
        .onAppear {
            vm.setup(appViewModel)
        }
    }
}

extension EditTemplateSheet {
    var form: some View {
        VStack(spacing: 20) {
            inputBuilder(imageName: "t.square", title: "描述", hint: "输入描述", text: $vm.name)

            inputBuilder(imageName: "dollarsign.circle", title: "金额", hint: "金额(单位元)", text: $vm.incomeNum)
            
            IconTextItem(imageName: "calendar", title: "开始时间") {
                NavigationLink {
                    MonthPickerView(vm: .init(year: $vm.year, month: $vm.month))
                } label: {
                    RoundedArea(backgroundColor: Color.purpleStyle[3]) {
                        HStack(spacing: 8) {
                            Text(String(format: "%d年%d月", vm.year, vm.month))
                        }
                        .foregroundColor(.purpleStyle[0])
                        .font(.system(size: 14, weight: .medium))
                        .padding(.leading, 8)
                        .padding(.trailing, 8)
                        .frame(minHeight: 16)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func inputBuilder(imageName: String, title: String, hint: String, text: Binding<String>) -> some View {
        IconTextItem(imageName: imageName, title: title) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.purpleStyle[4])
                .frame(height: 40)
                .overlay {
                    TextField("", text: text, prompt: Text(hint).foregroundColor(.secondaryTextColor))
                        .multilineTextAlignment(.trailing)
                        .frame(alignment: .trailing)
                        .onSubmit {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                        .submitLabel(.done)
                        .padding(.trailing, 12)
                        .font(.system(size: 15, weight: .medium))
                }
                .padding(.leading, 12)
        }
    }
}

struct EditTemplateSheet_Previews: PreviewProvider {
    static var previews: some View {
        EditTemplateSheet(vm: .init(display: Binding.constant(true),
                                    template: Binding.constant(.init(name: "测试", money: 3000)), isEdit: true))
    }
}
