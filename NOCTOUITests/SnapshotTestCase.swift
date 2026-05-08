import SwiftUI
import UIKit
import XCTest

@MainActor
class SnapshotTestCase: XCTestCase {
    struct SnapshotViewport {
        let width: CGFloat
        let height: CGFloat
        let scale: CGFloat

        static let iPhone16Pro = SnapshotViewport(width: 393, height: 852, scale: 3)
        static let lockScreenCard = SnapshotViewport(width: 360, height: 180, scale: 3)
        static let dynamicIslandExpanded = SnapshotViewport(width: 360, height: 120, scale: 3)
    }

    private var recordMode: Bool {
        let environment = ProcessInfo.processInfo.environment
        return environment["NOCTO_RECORD_SNAPSHOTS"] == "1" ||
            environment["TEST_RUNNER_NOCTO_RECORD_SNAPSHOTS"] == "1" ||
            ProcessInfo.processInfo.arguments.contains("--record-snapshots")
    }
    private let mismatchThresholdPerChannel = 2

    func assertSnapshot<V: View>(
        of view: V,
        named name: String,
        viewport: SnapshotViewport,
        pixelTolerance: Double = 0.01,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        let image = await render(view: view, viewport: viewport)
        let referenceURL = snapshotsDirectory(for: file).appendingPathComponent("\(name).png")

        if recordMode {
            writeReference(image, to: referenceURL)
            return
        }

        guard FileManager.default.fileExists(atPath: referenceURL.path) else {
            writeReference(image, to: referenceURL)
            XCTFail(
                "Липсва snapshot baseline: \(referenceURL.path). Baseline е записан, пусни теста повторно.",
                file: file,
                line: line
            )
            return
        }

        guard
            let referenceData = try? Data(contentsOf: referenceURL),
            let referenceImage = UIImage(data: referenceData)
        else {
            XCTFail("Snapshot baseline е невалиден: \(referenceURL.path)", file: file, line: line)
            return
        }

        let mismatch = pixelMismatchRatio(lhs: image, rhs: referenceImage, file: file, line: line)
        if mismatch > pixelTolerance {
            let renderedAttachment = XCTAttachment(image: image)
            renderedAttachment.name = "rendered-\(name)"
            renderedAttachment.lifetime = .keepAlways
            add(renderedAttachment)

            let referenceAttachment = XCTAttachment(image: referenceImage)
            referenceAttachment.name = "reference-\(name)"
            referenceAttachment.lifetime = .keepAlways
            add(referenceAttachment)

            XCTFail(
                String(
                    format: "Визуална регресия в %@. Несъответствие %.3f%% > %.3f%%",
                    name,
                    mismatch * 100,
                    pixelTolerance * 100
                ),
                file: file,
                line: line
            )
        }
    }

    private func render<V: View>(view: V, viewport: SnapshotViewport) async -> UIImage {
        let size = CGSize(width: viewport.width, height: viewport.height)
        let host = UIHostingController(rootView: view.preferredColorScheme(.dark))

        let window = UIWindow(frame: CGRect(origin: .zero, size: size))
        window.overrideUserInterfaceStyle = .dark
        window.backgroundColor = .black
        window.rootViewController = host

        let animationsEnabled = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
        defer {
            UIView.setAnimationsEnabled(animationsEnabled)
            window.isHidden = true
            window.rootViewController = nil
        }

        host.overrideUserInterfaceStyle = .dark
        host.view.frame = window.bounds
        host.view.backgroundColor = .black
        window.isHidden = false
        window.layoutIfNeeded()
        host.view.setNeedsLayout()
        host.view.layoutIfNeeded()
        await Task.yield()
        window.layoutIfNeeded()
        host.view.layoutIfNeeded()

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = viewport.scale
        format.opaque = true

        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            window.layer.render(in: context.cgContext)
        }
    }

    private func pixelMismatchRatio(
        lhs: UIImage,
        rhs: UIImage,
        file: StaticString,
        line: UInt
    ) -> Double {
        guard let lhsImage = lhs.cgImage else {
            XCTFail("Rendered snapshot has no CGImage backing.", file: file, line: line)
            return 1
        }

        guard let rhsImage = rhs.cgImage else {
            XCTFail("Reference snapshot has no CGImage backing.", file: file, line: line)
            return 1
        }

        guard lhsImage.width == rhsImage.width, lhsImage.height == rhsImage.height else {
            XCTFail(
                "Snapshot size mismatch: rendered \(lhsImage.width)x\(lhsImage.height) vs reference \(rhsImage.width)x\(rhsImage.height).",
                file: file,
                line: line
            )
            return 1
        }

        guard let lhsBuffer = rgbaBuffer(from: lhsImage) else {
            XCTFail("Failed to read rendered snapshot pixel buffer.", file: file, line: line)
            return 1
        }

        guard let rhsBuffer = rgbaBuffer(from: rhsImage) else {
            XCTFail("Failed to read reference snapshot pixel buffer.", file: file, line: line)
            return 1
        }

        let pixelCount = lhsImage.width * lhsImage.height
        guard pixelCount > 0 else {
            XCTFail(
                "Snapshot image е с нулев размер: rendered \(lhsImage.width)x\(lhsImage.height), reference \(rhsImage.width)x\(rhsImage.height).",
                file: file,
                line: line
            )
            return 1
        }

        var mismatchPixels = 0

        for pixelIndex in 0..<pixelCount {
            let offset = pixelIndex * 4
            let lhsAlpha = lhsBuffer[offset + 3]
            let rhsAlpha = rhsBuffer[offset + 3]
            let lhsRGB = unpremultiply(
                r: lhsBuffer[offset],
                g: lhsBuffer[offset + 1],
                b: lhsBuffer[offset + 2],
                a: lhsAlpha
            )
            let rhsRGB = unpremultiply(
                r: rhsBuffer[offset],
                g: rhsBuffer[offset + 1],
                b: rhsBuffer[offset + 2],
                a: rhsAlpha
            )

            let deltaR = abs(Int(lhsRGB.r) - Int(rhsRGB.r))
            let deltaG = abs(Int(lhsRGB.g) - Int(rhsRGB.g))
            let deltaB = abs(Int(lhsRGB.b) - Int(rhsRGB.b))
            let deltaA = abs(Int(lhsAlpha) - Int(rhsAlpha))

            if deltaR > mismatchThresholdPerChannel ||
                deltaG > mismatchThresholdPerChannel ||
                deltaB > mismatchThresholdPerChannel ||
                deltaA > mismatchThresholdPerChannel {
                mismatchPixels += 1
            }
        }

        return Double(mismatchPixels) / Double(pixelCount)
    }

    private func unpremultiply(r: UInt8, g: UInt8, b: UInt8, a: UInt8) -> (r: UInt8, g: UInt8, b: UInt8) {
        guard a > 0 else { return (0, 0, 0) }

        let alpha = Double(a) / 255.0
        let invAlpha = 1.0 / alpha

        let rr = min(255.0, round(Double(r) * invAlpha))
        let gg = min(255.0, round(Double(g) * invAlpha))
        let bb = min(255.0, round(Double(b) * invAlpha))

        return (UInt8(rr), UInt8(gg), UInt8(bb))
    }

    private func rgbaBuffer(from image: CGImage) -> [UInt8]? {
        let width = image.width
        let height = image.height
        let bytesPerRow = width * 4
        var pixels = [UInt8](repeating: 0, count: height * bytesPerRow)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard
            let context = CGContext(
                data: &pixels,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
        else {
            return nil
        }

        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return pixels
    }

    private func writeReference(_ image: UIImage, to url: URL) {
        let directory = url.deletingLastPathComponent()
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            guard let data = image.pngData() else {
                XCTFail("pngData() returned nil for baseline: \(url.lastPathComponent)")
                return
            }
            try data.write(to: url)
        } catch {
            XCTFail("Failed to write snapshot baseline at \(url.path): \(error)")
        }
    }

    private func snapshotsDirectory(for file: StaticString) -> URL {
        URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("__Snapshots__", isDirectory: true)
    }
}
