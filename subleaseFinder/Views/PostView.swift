import SwiftUI
import PhotosUI
import MapKit

struct PostView: View {
    @EnvironmentObject var postFlow: PostFlow
    @EnvironmentObject var authService: AuthServiceProtocol
    
    var body: some View {
        NavigationView {
            Group {
                if !authService.isAuthenticated {
                    AuthRequiredView()
                } else {
                    PostWizardView()
                        .environmentObject(postFlow)
                }
            }
            .navigationTitle("Post Listing")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Auth Required View
struct AuthRequiredView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Sign In Required")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("You need to sign in to post a listing")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Post Wizard View
struct PostWizardView: View {
    @EnvironmentObject var postFlow: PostFlow
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Indicator
            ProgressIndicator(currentStep: postFlow.currentStep)
            
            // Content
            TabView(selection: $postFlow.currentStep) {
                BasicInfoStep()
                    .environmentObject(postFlow)
                    .tag(0)
                
                DetailsStep()
                    .environmentObject(postFlow)
                    .tag(1)
                
                PhotosStep()
                    .environmentObject(postFlow)
                    .tag(2)
                
                ReviewStep()
                    .environmentObject(postFlow)
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: postFlow.currentStep)
            
            // Navigation Buttons
            NavigationButtons()
                .environmentObject(postFlow)
        }
        .sheet(isPresented: $postFlow.showSuccess) {
            SuccessView()
        }
    }
}

// MARK: - Progress Indicator
struct ProgressIndicator: View {
    let currentStep: Int
    private let totalSteps = 4
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? Color.blue : Color(.systemGray4))
                    .frame(width: 12, height: 12)
                    .overlay(
                        Text("\(step + 1)")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    )
                
                if step < totalSteps - 1 {
                    Rectangle()
                        .fill(step < currentStep ? Color.blue : Color(.systemGray4))
                        .frame(height: 2)
                }
            }
        }
        .padding()
    }
}

// MARK: - Basic Info Step
struct BasicInfoStep: View {
    @EnvironmentObject var postFlow: PostFlow
    @State private var showLocationPicker = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Basic Information")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 16) {
                    TextField("Listing Title", text: $postFlow.draft.title)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Description", text: $postFlow.draft.description, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                    
                    HStack {
                        TextField("Price", value: $postFlow.draft.price, format: .currency(code: "USD"))
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                        
                        Text("USD")
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: { showLocationPicker = true }) {
                        HStack {
                            Image(systemName: "location")
                                .foregroundColor(.blue)
                            
                            Text(postFlow.draft.location.isEmpty ? "Select Location" : postFlow.draft.location)
                                .foregroundColor(postFlow.draft.location.isEmpty ? .secondary : .primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    HStack {
                        DatePicker("Start Date", selection: $postFlow.draft.startDate, displayedComponents: .date)
                        
                        DatePicker("End Date", selection: $postFlow.draft.endDate, displayedComponents: .date)
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showLocationPicker) {
            LocationPickerView(
                location: $postFlow.draft.location,
                latitude: $postFlow.draft.latitude,
                longitude: $postFlow.draft.longitude
            )
        }
    }
}

// MARK: - Details Step
struct DetailsStep: View {
    @EnvironmentObject var postFlow: PostFlow
    
    private let amenities = [
        "WiFi", "Gym", "Pool", "Parking", "Laundry", "Dishwasher",
        "Air Conditioning", "Balcony", "Furnished", "Pet Friendly"
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Property Details")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Bedrooms")
                        Spacer()
                        Stepper("\(postFlow.draft.bedrooms)", value: $postFlow.draft.bedrooms, in: 0...5)
                    }
                    
                    HStack {
                        Text("Bathrooms")
                        Spacer()
                        Stepper("\(postFlow.draft.bathrooms, specifier: "%.1f")", value: $postFlow.draft.bathrooms, in: 0.5...5.0, step: 0.5)
                    }
                    
                    TextField("Square Footage (optional)", value: $postFlow.draft.squareFootage, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                    
                    Picker("Property Type", selection: $postFlow.draft.propertyType) {
                        ForEach(SubleaseListing.PropertyType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Toggle("Has Roommates", isOn: $postFlow.draft.hasRoommates)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Amenities")
                            .font(.headline)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            ForEach(amenities, id: \.self) { amenity in
                                Button(action: {
                                    if postFlow.draft.amenities.contains(amenity) {
                                        postFlow.draft.amenities.removeAll { $0 == amenity }
                                    } else {
                                        postFlow.draft.amenities.append(amenity)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: postFlow.draft.amenities.contains(amenity) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(postFlow.draft.amenities.contains(amenity) ? .blue : .secondary)
                                        
                                        Text(amenity)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Photos Step
struct PhotosStep: View {
    @EnvironmentObject var postFlow: PostFlow
    @State private var selectedItems: [PhotosPickerItem] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Photos")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 16) {
                    PhotosPicker(
                        selection: $selectedItems,
                        maxSelectionCount: 10,
                        matching: .images
                    ) {
                        HStack {
                            Image(systemName: "camera")
                                .foregroundColor(.blue)
                            
                            Text("Add Photos")
                                .foregroundColor(.blue)
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .onChange(of: selectedItems) { items in
                        Task {
                            await loadImages(from: items)
                        }
                    }
                    
                    if !postFlow.draft.selectedImages.isEmpty {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(Array(postFlow.draft.selectedImages.enumerated()), id: \.offset) { index, imageData in
                                if let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 150)
                                        .clipped()
                                        .cornerRadius(8)
                                        .overlay(
                                            Button(action: {
                                                postFlow.draft.selectedImages.remove(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.white)
                                                    .background(Color.black.opacity(0.5))
                                                    .clipShape(Circle())
                                            }
                                            .padding(8),
                                            alignment: .topTrailing
                                        )
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private func loadImages(from items: [PhotosPickerItem]) async {
        postFlow.draft.selectedImages.removeAll()
        
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                // Compress and resize image
                if let uiImage = UIImage(data: data),
                   let compressedData = uiImage.jpegData(compressionQuality: 0.8) {
                    await MainActor.run {
                        postFlow.draft.selectedImages.append(compressedData)
                    }
                }
            }
        }
    }
}

// MARK: - Review Step
struct ReviewStep: View {
    @EnvironmentObject var postFlow: PostFlow
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Review & Publish")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 16) {
                    ReviewSection(title: "Basic Info") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(postFlow.draft.title)
                                .font(.headline)
                            
                            Text(postFlow.draft.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(postFlow.draft.formattedPrice)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                            
                            Text(postFlow.draft.location)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("\(postFlow.draft.startDate, style: .date) - \(postFlow.draft.endDate, style: .date)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    ReviewSection(title: "Property Details") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(postFlow.draft.bedrooms) bed, \(postFlow.draft.bathrooms, specifier: "%.1f") bath")
                                .font(.subheadline)
                            
                            if let squareFootage = postFlow.draft.squareFootage {
                                Text("\(squareFootage) sq ft")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(postFlow.draft.propertyType.rawValue.capitalized)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            if postFlow.draft.hasRoommates {
                                Text("Has roommates")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            if !postFlow.draft.amenities.isEmpty {
                                Text("Amenities: \(postFlow.draft.amenities.joined(separator: ", "))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    ReviewSection(title: "Photos") {
                        Text("\(postFlow.draft.selectedImages.count) photos selected")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Review Section
struct ReviewSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            content
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
}

// MARK: - Navigation Buttons
struct NavigationButtons: View {
    @EnvironmentObject var postFlow: PostFlow
    
    var body: some View {
        HStack {
            if postFlow.currentStep > 0 {
                Button("Back") {
                    postFlow.previousStep()
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
            
            if postFlow.currentStep < 3 {
                Button("Next") {
                    postFlow.nextStep()
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Publish") {
                    Task {
                        await postFlow.publishListing()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(postFlow.isPublishing)
                
                if postFlow.isPublishing {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
        }
        .padding()
    }
}

// MARK: - Success View
struct SuccessView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Listing Published!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Your listing is now live and visible to potential tenants.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Location Picker View
struct LocationPickerView: View {
    @Binding var location: String
    @Binding var latitude: Double
    @Binding var longitude: Double
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var body: some View {
        NavigationView {
            VStack {
                Map(coordinateRegion: $region, interactionModes: .all)
                    .onTapGesture { coordinate in
                        latitude = coordinate.latitude
                        longitude = coordinate.longitude
                        // Reverse geocode to get location name
                        reverseGeocode(coordinate: coordinate)
                    }
                
                VStack {
                    TextField("Search location", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    
                    Button("Use Current Location") {
                        // In a real app, you'd request location permission
                        // For now, just use a default location
                        location = "San Francisco, CA"
                        latitude = 37.7749
                        longitude = -122.4194
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Select Location")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Done") { dismiss() }
            )
        }
    }
    
    private func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                let address = [
                    placemark.locality,
                    placemark.administrativeArea
                ].compactMap { $0 }.joined(separator: ", ")
                
                DispatchQueue.main.async {
                    self.location = address
                }
            }
        }
    }
}

// MARK: - Extensions
extension ListingDraft {
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: price as NSDecimalNumber) ?? "\(price)"
    }
}

// MARK: - Preview
struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView()
            .environmentObject(PostFlow(
                listingService: MockListingService(),
                uploadService: MockUploadService()
            ))
            .environmentObject(MockAuthService())
    }
}

// MARK: - Mock Services for Preview
class MockUploadService: UploadServiceProtocol {
    func uploadImage(_ imageData: Data, contentType: String) async throws -> String {
        return "https://example.com/image.jpg"
    }
    
    func uploadImages(_ imageDataArray: [Data], contentType: String) async throws -> [String] {
        return Array(repeating: "https://example.com/image.jpg", count: imageDataArray.count)
    }
}
