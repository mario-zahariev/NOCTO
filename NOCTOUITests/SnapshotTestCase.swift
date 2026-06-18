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

    private var defaultPixelTolerance: Double {
        let environment = ProcessInfo.processInfo.environment
        if let parsed = parsePixelTolerance(environment["NOCTO_SNAPSHOT_PIXEL_TOLERANCE"]) {
            return parsed
        }
        if let parsed = parsePixelTolerance(environment["TEST_RUNNER_NOCTO_SNAPSHOT_PIXEL_TOLERANCE"]) {
            return parsed
        }
        return 0.01
    }

    private let mismatchThresholdPerChannel = 2

    private func parsePixelTolerance(_ rawValue: String?) -> Double? {
        guard let rawValue else { return nil }
        guard let parsed = Double(rawValue), parsed >= 0, parsed <= 1 else {
            return nil
        }
        return parsed
    }

    func assertSnapshot<V: View>(
        of view: V,
        named name: String,
        viewport: SnapshotViewport,
        pixelTolerance: Double? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let effectivePixelTolerance = pixelTolerance ?? defaultPixelTolerance
        let image = render(view: view, viewport: viewport)
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
        if mismatch > effectivePixelTolerance {
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
                    format: "Visual regression in %@. Mismatch %.3f%% > %.3f%%",
                    name,
                    mismatch * 100,
                    effectivePixelTolerance * 100
                ),
                file: file,
                line: line
            )
        }
    }

    private func render<V: View>(view: V, viewport: SnapshotViewport) -> UIImage {
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
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))

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
        var mismatchPixels = 0

        for pixelIndex in 0..<pixelCount {
            let offset = pixelIndex * 4
            let deltaR = abs(Int(lhsBuffer[offset]) - Int(rhsBuffer[offset]))
            let deltaG = abs(Int(lhsBuffer[offset + 1]) - Int(rhsBuffer[offset + 1]))
            let deltaB = abs(Int(lhsBuffer[offset + 2]) - Int(rhsBuffer[offset + 2]))
            let deltaA = abs(Int(lhsBuffer[offset + 3]) - Int(rhsBuffer[offset + 3]))

            if deltaR > mismatchThresholdPerChannel ||
                deltaG > mismatchThresholdPerChannel ||
                deltaB > mismatchThresholdPerChannel ||
                deltaA > mismatchThresholdPerChannel {
                mismatchPixels += 1
            }
        }

        return Double(mismatchPixels) / Double(pixelCount)
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
