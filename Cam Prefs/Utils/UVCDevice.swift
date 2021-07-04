//
//  UVCDevice.swift
//  Cam Prefs
//
//  Created by scchn on 2021/6/29.
//

import Foundation

extension UVCDevice {
    
    enum ValueType {
        case min, max
        case def, cur
        
        fileprivate var request: uvc_req_code {
            switch self {
            case .min: return UVC_GET_MIN
            case .max: return UVC_GET_MAX
            case .def: return UVC_GET_DEF
            case .cur: return UVC_GET_CUR
            }
        }
    }
    
    enum StateType {
        case def, cur
        
        fileprivate var request: uvc_req_code {
            switch self {
            case .def: return UVC_GET_DEF
            case .cur: return UVC_GET_CUR
            }
        }
    }
    
    enum AutoExposureMode: UInt8, CaseIterable {
        case manual           = 1
        case auto             = 2
        case shutterPriority  = 4
        case aperturePriority = 8
    }
    
}

class UVCDevice {
    
    private let device: OpaquePointer
    private let device_handle: OpaquePointer
    private var device_descriptor_pointer: UnsafeMutablePointer<uvc_device_descriptor_t>?
    private var device_descriptor: uvc_device_descriptor_t? { device_descriptor_pointer?.pointee }
    
    var productName: String? {
        guard let cName = device_descriptor?.product else { return nil }
        return String(cString: cName)
    }
    
    deinit {
        if let descriptor = device_descriptor_pointer {
            uvc_free_device_descriptor(descriptor)
        }
        uvc_unref_device(device)
    }
    
    init?(device: OpaquePointer) {
        var device_handle: OpaquePointer?
        guard uvc_open(device, &device_handle) == UVC_SUCCESS,
              let device_handle = device_handle
        else { return nil }
        
        self.device = device
        self.device_handle = device_handle
        
        uvc_get_device_descriptor(device, &device_descriptor_pointer)
    }
    
    // MARK: - Brightness
    
    func getBrightness(type: ValueType) -> Int? {
        var value: Int16 = 0
        return uvc_get_brightness(device_handle, &value, type.request) == UVC_SUCCESS ? Int(value) : nil
    }
    
    @discardableResult
    func setBrightness(_ value: Int) -> Bool {
        uvc_set_brightness(device_handle, Int16(value)) == UVC_SUCCESS
    }
    
    // MARK: - Contrast
    
    func getAutoContrast(type: StateType) -> Bool? {
        var value: UInt8 = 0
        return uvc_get_contrast_auto(device_handle, &value, type.request) == UVC_SUCCESS ? value != 0 : nil
    }
    
    @discardableResult
    func setAutoContrast(_ state: Bool) -> Bool {
        uvc_set_contrast_auto(device_handle, state ? 1 : 0) == UVC_SUCCESS
    }
    
    func getContrast(type: ValueType) -> Int? {
        var value: UInt16 = 0
        return uvc_get_contrast(device_handle, &value, type.request) == UVC_SUCCESS ? Int(value) : nil
    }
    
    @discardableResult
    func setContrast(_ value: Int) -> Bool {
        uvc_set_contrast(device_handle, UInt16(value)) == UVC_SUCCESS
    }
    
    // MARK: - Sharpness
    
    func getSharpness(type: ValueType) -> Int? {
        var value: UInt16 = 0
        return uvc_get_sharpness(device_handle, &value, type.request) == UVC_SUCCESS ? Int(value) : nil
    }
    
    @discardableResult
    func setSharpness(_ value: Int) -> Bool {
        uvc_set_sharpness(device_handle, UInt16(value)) == UVC_SUCCESS
    }
    
    // MARK: - Saturation
    
    func getSaturation(type: ValueType) -> Int? {
        var value: UInt16 = 0
        return uvc_get_saturation(device_handle, &value, type.request) == UVC_SUCCESS ? Int(value) : nil
    }
    
    @discardableResult
    func setSaturation(_ value: Int) -> Bool {
        uvc_set_saturation(device_handle, UInt16(value)) == UVC_SUCCESS
    }
    
    // MARK: - Gamma
    
    func getGamma(type: ValueType) -> Int? {
        var value: UInt16 = 0
        return uvc_get_gamma(device_handle, &value, type.request) == UVC_SUCCESS ? Int(value) : nil
    }
    
    @discardableResult
    func setGamma(_ value: Int) -> Bool {
        uvc_set_gamma(device_handle, UInt16(value)) == UVC_SUCCESS
    }
    
    // MARK: - HUE
    
    func getAutoHue(type: StateType) -> Bool? {
        var state: UInt8 = 0
        return uvc_get_hue_auto(device_handle, &state, type.request) == UVC_SUCCESS ? state != 0 : nil
    }
    
    @discardableResult
    func setAutoHue(_ state: Bool) -> Bool {
        uvc_set_hue_auto(device_handle, state ? 1 : 0) == UVC_SUCCESS
    }
    
    func getHue(type: ValueType) -> Int? {
        var value: Int16 = 0
        return uvc_get_hue(device_handle, &value, type.request) == UVC_SUCCESS ? Int(value) : nil
    }
    
    @discardableResult
    func setHue(_ value: Int) -> Bool {
        uvc_set_hue(device_handle, Int16(value)) == UVC_SUCCESS
    }
    
    // MARK: - Exposure
    
    func getAutoExposureMode(type: StateType) -> AutoExposureMode? {
        var value: UInt8 = 0
        return uvc_get_ae_mode(device_handle, &value, type.request) == UVC_SUCCESS ? AutoExposureMode(rawValue: value) : nil
    }
    
    @discardableResult
    func setAutoExposureMode(_ mode: AutoExposureMode) -> Bool {
        uvc_set_ae_mode(device_handle, mode.rawValue) == UVC_SUCCESS
    }
    
    func getAutoExposureModeIndex(type: ValueType) -> Int? {
        switch type {
        case .min: return 0
        case .max: return 3
        case .def:
            guard let mode = getAutoExposureMode(type: .def) else { return nil }
            return AutoExposureMode.allCases.firstIndex(of: mode)
        case .cur:
            guard let mode = getAutoExposureMode(type: .cur) else { return nil }
            return AutoExposureMode.allCases.firstIndex(of: mode)
        }
    }
    
    func setAutoExposureModeWithIndex(_ index: Int) -> Bool {
        guard (0..<AutoExposureMode.allCases.count).contains(index) else { return false }
        let mode = AutoExposureMode.allCases[index]
        return setAutoExposureMode(mode)
    }
    
    func getExposureAbs(type: ValueType) -> Int? {
        var value: UInt32 = 0
        return uvc_get_exposure_abs(device_handle, &value, type.request) == UVC_SUCCESS ? Int(value) : nil
    }
    
    @discardableResult
    func setExposureAbs(_ value: Int) -> Bool {
        uvc_set_exposure_abs(device_handle, UInt32(value)) == UVC_SUCCESS
    }
    
    // MARK: - Gain
    
    func getGain(type: ValueType) -> Int? {
        var value: UInt16 = 0
        return uvc_get_gain(device_handle, &value, type.request) == UVC_SUCCESS ? Int(value) : nil
    }
    
    @discardableResult
    func setGain(_ value: Int) -> Bool {
        uvc_set_gain(device_handle, UInt16(value)) == UVC_SUCCESS
    }
    
    // MARK: - White Balance
    
    func getAutoWhiteBalanceTemp(type: StateType) -> Bool? {
        var value: UInt8 = 0
        return uvc_get_white_balance_temperature_auto(device_handle, &value, type.request) == UVC_SUCCESS ? value != 0 : nil
    }
    
    @discardableResult
    func setAutoWhiteBalanceTemp(_ state: Bool) -> Bool {
        uvc_set_white_balance_temperature_auto(device_handle, state ? 1 : 0) == UVC_SUCCESS
    }
    
    func getWhiteBalanceTemp(type: ValueType) -> Int? {
        var value: UInt16 = 0
        return uvc_get_white_balance_temperature(device_handle, &value, type.request) == UVC_SUCCESS ? Int(value) : nil
    }
    
    @discardableResult
    func setWhiteBalanceTemp(_ value: Int) -> Bool {
        uvc_set_white_balance_temperature(device_handle, UInt16(value)) == UVC_SUCCESS
    }
    
    // MARK: - Focus
    
    func getAutoFocus(type: StateType) -> Bool? {
        var value: UInt8 = 0
        return uvc_get_focus_auto(device_handle, &value, type.request) == UVC_SUCCESS ? value != 0 : nil
    }
    
    @discardableResult
    func setAutoFocus(_ state: Bool) -> Bool {
        uvc_set_focus_auto(device_handle, state ? 1 : 0) == UVC_SUCCESS
    }
    
    func getFocusAbs(type: ValueType) -> Int? {
        var value: UInt16 = 0
        return uvc_get_focus_abs(device_handle, &value, type.request) == UVC_SUCCESS ? Int(value) : nil
    }
    
    @discardableResult
    func setFocusAbs(_ value: Int) -> Bool {
        uvc_set_focus_abs(device_handle, UInt16(value)) == UVC_SUCCESS
    }
    
    // MARK: - Zoom
    
    func getZoomAbs(type: ValueType) -> Int? {
        var value: UInt16 = 0
        return uvc_get_zoom_abs(device_handle, &value, type.request) == UVC_SUCCESS ? Int(value) : nil
    }
    
    @discardableResult
    func setZoomAbs(_ value: Int) -> Bool {
        uvc_set_zoom_abs(device_handle, UInt16(value)) == UVC_SUCCESS
    }
    
    // MARK: - Pan & Tilt
    
    func getPanTilt(type: ValueType) -> (pan: Int, tilt: Int)? {
        var pan: Int32 = 0
        var tilt: Int32 = 0
        return uvc_get_pantilt_abs(device_handle, &pan, &tilt, type.request) == UVC_SUCCESS ? (Int(pan), Int(tilt)) : nil
    }
    
    @discardableResult
    func setPanTilt(_ pan: Int, _ tilt: Int) -> Bool {
        uvc_set_pantilt_abs(device_handle, Int32(pan), Int32(tilt)) == UVC_SUCCESS
    }
    
    func getPan(type: ValueType) -> Int? {
        getPanTilt(type: type)?.pan
    }
    
    @discardableResult
    func setPan(_ value: Int) -> Bool {
        guard let (_, tilt) = getPanTilt(type: .cur) else { return false }
        return setPanTilt(value, tilt)
    }
    
    func getTilt(type: ValueType) -> Int? {
        getPanTilt(type: type)?.tilt
    }
    
    @discardableResult
    func setTilt(_ value: Int) -> Bool {
        guard let (pan, _) = getPanTilt(type: .cur) else { return false }
        return setPanTilt(pan, value)
    }
    
    // MARK: - Backlight Compensation
    
    func getBacklightCompensation(type: ValueType) -> Int? {
        var value: UInt16 = 0
        return uvc_get_backlight_compensation(device_handle, &value, type.request) == UVC_SUCCESS ? Int(value) : nil
    }
    
    @discardableResult
    func setBacklightCompensation(_ value: Int) -> Bool {
        uvc_set_backlight_compensation(device_handle, UInt16(value)) == UVC_SUCCESS
    }
    
    // MARK: - Power-Line Frequency
    
    func getPowerLineFrequency(type: ValueType) -> Int? {
        var value: UInt8 = 0
        return uvc_get_power_line_frequency(device_handle, &value, type.request) == UVC_SUCCESS ? Int(value) : nil
    }
    
    @discardableResult
    func setPowerLineFrequency(_ value: Int) -> Bool {
        uvc_set_power_line_frequency(device_handle, UInt8(value)) == UVC_SUCCESS
    }
    
    // MARK: - Reset
    
    func resetAll() {
        if let value = getBrightness(type: .def)            { setBrightness(value) }
        if let value = getContrast(type: .def)              { setContrast(value) }
        if let value = getSharpness(type: .def)             { setSharpness(value) }
        if let value = getSaturation(type: .def)            { setSaturation(value) }
        if let value = getGamma(type: .def)                 { setGamma(value) }
        if let value = getHue(type: .def)                   { setHue(value) }
        if let value = getExposureAbs(type: .def)           { setExposureAbs(value) }
        if let value = getGain(type: .def)                  { setGain(value) }
        if let value = getWhiteBalanceTemp(type: .def)      { setWhiteBalanceTemp(value) }
        if let value = getFocusAbs(type: .def)              { setFocusAbs(value) }
        if let value = getBacklightCompensation(type: .def) { setBacklightCompensation(value) }
        if let value = getPowerLineFrequency(type: .def)    { setPowerLineFrequency(value) }
        if let value = getZoomAbs(type: .def)               { setZoomAbs(value) }
        if let value = getPanTilt(type: .def)               { setPanTilt(value.pan, value.tilt) }
        if let value = getAutoContrast(type: .def)          { setAutoContrast(value) }
        if let value = getAutoHue(type: .def)               { setAutoHue(value) }
        if let value = getAutoExposureMode(type: .def)      { setAutoExposureMode(value) }
        if let value = getAutoWhiteBalanceTemp(type: .def)  { setAutoWhiteBalanceTemp(value) }
        if let value = getAutoFocus(type: .def)             { setAutoFocus(value) }
    }
    
}
