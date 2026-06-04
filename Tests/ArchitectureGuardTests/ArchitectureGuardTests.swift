import Foundation
import SwiftParser
import SwiftSyntax
import XCTest

final class ArchitectureGuardTests: XCTestCase {
    fileprivate static let repositoryRoot = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()

    func testPresentationViewsDoNotImportInfrastructureFrameworks() throws {
        let forbiddenImports = [
            "FirebaseCore": "Firebase must remain behind an explicit remote adapter decision.",
            "FirebaseAnalytics": "Analytics must not be wired directly from SwiftUI views.",
            "FirebaseFirestore": "Remote data access must not be imported by SwiftUI views.",
            "FirebaseAuth": "Authentication must stay behind an app service boundary.",
            "FirebaseStorage": "Remote storage must stay behind an app service boundary.",
            "CoreData": "Persistence must stay outside the presentation layer.",
            "CloudKit": "Remote persistence must stay outside the presentation layer.",
            "RealmSwift": "Persistence must stay outside the presentation layer.",
            "SQLite3": "Storage engines must stay outside the presentation layer.",
            "Security": "Keychain and security APIs must stay behind a dedicated security wrapper.",
            "CryptoKit": "Cryptography must stay behind a dedicated security wrapper.",
            "Network": "Networking must stay behind repository or service boundaries.",
            "WebKit": "Embedded web surfaces need an explicit architecture decision before entering views."
        ]

        let violations = try presentationFiles().flatMap { file in
            let imports = try facts(for: file).imports
            return imports.compactMap { importName -> ArchitectureViolation? in
                let module = rootModuleName(from: importName)
                guard let reason = forbiddenImports[module] else { return nil }
                return ArchitectureViolation(file: file, detail: "forbidden import '\(importName)': \(reason)")
            }
        }

        XCTAssertTrue(violations.isEmpty, formattedViolations(violations))
    }

    func testPresentationViewsDoNotUseDirectPersistenceNetworkingOrSecurityTypes() throws {
        let forbiddenIdentifiers = [
            "UserDefaults": "Use FavoritesManager or a dedicated state boundary instead.",
            "URLSession": "Networking must go through a repository or service boundary.",
            "URLRequest": "Networking must go through a repository or service boundary.",
            "FileManager": "Filesystem access must stay behind a data/service boundary.",
            "NSPersistentContainer": "Core Data must not be constructed from SwiftUI views.",
            "NSManagedObjectContext": "Core Data must not leak into SwiftUI views.",
            "Firestore": "Firebase data access must stay behind a remote adapter.",
            "FirebaseApp": "Firebase runtime must remain detached until a reviewed adapter exists.",
            "LocalVenueRepository": "Views must not bypass VenueRepository.",
            "LocalVenueDataSource": "Views must not bypass VenueRepository.",
            "VenueRepositoryCore": "Views must not bypass the app-facing repository boundary.",
            "SecItemAdd": "Keychain writes must go through a dedicated security wrapper.",
            "SecItemCopyMatching": "Keychain reads must go through a dedicated security wrapper.",
            "SecItemUpdate": "Keychain updates must go through a dedicated security wrapper.",
            "SecItemDelete": "Keychain deletes must go through a dedicated security wrapper."
        ]

        let violations = try presentationFiles().flatMap { file in
            let source = try String(contentsOf: file, encoding: .utf8)
            _ = Parser.parse(source: source)
            return forbiddenIdentifiers.compactMap { identifier, reason -> ArchitectureViolation? in
                guard source.containsIdentifier(identifier) else { return nil }
                return ArchitectureViolation(file: file, detail: "forbidden direct use of '\(identifier)': \(reason)")
            }
        }

        XCTAssertTrue(violations.isEmpty, formattedViolations(violations))
    }

    func testCorePackageDoesNotImportAppOrPresentationFrameworks() throws {
        let forbiddenImports = [
            "SwiftUI": "NOCTOCore must stay UI-independent.",
            "UIKit": "NOCTOCore must stay UI-independent.",
            "AppKit": "NOCTOCore must stay UI-independent.",
            "ActivityKit": "Live Activity code belongs in the app/widget layer.",
            "MapKit": "Map rendering belongs in the presentation layer.",
            "FirebaseCore": "Firebase must remain outside NOCTOCore.",
            "FirebaseFirestore": "Remote adapters must not enter NOCTOCore directly."
        ]

        let violations = try swiftFiles(in: "Sources/NOCTOCore").flatMap { file in
            let imports = try facts(for: file).imports
            return imports.compactMap { importName -> ArchitectureViolation? in
                let module = rootModuleName(from: importName)
                guard let reason = forbiddenImports[module] else { return nil }
                return ArchitectureViolation(file: file, detail: "forbidden import '\(importName)': \(reason)")
            }
        }

        XCTAssertTrue(violations.isEmpty, formattedViolations(violations))
    }

    func testRepositoryBoundaryDoesNotImportPresentationFrameworks() throws {
        let boundaryFiles = [
            "NOCTO/VenueRepository.swift",
            "NOCTO/VenueDataSource.swift",
            "NOCTO/OperationalSnapshot.swift",
            "NOCTO/VenueCatalogViewModel.swift"
        ]
        let forbiddenImports = [
            "SwiftUI": "Repository and app-logic boundaries must not depend on SwiftUI.",
            "UIKit": "Repository and app-logic boundaries must not depend on UIKit.",
            "MapKit": "Map rendering belongs in presentation.",
            "ActivityKit": "Live Activity rendering belongs in app/widget surfaces."
        ]

        let violations = try boundaryFiles.flatMap { relativePath in
            let file = Self.repositoryRoot.appendingPathComponent(relativePath)
            let imports = try facts(for: file).imports
            return imports.compactMap { importName -> ArchitectureViolation? in
                let module = rootModuleName(from: importName)
                guard let reason = forbiddenImports[module] else { return nil }
                return ArchitectureViolation(file: file, detail: "forbidden import '\(importName)': \(reason)")
            }
        }

        XCTAssertTrue(violations.isEmpty, formattedViolations(violations))
    }

    func testFirebaseRuntimeRemainsDetachedFromSwiftCode() throws {
        let forbiddenSnippets = [
            "FirebaseApp.configure": "Firebase runtime initialization is blocked until a remote adapter contract is reviewed.",
            "import Firebase": "Firebase imports must not enter Swift code while Firebase is detached."
        ]

        let violations = try swiftFiles(in: "NOCTO").flatMap { file in
            let source = try String(contentsOf: file, encoding: .utf8)
            _ = Parser.parse(source: source)
            return forbiddenSnippets.compactMap { snippet, reason -> ArchitectureViolation? in
                guard source.contains(snippet) else { return nil }
                return ArchitectureViolation(file: file, detail: "forbidden Firebase snippet '\(snippet)': \(reason)")
            }
        }

        XCTAssertTrue(violations.isEmpty, formattedViolations(violations))
    }

    private func presentationFiles() throws -> [URL] {
        try swiftFiles(in: "NOCTO").filter { file in
            guard let source = try? String(contentsOf: file, encoding: .utf8) else { return false }
            return source.contains("import SwiftUI") &&
                (source.contains(": View") || source.contains(": ViewModifier") || source.contains(": UIViewRepresentable"))
        }
    }

    private func swiftFiles(in relativeDirectory: String) throws -> [URL] {
        let directory = Self.repositoryRoot.appendingPathComponent(relativeDirectory)
        guard let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: nil) else {
            throw ArchitectureGuardError.missingDirectory(directory.path)
        }

        return enumerator
            .compactMap { $0 as? URL }
            .filter { $0.pathExtension == "swift" }
            .sorted { $0.path < $1.path }
    }

    private func facts(for file: URL) throws -> SwiftFileFacts {
        let source = try String(contentsOf: file, encoding: .utf8)
        let tree = Parser.parse(source: source)
        let importCollector = ImportCollector(viewMode: .sourceAccurate)
        importCollector.walk(tree)
        return SwiftFileFacts(imports: importCollector.imports)
    }

    private func rootModuleName(from importName: String) -> String {
        importName.split(separator: ".").first.map(String.init) ?? importName
    }

    private func formattedViolations(_ violations: [ArchitectureViolation]) -> String {
        guard !violations.isEmpty else { return "" }
        return (["Architecture guard violations:"] + violations.map { "- \($0.description)" }).joined(separator: "\n")
    }
}

private final class ImportCollector: SyntaxVisitor {
    private(set) var imports: [String] = []

    override func visit(_ node: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
        imports.append(node.path.description.trimmingCharacters(in: .whitespacesAndNewlines))
        return .skipChildren
    }
}

private struct SwiftFileFacts {
    let imports: [String]
}

private struct ArchitectureViolation: CustomStringConvertible {
    let file: URL
    let detail: String

    var description: String {
        "\(relativePath): \(detail)"
    }

    private var relativePath: String {
        let root = ArchitectureGuardTests.repositoryRoot.path
        let path = file.path
        guard path.hasPrefix(root) else { return path }
        return String(path.dropFirst(root.count + 1))
    }
}

private enum ArchitectureGuardError: Error {
    case missingDirectory(String)
}

private extension String {
    func containsIdentifier(_ identifier: String) -> Bool {
        let escaped = NSRegularExpression.escapedPattern(for: identifier)
        return range(
            of: #"(?<![A-Za-z0-9_])\#(escaped)(?![A-Za-z0-9_])"#,
            options: .regularExpression
        ) != nil
    }
}
