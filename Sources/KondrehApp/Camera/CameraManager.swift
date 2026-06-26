import AVFoundation
import Combine
import KondrehCore

final class CameraManager: NSObject, ObservableObject, @unchecked Sendable {
    @Published private(set) var state: CameraSessionState = .idle
    @Published private(set) var devices: [CameraDevice] = []
    @Published private(set) var activeDeviceID: String?

    let session = AVCaptureSession()

    private let settings: SettingsService
    // AVFoundation session mutation is serialized through this queue; UI state is published back on the main actor.
    private let sessionQueue = DispatchQueue(label: "com.codewithbro.kondreh.camera.session")
    private var currentInput: AVCaptureDeviceInput?
    private var wantsRunning = false
    private var deviceObservers: [NSObjectProtocol] = []

    @MainActor
    init(settings: SettingsService) {
        self.settings = settings
        super.init()
        observeDeviceChanges()
        refreshDevices()
    }

    deinit {
        for observer in deviceObservers {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    @MainActor
    func refreshDevices() {
        state = .discoveringDevices
        let discovered = Self.discoverDevices()
        devices = discovered.map(CameraDevice.init(device:))
        if devices.isEmpty {
            state = .noDevice
        } else if state == .discoveringDevices {
            state = session.isRunning ? .running : .idle
        }
    }

    @MainActor
    func start() {
        guard wantsRunning == false else { return }
        wantsRunning = true

        switch CameraAuthorizationService().currentState() {
        case .authorized:
            startAuthorized()
        case .notDetermined:
            state = .requestingPermission
        case .denied:
            state = .permissionDenied
        case .restricted:
            state = .permissionRestricted
        }
    }

    @MainActor
    func stop() {
        wantsRunning = false
        state = .stopping
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
            self.session.beginConfiguration()
            if let input = self.currentInput {
                self.session.removeInput(input)
                self.currentInput = nil
            }
            self.session.commitConfiguration()
            Task { @MainActor in
                self.activeDeviceID = nil
                self.state = .idle
            }
        }
    }

    @MainActor
    func requestPermissionAndStart() {
        state = .requestingPermission
        Task {
            let result = await CameraAuthorizationService().requestAccess()
            switch result {
            case .authorized:
                startAuthorized()
            case .denied:
                wantsRunning = false
                state = .permissionDenied
            case .restricted:
                wantsRunning = false
                state = .permissionRestricted
            case .notDetermined:
                wantsRunning = false
                state = .requestingPermission
            }
        }
    }

    @MainActor
    func switchCamera(to id: String) {
        settings.selectedCameraID = id
        guard wantsRunning else {
            activeDeviceID = id
            return
        }
        state = .switchingDevice
        configureAndStart(selectedID: id)
    }

    @MainActor
    private func startAuthorized() {
        refreshDevices()
        guard devices.isEmpty == false else {
            wantsRunning = false
            state = .noDevice
            return
        }
        state = .starting
        configureAndStart(selectedID: settings.selectedCameraID)
    }

    @MainActor
    private func configureAndStart(selectedID: String?) {
        let fallbackID = CameraDeviceSelector.preferredDevice(
            from: devices,
            selectedID: selectedID,
            reopenLastSelectedCamera: settings.reopenLastSelectedCamera
        )?.id
        let preset = settings.preferredQuality.captureSessionPreset

        sessionQueue.async { [weak self] in
            guard let self else { return }

            guard let device = Self.avDevice(with: fallbackID) ?? AVCaptureDevice.default(for: .video) else {
                Task { @MainActor in
                    self.wantsRunning = false
                    self.state = .noDevice
                }
                return
            }

            do {
                let input = try AVCaptureDeviceInput(device: device)
                self.session.beginConfiguration()
                self.session.sessionPreset = self.session.canSetSessionPreset(preset) ? preset : .medium
                if let currentInput = self.currentInput {
                    self.session.removeInput(currentInput)
                }
                guard self.session.canAddInput(input) else {
                    self.session.commitConfiguration()
                    throw CameraSessionError.cannotAddInput
                }
                self.session.addInput(input)
                self.currentInput = input
                self.session.commitConfiguration()

                if self.session.isRunning == false {
                    self.session.startRunning()
                }

                Task { @MainActor in
                    self.activeDeviceID = device.uniqueID
                    self.settings.selectedCameraID = device.uniqueID
                    self.state = .running
                }
            } catch {
                AppLogger.camera.error("Camera start failed: \(String(describing: error), privacy: .public)")
                Task { @MainActor in
                    self.wantsRunning = false
                    self.state = .failed(CameraSessionError.configurationFailed.localizedDescription)
                }
            }
        }
    }

    private func observeDeviceChanges() {
        let connected = NotificationCenter.default.addObserver(
            forName: .AVCaptureDeviceWasConnected,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.handleDeviceChange() }
        }

        let disconnected = NotificationCenter.default.addObserver(
            forName: .AVCaptureDeviceWasDisconnected,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.handleDeviceChange() }
        }

        deviceObservers = [connected, disconnected]
    }

    @MainActor
    private func handleDeviceChange() {
        refreshDevices()
        guard wantsRunning else { return }
        if let activeDeviceID, devices.contains(where: { $0.id == activeDeviceID }) == false {
            state = .switchingDevice
            configureAndStart(selectedID: nil)
        }
    }

    private static func discoverDevices() -> [AVCaptureDevice] {
        var deviceTypes: [AVCaptureDevice.DeviceType] = [.builtInWideAngleCamera, .externalUnknown]
        if #available(macOS 14.0, *) {
            deviceTypes.append(.external)
            deviceTypes.append(.continuityCamera)
        }
        let discovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: deviceTypes,
            mediaType: .video,
            position: .unspecified
        )
        return discovery.devices
    }

    private static func avDevice(with id: String?) -> AVCaptureDevice? {
        guard let id else { return nil }
        return discoverDevices().first(where: { $0.uniqueID == id })
    }
}

private extension CameraDevice {
    init(device: AVCaptureDevice) {
        let continuity: Bool
        if #available(macOS 14.0, *) {
            continuity = device.deviceType == .continuityCamera
        } else {
            continuity = false
        }
        self.init(
            id: device.uniqueID,
            name: device.localizedName,
            isContinuityCamera: continuity,
            isBuiltIn: device.deviceType == .builtInWideAngleCamera
        )
    }
}

private extension PreviewQuality {
    var captureSessionPreset: AVCaptureSession.Preset {
        switch self {
        case .efficient: .low
        case .balanced: .medium
        case .high: .high
        }
    }
}
