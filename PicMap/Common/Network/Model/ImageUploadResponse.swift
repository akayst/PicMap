//
//  ImageUploadResponse.swift
//  PicMap
//
//  Created by 송준기 on 2023/06/01.
//

import Foundation

struct ImageUploadResponse: Codable {
	let imageUrl: String
	let imagesPath: String
	let originName: String
	let recordId: Int
	let userId: String
}
