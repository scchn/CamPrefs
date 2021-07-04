//
//  UVCDeviceViewController.swift
//  Cam Prefs
//
//  Created by chen on 2021/6/28.
//

import Cocoa
import AVFoundation

import RxSwift
import RxCocoa

class UVCDeviceViewController: NSViewController {
    
    @IBOutlet weak var titleLabel: NSTextField!
    // Tab
    @IBOutlet weak var tabSegmentedControl: NSSegmentedControl!
    @IBOutlet weak var tabView: NSTabView!
    
    // MARK: General
    @IBOutlet weak var brightnessSlider: NSSlider!
    @IBOutlet weak var contrastSlider: NSSlider!
    @IBOutlet weak var sharpnessSlider: NSSlider!
    @IBOutlet weak var saturationSlider: NSSlider!
    @IBOutlet weak var gammaSlider: NSSlider!
    @IBOutlet weak var hueSlider: NSSlider!
    // White Balance
    @IBOutlet weak var autoWhiteBalanceCheckbox: NSButton!
    @IBOutlet weak var whiteBalanceTempSlider: NSSlider!
    // Auto Exposure
    @IBOutlet weak var autoExposureModeSegmentedControl: NSSegmentedControl!
    @IBOutlet weak var exposureTimeSlider: NSSlider!
    @IBOutlet weak var gainSlider: NSSlider!
    // MARK: Advanced
    @IBOutlet weak var zoomSlider: NSSlider!
    @IBOutlet weak var panSlider: NSSlider!
    @IBOutlet weak var tiltSlider: NSSlider!
    @IBOutlet weak var backlightCompensationSegmentedControl: NSSegmentedControl!
    @IBOutlet weak var powerLineFrequencySegmentedControl: NSSegmentedControl!
    // Focus
    @IBOutlet weak var autoFocusCheckbox: NSButton!
    @IBOutlet weak var focalLengthSlider: NSSlider!
    // Preview
    @IBOutlet weak var previewButton: NSButton!
    @IBOutlet weak var previewView: NSView!
    
    private let disposeBag = DisposeBag()
    private let forceRefresh = PublishRelay<Void>()
    
    var viewModel: UVCDeviceViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.stringValue = viewModel.title
        tabSegmentedControl.selectedSegment = 0
        tabView.selectTabViewItem(at: 0)
        tabView.tabViewType = .noTabsBezelBorder
        
        previewView.layer = CALayer()
        previewView.wantsLayer = true
        previewView.layer?.cornerRadius = 8
        previewView.layer?.backgroundColor = .black
        
        disposeBag.insert([
            viewModel.mode.map(\.image).bind(to: previewButton.rx.image),
            viewModel.mode.map(\.size).bind(to: self.rx.preferredContentSize),
        ])
        
        setupSliders()
        setupCheckboxes()
        setupSegmentedControls()
        setupRefresh()
    }
        
    private func setupSliders() {
        for (control, slider) in slidersForRangeControls {
            guard let range = viewModel.getRange(for: control) else {
                slider.setRange(0...0)
                slider.isEnabled = false
                continue
            }
            
            slider.isContinuous = true
            slider.setRange(range)
            slider.rx.selectIntegerValue
                .subscribe(onNext: { [weak self] value in
                    guard let self = self else { return }
                    self.viewModel.setValue(value, for: control)
                })
                .disposed(by: disposeBag)
        }
    }
        
    private func setupCheckboxes() {
        for (control, checkbox) in checkboxesForStateControls {
            guard let state = viewModel.getState(for: control) else {
                checkbox.state = .off
                checkbox.isEnabled = false
                continue
            }
            
            checkbox.state = state ? .on : .off
            checkbox.rx.toggle
                .subscribe(onNext: { [weak self] on in
                    guard let self = self else { return }
                    self.viewModel.setState(on, for: control)
                    self.forceRefresh.accept(())
                })
                .disposed(by: disposeBag)
        }
    }
    
    private func setupSegmentedControls() {
        for (control, segmentedControl) in segmentedControlsForRangeControl {
            guard let range = viewModel.getRange(for: control) else {
                segmentedControl.selectedSegment = -1
                segmentedControl.isEnabled = false
                continue
            }
            
            for segment in 0..<segmentedControl.segmentCount {
                segmentedControl.setEnabled(range.contains(segment), forSegment: segment)
            }
            
            segmentedControl.rx.select
                .subscribe(onNext: { [weak self] segment in
                    guard let self = self else { return }
                    if !self.viewModel.setValue(segment, for: control) {
                        self.showOptionError()
                    }
                    self.forceRefresh.accept(())
                })
                .disposed(by: disposeBag)
        }
    }
    
    private func setupRefresh() {
        let autoRefresh = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .mapToVoid()
            .startWith(())
        let forceRefresh = forceRefresh.asObservable()
        
        Observable.of(autoRefresh, forceRefresh).merge()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.refreshAllValues()
            })
            .disposed(by: disposeBag)
    }
        
    @objc
    private func refreshAllValues() {
        for (control, slider) in slidersForRangeControls {
            guard let value = viewModel.getValue(for: control),
                  value != slider.integerValue
            else { continue }
            slider.integerValue = value
        }
        
        for (control, checkbox) in checkboxesForStateControls {
            guard let state = viewModel.getState(for: control) else { continue }
            
            checkbox.state = state ? .on : .off
            
            switch control {
            case .autoWhiteBalanceTemp where whiteBalanceTempSlider.range.count > 1:
                whiteBalanceTempSlider.isEnabled = !state
            case .autoFocus where focalLengthSlider.range.count > 1:
                focalLengthSlider.isEnabled = !state
            default:
                break
            }
        }
        
        for (control, segmentedControl) in segmentedControlsForRangeControl {
            guard let index = viewModel.getValue(for: control) else { continue }
            
            let validRange = 0..<segmentedControl.segmentCount
            
            if validRange.contains(index) {
                segmentedControl.selectedSegment = index
            } else {
                segmentedControl.selectedSegment = -1
            }
            
            if control == .autoExposureMode {
                if exposureTimeSlider.range.count > 1 {
                    exposureTimeSlider.isEnabled = index == 0 || index == 2
                }
                if gainSlider.range.count > 1 {
                    gainSlider.isEnabled = index == 0
                }
            }
        }
    }
    
    // MARK: -
    
    private func showOptionError() {
        guard let window = view.window else { return }
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = NSLocalizedString("Unsupported_Option", comment: "不支援")
        alert.informativeText = ""
        alert.beginSheetModal(for: window)
    }
    
    private func showAccessError() {
        guard let window = view.window else { return }
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = NSLocalizedString("Permission_Denied.Title", comment: "")
        alert.informativeText = NSLocalizedString("Permission_Denied.Message", comment: "")
        alert.addButton(withTitle: NSLocalizedString("Open_System_Preferences", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("OK", comment: ""))
        alert.beginSheetModal(for: window) { response in
            guard response == .alertFirstButtonReturn else { return }
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera")!
            NSWorkspace.shared.open(url)
        }
    }
    
    private func showCameraError() {
        guard let window = view.window else { return }
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = NSLocalizedString("Create_Input_Failed", comment: "")
        alert.informativeText = ""
        alert.beginSheetModal(for: window)
    }
    
    private func requestCameraAccess(_ completionHandler: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { ok in
            DispatchQueue.main.async {
                completionHandler(ok)
            }
        }
    }
    
    // MARK: - UI Actions
    
    @IBAction func tabSegmentedControlAction(_ sender: NSSegmentedControl) {
        tabView.selectTabViewItem(at: sender.indexOfSelectedItem)
    }
    
    @IBAction func resetButtonAction(_ sender: Any) {
        viewModel.resetToDefault()
        forceRefresh.accept(())
    }
        
    @IBAction func previewButton(_ sender: Any) {
        requestCameraAccess { [weak self] ok in
            guard let self = self else { return }
            
            guard ok else {
                self.showAccessError()
                NSApp.activate(ignoringOtherApps: true)
                return
            }
            
            guard let previewLayer = self.viewModel.previewLayer else {
                self.showCameraError()
                NSApp.activate(ignoringOtherApps: true)
                return
            }
            
            NSApp.activate(ignoringOtherApps: true)
            
            if self.previewView.layer?.sublayers?.contains(previewLayer) != true {
                previewLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
                previewLayer.frame = self.previewView.bounds
                self.previewView.layer?.addSublayer(previewLayer)
            }
            
            self.viewModel.togglePreview()
        }
    }
    
}

extension UVCDeviceViewController {
    
    private var slidersForRangeControls: [UVCRangeControl: NSSlider] {
        [
            .brightness:    brightnessSlider,
            .contrast:      contrastSlider,
            .sharpness:     sharpnessSlider,
            .saturation:    saturationSlider,
            .gamma:         gammaSlider,
            .hue:           hueSlider,
            .whiteBalance:  whiteBalanceTempSlider,
            .focus:         focalLengthSlider,
            .zoom:          zoomSlider,
            .pan:           panSlider,
            .tilt:          tiltSlider,
            .exposureTime:  exposureTimeSlider,
            .gain:          gainSlider,
        ]
    }
    
    private var checkboxesForStateControls: [UVCStateControl: NSButton] {
        [
            .autoWhiteBalanceTemp: autoWhiteBalanceCheckbox,
            .autoFocus: autoFocusCheckbox,
        ]
    }
    
    private var segmentedControlsForRangeControl: [UVCRangeControl: NSSegmentedControl] {
        [
            .autoExposureMode: autoExposureModeSegmentedControl,
            .backlightCompensation: backlightCompensationSegmentedControl,
            .powerLineFrequency: powerLineFrequencySegmentedControl
        ]
    }
    
}
