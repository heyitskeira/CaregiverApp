//
//  TaskSheetView.swift
//  CaregiverApp
//
//  Custom "Add New Task" / "Edit Task" sheet matching the design mockup.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

enum TaskSheetMode {
    case create
    case view(TimelineTaskModel)
    case edit(TimelineTaskModel)
}

struct TaskSheetView: View {
    var mode: TaskSheetMode
    var onSave: ((TimelineTaskModel) -> Void)?
    var onUpdate: ((TimelineTaskModel) -> Void)?
    var onDelete: ((UUID) -> Void)?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.contactRepository) private var contactRepository
    @Environment(\.authService) private var authService

    private let brandBlue = Color(hex: 0x2051B9)

    // MARK: - State
    @State private var taskName: String
    @State private var taskNote: String
    @State private var taskDate: Date
    @State private var taskStartTime: Date
    @State private var taskEndTime: Date
    @State private var repeatOption: RepeatOption
    @State private var isRecurring: Bool
    @State private var showingCustomRepeat = false
    @State private var repeatInterval = 1
    @State private var repeatUnit: RepeatUnit = .weeks

    @State private var isAssignEnabled = false
    @State private var allContacts: [CareContact] = []
    @State private var selectedPrimaryID: UUID?
    @State private var selectedBackupID: UUID?

    @State private var attachments: [TaskAttachment] = []
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var isFilePickerPresented = false

    @State private var showDatePicker = false
    @State private var showTimePicker = false
    @State private var showRecurringPicker = false

    @State private var isEditing: Bool
    @State private var editingTaskId: UUID?

    private let maxNameLength = 30

    init(
        mode: TaskSheetMode = .create,
        onSave: ((TimelineTaskModel) -> Void)? = nil,
        onUpdate: ((TimelineTaskModel) -> Void)? = nil,
        onDelete: ((UUID) -> Void)? = nil
    ) {
        self.mode = mode
        self.onSave = onSave
        self.onUpdate = onUpdate
        self.onDelete = onDelete

        switch mode {
        case .create:
            _taskName = State(initialValue: "")
            _taskNote = State(initialValue: "")
            _taskDate = State(initialValue: Date())
            _taskStartTime = State(initialValue: Date())
            _taskEndTime = State(initialValue: Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date())
            _repeatOption = State(initialValue: .none)
            _isRecurring = State(initialValue: false)
            _isEditing = State(initialValue: true)
            _editingTaskId = State(initialValue: nil)
        case .view(let task), .edit(let task):
            _taskName = State(initialValue: task.title)
            _taskNote = State(initialValue: task.taskNote)
            _taskDate = State(initialValue: task.startDate)
            _taskStartTime = State(initialValue: task.startDate)
            _taskEndTime = State(initialValue: task.endDate)
            _repeatOption = State(initialValue: task.repeatOption)
            _isRecurring = State(initialValue: task.repeatOption != .none)
            _isEditing = State(initialValue: {
                if case .edit = mode { return true }
                return false
            }())
            _editingTaskId = State(initialValue: task.id)
            _isAssignEnabled = State(initialValue: task.primaryAssigneeID != nil)
            _selectedPrimaryID = State(initialValue: task.primaryAssigneeID)
            _selectedBackupID = State(initialValue: task.backupAssigneeID)
            _attachments = State(initialValue: task.attachments)
        }
    }

    private var isCreateMode: Bool {
        if case .create = mode { return true }
        return false
    }

    /// Combine date from taskDate with time from the time value
    private func combinedDateTime(date: Date, time: Date) -> Date {
        let cal = Calendar.current
        let dateComponents = cal.dateComponents([.year, .month, .day], from: date)
        let timeComponents = cal.dateComponents([.hour, .minute], from: time)
        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute
        return cal.date(from: combined) ?? date
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            blueHeaderSection

            ScrollView {
                VStack(spacing: 20) {
                    dateTimeSection
                    assignTaskSection
                    attachmentAndNotesSection

                    // Delete button (edit mode only, not create)
                    if isEditing && !isCreateMode {
                        Button(role: .destructive) {
                            if let id = editingTaskId {
                                onDelete?(id)
                            }
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Task")
                            }
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top, 20)
            }
            .background(Color(.secondarySystemBackground))
        }
        .background(Color(.secondarySystemBackground))
        .sheet(isPresented: $showingCustomRepeat) {
            CustomRepeatView(repeatInterval: $repeatInterval, repeatUnit: $repeatUnit)
        }
        .fileImporter(
            isPresented: $isFilePickerPresented,
            allowedContentTypes: [.item],
            allowsMultipleSelection: true
        ) { result in
            handleFileImport(result)
        }
        .task {
            await loadContacts()
        }
    }

    // MARK: - Blue Header
    private var blueHeaderSection: some View {
        VStack(spacing: 14) {
            Capsule()
                .fill(Color.white.opacity(0.4))
                .frame(width: 36, height: 4)
                .padding(.top, 10)

            HStack {
                Button(action: {
                    if isEditing && !isCreateMode {
                        if case .view(let task) = mode {
                            taskName = task.title
                            taskNote = task.taskNote
                            taskDate = task.startDate
                            taskStartTime = task.startDate
                            taskEndTime = task.endDate
                            repeatOption = task.repeatOption
                            isRecurring = task.repeatOption != .none
                            isEditing = false
                        }
                    } else {
                        dismiss()
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(brandBlue.opacity(0.8))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
                }

                Spacer()

                Text(isCreateMode ? "Add New Task" : (isEditing ? "Edit Task" : taskName))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                Spacer()

                if isEditing {
                    Button(action: { saveTask() }) {
                        Image(systemName: "checkmark")
                            .font(.body.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(brandBlue.opacity(0.8))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
                    }
                    .disabled(taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                } else {
                    if authService.currentRole.canEditTask {
                        Button(action: { isEditing = true }) {
                            Image(systemName: "pencil")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.white)
                                .frame(width: 40, height: 40)
                                .background(brandBlue.opacity(0.8))
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
                        }
                    }
                }
            }
            .padding(.horizontal, 16)

            if isEditing {
                VStack(spacing: 4) {
                    TextField("Task Name", text: $taskName)
                        .font(.body)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .tint(.white)
                        .onChange(of: taskName) { _, newValue in
                            if newValue.count > maxNameLength {
                                taskName = String(newValue.prefix(maxNameLength))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )

                    HStack {
                        Spacer()
                        Text("/\(maxNameLength)")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                .padding(.horizontal, 32)
            }
        }
        .padding(.bottom, 16)
        .background(brandBlue)
    }

    // MARK: - Date & Time Section
    private var dateTimeSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Date & Time")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.bottom, 12)

            VStack(spacing: 0) {
                // Date row — full row tappable
                Button(action: {
                    guard isEditing else { return }
                    withAnimation { showDatePicker.toggle(); showTimePicker = false }
                }) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(brandBlue)
                            .frame(width: 28)
                        Text("Date")
                            .foregroundStyle(.primary)
                        Spacer()
                        Text(taskDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if showDatePicker {
                    inlineDatePicker
                }

                Divider().padding(.leading, 56)

                // Time row — full row tappable, shows range
                Button(action: {
                    guard isEditing else { return }
                    withAnimation { showTimePicker.toggle(); showDatePicker = false }
                }) {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(brandBlue)
                            .frame(width: 28)
                        Text("Time")
                            .foregroundStyle(.primary)
                        Spacer()
                        Text(timeRangeString)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if showTimePicker {
                    inlineTimePicker
                }

                Divider().padding(.leading, 56)

                // Recurring toggle
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundStyle(brandBlue)
                        .frame(width: 28)
                    Text("Recurring")
                        .foregroundStyle(.primary)
                    Spacer()
                    Toggle("", isOn: $isRecurring)
                        .labelsHidden()
                        .tint(brandBlue)
                        .disabled(!isEditing)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

                // Recurring frequency picker (when toggled on)
                if isRecurring {
                    Divider().padding(.leading, 56)

                    Button(action: {
                        guard isEditing else { return }
                        withAnimation { showRecurringPicker.toggle() }
                    }) {
                        HStack {
                            Image(systemName: "repeat")
                                .foregroundStyle(brandBlue)
                                .frame(width: 28)
                            Text("Frequency")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(repeatOption == .none ? "Daily" : repeatOption.rawValue)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if showRecurringPicker {
                        VStack(spacing: 0) {
                            ForEach([RepeatOption.daily, .weekly, .monthly, .yearly], id: \.self) { option in
                                Button {
                                    repeatOption = option
                                    withAnimation { showRecurringPicker = false }
                                } label: {
                                    HStack {
                                        Text(option.rawValue)
                                            .foregroundStyle(.primary)
                                        Spacer()
                                        if repeatOption == option {
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(brandBlue)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                }
                                .buttonStyle(.plain)

                                if option != .yearly {
                                    Divider().padding(.leading, 16)
                                }
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal)

            Text("Assignees are reminded 30 minutes before and at task time.")
                .font(.caption2)
                .foregroundStyle(.gray)
                .italic()
                .padding(.horizontal, 20)
                .padding(.top, 8)

            // Assign Task row — connected to the toggled-on panel
            VStack(spacing: 0) {
                HStack {
                    Text("Assign Task")
                        .font(.body)
                    Spacer()
                    Toggle("", isOn: $isAssignEnabled)
                        .labelsHidden()
                        .tint(brandBlue)
                        .disabled(!isEditing)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

                if isAssignEnabled {
                    Divider().padding(.leading, 16)
                    assignContactsContent
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal)
            .padding(.top, 12)
        }
    }

    private var timeRangeString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm a"
        return "\(fmt.string(from: taskStartTime)) - \(fmt.string(from: taskEndTime))"
    }

    // MARK: - Inline Date Picker
    private var inlineDatePicker: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Date")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(taskDate.formatted(.dateTime.weekday(.wide).day().month(.wide).year()))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
                Image(systemName: "checkmark")
                    .font(.body.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
                    .onTapGesture {
                        withAnimation { showDatePicker = false }
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(brandBlue)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 8)

            DatePicker("Select Date", selection: $taskDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(brandBlue)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    // MARK: - Inline Time Picker (Start + End range)
    private var inlineTimePicker: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Time Range")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(timeRangeString)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
                Image(systemName: "checkmark")
                    .font(.body.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
                    .onTapGesture {
                        withAnimation { showTimePicker = false }
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(brandBlue)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 8)

            VStack(spacing: 16) {
                // Start time
                HStack {
                    Text("Start")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    Spacer()
                    DatePicker("", selection: $taskStartTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .tint(brandBlue)
                }
                .padding(.horizontal, 16)

                Divider().padding(.horizontal, 16)

                // End time
                HStack {
                    Text("End")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    Spacer()
                    DatePicker("", selection: $taskEndTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .tint(brandBlue)
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 16)
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    // MARK: - Assign Task Section
    private var assignTaskSection: some View {
        EmptyView()
    }

    // MARK: - Assign Contacts Content
    private var assignContactsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            if allContacts.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding(.vertical, 20)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Primary")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                        Spacer()
                        if let id = selectedPrimaryID,
                           let contact = allContacts.first(where: { $0.id == id }) {
                            Text(contact.name)
                                .font(.subheadline)
                                .foregroundStyle(brandBlue)
                        }
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(allContacts) { contact in
                                contactAvatarChip(
                                    contact,
                                    isSelected: selectedPrimaryID == contact.id
                                ) {
                                    guard isEditing else { return }
                                    selectedPrimaryID = selectedPrimaryID == contact.id ? nil : contact.id
                                    if selectedBackupID == contact.id {
                                        selectedBackupID = nil
                                    }
                                }
                            }
                        }
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Backup")
                        .font(.subheadline)
                        .foregroundStyle(.gray)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(allContacts) { contact in
                                contactAvatarChip(
                                    contact,
                                    isSelected: selectedBackupID == contact.id
                                ) {
                                    guard isEditing else { return }
                                    selectedBackupID = selectedBackupID == contact.id ? nil : contact.id
                                    if selectedPrimaryID == contact.id {
                                        selectedPrimaryID = nil
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
    }

    private func contactAvatarChip(_ contact: CareContact, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    ContactAvatarView(contact: contact, size: 56)

                    if isSelected {
                        Circle()
                            .stroke(brandBlue, lineWidth: 3)
                            .frame(width: 60, height: 60)
                    }
                }

                Text(contact.name)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? brandBlue : .primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: 70)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Attachment & Notes Section
    private var attachmentAndNotesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Attachment and Notes")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.horizontal)

            if isEditing {
                TextField("Notes here...", text: $taskNote, axis: .vertical)
                    .lineLimit(3...5)
                    .padding(14)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)
            } else {
                Text(taskNote.isEmpty ? "No notes" : taskNote)
                    .font(.body)
                    .foregroundStyle(taskNote.isEmpty ? .secondary : .primary)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)
            }

            if isEditing {
                VStack(spacing: 0) {
                    Button(action: { isFilePickerPresented = true }) {
                        HStack(spacing: 10) {
                            Image(systemName: "paperclip")
                                .foregroundStyle(brandBlue)
                            Text("Add Attachment...")
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Divider().padding(.leading, 44)

                    PhotosPicker(selection: $selectedPhotoItems, matching: .images) {
                        HStack(spacing: 10) {
                            Image(systemName: "photo")
                                .foregroundStyle(brandBlue)
                            Text("Add Picture...")
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                    .onChange(of: selectedPhotoItems) { _, newItems in
                        Task { await handlePhotoSelection(newItems) }
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)
            }

            if !attachments.isEmpty {
                List {
                    ForEach(attachments) { attachment in
                        attachmentRow(attachment)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color(.systemBackground))
                    }
                    .onDelete { indexSet in
                        if isEditing {
                            withAnimation {
                                attachments.remove(atOffsets: indexSet)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .frame(height: CGFloat(attachments.count) * 60)
                .scrollDisabled(true)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)
            }
        }
    }

    private func attachmentRow(_ attachment: TaskAttachment) -> some View {
        HStack(spacing: 12) {
            if let imageData = attachment.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: attachment.iconName)
                    .font(.title3)
                    .foregroundStyle(brandBlue)
                    .frame(width: 40, height: 40)
                    .background(brandBlue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(attachment.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(attachment.fileType.rawValue.capitalized)
                    .font(.caption2)
                    .foregroundStyle(.gray)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - File Import
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            for url in urls {
                let ext = url.pathExtension
                let attachment = TaskAttachment(
                    fileName: url.lastPathComponent,
                    fileType: AttachmentType.from(fileExtension: ext),
                    localURL: url
                )
                attachments.append(attachment)
            }
        case .failure:
            break
        }
    }

    // MARK: - Photo Selection
    private func handlePhotoSelection(_ items: [PhotosPickerItem]) async {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                let attachment = TaskAttachment(
                    fileName: "Image",
                    fileType: .image,
                    imageData: data
                )
                await MainActor.run {
                    attachments.append(attachment)
                }
            }
        }
        await MainActor.run {
            selectedPhotoItems = []
        }
    }

    // MARK: - Load Contacts
    private func loadContacts() async {
        do {
            allContacts = try await contactRepository.fetchContacts()
        } catch {
            allContacts = []
        }
    }

    // MARK: - Save
    private func saveTask() {
        let primaryContact = selectedPrimaryID.flatMap { id in allContacts.first(where: { $0.id == id }) }
        let initials = primaryContact?.initials

        let effectiveRepeat: RepeatOption = isRecurring ? (repeatOption == .none ? .daily : repeatOption) : .none

        let startDate = combinedDateTime(date: taskDate, time: taskStartTime)
        let endDate = combinedDateTime(date: taskDate, time: taskEndTime)

        let timelineModel = TimelineTaskModel(
            id: editingTaskId ?? UUID(),
            startDate: startDate,
            endDate: endDate,
            title: taskName.trimmingCharacters(in: .whitespacesAndNewlines),
            initials: initials,
            hasRepeatIcon: effectiveRepeat != .none,
            state: (isAssignEnabled && selectedPrimaryID != nil) ? .assigned : .pending,
            taskNote: taskNote.trimmingCharacters(in: .whitespacesAndNewlines),
            repeatOption: effectiveRepeat,
            primaryAssigneeID: isAssignEnabled ? selectedPrimaryID : nil,
            backupAssigneeID: isAssignEnabled ? selectedBackupID : nil,
            attachments: attachments
        )

        if isCreateMode {
            onSave?(timelineModel)
        } else {
            onUpdate?(timelineModel)
        }
        dismiss()
    }
}

#Preview {
    TaskSheetView()
        .environment(\.contactRepository, AppDependencies.live.contactRepository)
        .environment(\.taskRepository, AppDependencies.live.taskRepository)
}
