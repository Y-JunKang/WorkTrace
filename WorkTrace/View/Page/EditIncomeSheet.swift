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
    var isEdit = true
    
    @Published var conformAlertDisplay: Bool
    @Published var name: String
    @Published var incomeNum: String

    var appViewModel: AppViewModel?

    init(display: Binding<Bool>, income: Binding<Income>, isEdit: Bool) {
        _display = display
        _income = income
        self.isEdit = isEdit
        
        conformAlertDisplay = false
        name = income.wrappedValue.name
        incomeNum = String(income.wrappedValue.money)
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

        income.name = name
        if let money = Int(incomeNum) {
            income.money = money
        }

        let bill = AppStore.shared.findBill(year: income.year, month: income.month)
        bill.editIncome(income)
        
        appViewModel?.globalToast = .success(title: isEdit ? "✅ 修改成功" :  "✅ 成功添加一笔收入")
        return true
    }
  
    func deleteIncome() {
      AppStore.shared.findBill(year: income.year, month: income.month).deleteIncome(income.id
      )
    }
}

struct EditIncomeSheet: View {
    @EnvironmentObject var appViewModel: AppViewModel

    @StateObject var vm: EditIncomeSheetModel

    var body: some View {
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
                           message: String(format: "删除收入 名称：%@ 金额：%d", vm.income.name, vm.income.info)) {
                vm.deleteIncome()
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
      .onAppear {
          vm.setup(appViewModel)
      }
    }
}

extension EditIncomeSheet {
    var form: some View {
        VStack(spacing: 20) {
            inputBuilder(imageName: "t.square", title: "描述", hint: "输入描述", text: $vm.name)
            inputBuilder(imageName: "dollarsign.circle", title: "金额", hint: "金额(单位元)", text: $vm.incomeNum)
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
                                  income: Binding.constant(.init(year: Date.now.year, month: Date.now.month, name: "", money: 0)), isEdit: true))
    }
}
