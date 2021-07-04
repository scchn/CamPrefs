//
//  UVCDevice+Ext.swift
//  Cam Prefs
//
//  Created by scchn on 2021/6/29.
//

import Foundation

enum UVCRangeControl: CaseIterable {
    case brightness
    case contrast
    case saturation
    case sharpness
    case gamma
    case hue
    case whiteBalance
    case autoExposureMode
    case exposureTime
    case gain
    case zoom
    case pan
    case tilt
    case focus
    case backlightCompensation
    case powerLineFrequency
}

enum UVCStateControl: CaseIterable {
    case autoHue
    case autoFocus
    case autoWhiteBalanceTemp
}

extension UVCDevice {
    
    private func getValue(_ control: UVCRangeControl, type: ValueType) -> Int? {
        var getter: ((ValueType) -> Int?)
        
        switch control {
        case .brightness:               getter = getBrightness(type:)
        case .contrast:                 getter = getContrast(type:)
        case .saturation:               getter = getSaturation(type:)
        case .sharpness:                getter = getSharpness(type:)
        case .gamma:                    getter = getGamma(type:)
        case .hue:                      getter = getHue(type:)
        case .whiteBalance:             getter = getWhiteBalanceTemp(type:)
        case .autoExposureMode:         getter = getAutoExposureModeIndex(type:)
        case .exposureTime:             getter = getExposureAbs(type:)
        case .gain:                     getter = getGain(type:)
        case .zoom:                     getter = getZoomAbs(type:)
        case .pan:                      getter = getPan(type:)
        case .tilt:                     getter = getTilt(type:)
        case .focus:                    getter = getFocusAbs(type:)
        case .backlightCompensation:    getter = getBacklightCompensation(type:)
        case .powerLineFrequency:       getter = getPowerLineFrequency(type:)
        }
        
        return getter(type)
    }
    
    func getRange(_ control: UVCRangeControl) -> ClosedRange<Int>? {
        guard let min = getValue(control, type: .min),
              let max = getValue(control, type: .max)
        else { return nil }
        return min...max
    }
    
    func getValue(_ control: UVCRangeControl) -> Int? {
        getValue(control, type: .cur)
    }
    
    @discardableResult
    func setValue(_ value: Int, for control: UVCRangeControl) -> Bool {
        var setter: ((Int) -> Bool)
        
        switch control {
        case .brightness:               setter = setBrightness(_:)
        case .contrast:                 setter = setContrast(_:)
        case .saturation:               setter = setSaturation(_:)
        case .sharpness:                setter = setSharpness(_:)
        case .gamma:                    setter = setGamma(_:)
        case .hue:                      setter = setHue(_:)
        case .whiteBalance:             setter = setWhiteBalanceTemp(_:)
        case .autoExposureMode:         setter = setAutoExposureModeWithIndex(_:)
        case .exposureTime:             setter = setExposureAbs(_:)
        case .gain:                     setter = setGain(_:)
        case .zoom:                     setter = setZoomAbs(_:)
        case .pan:                      setter = setPan(_:)
        case .tilt:                     setter = setTilt(_:)
        case .focus:                    setter = setFocusAbs(_:)
        case .backlightCompensation:    setter = setBacklightCompensation(_:)
        case .powerLineFrequency:       setter = setPowerLineFrequency(_:)
        }
        
        return setter(value)
    }
    
}

extension UVCDevice {
    
    private func getState(_ control: UVCStateControl, type: StateType) -> Bool? {
        var getter: ((StateType) -> Bool?)
        
        switch control {
        case .autoHue:              getter = getAutoHue(type:)
        case .autoFocus:            getter = getAutoFocus(type:)
        case .autoWhiteBalanceTemp: getter = getAutoWhiteBalanceTemp(type:)
        }
        
        return getter(type)
    }
    
    func getState(_ control: UVCStateControl) -> Bool? {
        getState(control, type: .cur)
    }
    
    @discardableResult
    func setState(_ state: Bool, for control: UVCStateControl) -> Bool {
        var setter: ((Bool) -> Bool)
        
        switch control {
        case .autoHue:              setter = setAutoHue(_:)
        case .autoFocus:            setter = setAutoFocus(_:)
        case .autoWhiteBalanceTemp: setter = setAutoWhiteBalanceTemp(_:)
        }
        
        return setter(state)
    }
    
}
