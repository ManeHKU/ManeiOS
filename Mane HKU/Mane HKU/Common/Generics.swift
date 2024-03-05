//
//  Generics.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 5/3/2024.
//

import Foundation

typealias SemesterDict<T> = [Semester: T]
typealias SemesterDictArray<T> = SemesterDict<[T]>

typealias YearSemesterDict<T> = [String: SemesterDict<T>]
typealias YearSemesterDictArray<T> = [String: SemesterDictArray<T>]
