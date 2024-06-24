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
    var isEdit: Bool
    @Published var editIncome: Income

    @Published var addWorkTimePickerDisplay: Bool
    @Published var editTimeInterval: TimeInterval
    var appViewModel: AppViewModel?

    var bill: MonthBill {
        return AppStore.shared.findBill(year: year, month: month)
    }

    init(year: Int, month: Int) {
        self.year = year
        self.month = month
        monthPickerDisplay = false
        isWorking = AppStore.shared.findBill(year: year, month: month).isWorkingNow
        editIncomeSheetDisplay = false
        isEdit = false
        editIncome = .init(year: Date.now.year, month: Date.now.month)
        addWorkTimePickerDisplay = false
        editTimeInterval = .init(start: TimePoint(time: HourMinute(9, 30), type: .start),
                                 end: TimePoint(time: HourMinute(17, 30), type: .end), status: .work)
    }

    func setup(_ appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
    }

    func showMonthPicker() {
        monthPickerDisplay = true
    }

    func showEditIncomeSheet(_ income: Income? = nil) {
        editIncomeSheetDisplay = true
        if let income = income {
            isEdit = true
            editIncome = income
        } else {
            isEdit = false
            editIncome = .init(year: Date.now.year, month: Date.now.month)
        }
    }

    func startWork() {
        let now = Date.now
        let currentYear = now.year
        let currentMonth = now.month
        if year != currentYear || month != currentMonth {
            year = currentYear
            month = currentMonth
            appViewModel?.globalToast = .success(title: "切换回当前时间")
        }

        isWorking.toggle()
        isWorking ? bill.startWork() : bill.finishWork()
    }

    func showWorkTimePicker() {
        addWorkTimePickerDisplay = true
    }

    func switchToMonth(year: Int, month: Int) {
        self.year = year
        self.month = month

        let title = String(format: "切换到%d年%d月", year, month)
        appViewModel?.globalToast = .success(title: title)
    }
}

struct HomeView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject var vm: HomeViewModel

    var body: some View {
        NavigationStack {
            VStack {
                titleBar

                VStack {
                    ScrollView(showsIndicators: false) {
                        header

                        incomeSection

                        workDaySection
                    }

                    bottomBar
                }
                .padding(.horizontal, 12)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $vm.editIncomeSheetDisplay, content: {
                editIncomeSheet
            }).background(Color.white)
            .sheet(isPresented: $vm.editIncomeSheetDisplay, content: {
                editIncomeSheet
            }).background(Color.white)
            .onAppear {
                vm.setup(appViewModel)
            }
        }
    }
}

extension HomeView {
    var title: String {
        var res = vm.bill.dateDescription
        let now = Date.now
        if vm.isWorking && now.year == vm.year && now.month == vm.month {
            res = res + "(" + (vm.isWorking ? "工作中 🧑🏻‍💻" : "休息中 💤") + ")"
        }

        return res
    }

    var titleBar: some View {
        TitleTappableToolBar(title: title) {
            NavigationLink {
                SettingView()
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
        }
        .sheet(isPresented: $vm.addWorkTimePickerDisplay, content: {
            EditWorkTimeSheet(vm: .init(display: $vm.addWorkTimePickerDisplay,
                                        year: vm.year,
                                        month: vm.month,
                                        day: editWorkTimeDefaultDay,
                                        timeInterval: $vm.editTimeInterval,
                                        isEdit: false))
                .presentationDetents([.medium])
        }).background(Color.white)
        .sheet(isPresented: $vm.monthPickerDisplay, content: {
            MonthPicker(year: vm.year, month: vm.month, onSuccess: { year, month, _ in
                vm.switchToMonth(year: year, month: month)
            }, onCancel: {
                vm.monthPickerDisplay = false
            })

            .presentationDetents([.medium])
        }).background(Color.white)
    }
}

extension HomeView {
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
            HStack {
                infoViewBuilder(title: "工作", subTitle: "小时", content: String(format: "%.1f", vm.bill.totalWorkHours))

                infoViewBuilder(title: "收入", subTitle: "元", content: String(vm.bill.totalIncome))

                infoViewBuilder(title: "时薪", subTitle: "元", content: vm.bill.avgIncome == 0 ? "-" : String(vm.bill.avgIncome))
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
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
        HStack(alignment: .center, spacing: 4) {
            Text(income.name)
                .monospacedDigit()
                .lineLimit(1)
                .layoutPriority(2)

            if income.templateId != nil {
                Image(systemName: "yensign.circle")
            }

            DottedLine()
                .foregroundColor(.purpleStyle[2])

            Text(income.info)
                .layoutPriority(2)

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .frame(width: 12, height: 12)
                .foregroundColor(.purpleStyle[2])
        }
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(.purpleStyle[0])
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
            vm.showWorkTimePicker()
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
            HStack(alignment: .center, spacing: 0) {
                Text(workday.name)
                    .padding(.trailing, 8)
                    .monospacedDigit()
                    .lineLimit(1)
                    .layoutPriority(2)

                WorkDayStatusBar(intervals: workday.timeIntervals)
                    .frame(height: 5)

                Text(workday.info)
                    .monospacedDigit()
                    .frame(width: 70, alignment: .trailing)
                    .layoutPriority(2)
                    .padding(.trailing, 4)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .frame(width: 12, height: 12)
                    .foregroundColor(.purpleStyle[2])
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.purpleStyle[0])
            .padding(.vertical, 6)
        }
    }

    var editWorkTimeDefaultDay: Int {
        let now = Date.now
        if vm.year == now.year && vm.month == now.month {
            return now.day
        }

        return 1
    }

    var addWorkTimeButton: some View {
        HStack {
            Spacer()

            SureButton(size: .small, title: "新增", color: Color.buttonGreen) {
                vm.showWorkTimePicker()
            }
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
                                  income: $vm.editIncome, isEdit: vm.isEdit))
            .presentationDetents([.medium])
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(vm: HomeViewModel(year: Date.now.year, month: Date.now.month))
            .environmentObject(AppViewModel.preview)
    }
}
