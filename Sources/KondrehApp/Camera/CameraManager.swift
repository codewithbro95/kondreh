@preconcurrency import AVFoundation
import AppKit
import Combine
import KondrehCore

final class CameraManager: NSObject, ObservableObject, @unchecked Sendable {
    @Published private(set) var state: CameraSessionState = .idle
    @Published private(set) var devices: [CameraDevice] = []
    @Published private(set) var activeDeviceID: String?

    let session = AVCaptureSession()

    private let settings: SettingsService
    private let photoOutput = AVCapturePhotoOutput()
    // AVFoundation session mutation is serialized through this queue; UI state is published back on the main actor.
    private let sessionQueue = DispatchQueue(label: "com.codewithbro.kondreh.camera.session")
    private var currentInput: AVCaptureDeviceInput?
    private var photoDelegates: [QuickPhotoCaptureDelegate] = []
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
    func captureQuickPicture(completion: @escaping (Result<URL, Error>) -> Void) {
        guard state == .running, session.isRunning else {
            completion(.failure(QuickPictureError.cameraNotReady))
            return
        }

        var delegateRef: QuickPhotoCaptureDelegate?
        let delegate = QuickPhotoCaptureDelegate { [weak self] result in
            Task { @MainActor in
                if let self, let delegateRef {
                    self.photoDelegates.removeAll { $0 === delegateRef }
                }
                completion(result)
            }
        }
        delegateRef = delegate
        photoDelegates.append(delegate)

        sessionQueue.async { [weak self] in
            guard let self else { return }
            let photoSettings = AVCapturePhotoSettings()
            self.photoOutput.capturePhoto(with: photoSettings, delegate: delegate)
        }
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
                if self.session.outputs.contains(self.photoOutput) == false,
                   self.session.canAddOutput(self.photoOutput) {
                    self.session.addOutput(self.photoOutput)
                }
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

enum QuickPictureError: LocalizedError {
    case cameraNotReady
    case missingImageData
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .cameraNotReady:
            "Camera is not ready yet."
        case .missingImageData:
            "Could not read the captured image."
        case .saveFailed:
            "Could not save the picture."
        }
    }
}

private final class QuickPhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate, @unchecked Sendable {
    private let completion: (Result<URL, Error>) -> Void

    init(completion: @escaping (Result<URL, Error>) -> Void) {
        self.completion = completion
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error {
            completion(.failure(error))
            return
        }

        guard let data = photo.fileDataRepresentation() else {
            completion(.failure(QuickPictureError.missingImageData))
            return
        }

        do {
            let url = try Self.save(data: data)
            completion(.success(url))
        } catch {
            DispatchQueue.main.async {
                Self.askUserWhereToSave(data: data, completion: self.completion)
            }
        }
    }

    private static func save(data: Data) throws -> URL {
        let manager = FileManager.default
        let directories = [
            manager.urls(for: .picturesDirectory, in: .userDomainMask).first,
            manager.urls(for: .documentDirectory, in: .userDomainMask).first,
            manager.urls(for: .downloadsDirectory, in: .userDomainMask).first,
            manager.temporaryDirectory
        ].compactMap { $0 }

        var lastError: Error?
        for baseURL in directories {
            do {
                let directory = baseURL.appendingPathComponent("Kondreh", isDirectory: true)
                try manager.createDirectory(at: directory, withIntermediateDirectories: true)
                let url = directory.appendingPathComponent(filename())
                try data.write(to: url, options: .atomic)
                return url
            } catch {
                lastError = error
            }
        }

        throw lastError ?? QuickPictureError.saveFailed
    }

    @MainActor
    private static func askUserWhereToSave(data: Data, completion: @escaping (Result<URL, Error>) -> Void) {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = filename()
        panel.allowedContentTypes = [.jpeg]
        panel.canCreateDirectories = true
        panel.begin { response in
            guard response == .OK, let url = panel.url else {
                completion(.failure(QuickPictureError.saveFailed))
                return
            }

            do {
                try data.write(to: url, options: .atomic)
                completion(.success(url))
            } catch {
                completion(.failure(error))
            }
        }
    }

    private static func filename() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return "Kondreh-\(formatter.string(from: Date())).jpg"
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
