//
//  Log.swift
//  CaregiverApp
//
//  Created by Christopher Jonathan on 04/06/26.
//

import UIKit

struct Log: Identifiable {

    let id: UUID
    let author: CareContact

    var content: String

    var images: [UIImage]

    var timestamp: Date

    init(
        id: UUID = UUID(),
        author: CareContact,
        content: String,
        images: [UIImage] = [],
        timestamp: Date = Date()
    ) {
        self.id = id
        self.author = author
        self.content = content
        self.images = images
        self.timestamp = timestamp
    }
}
