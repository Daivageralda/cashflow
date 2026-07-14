import SwiftUI
import SwiftData
import CoreLocation
import MapKit
import PhotosUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState

    @State private var amountText: String = ""
    @State private var transactionType: TransactionType = .expense
    @State private var selectedCategory: Category? = nil
    @State private var note: String = ""
    @State private var date: Date = .now
    @State private var showDatePicker: Bool = false

    @State private var locationManager = LocationManager()
    @State private var attachLocation: Bool = false
    @State private var showMapPicker: Bool = false
    @State private var manualCoordinates: CLLocationCoordinate2D? = nil
    @State private var mapPosition: MapCameraPosition = .automatic

    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var attachedImage: UIImage? = nil
    @State private var showCutterEditor: Bool = false
    @State private var originalPickedImage: UIImage? = nil
    @State private var showCamera: Bool = false

    var prefillAmount: Double? = nil
    var prefillNote: String? = nil
    var prefillCategoryName: String? = nil
    var onSuccess: (() -> Void)? = nil

    @Query(sort: \Category.sortOrder) private var categories: [Category]

    private var filteredCategories: [Category] {
        transactionType == .income
            ? categories.filter { $0.name == "Pendapatan" || !$0.isSystem }
            : categories.filter { $0.name != "Pendapatan" }
    }

    private var amount: Double {
        Double(amountText.filter(\.isNumber)) ?? 0
    }

    private var canSave: Bool {
        amount > 0 && selectedCategory != nil
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.s24) {
                    amountSection
                    typeToggle
                    categorySection
                    dateSection
                    locationSection
                    noteSection
                    attachmentSection
                }
                .padding(Spacing.s16)
            }
            .background(Color.bgPrimary)
            .navigationTitle("Catat Transaksi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Batal") { dismiss() }
                        .foregroundStyle(Color.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Simpan") { save() }
                        .font(.cashflowHeadline)
                        .foregroundStyle(canSave ? Color.accentPrimary : Color.textTertiary)
                        .disabled(!canSave)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(Radius.xl)
        .onAppear {
            if let prefill = prefillAmount {
                amountText = String(Int(prefill))
            }
            if let prefillNote {
                note = prefillNote
            }
            if let prefillCat = prefillCategoryName {
                selectedCategory = categories.first { $0.name.localizedCaseInsensitiveContains(prefillCat) }
            }
        }
        .sheet(isPresented: $showMapPicker) {
            MapPinPickerView(initialLocation: locationManager.location) { coord, name in
                self.manualCoordinates = coord
                self.locationManager.locationName = name
                self.mapPosition = .region(MKCoordinateRegion(
                    center: coord,
                    span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
                ))
            }
        }
        .sheet(isPresented: $showCutterEditor) {
            if let originalPickedImage {
                SmartCutoutEditorView(originalImage: originalPickedImage) { cutImage in
                    self.attachedImage = cutImage
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker(image: Binding(
                get: { originalPickedImage },
                set: { newImg in
                    if let newImg {
                        self.originalPickedImage = newImg
                        self.attachedImage = newImg
                        self.showCutterEditor = true
                    }
                }
            ))
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    originalPickedImage = uiImage
                    attachedImage = uiImage
                    showCutterEditor = true
                }
            }
        }
    }

    private var amountSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            Text("Nominal")
                .font(.cashflowSubheadline)
                .foregroundStyle(Color.textSecondary)

            HStack(spacing: Spacing.s8) {
                Text("Rp")
                    .font(.cashflowTitle2)
                    .foregroundStyle(Color.textTertiary)

                TextField("0", text: $amountText)
                    .font(.cashflowTitle1)
                    .foregroundStyle(Color.textPrimary)
                    .keyboardType(.numberPad)
                    .cashflowMonospacedDigits()
                    .onChange(of: amountText) { _, new in
                        let digits = new.filter(\.isNumber)
                        if let num = Int(digits) {
                            amountText = NumberFormatter.localizedString(from: NSNumber(value: num), number: .decimal)
                                .replacingOccurrences(of: ",", with: ".")
                        }
                    }
            }
            .padding(Spacing.s16)
            .background(Color.bgSecondary, in: RoundedRectangle(cornerRadius: Radius.sm))
        }
    }

    private var typeToggle: some View {
        Picker("Tipe", selection: $transactionType) {
            Text("Pengeluaran").tag(TransactionType.expense)
            Text("Pemasukan").tag(TransactionType.income)
        }
        .pickerStyle(.segmented)
        .onChange(of: transactionType) { _, _ in
            selectedCategory = nil
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            Text("Kategori")
                .font(.cashflowSubheadline)
                .foregroundStyle(Color.textSecondary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: Spacing.s12) {
                ForEach(filteredCategories, id: \.id) { category in
                    categoryChip(category)
                }
            }
        }
    }

    private func categoryChip(_ category: Category) -> some View {
        let isSelected = selectedCategory?.id == category.id
        let color = Color(hex: category.colorHex)

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                selectedCategory = category
            }
        } label: {
            VStack(spacing: Spacing.s4) {
                ZStack {
                    Circle()
                        .fill(isSelected ? color : color.opacity(0.12))
                        .frame(width: 48, height: 48)

                    Image(systemName: category.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(isSelected ? Color.white : color)
                }

                Text(category.name)
                    .font(.cashflowCaption2)
                    .foregroundStyle(isSelected ? Color.accentPrimary : Color.textSecondary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            Text("Tanggal")
                .font(.cashflowSubheadline)
                .foregroundStyle(Color.textSecondary)

            Button {
                withAnimation { showDatePicker.toggle() }
            } label: {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(Color.textSecondary)

                    Text(date.formatted(date: .long, time: .shortened))
                        .font(.cashflowBody)
                        .foregroundStyle(Color.textPrimary)

                    Spacer()

                    Image(systemName: showDatePicker ? "chevron.up" : "chevron.down")
                        .font(.cashflowCaption1)
                        .foregroundStyle(Color.textTertiary)
                }
                .padding(Spacing.s16)
                .background(Color.bgSecondary, in: RoundedRectangle(cornerRadius: Radius.sm))
            }
            .buttonStyle(.plain)

            if showDatePicker {
                DatePicker("", selection: $date, in: ...Date.now, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.graphical)
                    .tint(Color.accentPrimary)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            Toggle(isOn: $attachLocation) {
                HStack(spacing: Spacing.s8) {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundStyle(Color.textSecondary)
                    Text("Tambahkan Lokasi")
                        .font(.cashflowBody)
                        .foregroundStyle(Color.textPrimary)
                }
            }
            .tint(Color.accentPrimary)
            .onChange(of: attachLocation) { _, newValue in
                if newValue {
                    locationManager.requestLocation()
                } else {
                    manualCoordinates = nil
                }
            }

            if attachLocation {
                VStack(alignment: .leading, spacing: Spacing.s12) {
                    Divider()
                        .padding(.vertical, 2)
                    
                    HStack(alignment: .center, spacing: Spacing.s8) {
                        if locationManager.isLocating {
                            ProgressView()
                                .tint(Color.accentPrimary)
                            Text("Mencari lokasi...")
                                .font(.cashflowFootnote)
                                .foregroundStyle(Color.textSecondary)
                        } else if let error = locationManager.error {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.cashflowCaption1)
                                .foregroundStyle(Color.stateCritical)
                            Text(error.localizedDescription)
                                .font(.cashflowFootnote)
                                .foregroundStyle(Color.stateCritical)
                        } else if let name = locationManager.locationName {
                            Image(systemName: "location.fill")
                                .font(.cashflowCaption1)
                                .foregroundStyle(Color.accentPrimary)
                            Text(name)
                                .font(.cashflowFootnote)
                                .foregroundStyle(Color.textSecondary)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
                        Button {
                            showMapPicker = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "map")
                                Text("Ubah")
                            }
                            .font(.cashflowCaption1)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.accentPrimary)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(Color.accentPrimary.opacity(0.12), in: Capsule())
                        }
                    }

                    // Render mini Map preview if coordinate exists
                    if let lat = manualCoordinates?.latitude ?? locationManager.location?.coordinate.latitude,
                       let lon = manualCoordinates?.longitude ?? locationManager.location?.coordinate.longitude {
                        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        ZStack(alignment: .bottomTrailing) {
                            Map(position: $mapPosition) {
                                Marker("", coordinate: coord)
                                    .tint(Color.accentPrimary)
                            }
                            .frame(height: 140)
                            .cornerRadius(Radius.md)
                            .onAppear {
                                mapPosition = .region(MKCoordinateRegion(
                                    center: coord,
                                    span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
                                ))
                            }
                            .onChange(of: locationManager.location) { _, newLocation in
                                if let newLoc = newLocation, manualCoordinates == nil {
                                    mapPosition = .region(MKCoordinateRegion(
                                        center: newLoc.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003)
                                    ))
                                }
                            }

                            Button {
                                withAnimation {
                                    mapPosition = .region(MKCoordinateRegion(
                                        center: coord,
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
                .transition(.opacity)
            }
        }
        .padding(Spacing.s16)
        .background(Color.bgSecondary, in: RoundedRectangle(cornerRadius: Radius.sm))
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            Text("Catatan (opsional)")
                .font(.cashflowSubheadline)
                .foregroundStyle(Color.textSecondary)

            TextField("Tambahkan catatan...", text: $note, axis: .vertical)
                .font(.cashflowBody)
                .foregroundStyle(Color.textPrimary)
                .lineLimit(3...6)
                .padding(Spacing.s16)
                .background(Color.bgSecondary, in: RoundedRectangle(cornerRadius: Radius.sm))
        }
    }

    private var attachmentSection: some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            Text("Foto Lampiran (opsional)")
                .font(.cashflowSubheadline)
                .foregroundStyle(Color.textSecondary)

            VStack(alignment: .leading, spacing: Spacing.s12) {
                if let attachedImage {
                    HStack(spacing: Spacing.s12) {
                        Image(uiImage: attachedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .cornerRadius(Radius.xs)
                            .clipped()

                        VStack(alignment: .leading, spacing: Spacing.s4) {
                            Text("Foto terpilih")
                                .font(.cashflowBody)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.textPrimary)
                            
                            HStack(spacing: Spacing.s8) {
                                Button {
                                    showCutterEditor = true
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "wand.and.stars")
                                        Text("Smart Crop")
                                    }
                                    .font(.cashflowCaption1)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.accentPrimary)
                                }

                                Button(role: .destructive) {
                                    self.attachedImage = nil
                                    self.selectedPhotoItem = nil
                                    self.originalPickedImage = nil
                                } label: {
                                    Text("Hapus")
                                        .font(.cashflowCaption1)
                                        .foregroundStyle(Color.stateCritical)
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(Spacing.s12)
                    .background(Color.bgPrimary, in: RoundedRectangle(cornerRadius: Radius.xs))
                } else {
                    HStack(spacing: Spacing.s12) {
                        Button {
                            showCamera = true
                        } label: {
                            HStack(spacing: Spacing.s8) {
                                Image(systemName: "camera.fill")
                                Text("Ambil Foto")
                            }
                            .font(.cashflowBody)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.accentPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(Spacing.s12)
                            .background(Color.accentPrimary.opacity(0.08), in: RoundedRectangle(cornerRadius: Radius.xs))
                        }

                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            HStack(spacing: Spacing.s8) {
                                Image(systemName: "photo.on.rectangle")
                                Text("Galeri")
                            }
                            .font(.cashflowBody)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.accentPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(Spacing.s12)
                            .background(Color.accentPrimary.opacity(0.08), in: RoundedRectangle(cornerRadius: Radius.xs))
                        }
                    }
                }
            }
            .padding(Spacing.s12)
            .background(Color.bgSecondary, in: RoundedRectangle(cornerRadius: Radius.sm))
        }
    }

    private func save() {
        guard let category = selectedCategory, amount > 0 else { return }

        let lat: Double?
        let lon: Double?
        if let manualCoords = manualCoordinates {
            lat = manualCoords.latitude
            lon = manualCoords.longitude
        } else {
            lat = attachLocation ? locationManager.location?.coordinate.latitude : nil
            lon = attachLocation ? locationManager.location?.coordinate.longitude : nil
        }
        let name = attachLocation ? locationManager.locationName : nil

        let imageData = attachedImage?.pngData()

        let tx = Transaction(
            amount: amount,
            type: transactionType,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            date: date,
            category: category,
            latitude: lat,
            longitude: lon,
            locationName: name,
            attachmentImageData: imageData
        )
        modelContext.insert(tx)
        try? modelContext.save()

        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        dismiss()
        onSuccess?()
    }
}
