//
//  IncomeTemplateEntity.swift
//  WorkTrace
//
//  Created by 应俊康 on 2024/7/5.
//

import CoreData

extension IncomeTemplateEntity {
    convenience init(incomeTemplate: IncomeTemplate) {
        self.init(context: Persistence.shared.container.viewContext, incomeTemplate: incomeTemplate)
    }

    convenience init(context: NSManagedObjectContext, incomeTemplate: IncomeTemplate) {
        self.init(context: context)
        id = incomeTemplate.id
        name = incomeTemplate.name
        money = Int32(incomeTemplate.money)
        startYear = Int32(incomeTemplate.startYear)
        startMonth = Int32(incomeTemplate.startMonth)
        createDate = incomeTemplate.createDate
    }

    var incomeTemplate: IncomeTemplate {
        return IncomeTemplate(id: id ?? UUID(), name: name ?? "", money: Int(money), startYear: Int(startYear), startMonth: Int(startMonth), createDate: createDate ?? Date.now)
    }
}
