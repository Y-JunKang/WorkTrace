//
//  NewIncomSheet.swift
//  Hourly Wage Calculator
//
//  Created by 应俊康 on 2024/6/23.
//

import SwiftUI

class EditIncomeSheetModel: ObservableObject {
    @Binding var display: Bool
    @Binding var income: Income

    @Published var name: String
    @Published var incomeNum: String
    @Published var isFixedIncome: Bool

    init(display: Binding<Bool>, income: Binding<Income>) {
        _display = display
        _income = income

        name = income.wrappedValue.name
        incomeNum = String(income.wrappedValue.money)
        isFixedIncome = income.wrappedValue.isFixed
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

    func editComplete() -> Bool {
        if name.isEmpty || incomeNum.isEmpty {
            AppViewModel.inst.globalToast = .error(title: errorMessage)
            return false
        }

        income.name = name
        if let money = Int(incomeNum) {
            income.money = money
        }
        income.isFixed = isFixedIncome

        let bill = AppStore.inst.findBill(year: income.year, month: income.month)
        let idx = bill.incomes.firstIndex { income in
            income.id == income.id
        }

        if let idx = idx {
            bill.incomes[idx] = income
        } else {
            bill.incomes.append(income)
        }
        AppViewModel.inst.globalToast = .success(title: "✅ 成功添加一笔收入")
        return true
    }
}

// todo 无法编辑数据fix
struct EditIncomeSheet: View {
    @StateObject var vm: EditIncomeSheetModel

    var body: some View {
        DeterminablePicker(display: $vm.display) {
            form
        } onDeterminate: {
            vm.editComplete()
        }
    }
}

extension EditIncomeSheet {
    var form: some View {
        VStack(spacing: 20) {
            inputBuilder(imageName: "t.square", title: "描述", hint: "输入描述", text: $vm.name)
            inputBuilder(imageName: "dollarsign.circle", title: "金额", hint: "金额(单位元)", text: $vm.incomeNum)
            IconTextItem(imageName: "calendar", title: "每月固定收入") {
                CustomToggle(isOn: $vm.isFixedIncome)
                    .frame(height: 40)
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

struct NewIncomSheet_Previews: PreviewProvider {
    static var previews: some View {
        EditIncomeSheet(vm: .init(display: Binding.constant(true),
                                  income: Binding.constant(.init(year: Date.now.year(), month: Date.now.month()))))
    }
}
