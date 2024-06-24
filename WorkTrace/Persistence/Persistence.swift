//
//  Persistence.swift
//  WorkTrace
//
//  Created by 应俊康 on 2024/7/8.
//

import CoreData

struct Persistence {
    static var shared = Persistence()

    static var preview: Persistence = {
        let result = Persistence(inMemory: true)
        let viewContext = result.container.viewContext

        var _timePoint: TimePointEntity

      _timePoint = TimePointEntity(context: viewContext, year: 2024, month: 6, day: 21, timepoint: .init(time: HourMinute(1, 12), type: .end))
      _timePoint = TimePointEntity(context: viewContext, year: 2024, month: 6, day: 21, timepoint: .init(time: HourMinute(6, 12), type: .start))
        _timePoint = TimePointEntity(context: viewContext, year: 2024, month: 6, day: 21, timepoint: .init(time: HourMinute(7, 12), type: .start))
        _timePoint = TimePointEntity(context: viewContext, year: 2024, month: 6, day: 21, timepoint: .init(time: HourMinute(8, 30), type: .end))

        _timePoint = TimePointEntity(context: viewContext, year: 2024, month: 7, day: 8, timepoint: .init(time: HourMinute(1, 12), type: .end))
        _timePoint = TimePointEntity(context: viewContext, year: 2024, month: 7, day: 8, timepoint: .init(time: HourMinute(6, 12), type: .start))
        _timePoint = TimePointEntity(context: viewContext, year: 2024, month: 7, day: 8, timepoint: .init(time: HourMinute(7, 12), type: .start))
        _timePoint = TimePointEntity(context: viewContext, year: 2024, month: 7, day: 8, timepoint: .init(time: HourMinute(11, 30), type: .end))

        _timePoint = TimePointEntity(context: viewContext, year: 2024, month: 7, day: 9, timepoint: .init(time: HourMinute(1, 12), type: .end))
        _timePoint = TimePointEntity(context: viewContext, year: 2024, month: 7, day: 9, timepoint: .init(time: HourMinute(6, 12), type: .start))
        _timePoint = TimePointEntity(context: viewContext, year: 2024, month: 7, day: 9, timepoint: .init(time: HourMinute(7, 12), type: .start))
        _timePoint = TimePointEntity(context: viewContext, year: 2024, month: 7, day: 9, timepoint: .init(time: HourMinute(8, 30), type: .end))
        _timePoint = TimePointEntity(context: viewContext, year: 2024, month: 7, day: 9, timepoint: .init(time: HourMinute(9, 12), type: .start))
        _timePoint = TimePointEntity(context: viewContext, year: 2024, month: 7, day: 9, timepoint: .init(time: HourMinute(12, 12), type: .end))

        _timePoint = TimePointEntity(context: viewContext, year: 2024, month: 7, day: 10, timepoint: .init(time: HourMinute(1, 12), type: .end))
        _timePoint = TimePointEntity(context: viewContext, year: 2024, month: 7, day: 10, timepoint: .init(time: HourMinute(3, 33), type: .start))
        _timePoint = TimePointEntity(context: viewContext, year: 2024, month: 7, day: 10, timepoint: .init(time: HourMinute(6, 12), type: .start))
        _timePoint = TimePointEntity(context: viewContext, year: 2024, month: 7, day: 10, timepoint: .init(time: HourMinute(7, 12), type: .start))
        _timePoint = TimePointEntity(context: viewContext, year: 2024, month: 7, day: 10, timepoint: .init(time: HourMinute(8, 30), type: .end))
        _timePoint = TimePointEntity(context: viewContext, year: 2024, month: 7, day: 10, timepoint: .init(time: HourMinute(9, 12), type: .start))
        _timePoint = TimePointEntity(context: viewContext, year: 2024, month: 7, day: 10, timepoint: .init(time: HourMinute(11, 31), type: .end))
        _timePoint = TimePointEntity(context: viewContext, year: 2024, month: 7, day: 10, timepoint: .init(time: HourMinute(12, 12), type: .end))
        _timePoint = TimePointEntity(context: viewContext, year: 2024, month: 7, day: 10, timepoint: .init(time: HourMinute(12, 31), type: .start))
        _timePoint = TimePointEntity(context: viewContext, year: 2024, month: 7, day: 10, timepoint: .init(time: HourMinute(15, 31), type: .end))
        _timePoint = TimePointEntity(context: viewContext, year: 2024, month: 7, day: 10, timepoint: .init(time: HourMinute(15, 52), type: .end))
        _timePoint = TimePointEntity(context: viewContext, year: 2024, month: 7, day: 10, timepoint: .init(time: HourMinute(17, 52), type: .start))
        _timePoint = TimePointEntity(context: viewContext, year: 2024, month: 7, day: 10, timepoint: .init(time: HourMinute(23, 28), type: .end))
        _timePoint = TimePointEntity(context: viewContext, year: 2024, month: 7, day: 10, timepoint: .init(time: HourMinute(23, 55), type: .start))

        var _Income: IncomeEntity
        _Income = IncomeEntity(context: viewContext, income: .init(year: 2024, month: 7, name: "工资", money: 18000))
        _Income = IncomeEntity(context: viewContext, income: .init(year: 2024, month: 7, name: "副业1", money: 4000))
        _Income = IncomeEntity(context: viewContext, income: .init(year: 2024, month: 7, name: "副业2", money: 5000))
        _Income = IncomeEntity(context: viewContext, income: .init(year: 2024, month: 6, name: "工资", money: 18000))
        _Income = IncomeEntity(context: viewContext, income: .init(year: 2024, month: 6, name: "副业", money: 6000))

        var _IncomeTemplate: IncomeTemplateEntity
        _IncomeTemplate = IncomeTemplateEntity(context: viewContext, incomeTemplate: .init(name: "工资", money: 8000))

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "WorkTrace")
        if inMemory {
            container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: URL(fileURLWithPath: "/dev/null"))]
        }

        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    var incomeEntitys: [IncomeEntity] {
        let managedContext = container.viewContext
        let fetchRequest = IncomeEntity.fetchRequest()

        var res: [IncomeEntity]
        do {
            res = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
        return res
    }

    var incomeTemplateEntitys: [IncomeTemplateEntity] {
        let managedContext = container.viewContext
        let fetchRequest = IncomeTemplateEntity.fetchRequest()

        var res: [IncomeTemplateEntity]
        do {
            res = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
        return res
    }

    var timePointEntitys: [TimePointEntity] {
        let managedContext = container.viewContext
        let fetchRequest = TimePointEntity.fetchRequest()

        var res: [TimePointEntity]
        do {
            res = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
        return res
    }

    static func storeURL(databaseName: String) -> URL {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Shared file container could not be created.")
        }

        return documentsURL.appendingPathComponent("\(databaseName).sqlite")
    }
  
  mutating func deleteIncome(_ id: UUID)  {
    let entity = incomeEntitys.first { entity in
      entity.id == id
    }
    
    if let entity = entity {
      container.viewContext.delete(entity)
    }
    
    save()
  }
  
  mutating func deleteIncomeTemplate(_ id: UUID) {
    let entity = incomeTemplateEntitys.first { entity in
      entity.id == id
    }
    
    if let entity = entity {
      container.viewContext.delete(entity)
    }
    save()
  }
  
  mutating func deleteTimepoint(_ id: UUID) {
    let entity = timePointEntitys.first { entity in
      entity.id == id
    }
    
    if let entity = entity {
      container.viewContext.delete(entity)
    }
    save()
  }

    func save() {
        let viewContext = container.viewContext

        if !viewContext.hasChanges {
            return
        }

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

//        WidgetCenter.shared.reloadAllTimelines()
    }
}
