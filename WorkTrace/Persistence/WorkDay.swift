//
//  WorkDay.swift
//  Hourly Wage Calculator
//
//  Created by 应俊康 on 2024/6/22.
//

import Foundation

// for workday test
// let _ =  WorkDay(year: 2024, month: 4, day: 14, timePoints: [
//    .end(date: Date(year: 2024, month: 4, day: 14, hour: 1, minute: 12)!),
//    .start(date: Date(year: 2024, month: 4, day: 14, hour: 6, minute: 12)!),
//    .end(date: Date(year: 2024, month: 4, day: 14, hour: 8, minute: 30)!),
//    .start(date: Date(year: 2024, month: 4, day: 14, hour: 7, minute: 12)!),
//    .end(date: Date(year: 2024, month: 4, day: 14, hour: 12)!),
//    .start(date: Date(year: 2024, month: 4, day: 14, hour: 9)!),
//    .end(date: Date(year: 2024, month: 4, day: 14, hour: 12, minute: 31)!),
//    .end(date: Date(year: 2024, month: 4, day: 14, hour: 15, minute: 31)!),
//    .start(date: Date(year: 2024, month: 4, day: 14, hour: 11, minute: 31)!),
//    .end(date: Date(year: 2024, month: 4, day: 14, hour: 17, minute: 31)!),
//    .start(date: Date(year: 2024, month: 4, day: 14, hour: 3, minute: 33)!),
//    .start(date: Date(year: 2024, month: 4, day: 14, hour: 23, minute: 48)!),
// ])

enum TimePoint: Hashable, CustomStringConvertible {
    case start(date: Date)
    case end(date: Date)

    var date: Date {
        switch self {
        case let .start(date):
            return date
        case let .end(date):
            return date
        }
    }

    var description: String {
        var res: String
        switch self {
        case .start:
            res = "sta "
        case .end:
            res = "end "
        }
        return res + date.debugDescription
    }
}

struct TimeInterval: Hashable, CustomStringConvertible {
    enum Status {
        case work
        case rest
    }

    var start: Date
    var end: Date
    var status: Status
    var isGoing: Bool = false

    var totalSeconds: Double {
        if isGoing {
            return Date.now.timeIntervalSince1970 - start.timeIntervalSince1970
        }
        return end.timeIntervalSince1970 - start.timeIntervalSince1970
    }

    var description: String {
        var res: String
        switch status {
        case .work:
            res = "work "
        case .rest:
            res = "rest "
        }
        return res + start.debugDescription + " -> " + end.debugDescription
    }

    var radio: Double {
        return totalSeconds / (24 * 60 * 60)
    }
}

func dealTimePoints(year: Int, month: Int, day: Int, points inputPoints: [TimePoint]) -> [TimePoint] {
    if inputPoints.count == 0 {
        return []
    }

    let points = inputPoints.sorted { p0, p1 in
        p0.date.timeIntervalSince1970 < p1.date.timeIntervalSince1970
    }

    var res: [TimePoint] = []
    if case .end = points.first {
        res.append(.start(date: Date(year: year, month: month, day: day, hour: 0, minute: 0)!))
    }

    var ignoreStart: Bool = false
    if case .end = points.first {
        ignoreStart = true
    }
    for point in points {
        switch point {
        case .start:
            if ignoreStart {
                continue
            }
            res.append(point)
            ignoreStart = true
        case .end:
            if !ignoreStart {
                continue
            }
            res.append(point)
            ignoreStart = false
        }
    }

    // todo today 的情况下不要自动插入end
    let now = Date.now
    if now.year() != year || now.month() != month || now.day() != day, case .start = points.last {
        res.append(.end(date: Date(year: year, month: month, day: day, hour: 23, minute: 59)!))
    }

    return res
}

func dealTimeIntervals(year: Int, month: Int, day: Int, points: [TimePoint]) -> [TimeInterval] {
    if points.count == 0 {
        return [
            TimeInterval(start: Date(year: year, month: month, day: day, hour: 0, minute: 0)!,
                         end: Date(year: year, month: month, day: day, hour: 59, minute: 59)!,
                         status: .rest)]
    }

    var last = points.first!
    var firstStatus = TimeInterval.Status.work
    if case .start = last {
        firstStatus = .rest
    }
    var res: [TimeInterval] = [
        TimeInterval(start: Date(year: year, month: month, day: day)!, end: last.date, status: firstStatus),
    ]
    for i in 1 ..< points.count {
        var status: TimeInterval.Status = .work
        if case .end = last {
            status = .rest
        }

        res.append(TimeInterval(start: last.date, end: points[i].date, status: status))
        last = points[i]
    }

    if case .start = points.last {
        res.append(TimeInterval(start: points.last!.date, end: Date.now, status: .work, isGoing: true))
    } else {
        res.append(TimeInterval(start: points.last!.date, end: Date(year: year, month: month, day: day, hour: 23, minute: 59)!, status: .rest))
    }

    return res
}

func caculateTotalWorkSeconds(intervals: [TimeInterval]) -> Double {
    return intervals.reduce(0) { partialResult, interval in
        if case .work = interval.status {
            return partialResult + interval.totalSeconds
        }
        return partialResult
    }
}

func caculateIsWorking(year: Int, month: Int, day: Int, points: [TimePoint]) -> Bool {
    if case .start = points.last {
        return year == Date.now.year() && month == Date.now.month() && day == Date.now.day()
    }

    return false
}

struct WorkDay: Hashable {
    var year: Int
    var month: Int
    var day: Int
    var timePoints: [TimePoint]
    var timeIntervals: [TimeInterval]
    var totalWorkSeconds: Double
    var isWorkingNow: Bool

    init() {
        self.init(year: Date.now.year(), month: Date.now.month(), day: Date.now.day())
    }

    init(year: Int, month: Int, day: Int) {
        self.init(year: year, month: month, day: day, timePoints: [])
    }

    init(year: Int, month: Int, day: Int, timePoints: [TimePoint]) {
        self.year = year
        self.month = month
        self.day = day
        self.timePoints = dealTimePoints(year: year, month: month, day: day, points: timePoints)
        timeIntervals = dealTimeIntervals(year: year, month: month, day: day, points: self.timePoints)
        totalWorkSeconds = caculateTotalWorkSeconds(intervals: timeIntervals)
        isWorkingNow = caculateIsWorking(year: year, month: month, day: day, points: self.timePoints)
    }

    var name: String {
        var res = String(format: "%d-%d-%d", year, month, day)
        if isToday() {
            res = res + " (" + (isWorkingNow ? "工作中 🧑🏻‍💻" : "休息中 💤") + ")"
        }
        return res
    }

    var info: String {
        if totalWorkSeconds < 60 * 60 {
            return String(format: "%.1f", totalWorkSeconds / 60) + "分钟"
        }
        return String(format: "%.1f", totalWorkSeconds / (60 * 60)) + "小时"
    }

    func isToday() -> Bool {
        let now = Date.now
        return year == now.year() && month == now.month() && day == now.day()
    }
}
