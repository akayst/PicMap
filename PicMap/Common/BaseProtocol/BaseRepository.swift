//
//  BaseRepository.swift
//  PicMap
//
//  Created by 김진형 on 2023/06/02.
//

import Foundation
import Combine

protocol BaseRepository {
    associatedtype Input
    associatedtype Output
    
    var input: PassthroughSubject<Input, Never> { get }
    var output: PassthroughSubject<Output, Never> { get }
}
