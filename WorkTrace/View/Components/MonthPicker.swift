//
//  MonthPicker.swift
//  HourGlass
//
//  Created by 应俊康 on 2023/9/2.
//

import SwiftUI

let monthPickerYearNums = 50

struct MonthPickerRepresentable: UIViewRepresentable {
    @Binding var year: Int
    @Binding var month: Int
    @Binding var day: Int?

    init(year: Binding<Int>, month: Binding<Int>) {
        _year = year
        _month = month
        _day = Binding.constant(nil)
    }

    init(year: Binding<Int>, month: Binding<Int>, day: Binding<Int?>) {
        _year = year
        _month = month
        _day = day
    }

    private var yearIndex: Int {
        return monthPickerYearNums - (Date.now.year - year)
    }

    private var monthIndex: Int {
        return month - 1
    }

    private var dayIndex: Int {
        return day != nil ? day! - 1 : 0
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, year: $year, month: $month, day: $day)
    }

    func makeUIView(context: Context) -> UIView {
        let picker = UIPickerView()
        picker.delegate = context.coordinator
        picker.dataSource = context.coordinator
        picker.selectRow(yearIndex, inComponent: 0, animated: false)
        picker.selectRow(monthIndex, inComponent: 1, animated: false)
        if day != nil {
            picker.selectRow(dayIndex, inComponent: 2, animated: false)
        }
        return picker
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        let pickerView = uiView as! UIPickerView
        pickerView.reloadAllComponents()
    }

    private func updateWithCalendarType(_ picker: UIDatePicker) {
    }

    class Coordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
        @Binding var year: Int
        @Binding var month: Int
        @Binding var day: Int?

        private var yearOptions: [Int]
        private var monthOptions: [Int]
        private var dayOptions: [Int]

        private var parent: MonthPickerRepresentable

        init(_ parent: MonthPickerRepresentable, year: Binding<Int>, month: Binding<Int>, day: Binding<Int?>) {
            self.parent = parent
            _year = year
            _month = month
            _day = day
            yearOptions = []
            monthOptions = []
            dayOptions = []
            super.init()

            yearOptions = genYearOptions()
            monthOptions = genMonthOptions()
            dayOptions = genDayOptions()
        }

        private func genYearOptions() -> [Int] {
            var res: [Int] = []
            for i in (Date.now.year - monthPickerYearNums) ... Date.now.year {
                res.append(i)
            }
            return res
        }

        private func genMonthOptions() -> [Int] {
            var res: [Int] = []
            var max = 12
            if year == Date.now.year {
                max = Date.now.month
            }
            for m in 1 ... max {
                res.append(m)
            }
            return res
        }

        private func genDayOptions() -> [Int] {
            var res: [Int] = []
            let calendar = Calendar(identifier: .gregorian)
            guard let date = calendar.date(from: DateComponents(year: year, month: month)) else {
                return res
            }

            guard var count = calendar.range(of: .day, in: .month, for: date)?.count else {
                return res
            }

            if year == Date.now.year && month == Date.now.month {
                count = Date.now.day
            }

            for d in 1 ... count {
                res.append(d)
            }
            return res
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return day == nil ? 2 : 3
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            switch component {
            case 0:
                return yearOptions.count
            case 1:
                return monthOptions.count
            case 2:
                return dayOptions.count
            default:
                return 0
            }
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            switch component {
            case 0:
                year = yearOptions[row]
                monthOptions = genMonthOptions()
                pickerView.reloadComponent(1)
                if day != nil {
                    dayOptions = genDayOptions()
                    pickerView.reloadComponent(2)
                }
            case 1:
                month = monthOptions[row]
                if day != nil {
                    dayOptions = genDayOptions()
                    if pickerView.selectedRow(inComponent: 2) >= dayOptions.count && day != nil {
                        day = dayOptions.last!
                    }
                    pickerView.reloadComponent(2)
                }

            case 2:
                if day != nil {
                    day = dayOptions[row]
                }
            default:
                break
            }
        }

        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            return 48.5
        }

        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let label = UILabel()
            switch component {
            case 0:
                label.text = "\(yearOptions[row])年"
            case 1:
                label.text = "\(monthOptions[row])月"
            case 2:
                label.text = "\(dayOptions[row])日"
            default:
                break
            }
            label.font = .systemFont(ofSize: 20, weight: .bold)
            label.textColor = UIColor(Color.purpleStyle[0])
            label.textAlignment = .center
            return label
        }
    }
}

struct MonthPicker: View {
    var onSuccess: (Int, Int, Int?) -> Void
    var onCancel: () -> Void

    @State private var year: Int
    @State private var month: Int
    @State private var day: Int?

    init(year: Int, month: Int, onSuccess: @escaping (Int, Int, Int?) -> Void, onCancel: @escaping () -> Void) {
        self.init(year: year, month: month, day: nil, onSuccess: onSuccess, onCancel: onCancel)
    }

    init(year: Int, month: Int, day: Int?, onSuccess: @escaping (Int, Int, Int?) -> Void, onCancel: @escaping () -> Void) {
        self.year = year
        self.month = month
        self.day = day
        self.onSuccess = onSuccess
        self.onCancel = onCancel
    }

    var body: some View {
        VStack {
            Spacer()

            MonthPickerRepresentable(year: $year, month: $month, day: day != nil ? $day : Binding.constant(nil))

            Spacer()

            HStack {
                SureButton(title: "取消", color: Color.redStyle[1]) {
                    onCancel()
                }

                SureButton(title: "确定", color: Color.buttonGreen) {
                    onSuccess(year, month, day)
                }
            }
        }
        .padding(.horizontal, 18)
    }
}

struct MonthPickerPicker_Previews: PreviewProvider {
    static var previews: some View {
        MonthPicker(year: 2023, month: 4, onSuccess: { _, _, _ in

        }, onCancel: {
        })

        MonthPicker(year: 2023, month: 4, day: 13, onSuccess: { _, _, _ in

        }, onCancel: {
        })
    }
}
