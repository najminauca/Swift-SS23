//
//  DatabaseService.swift
//  ProductApp
//
//  Created by Najmi Antariksa on 20.06.23.
//

import Foundation
class DatabaseService: ObservableObject {
    let queue: DatabaseQueue
    
    init(inMemory: Bool) {
        if inMemory {
            queue = try! DatabaseQueue(path: ":memory:")
        } else {
            let documentsDirectory = try! FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let databaseUrl = documentsDirectory.appendingPathComponent("database.sqlite")
            let databasePath = databaseUrl.absoluteString
            print("Database Path: \(databasePath)")
            queue = try! DatabaseQueue(path: databasePath)
        }
        
        var migrator: DatabaseMigrator = DatabaseMigrator()
        
        migrator.registerMigration("V1") { db in
            try db.create(table: "Course") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("title", .text).notNull()
                t.column("identifier", .text).notNull().unique()
            }
            try db.create(table: "Student") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("given_name", .text).notNull()
                t.column("family_name", .text).notNull()
                t.column("matrikel_nr", .text).notNull().unique()
            }
            try db.create(table: "Teacher") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("given_name", .text).notNull()
                t.column("family_name", .text).notNull()
            }
            try db.create(table: "Exam") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("grade", .real).notNull()
                t.column("date", .date).notNull()
                t.column("course_id", .integer).notNull()
                    .indexed()
                    .references("Course", onDelete: .cascade)
                t.column("student_id", .integer).notNull()
                    .indexed()
                    .references("Student", onDelete: .cascade)
            }
            try db.create(table: "Exam_Teacher") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("exam_id", .integer).notNull()
                    .indexed()
                    .references("Exam", onDelete: .cascade)
                t.column("teacher_id", .integer).notNull()
                    .indexed()
                    .references("Teacher", onDelete: .cascade)
            }
        }
        try! migrator.migrate(queue)
        
        if inMemory {
            addTestData()
        }
    }
    
    func addTestData() {
        var student = Student(given_name: "Max", family_name: "Mustermann", matrikel_nr: "1234567")
        var teacher1 = Teacher(given_name: "Samuel", family_name: "Schepp")
        var teacher2 = Teacher(given_name: "Kevin", family_name: "Linne")
        var course1 = Course(title: "Webbasierte Systeme 2", identifier: "IT2000")
        var course2 = Course(title: "Swift-Programmierung unter iOS", identifier: "CS2365")
        var course3 = Course(title: "Webbasierte Programmierung 2", identifier: "IT1002")
        
        try! queue.write { db in
            student = try! student.saveAndFetch(db)!
            teacher1 = try! teacher1.saveAndFetch(db)!
            teacher2 = try! teacher2.saveAndFetch(db)!
            course1 = try! course1.saveAndFetch(db)!
            course2 = try! course2.saveAndFetch(db)!
            course3 = try! course3.saveAndFetch(db)!
            
            var exam1 = Exam(grade: 2.4, date: DateComponents(calendar: Calendar.current, year: 2023, month: 4, day: 30).date!, course_id: course1.id, student_id: student.id)
            var exam2 = Exam(grade: 1.3, date: DateComponents(calendar: Calendar.current, year: 2023, month: 4, day: 31).date!, course_id: course2.id, student_id: student.id)
            var exam3 = Exam(grade: 1.1, date: DateComponents(calendar: Calendar.current, year: 2023, month: 5, day: 2).date!, course_id: course3.id, student_id: student.id)
            
            exam1 = try! exam1.saveAndFetch(db)!
            exam2 = try! exam2.saveAndFetch(db)!
            exam3 = try! exam3.saveAndFetch(db)!
            
            let exam1_teacher1 = Exam_Teacher(exam_id: exam1.course_id, teacher_id: teacher1.id)
            let exam2_teacher1 = Exam_Teacher(exam_id: exam2.course_id, teacher_id: teacher1.id)
            let exam2_teacher2 = Exam_Teacher(exam_id: exam2.course_id, teacher_id: teacher2.id)
            let exam3_teacher2 = Exam_Teacher(exam_id: exam3.course_id, teacher_id: teacher2.id)
            
            try! exam1_teacher1.insert(db)
            try! exam2_teacher1.insert(db)
            try! exam2_teacher2.insert(db)
            try! exam3_teacher2.insert(db)
        }
    }
}
