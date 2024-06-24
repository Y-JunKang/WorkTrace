//
//  WorkDayStatusBar.swift
//  WorkTrace
//
//  Created by 应俊康 on 2024/7/10.
//

import SwiftUI

struct Interval: Hashable {
    enum Status {
        case work
        case rest
        case working
    }

    var start: Double
    var end: Double
    var status: Status

    var radio: Double {
        return end - start
    }
}

struct WorkDayStatusBar: View {
    var intervals: [TimeInterval]

    @State var progress = 0.0

    var body: some View {
        HStack(spacing: 0) {
            GeometryReader(content: { geometry in
                HStack(spacing: 0) {
                    ForEach(intervals, id: \.self) { interval in
                        if case .working = interval.status {
                            Rectangle()
                                .fill(Color.yellow)
                                .frame(width: geometry.size.width * progress * interval.percent, height: geometry.size.height)

                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: geometry.size.width * (1 - progress) * interval.percent, height: geometry.size.height)
                                .animation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: false), value: progress)
                                .onAppear(perform: {
                                    progress = 1.0

                                })

                        } else {
                            Rectangle()
                                .fill(interval.status == .rest ? Color.clear : Color.yellow)
                                .frame(width: geometry.size.width * interval.percent)
                        }
                    }
                }
                .frame(width: geometry.size.width)
                .background(Color.blueStyle[3])
            })
        }.frame(maxWidth: .infinity)
    }
}

#if DEBUG
    struct WorkDayStatusBar_Previews: PreviewProvider {
        static var previews: some View {
            VStack {
                NavigationLink {
                } label: {
                    HStack(alignment: .center, spacing: 0) {
                        Text("测试1")
                            .padding(.trailing, 8)
                            .monospacedDigit()
                            .lineLimit(1)
                            .layoutPriority(2)

                        WorkDayStatusBar(intervals: [
                          .init(start: TimePoint(time: HourMinute(0, 0), type: .end),
                                  end: TimePoint(time: HourMinute(6, 30), type: .start),
                                  status: .rest),
                            .init(start: TimePoint(time: HourMinute(6, 30), type: .start),
                                  end: TimePoint(time: HourMinute(10, 20), type: .end),
                                  status: .work),
                            .init(start: TimePoint(time: HourMinute(10, 20), type: .end),
                                  end: TimePoint(time: HourMinute(11, 0), type: .start),
                                  status: .rest),
                            .init(start: TimePoint(time: HourMinute(11, 0), type: .start),
                                  end: TimePoint(time: HourMinute(12, 20), type: .end),
                                  status: .work),
                            .init(start: TimePoint(time: HourMinute(12, 20), type: .end),
                                  end: TimePoint(time: HourMinute(14, 10), type: .start),
                                  status: .rest),
                            .init(start: TimePoint(time: HourMinute(14, 10), type: .start),
                                  end: TimePoint(time: HourMinute(23, 59), type: .end),
                                  status: .working),
                        ])
                        .frame(height: 5)

                        Text("测试")
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
        }
    }
#endif
