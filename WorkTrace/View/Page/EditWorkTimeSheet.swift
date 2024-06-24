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

    @Published var year: Int
    @Published var month: Int
    @Published var day: Int
    @Published var start: Date
    @Published var end: Date
    @Published var range: ClosedRange<Float>
    @Published var datePickerDisplay: Bool

    init(display: Binding<Bool>, timeInterval: Binding<TimeInterval>) {
        _display = display
        _timeInterval = timeInterval
        year = timeInterval.wrappedValue.start.year()
        month = timeInterval.wrappedValue.start.month()
        day = timeInterval.wrappedValue.start.day()
        start = timeInterval.wrappedValue.start
        end = timeInterval.wrappedValue.end
        range = 0.2 ... 0.8
        datePickerDisplay = false
    }

    func editComplete() -> Bool {
        return true
    }
}

struct EditWorkTimeSheet: View {
    @StateObject var vm: EditWorkTimeSheetModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            DeterminablePicker(display: $vm.display) {
                VStack(spacing: 12) {
                    Spacer()

                    datePickerItem

                    timeIntervalSlider

                    Spacer()
                }
            } onDeterminate: {
                vm.editComplete()
            }
        }
    }
}

extension EditWorkTimeSheet {

    var datePickerItem: some View {
        IconTextItem(imageName: "calendar", title: "日期") {
            NavigationLink {
                
                MonthPicker(display: $vm.datePickerDisplay,
                            year: vm.year,
                            month: vm.month,
                            day: vm.day) { year, month, day in
                    vm.year = year
                    vm.month = month
                    vm.day = day ?? 0
                }.onChange(of: vm.datePickerDisplay) { _ in
                    presentationMode.wrappedValue.dismiss()
                }
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
            HStack {
                IconText(imageName: "clock.arrow.circlepath", title: "时间段")
                Spacer()
            }
            RangeSlider(range: $vm.range)
                .rangeSliderStyle(
                    HorizontalRangeSliderStyle(
                        track:
                        HorizontalRangeTrack(
                            view: Capsule().foregroundColor(.yellow),
                            mask: Rectangle()
                        )
                        .background(RoundedRectangle(cornerRadius: 8).foregroundColor(.blueStyle[3]))
                        .frame(height: 32),
                        lowerThumb: thumbBuilder(vm.start),
                        upperThumb: thumbBuilder(vm.end),
                        lowerThumbSize: CGSize(width: 12, height: 48),
                        upperThumbSize: CGSize(width: 12, height: 48),
                        options: .forceAdjacentValue
                    )
                )
                .frame(maxHeight: 68)
        }
    }

    func thumbBuilder(_ date: Date) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .foregroundColor(.white)
            .shadow(radius: 3)
            .overlay(content: {
                Text(date.formatString("HH:mm"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.purpleStyle[0])
                    .frame(width: 72, height: 36)
                    .background(Color.white)
                    .cornerRadius(6)
                    .shadow(radius: 3)
                    .offset(CGSize(width: 0, height: 52))
                    .onTapGesture {
                        print("测试")
                    }
            })
    }
}

struct EditWorkTimeSheet_Previews: PreviewProvider {
    static var previews: some View {
        EditWorkTimeSheet(vm: .init(display: Binding.constant(false),
                                    timeInterval: Binding.constant(TimeInterval(start: Date.now, end: Date.now, status: .work))))
    }
}
