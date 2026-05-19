//
//  Data Controller.swift
//  Counter App
//
//  Created by Jack Kroll on 8/26/22.
//  Copyright © 2022 JackKroll. All rights reserved.
//

import Foundation
import CoreData
import SwiftData
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

@Model
final class Database {
    var date: Date
    var displayed: Bool
    var number: Int64
    var step: Int16
    var theme: String
    var title: String
    var fontDesignRawValue: String
    var fontWeightRawValue: String
    var customColorHex: String?
    var hapticStyleRawValue: String?
    var hapticIntensity: Double?
    var hapticSharpness: Double?
    var hapticDuration: Double?
    @Attribute(.unique) var uuid: UUID

    var fontDesign: Font.Design {
        get { Self.fontDesign(for: fontDesignRawValue) }
        set { fontDesignRawValue = Self.rawValue(for: newValue) }
    }

    var fontWeight: Font.Weight {
        get { Self.fontWeight(for: fontWeightRawValue) }
        set { fontWeightRawValue = Self.rawValue(for: newValue) }
    }

    init(
        date: Date = .now,
        displayed: Bool = false,
        number: Int64 = 0,
        step: Int16 = 1,
        theme: String = "Bismuth",
        title: String = "Untitled",
        fontDesign: Font.Design = .default,
        fontWeight: Font.Weight = .regular,
        customColorHex: String? = nil,
        hapticStyle: CounterHapticStyle? = nil,
        hapticIntensity: Double? = nil,
        hapticSharpness: Double? = nil,
        hapticDuration: Double? = nil,
        uuid: UUID = UUID()
    ) {
        self.date = date
        self.displayed = displayed
        self.number = number
        self.step = step
        self.theme = theme
        self.title = title
        self.fontDesignRawValue = Self.rawValue(for: fontDesign)
        self.fontWeightRawValue = Self.rawValue(for: fontWeight)
        self.customColorHex = customColorHex
        self.hapticStyleRawValue = hapticStyle?.rawValue
        self.hapticIntensity = hapticIntensity
        self.hapticSharpness = hapticSharpness
        self.hapticDuration = hapticDuration
        self.uuid = uuid
    }

    private static func fontDesign(for rawValue: String) -> Font.Design {
        switch rawValue {
        case "rounded":
            return .rounded
        case "serif":
            return .serif
        case "monospaced":
            return .monospaced
        default:
            return .default
        }
    }

    private static func rawValue(for fontDesign: Font.Design) -> String {
        switch fontDesign {
        case .rounded:
            return "rounded"
        case .serif:
            return "serif"
        case .monospaced:
            return "monospaced"
        default:
            return "default"
        }
    }

    private static func fontWeight(for rawValue: String) -> Font.Weight {
        switch rawValue {
        case "ultraLight":
            return .ultraLight
        case "thin":
            return .thin
        case "light":
            return .light
        case "medium":
            return .medium
        case "semibold":
            return .semibold
        case "bold":
            return .bold
        case "heavy":
            return .heavy
        case "black":
            return .black
        default:
            return .regular
        }
    }

    private static func rawValue(for fontWeight: Font.Weight) -> String {
        switch fontWeight {
        case .ultraLight:
            return "ultraLight"
        case .thin:
            return "thin"
        case .light:
            return "light"
        case .medium:
            return "medium"
        case .semibold:
            return "semibold"
        case .bold:
            return "bold"
        case .heavy:
            return "heavy"
        case .black:
            return "black"
        default:
            return "regular"
        }
    }
}

enum CounterHapticStyle: String, CaseIterable, Identifiable {
    case custom
    case light
    case medium
    case heavy
    case soft
    case rigid

    var id: String { rawValue }

    var label: String {
        switch self {
        case .custom:
            return "Custom"
        case .light:
            return "Light"
        case .medium:
            return "Medium"
        case .heavy:
            return "Heavy"
        case .soft:
            return "Soft"
        case .rigid:
            return "Rigid"
        }
    }

    #if canImport(UIKit)
    var impactStyle: UIImpactFeedbackGenerator.FeedbackStyle? {
        switch self {
        case .custom:
            return nil
        case .light:
            return .light
        case .medium:
            return .medium
        case .heavy:
            return .heavy
        case .soft:
            return .soft
        case .rigid:
            return .rigid
        }
    }
    #endif
}

extension Color {
    init?(rgbHexString: String?) {
        guard let rgbHexString else { return nil }

        let sanitized = rgbHexString.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard sanitized.count == 6, let value = Int(sanitized, radix: 16) else { return nil }

        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255

        self.init(red: red, green: green, blue: blue)
    }

    #if canImport(UIKit)
    var rgbHexString: String? {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }

        return String(
            format: "%02X%02X%02X",
            Int(red * 255),
            Int(green * 255),
            Int(blue * 255)
        )
    }
    #endif
}

enum LegacyCoreDataMigrator {
    private static let migrationKey = "LegacyCoreDataMigrationCompleted"

    private enum MigrationError: LocalizedError {
        case missingImportedCounts

        var errorDescription: String? {
            switch self {
            case .missingImportedCounts:
                return "Not all legacy counts were present after saving to SwiftData."
            }
        }
    }

    static func migrateIfNeeded(existingCounts: [Database], modelContext: ModelContext) -> [Database] {
        let defaults = UserDefaults.standard
        guard !ProcessInfo.processInfo.isRunningForPreviews else { return existingCounts }
        guard !defaults.bool(forKey: migrationKey) else { return existingCounts }

        let storeURL = NSPersistentContainer.defaultDirectoryURL()
            .appendingPathComponent("Database.sqlite")

        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            defaults.set(true, forKey: migrationKey)
            return existingCounts
        }

        do {
            try backupLegacyStore(at: storeURL)

            let legacyCounts = try fetchLegacyCounts(from: storeURL)
            let uniqueLegacyCounts = deduplicatedCounts(legacyCounts)
            guard !uniqueLegacyCounts.isEmpty else {
                defaults.set(true, forKey: migrationKey)
                return existingCounts
            }

            let existingIDs = Set(existingCounts.map(\.uuid))
            let countsToImport = uniqueLegacyCounts.filter { !existingIDs.contains($0.uuid) }
            guard !countsToImport.isEmpty else {
                defaults.set(true, forKey: migrationKey)
                return existingCounts
            }

            for count in countsToImport {
                modelContext.insert(count)
            }

            try modelContext.save()
            try verifyImportedCounts(countsToImport, in: modelContext)
            defaults.set(true, forKey: migrationKey)
            return existingCounts + countsToImport
        } catch {
            modelContext.rollback()
            print("Legacy Core Data migration failed: \(error.localizedDescription)")
            return existingCounts
        }
    }

    private static func backupLegacyStore(at storeURL: URL) throws {
        let fileManager = FileManager.default
        let supportDirectory = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let timestamp = legacyBackupTimestamp()
        let backupDirectory = supportDirectory
            .appendingPathComponent("LegacyCoreDataBackups", isDirectory: true)
            .appendingPathComponent("Database-\(timestamp)-\(UUID().uuidString)", isDirectory: true)

        try fileManager.createDirectory(
            at: backupDirectory,
            withIntermediateDirectories: true
        )

        let storePaths = [
            storeURL.path,
            storeURL.path + "-shm",
            storeURL.path + "-wal"
        ]

        for storePath in storePaths {
            guard fileManager.fileExists(atPath: storePath) else { continue }
            let sourceURL = URL(fileURLWithPath: storePath)
            let backupURL = backupDirectory.appendingPathComponent(sourceURL.lastPathComponent)
            try fileManager.copyItem(at: sourceURL, to: backupURL)
        }
    }

    private static func legacyBackupTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return formatter.string(from: .now)
    }

    private static func deduplicatedCounts(_ counts: [Database]) -> [Database] {
        var seenIDs = Set<UUID>()
        var output: [Database] = []

        for count in counts where !seenIDs.contains(count.uuid) {
            seenIDs.insert(count.uuid)
            output.append(count)
        }

        return output
    }

    private static func verifyImportedCounts(_ importedCounts: [Database], in modelContext: ModelContext) throws {
        let expectedIDs = Set(importedCounts.map(\.uuid))
        let savedCounts = try modelContext.fetch(FetchDescriptor<Database>())
        let savedIDs = Set(savedCounts.map(\.uuid))

        guard expectedIDs.isSubset(of: savedIDs) else {
            throw MigrationError.missingImportedCounts
        }
    }

    private static func fetchLegacyCounts(from storeURL: URL) throws -> [Database] {
        let model = makeLegacyModel()
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        try coordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: storeURL,
            options: [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true
            ]
        )

        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator

        let request = NSFetchRequest<NSManagedObject>(entityName: "Database")
        return try context.fetch(request).map { object in
            Database(
                date: object.value(forKey: "date") as? Date ?? .distantPast,
                displayed: object.value(forKey: "displayed") as? Bool ?? false,
                number: object.value(forKey: "number") as? Int64 ?? 0,
                step: object.value(forKey: "step") as? Int16 ?? 1,
                theme: object.value(forKey: "theme") as? String ?? "Bismuth",
                title: object.value(forKey: "title") as? String ?? "Untitled",
                uuid: object.value(forKey: "uuid") as? UUID ?? UUID()
            )
        }
    }

    private static func makeLegacyModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = "Database"
        entity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)
        entity.properties = [
            makeAttribute("date", type: .dateAttributeType, isOptional: true),
            makeAttribute("displayed", type: .booleanAttributeType, isOptional: true, defaultValue: false),
            makeAttribute("number", type: .integer64AttributeType, isOptional: true, defaultValue: 0),
            makeAttribute("step", type: .integer16AttributeType, isOptional: true, defaultValue: 0),
            makeAttribute("theme", type: .stringAttributeType, isOptional: true),
            makeAttribute("title", type: .stringAttributeType, isOptional: true),
            makeAttribute("uuid", type: .UUIDAttributeType, isOptional: true)
        ]
        model.entities = [entity]
        return model
    }

    private static func makeAttribute(
        _ name: String,
        type: NSAttributeType,
        isOptional: Bool,
        defaultValue: Any? = nil
    ) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = isOptional
        attribute.defaultValue = defaultValue
        return attribute
    }
}

enum PreviewDatabase {
    @MainActor
    static func container(includeMockCount: Bool = true) -> ModelContainer {
        do {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: Database.self, configurations: configuration)

            if includeMockCount {
                container.mainContext.insert(
                    Database(
                        date: .now,
                        displayed: true,
                        number: 42,
                        step: 1,
                        theme: "Gold",
                        title: "Preview Count"
                    )
                )
            }

            return container
        } catch {
            fatalError("Failed to create preview model container: \(error.localizedDescription)")
        }
    }
}

private extension ProcessInfo {
    var isRunningForPreviews: Bool {
        environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
