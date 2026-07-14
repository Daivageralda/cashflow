import SwiftUI
import SwiftData
import MapKit
import CoreLocation
import PhotosUI

struct TransactionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var transaction: Transaction
    var onDelete: () -> Void

    @State private var isEditing: Bool = false
    @State private var showDeleteConfirm: Bool = false

    @State private var editAmount: String = ""
    @State private var editType: TransactionType = .expense
    @State private var editCategory: Category? = nil
    @State private var editNote: String = ""
    @State private var editDate: Date = .now
    @State private var editLatitude: Double? = nil
    @State private var editLongitude: Double? = nil
    @State private var editLocationName: String? = nil
    
    @State private var showMapPicker: Bool = false
    @State private var mapPosition: MapCameraPosition = .automatic

    @State private var editPhotoItem: PhotosPickerItem? = nil
    @State private var editAttachedImage: UIImage? = nil
    @State private var showCutterEditor: Bool = false
    @State private var originalPickedImage: UIImage? = nil
    @State private var showCamera: Bool = false

    @Query(sort: \Category.sortOrder) private var categories: [Category]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if isEditing {
                        HStack {
                            Text("Rp")
                                .foregroundStyle(Color.textTertiary)
                            TextField("0", text: $editAmount)
                                .keyboardType(.numberPad)
                                .cashflowMonospacedDigits()
                        }

                        Picker("Tipe", selection: $editType) {
                            Text("Pengeluaran").tag(TransactionType.expense)
                            Text("Pemasukan").tag(TransactionType.income)
                        }
                        .pickerStyle(.segmented)

                        HStack {
                            Text("Kategori")
                                .foregroundStyle(Color.textSecondary)
                            Spacer()
                            Picker("Kategori", selection: $editCategory) {
                                Text("Pilih kategori").tag(Category?.none)
                                ForEach(categories, id: \.id) { cat in
                                    Text(cat.name).tag(cat as Category?)
                                }
                            }
                            .labelsHidden()
                        }

                        VStack(alignment: .leading, spacing: Spacing.s4) {
                            Text("Catatan")
                                .font(.cashflowCaption1)
                                .foregroundStyle(Color.textSecondary)
                            TextField("Tambahkan catatan...", text: $editNote, axis: .vertical)
                                .lineLimit(3...6)
                        }

                        HStack {
                            Text("Tanggal")
                                .foregroundStyle(Color.textSecondary)
                            Spacer()
                            DatePicker("", selection: $editDate, displayedComponents: [.date, .hourAndMinute])
                                .tint(Color.accentPrimary)
                                .labelsHidden()
                        }
                    } else {
                        HStack {
                            Text("Nominal")
                                .foregroundStyle(Color.textSecondary)
                            Spacer()
                            Text(transaction.amount.formatted(.currency(code: "IDR").presentation(.narrow)))
                                .foregroundStyle(transaction.type == .income ? Color.stateSuccess : Color.textPrimary)
                                .cashflowMonospacedDigits()
                        }

                        HStack {
                            Text("Tipe")
                                .foregroundStyle(Color.textSecondary)
                            Spacer()
                            Text(transaction.type == .income ? "Pemasukan" : "Pengeluaran")
                        }

                        HStack {
                            Text("Kategori")
                                .foregroundStyle(Color.textSecondary)
                            Spacer()
                            if let cat = transaction.category {
                                HStack(spacing: Spacing.s8) {
                                    Image(systemName: cat.icon)
                                        .foregroundStyle(Color(hex: cat.colorHex))
                                    Text(cat.name)
                                        .foregroundStyle(Color.textPrimary)
                                }
                            } else {
                                Text("Tidak ada kategori").foregroundStyle(Color.textTertiary)
                            }
                        }

                        HStack(alignment: .top) {
                            Text("Catatan")
                                .foregroundStyle(Color.textSecondary)
                            Spacer()
                            Text(transaction.note.isEmpty ? "—" : transaction.note)
                                .foregroundStyle(transaction.note.isEmpty ? Color.textTertiary : Color.textPrimary)
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: 200, alignment: .trailing)
                        }

                        HStack {
                            Text("Tanggal")
                                .foregroundStyle(Color.textSecondary)
                            Spacer()
                            Text(transaction.date.formatted(date: .long, time: .shortened))
                                .foregroundStyle(Color.textPrimary)
                        }
                    }
                }

                if isEditing {
                    Section("Lokasi") {
                        Toggle(isOn: Binding(
                            get: { editLatitude != nil && editLongitude != nil },
                            set: { value in
                                if value {
                                    editLatitude = transaction.latitude ?? -6.2000
                                    editLongitude = transaction.longitude ?? 106.8166
                                    editLocationName = transaction.locationName ?? "Lokasi Pilihan"
                                    mapPosition = .region(MKCoordinateRegion(
                                        center: CLLocationCoordinate2D(latitude: editLatitude!, longitude: editLongitude!),
                                        span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
                                    ))
                                } else {
                                    editLatitude = nil
                                    editLongitude = nil
                                    editLocationName = nil
                                }
                            }
                        )) {
                            Text("Tambahkan Lokasi")
                        }
                        .tint(Color.accentPrimary)
                        
                        if editLatitude != nil, let lat = editLatitude, let lon = editLongitude {
                            VStack(alignment: .leading, spacing: Spacing.s12) {
                                HStack {
                                    Image(systemName: "location.fill")
                                        .foregroundStyle(Color.accentPrimary)
                                    Text(editLocationName ?? "Lokasi terpilih")
                                        .font(.cashflowFootnote)
                                        .foregroundStyle(Color.textSecondary)
                                    Spacer()
                                    Button {
                                        showMapPicker = true
                                    } label: {
                                        Text("Ubah")
                                            .font(.cashflowCaption1)
                                            .fontWeight(.bold)
                                            .foregroundStyle(Color.accentPrimary)
                                    }
                                }
                                
                                ZStack(alignment: .bottomTrailing) {
                                    Map(position: $mapPosition) {
                                        Marker("", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                                            .tint(Color.accentPrimary)
                                    }
                                    .frame(height: 120)
                                    .cornerRadius(Radius.md)

                                    Button {
                                        withAnimation {
                                            mapPosition = .region(MKCoordinateRegion(
                                                center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                                                span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
                                            ))
                                        }
                                    } label: {
                                        Image(systemName: "scope")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundStyle(Color.accentPrimary)
                                            .padding(8)
                                            .background(Color.bgPrimary.opacity(0.85), in: Circle())
                                            .shadow(radius: 2)
                                    }
                                    .padding(Spacing.s8)
                                }
                            }
                            .padding(.top, Spacing.s4)
                        }
                    }
                } else if transaction.latitude != nil, let lat = transaction.latitude, let lon = transaction.longitude {
                    Section("Lokasi") {
                        VStack(alignment: .leading, spacing: Spacing.s12) {
                            HStack {
                                Text("Alamat")
                                    .foregroundStyle(Color.textSecondary)
                                Spacer()
                                Text(transaction.locationName ?? "Lokasi transaksi")
                                    .font(.cashflowFootnote)
                                    .foregroundStyle(Color.textPrimary)
                                    .multilineTextAlignment(.trailing)
                                    .frame(maxWidth: 220, alignment: .trailing)
                            }
                            
                            ZStack(alignment: .bottomTrailing) {
                                Map(initialPosition: .region(MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                                    span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
                                ))) {
                                    Marker("", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                                        .tint(Color.accentPrimary)
                                }
                                .frame(height: 140)
                                .cornerRadius(Radius.md)

                                Button {
                                    withAnimation {
                                        mapPosition = .region(MKCoordinateRegion(
                                            center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                                            span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
                                        ))
                                    }
                                } label: {
                                    Image(systemName: "scope")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(Color.accentPrimary)
                                        .padding(8)
                                        .background(Color.bgPrimary.opacity(0.85), in: Circle())
                                        .shadow(radius: 2)
                                }
                                .padding(Spacing.s8)
                            }
                        }
                    }
                }

                if isEditing {
                    Section("Lampiran") {
                        if let attachedUIImage = editAttachedImage {
                            VStack(alignment: .leading, spacing: Spacing.s12) {
                                HStack {
                                    Spacer()
                                    Image(uiImage: attachedUIImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxHeight: 180)
                                        .cornerRadius(Radius.sm)
                                    Spacer()
                                }
                                
                                HStack(spacing: Spacing.s12) {
                                    Button {
                                        showCutterEditor = true
                                    } label: {
                                        Label("Smart Crop", systemImage: "wand.and.stars")
                                            .font(.cashflowCaption1)
                                            .fontWeight(.bold)
                                            .foregroundStyle(Color.accentPrimary)
                                    }
                                    
                                    Button(role: .destructive) {
                                        editAttachedImage = nil
                                        editPhotoItem = nil
                                    } label: {
                                        Text("Hapus")
                                            .font(.cashflowCaption1)
                                            .foregroundStyle(Color.stateCritical)
                                    }
                                }
                            }
                        } else {
                            HStack(spacing: Spacing.s16) {
                                Button {
                                    showCamera = true
                                } label: {
                                    Label("Kamera", systemImage: "camera")
                                        .font(.cashflowBody)
                                        .foregroundStyle(Color.accentPrimary)
                                }
                                
                                Spacer()

                                PhotosPicker(selection: $editPhotoItem, matching: .images) {
                                    Label("Galeri", systemImage: "photo")
                                        .font(.cashflowBody)
                                        .foregroundStyle(Color.accentPrimary)
                                }
                            }
                        }
                    }
                } else if transaction.attachmentImageData != nil, let imgData = transaction.attachmentImageData, let uiImg = UIImage(data: imgData) {
                    Section("Lampiran") {
                        PhysicsSandboxView(image: uiImg)
                    }
                }

                if !isEditing {
                    Section {
                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            Label("Hapus Transaksi", systemImage: "trash")
                                .foregroundStyle(Color.stateCritical)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.bgPrimary)
            .navigationTitle("Detail Transaksi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(isEditing ? "Batal" : "Tutup") {
                        if isEditing { cancelEdit() } else { dismiss() }
                    }
                    .foregroundStyle(Color.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEditing ? "Simpan" : "Edit") {
                        if isEditing { saveEdit() } else { startEdit() }
                    }
                    .foregroundStyle(Color.accentPrimary)
                }
            }
            .confirmationDialog(
                "Hapus transaksi ini?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Hapus", role: .destructive) {
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    onDelete()
                    dismiss()
                }
                Button("Batal", role: .cancel) {}
            } message: {
                Text("Tindakan ini tidak bisa dibatalkan.")
            }
            .sheet(isPresented: $showMapPicker) {
                MapPinPickerView(initialLocation: transaction.latitude != nil ? CLLocation(latitude: transaction.latitude!, longitude: transaction.longitude!) : nil) { coord, name in
                    self.editLatitude = coord.latitude
                    self.editLongitude = coord.longitude
                    self.editLocationName = name
                    self.mapPosition = .region(MKCoordinateRegion(
                        center: coord,
                        span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
                    ))
                }
            }
            .sheet(isPresented: $showCutterEditor) {
                if let originalPickedImage {
                    SmartCutoutEditorView(originalImage: originalPickedImage) { cutImage in
                        self.editAttachedImage = cutImage
                    }
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraPicker(image: Binding(
                    get: { originalPickedImage },
                    set: { newImg in
                        if let newImg {
                            self.originalPickedImage = newImg
                            self.editAttachedImage = newImg
                            self.showCutterEditor = true
                        }
                    }
                ))
            }
            .onChange(of: editPhotoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        originalPickedImage = uiImage
                        editAttachedImage = uiImage
                        showCutterEditor = true
                    }
                }
            }
        }
    }

    private func startEdit() {
        editAmount = String(Int(transaction.amount))
        editType = transaction.type
        editCategory = transaction.category
        editNote = transaction.note
        editDate = transaction.date
        editLatitude = transaction.latitude
        editLongitude = transaction.longitude
        editLocationName = transaction.locationName
        
        if let imgData = transaction.attachmentImageData {
            editAttachedImage = UIImage(data: imgData)
            originalPickedImage = editAttachedImage
        } else {
            editAttachedImage = nil
            originalPickedImage = nil
        }
        
        if let lat = editLatitude, let lon = editLongitude {
            mapPosition = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
            ))
        }
        withAnimation { isEditing = true }
    }

    private func cancelEdit() {
        withAnimation { isEditing = false }
    }

    private func saveEdit() {
        let amount = Double(editAmount.filter(\.isNumber)) ?? 0
        guard amount > 0 else { return }

        transaction.amount = amount
        transaction.type = editType
        transaction.category = editCategory
        transaction.note = editNote
        transaction.date = editDate
        transaction.latitude = editLatitude
        transaction.longitude = editLongitude
        transaction.locationName = editLocationName
        transaction.attachmentImageData = editAttachedImage?.pngData()

        try? modelContext.save()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation { isEditing = false }
    }
}
