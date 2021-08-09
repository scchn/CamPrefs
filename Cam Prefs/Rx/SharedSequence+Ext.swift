//
//  SharedSequence+Ext.swift
//  
//
//  Created by scchn on 2021/4/15.
//

import Foundation

import RxSwift
import RxCocoa

extension SharedSequence where Element == Bool {
    
    func not() -> SharedSequence<SharingStrategy, Bool> {
        map(!)
    }
    
}

extension SharedSequenceConvertibleType {
    
    func mapToVoid() -> SharedSequence<SharingStrategy, Void> {
        map { _ in }
    }
    
    #if DEBUG
    func printNext() -> SharedSequence<SharingStrategy, Element> {
        `do`(onNext: { print($0) })
    }
    #endif
    
}
