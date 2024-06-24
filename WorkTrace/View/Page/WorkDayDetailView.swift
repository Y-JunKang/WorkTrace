//
//  WorkDayDetailView.swift
//  WorkTrace
//
//  Created by 应俊康 on 2024/6/25.
//

import SwiftUI

struct WorkTimeRow: View {
    var interval: TimeInterval

    var body: some View {
        HStack(alignment: .center) {
            dateAbstractText
                .monospacedDigit()
                .layoutPriority(2)

            DottedLine()

            durationAbstractText
                .monospacedDigit()
                .layoutPriority(2)

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .frame(width: 12, height: 12)
                .foregroundColor(.purpleStyle[2])
        }
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(.purpleStyle[2])
        .padding(.vertical, 12)
        .frame(maxHeight: 48)
    }

    var dateAbstractText: Text {
        var res = Text(interval.start.description).foregroundColor(.purpleStyle[0])
        res = res + Text(" 至 ")
        if case .working = interval.status {
            res = res + Text("工作中").foregroundColor(.purpleStyle[0])
        } else {
            res = res + Text(interval.end.description).foregroundColor(.purpleStyle[0])
        }
        return res
    }

    var durationAbstractText: Text {
        if interval.totalMinute > 60 {
            let res = Text(String(format: "%.1f%", Float(interval.totalMinute) / 60)).foregroundColor(.purpleStyle[0])
            return res + Text(" 小时")
        }

        let res = Text(String(interval.totalMinute)).foregroundColor(.purpleStyle[0])
        return res + Text(" 分钟")
    }
}

class WorkDayDetailViewModel: ObservableObject {
    @Published var year: Int
    @Published var month: Int
    @Published var day: Int

    @Published var dayPickerDisplay: Bool
    @Published var editWorkTimeSheetDisplay: Bool
    var isEdit: Bool
    @Published var editTimeInterval: TimeInterval
    var appViewModel: AppViewModel?

    var workDay: WorkDay {
        let bill = AppStore.shared.findBill(year: year, month: month)
        let index = bill.findWorkDayIdx(day: day)
        return index == nil ? WorkDay(year: year, month: month, day: day) : bill.workdays[index!]
    }

    init(_ workday: WorkDay) {
        year = workday.year
        month = workday.month
        day = workday.day
        dayPickerDisplay = false
        editWorkTimeSheetDisplay = false
        isEdit = false
        editTimeInterval = .init(start: TimePoint(time: HourMinute(9, 30), type: .start),
                                 end: TimePoint(time: HourMinute(17, 30), type: .end), status: .work)
    }

    func setup(_ appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
    }

    func showDayPicker() {
        dayPickerDisplay = true
    }

    func editWorkTimeSheetDisplay(_ interval: TimeInterval) {
        editTimeInterval = interval
        editWorkTimeSheetDisplay = true
    }

    func switchToDay(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day

        let message = String(format: "切换到%d年%d月%日", year, month, day)
        appViewModel?.globalToast = .success(title: message)
    }

    func addWorkTime() {
        let interval = TimeInterval(start: TimePoint(time: HourMinute(9, 30), type: .start),
                                    end: TimePoint(time: HourMinute(17, 30), type: .end), status: .work)
        editWorkTimeSheetDisplay(interval)
    }
}

struct WorkDayDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var vm: WorkDayDetailViewModel

    var body: some View {
        VStack {
            titleBar

            ScrollView(showsIndicators: false) {
                header
                    .padding(.bottom, 16)

                if vm.workDay.timeIntervals.count == 1 {
                    StatusView(message: "暂无工作记录") {
                        vm.isEdit = false
                        vm.addWorkTime()
                    }
                } else {
                    workTimeList
                }
            }
            .padding(.horizontal, 12)

            SureButton(title: "添加工作时段 🧑🏻‍💻", color: .buttonGreen) {
                vm.isEdit = false
                vm.addWorkTime()
            }
            .padding(.horizontal, 12)
        }
        .sheet(isPresented: $vm.editWorkTimeSheetDisplay, content: {
            EditWorkTimeSheet(vm: .init(display: $vm.editWorkTimeSheetDisplay,
                                        year: vm.year,
                                        month: vm.month,
                                        day: vm.day,
                                        timeInterval: $vm.editTimeInterval,
                                        isEdit: vm.isEdit))
                .presentationDetents([.medium])
        })
        .navigationBarHidden(true)
    }
}

extension WorkDayDetailView {
    var titleBar: some View {
        TitleTappableToolBar(title: String(format: "%d年%d月%d日", vm.year, vm.month, vm.day)) {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "arrow.backward")
                    .foregroundColor(.purpleStyle[0])
            }
        } trailingItemBuilder: {
        } onTap: {
            vm.showDayPicker()
        }.sheet(isPresented: $vm.dayPickerDisplay, content: {
            MonthPicker(year: vm.year, month: vm.month, onSuccess: { year, month, day in
                vm.switchToDay(year: year, month: month, day: day ?? 0)
            }, onCancel: {
                vm.dayPickerDisplay = false
            }).presentationDetents([.medium])
        }).background(Color.white)
    }
}

extension WorkDayDetailView {
    var dayAbstract: String {
        let count = vm.workDay.timeIntervals.filter { interval in
            interval.status == .work || interval.status == .working
        }.count
        return String(format: "工作%d段时间, 总计%@", count, vm.workDay.info)
    }

    var header: some View {
        VStack(spacing: 12) {
            HStack {
                Text(dayAbstract)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.purpleStyle[0])

                Spacer()
            }
            .padding(.top, 8)

            WorkDayStatusBar(intervals: vm.workDay.timeIntervals)
                .cornerRadius(6)
                .frame(maxWidth: .infinity)
                .frame(height: 32)

            HStack(spacing: 18) {
                Spacer()

                markViewBuilder(color: .blueStyle[3], title: "休息")

                markViewBuilder(color: .yellow, title: "工作")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(Color.purpleStyle[4])
        .cornerRadius(16)
    }

    func markViewBuilder(color: Color, title: String) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)

            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.purpleStyle[0])
        }
    }
}

extension WorkDayDetailView {
    var workTimeList: some View {
        ForEach(vm.workDay.timeIntervals, id: \.self) { interval in
            if interval.status == .work || interval.status == .working {
                WorkTimeRow(interval: interval)
                    .onTapGesture {
                        vm.isEdit = true
                        vm.editWorkTimeSheetDisplay(interval)
                    }
            }
        }
        .padding(.horizontal, 20)
    }
}

struct WorkDayDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WorkDayDetailView(vm: .init(WorkDay()))
    }
}
