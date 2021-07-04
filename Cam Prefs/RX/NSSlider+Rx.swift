//
//  NSSlider+Rx.swift
//  Cam Prefs
//
//  Created by scchn on 2021/6/30.
//

import Cocoa

import RxSwift
import RxCocoa

extension Reactive where Base == NSSlider {
    
    var integerValue: ControlProperty<Int> {
        base.rx.controlProperty(
            getter: { $0.integerValue },
            setter: { $0.integerValue = $1 }
        )
    }
    
    var selectIntegerValue: ControlEvent<Int> {
        let select = controlEvent.map { base.integerValue }
        return .init(events: select)
    }
    
}
