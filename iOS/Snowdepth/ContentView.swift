import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchaseManager: PurchaseManager

    @State private var showAdd = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingEntry: SnowdepthEntry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    ForEach(store.entries) { entry in
                        Button {
                            editingEntry = entry
                        } label: {
                            EntryRow(entry: entry)
                        }
                        .accessibilityIdentifier("entryRow_\(entry.id.uuidString)")
                        .listRowBackground(Theme.card)
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
            .navigationTitle("Snowdepth")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAdd(isPro: purchaseManager.isPro) {
                            showAdd = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showAdd) {
                EntryEditView(entry: nil) { newEntry in
                    store.add(newEntry)
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryEditView(entry: entry) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
        .tint(Theme.accent)
    }
}

struct EntryRow: View {
    let entry: SnowdepthEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.title)
                .font(Theme.bodyFont.weight(.semibold))
                .foregroundStyle(Theme.ink)
            Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                .font(Theme.captionFont)
                .foregroundStyle(Theme.muted)
            if !entry.depth.isEmpty {
                Text(entry.depth)
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.accent)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EntryEditView: View {
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: Field?
    enum Field { case title, f1, f2, notes }

    let entry: SnowdepthEntry?
    let onSave: (SnowdepthEntry) -> Void

    @State private var title: String
    @State private var date: Date
    @State private var f1: String
    @State private var f2: String
    @State private var notes: String

    init(entry: SnowdepthEntry?, onSave: @escaping (SnowdepthEntry) -> Void) {
        self.entry = entry
        self.onSave = onSave
        _title = State(initialValue: entry?.title ?? "")
        _date = State(initialValue: entry?.date ?? Date())
        _f1 = State(initialValue: entry?.depth ?? "")
        _f2 = State(initialValue: entry?.notes ?? "")
        _notes = State(initialValue: entry?.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Reading") {
                    TextField("Title", text: $title)
                        .focused($focusedField, equals: .title)
                        .accessibilityIdentifier("titleField")
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .accessibilityIdentifier("dateField")
                    TextField("Depth", text: $f1)
                        .focused($focusedField, equals: .f1)
                        .accessibilityIdentifier("f1Field")
                    TextField("Notes", text: $f2)
                        .focused($focusedField, equals: .f2)
                        .accessibilityIdentifier("f2Field")
                    TextField("Notes", text: $notes, axis: .vertical)
                        .focused($focusedField, equals: .notes)
                        .accessibilityIdentifier("notesField")
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .navigationTitle(entry == nil ? "Add Reading" : "Edit Reading")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let saved = SnowdepthEntry(
                            id: entry?.id ?? UUID(),
                            title: title.isEmpty ? "Reading" : title,
                            date: date,
                            depth: f1,
                            notes: f2,
                            notes: notes
                        )
                        onSave(saved)
                        dismiss()
                    }
                    .accessibilityIdentifier("saveButton")
                }
            }
        }
        .tint(Theme.accent)
    }
}
