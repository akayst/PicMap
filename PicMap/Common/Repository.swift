//
//  Repository.swift
//  PicMap
//
//  Created by 송준기 on 2023/05/27.
//

import Foundation

final class Repository {
	var userInfo: UserInfo
	var myPics: [PicData]
	var imgPics: [String]
	
	init() {
		let id = UserDefaults.standard.string(forKey: "userEmail") ?? ""
		userInfo = UserInfo(userId: id)
		myPics = []
		imgPics = []
	}
	
	
	func setUserInfo(_ userId: String) {
		if userId.isEmpty {
			UserDefaults.standard.removeObject(forKey: "userEmail")
		}
		UserDefaults.standard.set(userId, forKey: "userEmail")
		userInfo = UserInfo(userId: userId)
	}
	
	var userId: String {
		return userInfo.userId
	}
}
