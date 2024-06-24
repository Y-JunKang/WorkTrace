//
//  DayPickerView.swift
//  WorkTrace
//
//  Created by 应俊康 on 2024/7/4.
//

import SwiftUI

class DayPickerViewModel: ObservableObject {
    @Binding var year: Int
    @Binding var month: Int
    @Binding var day: Int

    @Published var newYear: Int
    @Published var newMonth: Int
    @Published var newDay: Int

    init(year: Binding<Int>, month: Binding<Int>, day: Binding<Int>) {
        _year = year
        _month = month
        _day = day

        newYear = year.wrappedValue
        newMonth = month.wrappedValue
        newDay = day.wrappedValue
    }

    func editComplete() {
        year = newYear
        month = newMonth
        day = newDay
    }
}

struct DayPickerView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject var vm: DayPickerViewModel

    var body: some View {
        VStack {
            NavBar(title: "") {
            } onBackTap: {
                presentationMode.wrappedValue.dismiss()
            }
            .padding(.top, 12)

            Spacer()

            MonthPickerRepresentable(year: $vm.newYear, month: $vm.newMonth, day: Binding(get: {
                vm.newDay
            }, set: { day in
                vm.newDay = day ?? 0
            }))

            Spacer()

            HStack {
                SureButton(title: "取消", color: Color.redStyle[1]) {
                    presentationMode.wrappedValue.dismiss()
                }

                SureButton(title: "确定", color: .buttonGreen) {
                    vm.editComplete()
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding(.horizontal, 16)
        }
        .navigationBarHidden(true)
    }
}

struct DayPickerView_Previews: PreviewProvider {
    static var previews: some View {
        DayPickerView(vm: .init(year: Binding.constant(2023), month: Binding.constant(11), day: Binding.constant(23)))
    }
}
