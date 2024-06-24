//
//  WorkDay.swift
//  Hourly Wage Calculator
//
//  Created by 应俊康 on 2024/6/22.
//

import Foundation

struct TimeInterval: Hashable, CustomStringConvertible {
    enum Status {
        case work
        case rest
        case working
    }

    var start: TimePoint
    var end: TimePoint
    var status: Status

    var totalMinute: Int {
        let now = Date.now
        let nowTotalMinute = now.hour * 60 + now.minute
      if nowTotalMinute < start.time.totalMinute {
            return 0
        }

        if case .working = status {
          return nowTotalMinute - start.time.totalMinute
        }
        return end.time.totalMinute - start.time.totalMinute
    }

    var description: String {
        var res: String
        switch status {
        case .work:
            res = "work "
        case .rest:
            res = "rest "
        case .working:
            res = "working "
        }
        return res + start.description + " -> " + end.description
    }

    var percent: Double {
        if case .working = status {
          return Double(HourMinute(23, 59).totalMinute - start.time.totalMinute) / (24 * 60)
        }

        return Double(totalMinute) / (24 * 60)
    }
  
    func contains(_ hourMinute: HourMinute) -> Bool {
      return hourMinute.totalMinute > start.time.totalMinute && hourMinute.totalMinute < end.time.totalMinute
    }
}

func dealTimePoints(year: Int, month: Int, day: Int, points inputPoints: [TimePoint]) -> [TimePoint] {
    if inputPoints.count == 0 {
        return []
    }

    let points = inputPoints.sorted { p0, p1 in
        p0.time.totalMinute < p1.time.totalMinute
    }

    var res: [TimePoint] = []
    let now = Date.now
    let nowTotalMinute = now.hourMinute.totalMinute
    let isToday = year == now.year && month == now.month && day == now.day
    var i = 0
    var pointSets: [[TimePoint]] = []
    while i < points.count {
        if isToday && points[i].time.totalMinute > nowTotalMinute {
            break
        }

        if pointSets.isEmpty {
            pointSets.append([points[i]])
        } else {
            guard let last = pointSets.last?.last else {
                break
            }
            
            if last.type == points[i].type {
                var lastSet = pointSets.last
                lastSet?.append(points[i])
                pointSets[pointSets.count - 1] = lastSet!
            } else {
                pointSets.append([points[i]])
            }
        }
        i = i + 1
    }
    
    for pointSet in pointSets {
      if case .start = pointSet.first?.type {
            res.append(pointSet.first!)
        } else {
            res.append(pointSet.last!)
        }
    }

    return res
}

struct WorkDay: Hashable {
    var year: Int
    var month: Int
    var day: Int
    var timePoints: [TimePoint]
  
    var timeIntervals: [TimeInterval] {
      if timePoints.count == 0 {
        return [TimeInterval(start: TimePoint(time: HourMinute(0, 0), type: .end),
                             end: TimePoint(time: HourMinute(23, 59), type: .start),
                             status: .rest)]
      }

      var _points = timePoints
      if case .start = timePoints.first!.type, timePoints.first!.time.percent != 0 {
          _points.insert(TimePoint(time: HourMinute(0, 0), type: .end), at: 0)
      } else {
          _points.insert(TimePoint(time: HourMinute(0, 0), type: .start), at: 0)
      }

      var lastIsWorking = false
      if case .start = timePoints.last!.type, timePoints.last!.time.percent != 1 {
          _points.append(TimePoint(time: HourMinute(23, 59), type: .end))
          let now = Date.now
          if year == now.year && month == now.month && day == now.day {
              lastIsWorking = true
          }
      } else {
          _points.append(TimePoint(time: HourMinute(23, 59), type: .start))
      }

      var res: [TimeInterval] = []
      var last = _points.first!
      for i in 1 ..< _points.count {
          if case .end = last.type {
              res.append(TimeInterval(start: last, end: _points[i], status: .rest))
          } else {
              res.append(TimeInterval(start: last, end: _points[i], status: .work))
          }

          last = _points[i]
      }

      if lastIsWorking {
          var last = res.last!
          last.status = .working
          res[res.count - 1] = last
      }

      return res
    }
  
    var totalWorkMinutes: Int {
      return timeIntervals.reduce(0) { partialResult, interval in
          if case .work = interval.status {
              return partialResult + interval.totalMinute
          }
          return partialResult
      }
    }
  
    var isWorkingNow: Bool {
      let now = Date.now
      let isToday = year == now.year && month == now.month && day == now.day
      if !isToday {
        return false
      }
      
      let intervals = timeIntervals.filter { interval in
        return interval.status == .work || interval.status == .working
      }
      
      for interval in intervals {
        if interval.contains(now.hourMinute) {
          return true
        }
      }
      
      return false
    }

    init() {
        self.init(year: Date.now.year, month: Date.now.month, day: Date.now.day)
    }

    init(year: Int, month: Int, day: Int) {
        self.init(year: year, month: month, day: day, timePoints: [])
    }

    init(year: Int, month: Int, day: Int, timePoints: [TimePoint]) {
        self.year = year
        self.month = month
        self.day = day
        self.timePoints = dealTimePoints(year: year, month: month, day: day, points: timePoints)
    }

    var name: String {
        return String(format: "%02d-%02d", month, day)
    }

    var info: String {
        if totalWorkMinutes < 60 {
            return String(totalWorkMinutes) + "分钟"
        }
        return String(format: "%.1f", Float(totalWorkMinutes) / 60) + "小时"
    }

    func isToday() -> Bool {
        let now = Date.now
        return year == now.year && month == now.month && day == now.day
    }

    mutating func editTimePoint(_ timePoint: TimePoint) {
      
      let idx = timePoints.firstIndex { t in
          t.id == timePoint.id
      }

      if let idx = idx {
        timePoints[idx].updateTime(timePoint.time)
      } else {
        timePoints.append(timePoint)
      }
      timePoints = dealTimePoints(year: year, month: month, day: day, points: timePoints)
      
      let entity = Persistence.shared.timePointEntitys.first { entity in
        entity.id == timePoint.id
      }

      if let entity = entity {
          entity.year = Int32(year)
          entity.month = Int32(month)
          entity.day = Int32(day)
          entity.timePoint = timePoint
      } else {
          _ = TimePointEntity(year: year, month: month, day: day, timepoint: timePoint)
      }
      
      Persistence.shared.save()
    }
  
    mutating func deleteTimePoint(_ id: UUID) {
      timePoints.removeAll { timePoint in
        timePoint.id == id
      }
        
      Persistence.shared.deleteTimepoint(id);
    }
}
