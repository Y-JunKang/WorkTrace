//
//  HomeView.swift
//  Hourly Wage Calculator
//
//  Created by 应俊康 on 2024/6/22.
//

import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var year: Int
    @Published var month: Int
    @Published var monthPickerDisplay: Bool
    @Published var isWorking: Bool
    @Published var editIncomeSheetDisplay: Bool
    @Published var editIncome: Income

    @Published var addWorkTimePicker: Bool

    var bill: MonthBill {
        return AppStore.inst.findBill(year: year, month: month)
    }

    init(year: Int, month: Int) {
        self.year = year
        self.month = month
        monthPickerDisplay = false
        isWorking = AppStore.inst.findBill(year: year, month: month).isWorkingNow
        editIncomeSheetDisplay = false
        editIncome = .init(year: Date.now.year(), month: Date.now.month())
        addWorkTimePicker = false
    }

    func showMonthPicker() {
        monthPickerDisplay = true
    }

    func showEditIncomeSheet(_ income: Income? = nil) {
        editIncomeSheetDisplay = true
        if let income = income {
            editIncome = income
        } else {
            editIncome = .init(year: Date.now.year(), month: Date.now.month())
        }
    }

    func startWork() {
        let now = Date.now
        let currentYear = now.year()
        let currentMonth = now.month()
        if year != currentYear || month != currentMonth {
            year = currentYear
            month = currentMonth
            AppViewModel.inst.globalToast = .success(title: "切换回当前时间")
        }

        isWorking.toggle()
        isWorking ? bill.startWork() : bill.finishWork()
    }

    func showWorkTimePicker() {
        addWorkTimePicker = true
    }

    func switchToMonth(year: Int, month: Int) {
        self.year = year
        self.month = month

        let title = String(format: "切换到%d年%d月", year, month)
        AppViewModel.inst.globalToast = .success(title: title)
    }
}

struct HomeView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject var vm: HomeViewModel

    var body: some View {
        NavigationStack {
            VStack {
                titleBar

                ScrollView(showsIndicators: false) {
                    header

                    incomeSection

                    workDaySection
                }

                bottomBar
            }
            .padding(.horizontal, 12)
            .navigationBarHidden(true)
            .sheet(isPresented: $vm.editIncomeSheetDisplay, content: {
                editIncomeSheet
            }).background(Color.white)
        }
    }
}

extension HomeView {
    var titleBar: some View {
        TitleTappableToolBar(title: vm.bill.dateDescription) {
            NavigationLink {
                SettingPage()
            } label: {
                Image(systemName: "gearshape")
                    .foregroundColor(.purpleStyle[0])
            }
        } trailingItemBuilder: {
            NavigationLink {
                MonthBillList()
            } label: {
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(.purpleStyle[0])
            }
        } onTap: {
            vm.showMonthPicker()
        }.sheet(isPresented: $vm.monthPickerDisplay, content: {
            MonthPicker(display: $vm.monthPickerDisplay, year: vm.year, month: vm.month, onSuccess: { year, month, _ in
                vm.switchToMonth(year: year, month: month)
            }).presentationDetents([.medium])
        }).background(Color.white)
    }
}

extension HomeView {
    var headerStatus: String {
        return vm.isWorking ? "工作中 🧑🏻‍💻" : "休息中 💤"
    }

    func infoViewBuilder(title: String, subTitle: String, content: String) -> some View {
        RoundedArea(backgroundColor: .purpleStyle[3]) {
            VStack {
                Text(title)
                Spacer()
                Text(content)
                    .font(.system(size: 27, weight: .bold))
                Spacer()
                Text(subTitle)
            }
            .frame(maxWidth: .infinity)
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(.purpleStyle[0])
        }
    }

    var header: some View {
        VStack(spacing: 0) {
            Text(headerStatus)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.purpleStyle[0])

            HStack {
                infoViewBuilder(title: "工作", subTitle: "小时", content: String(format: "%.1f", vm.bill.totalWorkHours))

                infoViewBuilder(title: "收入", subTitle: "元", content: String(vm.bill.totalIncome))

                infoViewBuilder(title: "时薪", subTitle: "元", content: vm.bill.avgIncome == 0 ? "-" : String(vm.bill.avgIncome))
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .padding(.top, 12)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(Color.purpleStyle[4])
        .cornerRadius(16)
    }
}

extension HomeView {
    var incomeSection: some View {
        VStack {
            IconTextItem(imageName: "dollarsign.circle", title: "收入") {
            }
            .padding(.top, 16)

            if vm.bill.incomes.count == 0 {
                incomeEmptyView
            } else {
                incomeList

                addIncomeButton
            }
        }
    }

    var incomeEmptyView: some View {
        StatusView(message: "暂无收入记录，点击添加") {
            vm.showEditIncomeSheet()
        }
    }

    var incomeList: some View {
        ForEach(vm.bill.incomes) { income in
            incomRowBuilder(income)
                .padding(.horizontal, 28)
        }
    }

    func incomRowBuilder(_ income: Income) -> some View {
        HStack(alignment: .bottom) {
            Text(income.name)
                .lineLimit(1)
                .layoutPriority(2)

            if income.isFixed {
                Image(systemName: "yensign.circle")
            }

            DottedLine()

            Text(income.info)
                .layoutPriority(2)
        }
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(.purpleStyle[2])
        .padding(.vertical, 6)
        .onTapGesture {
            vm.showEditIncomeSheet(income)
        }
    }

    var addIncomeButton: some View {
        HStack {
            Spacer()

            SureButton(size: .small, title: "新增", color: Color.buttonGreen) {
                vm.showEditIncomeSheet()
            }
        }
        .padding(.trailing, 28)
        .padding(.top, 4)
    }
}

extension HomeView {
    var workDaySection: some View {
        VStack {
            IconTextItem(imageName: "clock", title: "时间") {
            }
            .padding(.top, 16)

            if vm.bill.workdays.count == 0 {
                workDayEmptyView
            } else {
                workDayList

                addWorkTimeButton
            }
        }
    }

    var workDayEmptyView: some View {
        StatusView(message: "暂无工作记录，点击添加") {
        }
    }

    var workDayList: some View {
        ForEach(vm.bill.workdays, id: \.self) { workday in
            workDayRowBuilder(workday)
                .padding(.horizontal, 28)
        }
    }

    func workDayRowBuilder(_ workday: WorkDay) -> some View {
        NavigationLink {
            WorkDayDetailView(vm: .init(workday))
        } label: {
            HStack(alignment: .bottom) {
                Text(workday.name)
                    .lineLimit(1)
                    .layoutPriority(2)

                DottedLine()

                Text(workday.info)
                    .layoutPriority(2)
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.purpleStyle[2])
            .padding(.vertical, 6)
        }
    }

    var addWorkTimeButton: some View {
        HStack {
            Spacer()

            SureButton(size: .small, title: "新增", color: Color.buttonGreen) {
                vm.showWorkTimePicker()
            }.sheet(isPresented: $vm.addWorkTimePicker, content: {
            }).background(Color.white)
        }
        .padding(.trailing, 28)
        .padding(.top, 4)
    }
}

extension HomeView {
    var bottomBar: some View {
        SureButton(title: vm.isWorking ? "开始休息 💤 " : "开始工作 🧑🏻‍💻",
                   color: vm.isWorking ? Color.blueStyle[3] : Color.yellow) {
            vm.startWork()
        }
    }
}

extension HomeView {
    var editIncomeSheet: some View {
        EditIncomeSheet(vm: .init(display: $vm.editIncomeSheetDisplay,
                                  income: $vm.editIncome))
            .presentationDetents([.medium])
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(vm: HomeViewModel(year: Date.now.year(), month: Date.now.month()))
            .environmentObject(AppViewModel.debug)
    }
}
