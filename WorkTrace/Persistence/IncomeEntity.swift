//
//  IncomeEntity.swift
//  WorkTrace
//
//  Created by 应俊康 on 2024/7/5.
//

import CoreData
import Foundation

extension IncomeEntity {
    convenience init(income: Income) {
        self.init(context: Persistence.shared.container.viewContext, income: income)
    }
    
    convenience init(context: NSManagedObjectContext, income: Income) {
        self.init(context: context)
        id = income.id
        templateId = income.templateId
        year = Int32(income.year)
        month = Int32(income.month)
        name = income.name
        money = Int32(income.money)
    }

    var income: Income {
        return Income(id: id ?? UUID(), year: Int(year), month: Int(month), name: name ?? "", money: Int(money), templateId: templateId)
    }
}
