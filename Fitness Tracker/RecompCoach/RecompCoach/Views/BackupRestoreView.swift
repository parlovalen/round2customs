//
//  BackupRestoreView.swift
//  RecompCoach
//
//  Pushed from Profile's "Backup & Restore" row. Moved here from the History
//  tab: JSON export/restore of all logged data, plus the destructive
//  "clear all data" reset.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct BackupRestoreView: View {
    @Environment(\.modelContext) private var context
    @Query private var dailyLogs: [DailyLog]
    @Query private var sessions: [WorkoutSession]
    @Query private var checkIns: [WeeklyCheckIn]

    @State private var showResetConfirm = false
    @State private var showExporter = false
    @State private var showImporter = false
    @State private var exportDoc: JSONBackupDocument?
    @State private var showRestoreConfirm = false
    @State private var pendingImportData: Data?
    @State private var toast: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                backupCard
                resetCard
            }
            .padding(16)
            .padding(.bottom, 40)
        }
        .background(Theme.charcoal)
        .navigationTitle("Backup & Restore")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Clear all logged data on this device? This cannot be undone.",
            isPresented: $showResetConfirm,
            titleVisibility: .visible
        ) {
            Button("Clear all my data", role: .destructive, action: clearAll)
            Button("Cancel", role: .cancel) {}
        }
        .fileExporter(
            isPresented: $showExporter,
            document: exportDoc,
            contentType: .json,
            defaultFilename: BackupManager.defaultFilename()
        ) { result in
            if case .success = result { showToast("Backup saved") }
        }
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.json]
        ) { result in
            handleImport(result)
        }
        .confirmationDialog(
            "Restore will replace all data currently on this device with the backup. Continue?",
            isPresented: $showRestoreConfirm,
            titleVisibility: .visible
        ) {
            Button("Replace with backup", role: .destructive, action: performRestore)
            Button("Cancel", role: .cancel) { pendingImportData = nil }
        }
        .overlay(alignment: .bottom) { ToastView(text: toast) }
    }

    private var backupCard: some View {
        SectionCard(
            title: "Backup & Restore",
            subtitle: "Save all your logs to a file, or restore from one. Handy before app updates or on a new phone."
        ) {
            VStack(spacing: 10) {
                Button { exportBackup() } label: {
                    Label("Export backup", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(GhostButtonStyle())

                Button { showImporter = true } label: {
                    Label("Restore from file", systemImage: "square.and.arrow.down")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(GhostButtonStyle())
            }
        }
    }

    private func exportBackup() {
        do {
            let data = try BackupManager.exportData(context: context)
            exportDoc = JSONBackupDocument(data: data)
            showExporter = true
        } catch {
            showToast("Export failed")
        }
    }

    private func handleImport(_ result: Result<URL, Error>) {
        guard case .success(let url) = result else { return }
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }
        guard let data = try? Data(contentsOf: url) else {
            showToast("Couldn't read file")
            return
        }
        pendingImportData = data
        showRestoreConfirm = true
    }

    private func performRestore() {
        guard let data = pendingImportData else { return }
        defer { pendingImportData = nil }
        do {
            let summary = try BackupManager.restore(from: data, context: context)
            showToast("Restored \(summary.total) entries")
        } catch {
            showToast("Restore failed — invalid file")
        }
    }

    private func showToast(_ msg: String) {
        withAnimation { toast = msg }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation { toast = nil }
        }
    }

    // MARK: Reset

    private var resetCard: some View {
        SectionCard(title: "Reset", subtitle: "Clears all logs on this device. Cannot be undone.") {
            Button("Clear all my data") { showResetConfirm = true }
                .buttonStyle(GhostButtonStyle())
        }
    }

    private func clearAll() {
        for log in dailyLogs { context.delete(log) }
        for s in sessions { context.delete(s) }
        for c in checkIns { context.delete(c) }
        try? context.save()
    }
}
