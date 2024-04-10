//
//  LazyView.swift
//  Mane HKU
//
//  Created by Yau Chin Pang on 11/4/2024.
//
// FROM: https://www.objc.io/blog/2019/07/02/lazy-loading/
//

import SwiftUI

struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
