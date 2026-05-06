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
    ) {
        let image = render(view: view, viewport: viewport)
        let referenceURL = snapshotsDirectory().appendingPathComponent("\(name).png")

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

        let mismatch = pixelMismatchRatio(lhs: image, rhs: referenceImage)
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
                    format: "Visual regression in %@. Mismatch %.3f%% > %.3f%%",
                    name,
                    mismatch * 100,
                    pixelTolerance * 100
                ),
                file: file,
                line: line
            )
        }
    }

    private func render<V: View>(view: V, viewport: SnapshotViewport) -> UIImage {
        let size = CGSize(width: viewport.width, height: viewport.height)
        let host = UIHostingController(rootView: view.preferredColorScheme(.dark))
        host.overrideUserInterfaceStyle = .dark
        host.view.frame = CGRect(origin: .zero, size: size)
        host.view.backgroundColor = .black
        host.view.layoutIfNeeded()

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = viewport.scale
        format.opaque = true

        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            host.view.layer.render(in: context.cgContext)
        }
    }

    private func pixelMismatchRatio(lhs: UIImage, rhs: UIImage) -> Double {
        guard
            let lhsImage = lhs.cgImage,
            let rhsImage = rhs.cgImage,
            lhsImage.width == rhsImage.width,
            lhsImage.height == rhsImage.height,
            let lhsBuffer = rgbaBuffer(from: lhsImage),
            let rhsBuffer = rgbaBuffer(from: rhsImage)
        else {
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
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        guard let data = image.pngData() else { return }
        try? data.write(to: url)
    }

    private func snapshotsDirectory() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("__Snapshots__", isDirectory: true)
    }
}
