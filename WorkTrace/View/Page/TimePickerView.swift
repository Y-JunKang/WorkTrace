//
//  TimePickerView.swift
//  HourGlass
//
//  Created by 应俊康 on 2023/9/10.
//

import SwiftUI

struct UIPickerViewRepresentable: UIViewRepresentable {
    var data: [[String]]
    var widthForComponents: [CGFloat]?
    @Binding var selections: [Int]

    // Assign custom coordinator for delegate functions.
    func makeCoordinator() -> UIPickerViewRepresentable.Coordinator {
        Coordinator(self, selections: $selections)
    }

    // Creates the view object and configures its initial state.
    func makeUIView(context: UIViewRepresentableContext<UIPickerViewRepresentable>) -> UIPickerView {
        let picker = UIPickerView(frame: .zero)
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator
        for (index, selection) in selections.enumerated() {
            picker.selectRow(selection, inComponent: index, animated: false)
        }

        return picker
    }

    // Updates the state of the specified view with new information from SwiftUI.
    func updateUIView(_ view: UIPickerView, context: UIViewRepresentableContext<UIPickerViewRepresentable>) {
        for (index, selection) in selections.enumerated() {
            view.selectRow(selection, inComponent: index, animated: false)
        }
    }

    // Coordinator acting as the delegate in SwiftUI.
    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: UIPickerViewRepresentable
        @Binding var selections: [Int]

        // init(_:)
        init(_ pickerView: UIPickerViewRepresentable, selections: Binding<[Int]>) {
            parent = pickerView
            _selections = selections
        }

        // Set your custom row height here!
        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            return 48.5
        }

        func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
            if let widthes = parent.widthForComponents {
                return widthes[component]
            }

            return 90
        }

        // numberOfComponents(in:)
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return parent.data.count
        }

        // pickerView(_:numberOfRowsInComponent:)
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return parent.data[component].count
        }

        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let label = UILabel()
            label.text = parent.data[component][row]
            label.textAlignment = .center
            label.textColor = UIColor(Color.purpleStyle[0])
            label.font = .systemFont(ofSize: 20, weight: .bold)
            return label
        }

        // pickerView(_:didSelectRow:inComponent:)
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            parent.selections[component] = row
        }
    }
}

var hourOptions = genTimePickerOptions(range: 0 ... 23)
var minuteOptions = genTimePickerOptions(range: 0 ... 59)
func genTimePickerOptions(range: ClosedRange<Int>) -> [String] {
    var res: [String] = []
    for h in range {
        res.append(String(format: "%02d", h))
    }
    return res
}

class TimePickerViewModel: ObservableObject {
    var time: HourMinute
    var onSuccess: (HourMinute) -> Void

    @Published var selections: [Int]

    init(time: HourMinute, onSuccess: @escaping (HourMinute) -> Void) {
        self.time = time
        self.onSuccess = onSuccess

        selections = [time.hour, time.minute]
    }

    func editComplete() {
      onSuccess(HourMinute(selections[0], selections[1]))
    }
}

struct TimePicker: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject var vm: TimePickerViewModel

    var body: some View {
        VStack {
            NavBar(title: "") {
            } onBackTap: {
                presentationMode.wrappedValue.dismiss()
            }
            .padding(.top, 12)

            Spacer()

            UIPickerViewRepresentable(data: [hourOptions, minuteOptions], selections: $vm.selections)

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

struct TimePicker_Previews: PreviewProvider {
    static var previews: some View {
        TimePicker(vm: .init(time: HourMinute(12, 31), onSuccess: { _ in

        }))
        .environmentObject(AppViewModel())
    }
}
