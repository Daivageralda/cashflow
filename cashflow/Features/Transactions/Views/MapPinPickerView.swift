import SwiftUI
import MapKit
import CoreLocation

struct MapPinPickerView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Starting coordinates (default: Jakarta or fallback)
    @State private var position: MapCameraPosition
    @State private var selectedCoordinate: CLLocationCoordinate2D
    @State private var locationName: String = "Lokasi Pilihan"
    @State private var isResolving: Bool = false
    
    var onSelect: (CLLocationCoordinate2D, String) -> Void
    
    init(initialLocation: CLLocation?, onSelect: @escaping (CLLocationCoordinate2D, String) -> Void) {
        let coord = initialLocation?.coordinate ?? CLLocationCoordinate2D(latitude: -6.2000, longitude: 106.8166)
        _selectedCoordinate = State(initialValue: coord)
        _position = State(initialValue: .region(MKCoordinateRegion(
            center: coord,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )))
        self.onSelect = onSelect
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $position, interactionModes: .all) {
                    Marker(locationName, coordinate: selectedCoordinate)
                        .tint(Color.accentPrimary)
                }
                .onMapCameraChange { context in
                    // Center the coordinate where map is dragged
                    let center = context.camera.centerCoordinate
                    selectedCoordinate = center
                    resolveAddress(center)
                }
                
                // Overlay center target pin
                Image(systemName: "mappin")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(Color.accentPrimary)
                    .offset(y: -18) // Offset to match map pin anchor
                    .shadow(radius: 4)
                    .allowsHitTesting(false)
                
                VStack {
                    Spacer()
                    VStack(spacing: Spacing.s12) {
                        HStack {
                            Image(systemName: "location.circle.fill")
                                .foregroundStyle(Color.accentPrimary)
                            
                            if isResolving {
                                ProgressView()
                                    .tint(Color.accentPrimary)
                                    .padding(.trailing, Spacing.s4)
                                Text("Mencari alamat...")
                                    .font(.cashflowFootnote)
                                    .foregroundStyle(Color.textSecondary)
                            } else {
                                Text(locationName)
                                    .font(.cashflowSubheadline)
                                    .foregroundStyle(Color.textPrimary)
                                    .lineLimit(2)
                            }
                            Spacer()
                        }
                        
                        Button {
                            onSelect(selectedCoordinate, locationName)
                            dismiss()
                        } label: {
                            Text("Pilih Lokasi Ini")
                                .font(.cashflowBody)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Spacing.s12)
                                .background(Color.accentPrimary, in: RoundedRectangle(cornerRadius: Radius.md))
                        }
                    }
                    .padding(Spacing.s16)
                    .background(Color.bgSecondary)
                    .cornerRadius(Radius.lg)
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                    .padding(Spacing.s16)
                }
            }
            .navigationTitle("Pilih Lokasi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Batal") { dismiss() }
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
    }
    
    private func resolveAddress(_ coordinate: CLLocationCoordinate2D) {
        isResolving = true
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            isResolving = false
            if let placemark = placemarks?.first {
                let name = placemark.name ?? ""
                let subLocality = placemark.subLocality ?? ""
                let locality = placemark.locality ?? ""
                
                if !name.isEmpty {
                    self.locationName = name
                } else if !subLocality.isEmpty {
                    self.locationName = subLocality
                } else {
                    self.locationName = locality
                }
            } else {
                self.locationName = String(format: "%.4f, %.4f", coordinate.latitude, coordinate.longitude)
            }
        }
    }
}
