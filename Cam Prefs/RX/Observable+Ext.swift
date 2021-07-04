//
//  Observable+Ext.swift
//  
//
//  Created by scchn on 2021/4/15.
//

import Foundation

import RxSwift
import RxCocoa

extension ObservableType where Element == Bool {
    
    func not() -> Observable<Bool> {
        map(!)
    }
    
}

extension ObservableType {
    
    func mapToRawValue() -> Observable<Element.RawValue> where Element: RawRepresentable {
        asObservable().map(\.rawValue)
    }
    
    func catchErrorJustComplete() -> Observable<Element> {
        `catch` { _ in .empty() }
    }
    
    func asDriverOnErrorJustComplete() -> Driver<Element> {
        asDriver { _ in .empty() }
    }
    
    func mapToVoid() -> Observable<Void> {
        map { _ in }
    }
    
    #if DEBUG
    func printNext() -> Observable<Element> {
        `do`(onNext: { print($0) })
    }
    #endif
    
}
