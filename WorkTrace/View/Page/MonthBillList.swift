//
//  MonthBillList.swift
//  Hourly Wage Calculator
//
//  Created by 应俊康 on 2024/6/23.
//

import SwiftUI

struct MonthBillList: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            NavBar(title: "记录") {
            } onBackTap: {
                presentationMode.wrappedValue.dismiss()
            }

            list
        }
        .padding(.horizontal, 12)
        .navigationBarHidden(true)
    }
}

extension MonthBillList {
    var list: some View {
        ScrollView(showsIndicators: false) {
            ForEach(Array(AppStore.shared.monthBills.enumerated()), id: \.offset) { index, bill in
                monthBillRowBuilder(bill)
                if index != AppStore.shared.monthBills.count - 1 {
                    Divider()
                }
            }
        }
        .padding(.horizontal, 12)
    }

    func monthBillRowBuilder(_ bill: MonthBill) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(bill.dateDescription)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.purpleStyle[0])
                Spacer()

                Text(bill.hasRecord ? "已记录" : "未记录")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(bill.hasRecord ? .greenStyle[1] : .redStyle[1])
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .frame(width: 12, height: 12)
                    .foregroundColor(.purpleStyle[2])
            }
            .padding(.top, 12)

            if bill.hasRecord {
                abstractText(bill)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.purpleStyle[2])
            }
        }
        .onTapGesture {
            appViewModel.homeViewModel.switchToMonth(year: bill.year, month: bill.month)
            presentationMode.wrappedValue.dismiss()
        }
    }

    func abstractText(_ bill: MonthBill) -> Text {
        var res = Text("")
        if bill.workdays.count != 0 {
            res = res + Text("本月工作 ") + Text(String(bill.workdays.count)).bold().foregroundColor(.purpleStyle[0]) + Text(" 天, 共 ") + Text(String(format: "%.1f", bill.totalWorkHours)).bold().foregroundColor(.purpleStyle[0]) + Text(" 小时, ")
        }

        if bill.incomes.count != 0 {
            res = res + Text("收入 ") + Text(String(bill.totalIncome)).bold().foregroundColor(.purpleStyle[0]) + Text(" 元, ")
        }

        if bill.avgIncome != 0 {
            res = res + Text("时薪 ") + Text(String(bill.avgIncome)).bold().foregroundColor(.purpleStyle[0]) + Text(" 元")
        }

        return res
    }
}

struct MonthBillList_Previews: PreviewProvider {
    static var previews: some View {
        MonthBillList()
            .environmentObject(AppViewModel.preview)
    }
}
