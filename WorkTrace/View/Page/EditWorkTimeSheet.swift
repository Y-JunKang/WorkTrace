//
//  EditWorkTimeSheet.swift
//  WorkTrace
//
//  Created by 应俊康 on 2024/6/30.
//

import Sliders
import SwiftUI

class EditWorkTimeSheetModel: ObservableObject {
    @Binding var display: Bool
    @Binding var timeInterval: TimeInterval

    var isEdit: Bool
    @Published var year: Int
    @Published var month: Int
    @Published var day: Int
    @Published var start: TimePoint
    @Published var end: TimePoint
    var appViewModel: AppViewModel?

    var range: Binding<ClosedRange<Int>> {
        return Binding {
            let lowerBound = self.start.time.totalMinute
            let upperBound = self.end.time.totalMinute
            return lowerBound ... upperBound

        } set: { newValue in
            self.start.updateTime(HourMinute(totalMinte: newValue.lowerBound))
            self.end.updateTime(HourMinute(totalMinte: newValue.upperBound))
        }
    }

    @Published var datePickerDisplay: Bool
    @Published var timePickerDisplay: Bool
    @Published var pushTimPicker: Bool
    @Published var editTimeIsLower: Bool
    @Published var conformAlertDisplay: Bool

    init(display: Binding<Bool>, year: Int, month: Int, day: Int, timeInterval: Binding<TimeInterval>, isEdit: Bool) {
        _display = display
        _timeInterval = timeInterval
        self.isEdit = isEdit
        self.year = year
        self.month = month
        self.day = day
        start = timeInterval.wrappedValue.start
        end = timeInterval.wrappedValue.end
        datePickerDisplay = false
        timePickerDisplay = false
        pushTimPicker = false
        editTimeIsLower = false
        conformAlertDisplay = false
    }

    func editComplete() -> Bool {
        timeInterval.start = start
        timeInterval.end = end

        let bill = AppStore.shared.findBill(year: year, month: month)

        var index: Int
        if let index_ = bill.findWorkDayIdx(day: day) {
            index = index_
        } else {
            let workday = WorkDay(year: year, month: month, day: day)
            index = bill.addWorkDay(workday)
        }

        bill.workdays[index].editTimePoint(start)
        bill.workdays[index].editTimePoint(end)

        appViewModel?.globalToast = .success(title: isEdit ? "✅ 编辑成功" : "✅ 添加工作时间段成功")

        return true
    }

    func setup(_ appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
    }

    func showEditTimePicker(_ lower: Bool) {
        pushTimPicker = true
        editTimeIsLower = lower
    }

    func editTime(_ time: HourMinute) {
        if editTimeIsLower {
            if time.totalMinute > end.time.totalMinute {
                start = end
                end.updateTime(time)
            } else {
                start.updateTime(time)
            }
        } else {
            if time.totalMinute < start.time.totalMinute {
                end = start
                start.updateTime(time)
            } else {
                end.updateTime(time)
            }
        }
    }

    func deleteWorkTime() {
        let bill = AppStore.shared.findBill(year: year, month: month)
        if let index = bill.findWorkDayIdx(day: day) {
            bill.workdays[index].deleteTimePoint(start.id)
            bill.workdays[index].deleteTimePoint(end.id)
        }
    }
}

struct EditWorkTimeSheet: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject var vm: EditWorkTimeSheetModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Spacer()

                if !vm.isEdit {
                    datePickerItem
                }

                timeIntervalSlider

                Spacer()

                HStack {
                    if vm.isEdit {
                        SureButton(title: "删除", color: Color.redStyle[1]) {
                            withAnimation {
                                vm.conformAlertDisplay.toggle()
                            }
                        }
                        .customAlert(display: $vm.conformAlertDisplay, message: "删除工作时间段") {
                            vm.deleteWorkTime()
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
        .onTapGesture {
            vm.setup(appViewModel)
        }
    }
}

extension EditWorkTimeSheet {
    var datePickerItem: some View {
        IconTextItem(imageName: "calendar", title: "日期") {
            NavigationLink {
                VStack {
                    DayPickerView(vm: .init(year: $vm.year, month: $vm.month, day: $vm.day))
                }
                .navigationBarHidden(true)
            } label: {
                RoundedArea(backgroundColor: Color.purpleStyle[3]) {
                    HStack(spacing: 8) {
                        Text(String(format: "%d年%d月%d日", vm.year, vm.month, vm.day))
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
}

extension EditWorkTimeSheet {
    var timeIntervalSlider: some View {
        VStack(spacing: 0) {
            IconTextItem(imageName: "clock.arrow.circlepath", title: "时间段") {
                Text(durationDescription)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.purpleStyle[1])
            }

            RangeSlider(range: vm.range, in: 0 ... (24 * 60))
                .rangeSliderStyle(
                    HorizontalRangeSliderStyle(
                        track:
                        HorizontalRangeTrack(
                            view: Capsule().foregroundColor(.yellow),
                            mask: Rectangle()
                        )
                        .background(RoundedRectangle(cornerRadius: 8).foregroundColor(.blueStyle[3]))
                        .frame(height: 32),
                        lowerThumb: thumbBuilder(true),
                        upperThumb: thumbBuilder(false),
                        lowerThumbSize: CGSize(width: 12, height: 48),
                        upperThumbSize: CGSize(width: 12, height: 48),
                        options: .forceAdjacentValue
                    )
                )
                .navigationDestination(isPresented: $vm.pushTimPicker, destination: {
                    TimePicker(vm: .init(time: vm.editTimeIsLower ? vm.start.time : vm.end.time, onSuccess: { time in
                        vm.editTime(time)
                    }))
                })
                .frame(maxHeight: 68)
        }
    }

    var durationDescription: String {
        let totalMinute = vm.range.wrappedValue.count
        if totalMinute < 60 {
            return String(format: "%d 分钟", totalMinute)
        }

        return String(format: "%.1f 小时", Double(totalMinute) / 60)
    }

    func thumbBuilder(_ isLower: Bool) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .foregroundColor(.white)
            .shadow(radius: 3)
            .overlay(content: {
                Text(isLower ? vm.start.description : vm.end.description)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.purpleStyle[0])
                    .frame(width: 72, height: 36)
                    .background(Color.white)
                    .cornerRadius(6)
                    .shadow(radius: 3)
                    .offset(CGSize(width: 0, height: 52))
                    .onTapGesture {
                        vm.showEditTimePicker(isLower)
                    }
            })
    }
}

struct EditWorkTimeSheet_Previews: PreviewProvider {
    static var previews: some View {
        EditWorkTimeSheet(vm: .init(display: Binding.constant(false),
                                    year: 2024,
                                    month: 7,
                                    day: 4,
                                    timeInterval: Binding.constant(TimeInterval(start: .init(id: UUID(),
                                                                                             time: HourMinute(7, 30),
                                                                                             type: .start),
                                                                                end: .init(id: UUID(),
                                                                                           time: HourMinute(18, 30),
                                                                                           type: .end),
                                                                                status: .work)),
                                    isEdit: true))
    }
}
