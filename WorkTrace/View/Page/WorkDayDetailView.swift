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
        HStack(alignment: .bottom) {
            dateAbstractText
                .layoutPriority(2)

            DottedLine()

            durationAbstractText
                .layoutPriority(2)
        }
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(.purpleStyle[2])
        .padding(.vertical, 12)
        .frame(maxHeight: 48)
    }

    var dateAbstractText: Text {
        var res = Text(interval.start.formatString("HH:mm")).foregroundColor(.purpleStyle[0])
        res = res + Text(" 至 ")
        res = res + Text(interval.isGoing ? "工作中" : interval.end.formatString("HH:mm")).foregroundColor(.purpleStyle[0])
        return res
    }

    var durationAbstractText: Text {
        if interval.totalSeconds > 60 * 60 {
            let res = Text(String(format: "%.1f%", interval.totalSeconds / (60 * 60))).foregroundColor(.purpleStyle[0])
            return res + Text(" 小时")
        }

        let res = Text(String(format: "%.1f%", interval.totalSeconds / 60)).foregroundColor(.purpleStyle[0])
        return res + Text(" 分钟")
    }
}

class WorkDayDetailViewModel: ObservableObject {
    @Published var year: Int
    @Published var month: Int
    @Published var day: Int

    @Published var dayPickerDisplay: Bool
    @Published var editWorkTimeSheetDisplay: Bool

    var workDay: WorkDay {
        AppStore.inst.findBill(year: year, month: month).findWorkDay(day: day)
    }

    init(_ workday: WorkDay) {
        year = workday.year
        month = workday.month
        day = workday.day
        dayPickerDisplay = false
        editWorkTimeSheetDisplay = false
    }

    func showDayPicker() {
        dayPickerDisplay = true
    }

    func showEditWorkTimeSheetDisplay() {
        editWorkTimeSheetDisplay = true
    }

    func switchToDay(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day

        let message = String(format: "切换到%d年%d月%日", year, month, day)
        AppViewModel.inst.globalToast = .success(title: message)
    }

    func addWorkTime() {
        showEditWorkTimeSheetDisplay()
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
                        vm.addWorkTime()
                    }
                } else {
                    workTimeList
                }
            }
            .padding(.horizontal, 12)

            SureButton(title: "添加工作时段 🧑🏻‍💻", color: .buttonGreen) {
                vm.addWorkTime()
            }
            .padding(.horizontal, 12)
        }
        .sheet(isPresented: $vm.editWorkTimeSheetDisplay, content: {
            EditWorkTimeSheet(vm: .init(display: $vm.editWorkTimeSheetDisplay, timeInterval: Binding.constant(TimeInterval(start: Date.now, end: Date.now, status: .work))))
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
            MonthPicker(display: $vm.dayPickerDisplay, year: vm.year, month: vm.month, day: vm.day) { year, month, day in
                vm.switchToDay(year: year, month: month, day: day ?? 0)
            }.presentationDetents([.medium])
        }).background(Color.white)
    }
}

extension WorkDayDetailView {
    var dayAbstract: String {
        let count = vm.workDay.timeIntervals.filter { interval in
            interval.status == .work
        }.count
        if vm.workDay.totalWorkSeconds > 60 * 60 {
            return String(format: "工作%d段时间, 总计%.1f小时", count, vm.workDay.totalWorkSeconds / (60 * 60))
        }

        return String(format: "工作%d段时间, 总计%.1f分钟", count, vm.workDay.totalWorkSeconds / 60)
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

            HStack(spacing: 0) {
                GeometryReader(content: { geometry in
                    HStack(spacing: 0) {
                        ForEach(vm.workDay.timeIntervals, id: \.self) { interval in
                            Rectangle()
                                .fill(interval.status == .work ? Color.yellow : Color.clear)
                                .frame(width: geometry.size.width * interval.radio)
                        }
                    }
                    .frame(width: geometry.size.width)
                    .background(Color.blueStyle[3])
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 8, height: 8)))
                })
            }.frame(maxWidth: .infinity)
                .frame(height: 36)

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
            if case .work = interval.status {
                WorkTimeRow(interval: interval)
                    .onTapGesture {
                        vm.showEditWorkTimeSheetDisplay()
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
