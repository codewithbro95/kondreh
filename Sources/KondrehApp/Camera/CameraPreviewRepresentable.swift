import AVFoundation
import KondrehCore
import SwiftUI

struct CameraPreviewRepresentable: NSViewRepresentable {
    let session: AVCaptureSession
    let mirrored: Bool

    func makeNSView(context: Context) -> CameraPreviewNSView {
        let view = CameraPreviewNSView()
        view.configure(session: session, mirrored: mirrored)
        return view
    }

    func updateNSView(_ nsView: CameraPreviewNSView, context: Context) {
        nsView.configure(session: session, mirrored: mirrored)
    }
}

final class CameraPreviewNSView: NSView {
    private var previewLayer: AVCaptureVideoPreviewLayer?

    override var wantsUpdateLayer: Bool { true }

    override func layout() {
        super.layout()
        previewLayer?.frame = bounds
    }

    func configure(session: AVCaptureSession, mirrored: Bool) {
        if previewLayer?.session !== session {
            previewLayer?.removeFromSuperlayer()
            let layer = AVCaptureVideoPreviewLayer(session: session)
            layer.videoGravity = .resizeAspectFill
            wantsLayer = true
            self.layer?.addSublayer(layer)
            previewLayer = layer
        }

        previewLayer?.frame = bounds
        previewLayer?.connection?.automaticallyAdjustsVideoMirroring = false
        if previewLayer?.connection?.isVideoMirroringSupported == true {
            previewLayer?.connection?.isVideoMirrored = mirrored
        }
    }
}
