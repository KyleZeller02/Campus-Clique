//
//  EditProfileVIew.swift
//  Campus Clique
//
//  Created by Kyle Zeller on 6/5/23.
//

import SwiftUI
import Kingfisher

// SwiftUI view for editing the user profile.
struct EditProfileView: View {
    
    // User selected college
    @State private var selectedCollege:String = ""
    // New classes for the user
    @State private var newClass1:String = ""
    @State private var newClass2:String = ""
    @State private var newClass3:String = ""
    @State private var newClass4:String = ""
    @State private var newClass5:String = ""
    @State private var newClass6:String = ""
    // New major for the user
    @State private var newMajor:String = ""
    // New first and last name for the user
    @State private var newFirstName:String = ""
    @State private var newLastName:String = ""
    // Profile picture URL
    //@State private var profilePicture: String? // unused variable, commented out
    // In App View Model object
    @EnvironmentObject var vm: inAppViewVM
    // State to manage the display of image picker
    @State private var isPickerShowing = false
    // Selected image
    @State private var selectedImage: UIImage?
    // State to indicate if the user has changed the image
    @State private var didChangeImage:Bool = false
    // Presentation mode Environment object
    @Environment(\.presentationMode) var presentationMode
    // Search Filter object
    @ObservedObject var filter: SearchFilter = SearchFilter()
    // Focus state of the TextField
    @FocusState private var isTextFieldFocused: Bool
    // State to indicate if the college field is selected
    @State private var isCollegeFieldSelected: Bool = false
    // Alert states
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // Main view body
    var body: some View {
        // Spacer for padding
        Spacer().frame(maxHeight: 10)
        // Main view scroll view
        ScrollView{
            // Container for the profile view
            ZStack{
                // Black background color
                Color.Black.ignoresSafeArea()
                // Container for the profile content
                VStack{
                    // Cancel button view
                    cancelButton
                    // Button for uploading a new profile image
                    Button(action: {
                        // User wants to change the profile image
                        self.didChangeImage = true
                        self.isPickerShowing = true
                    }) {
                        // Display current or placeholder profile image
                        if let image = selectedImage {
                            // User has selected a new image
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 200, height: 200)
                                .clipShape(Circle())
                                .padding(.trailing,10)
                        } else if let urlString = vm.userDoc.profilePictureURL, let url = URL(string: urlString) {
                            // User has a profile image
                            KFImage(url)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 200, height: 200)
                                .clipShape(Circle())
                                .padding(.trailing,10)
                        } else {
                            // User does not have a profile image
                            Image(systemName: "person.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 200, height: 200)
                                .clipShape(Circle())
                                .padding(.trailing,10)
                        }
                    }
                    
                    // User profile fields view
                    fields
                    // User classes fields view
                    classesFields
                    // Filler space
                    Spacer()
                }
                // Action to perform when the view appears
            }.onAppear(){
                // Delay execution of the block of code
                DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                    // Set the search query for the search filter
                    self.filter.searchQuery = self.vm.userDoc.college
                }
                
                // Populate the fields with user's data
                self.newFirstName = vm.userDoc.firstName
                self.newLastName = vm.userDoc.lastName
                self.selectedCollege = vm.userDoc.college
                self.newMajor = vm.userDoc.major
                
                // Populate the classes fields with user's data
                self.newClass1 = vm.userDoc.classes.count > 0 ? vm.userDoc.classes[0] : ""
                self.newClass2 = vm.userDoc.classes.count > 1 ? vm.userDoc.classes[1] : ""
                self.newClass3 = vm.userDoc.classes.count > 2 ? vm.userDoc.classes[2] : ""
                self.newClass4 = vm.userDoc.classes.count > 3 ? vm.userDoc.classes[3] : ""
                self.newClass5 = vm.userDoc.classes.count > 4 ? vm.userDoc.classes[4] : ""
                self.newClass6 = vm.userDoc.classes.count > 5 ? vm.userDoc.classes[5] : ""
            }
            // Image picker view
            .sheet(isPresented: $isPickerShowing, onDismiss: nil) {
                ImagePicker(selectedImage: $selectedImage, isPickerShowing: $isPickerShowing)
            }
        }
        // Gesture to hide the keyboard and deselect the college field when tapped outside
        .onTapGesture {
            hideKeyboard()
            self.isCollegeFieldSelected = false
        }
    }
    
    // This is a computed property which returns a view containing the "Cancel" and "Done" buttons.
    private var cancelButton: some View {
        // Horizontally stack the buttons.
        HStack{
            // The "Cancel" button.
            Button {
                // Dismiss the modal view when this button is tapped.
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Cancel")
                    .foregroundColor(.cyan)
                    .font(.system(size: 18))
            }
            // Push the next button to the edge.
            Spacer()
            // The "Done" button.
            Button {
                // Check if the selected college is valid.
                if !filter.colleges.contains(filter.searchQuery) {
                    // Show an alert message if the college is not valid.
                    alertMessage = "The college you selected is not within the list to choose from."
                    showAlert = true
                } else {
                    // Trim white spaces and new lines.
                    filter.searchQuery = filter.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Extract the list of new classes, remove empty ones.
                    let classes = [newClass1, newClass2, newClass3, newClass4, newClass5, newClass6]
                        .compactMap { $0 }
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                    
                    // Prepare for checking if each field is changed.
                    let fieldMapping: [(value: String, key: String, comparison: String)] = [
                        (newMajor.trimmingCharacters(in: .whitespacesAndNewlines), "major", vm.userDoc.major),
                        (filter.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines), "college", vm.userDoc.college),
                        (newFirstName.trimmingCharacters(in: .whitespacesAndNewlines), "first_name", vm.userDoc.firstName),
                        (newLastName.trimmingCharacters(in: .whitespacesAndNewlines), "last_name", vm.userDoc.lastName)
                    ]
                    
                    // The set of fields that have been changed.
                    var changedFields: Set<String> = []
                    // Dictionary to hold the new values of the fields.
                    var updatedValues: [String:Any] = [:]
                    
                    // Check each field for changes.
                    fieldMapping.forEach {
                        if $0.value != $0.comparison {
                            // If the field value has changed, add it to the set of changed fields and the dictionary of updated values.
                            changedFields.insert($0.key)
                            updatedValues[$0.key] = $0.value
                        }
                    }
                    
                    // Check if the classes are changed.
                    let oldClasses = Set(vm.userDoc.classes)
                    let newClasses = Set(classes)
                    if oldClasses != newClasses {
                        // If the classes have changed, add it to the set of changed fields and the dictionary of updated values.
                        changedFields.insert("classes")
                        updatedValues["classes"] = Array(newClasses)
                    }
                    
                    // Check if the profile picture is changed.
                    if didChangeImage {
                        // If the profile picture has changed, add it to the set of changed fields and the dictionary of updated values.
                        changedFields.insert("profile_picture")
                        updatedValues["profile_picture"] = selectedImage
                    }
                    
                    // Call the function to handle the updates.
                    vm.handleEdit(changedFields: changedFields, updatedValues: updatedValues)
                    
                    // Dismiss the modal view.
                    presentationMode.wrappedValue.dismiss()
                }
            } label: {
                Text("Done")
                    .foregroundColor(.cyan)
                    .bold()
                    .font(.system(size: 18))
            }
        }.padding(.horizontal,20)
            .alert(isPresented: $showAlert) {
                // Alert view for showing the error message when the college is not valid.
                Alert(title: Text("Invalid College"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
    }
    
    
    // This computed property returns a group of input fields, each represented by a label and a TextField.
    private var fields: some View {
        Group {
            // Each call to field(_:, text:) generates an HStack with a text label and a TextField bound to the supplied string.
            field("First Name: ", text: $newFirstName)
            divider  // cyan-colored divider
            field("Last Name: ", text: $newLastName)
            divider  // cyan-colored divider
            VStack {
                HStack{
                    // The label for the college input field.
                    Text("College: ")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    // The TextField for the college input. This TextField's text is bound to the searchQuery of the filter.
                    // When this TextField's text changes, setSearchQuery(to:) is called on the filter with the new value.
                    // When this TextField is tapped, isCollegeFieldSelected is set to true, which shows a list of selectable colleges.
                    TextField("Your College", text: $filter.searchQuery)
                        .padding(.vertical, 12)
                        .padding(.horizontal,3)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white, lineWidth: 1))
                        .onChange(of: filter.searchQuery) { newValue in
                            filter.setSearchQuery(to: newValue)
                        }
                        .focused($isTextFieldFocused)
                        .onTapGesture {
                            self.isCollegeFieldSelected = true
                        }
                }
                .padding(.bottom, 10)
                // A list of selectable colleges that is shown when the college TextField is tapped.
                if isCollegeFieldSelected{
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(filter.colleges, id: \.self) { college in
                                Button(action: {
                                    // When a college is selected, the TextField's text is set to the selected college,
                                    // validateSearchQuery() is called on the filter, and the TextField loses focus.
                                    self.filter.searchQuery = college
                                    self.filter.validateSearchQuery()
                                    isTextFieldFocused = false
                                }) {
                                    Text(college)
                                        .padding(10)
                                        .background(Color.Gray)
                                        .foregroundColor(.White)
                                        .cornerRadius(8)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .padding(.vertical, 10)
                    }
                    .frame(maxHeight: 300)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(10)
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .padding(.horizontal)
            .background(Color.black.opacity(0.8))
            .cornerRadius(20)
            .padding(.top, 10)
            .onChange(of: isTextFieldFocused) { newValue in
                // When the TextField loses focus, validateSearchQuery() is called on the filter.
                if !newValue {
                    self.filter.validateSearchQuery()
                }
            }
            divider  // cyan-colored divider
            field("Major: ", text: $newMajor)
            divider  // cyan-colored divider
        }
    }
    
    // This computed property returns a view containing TextFields for the classes.
    private var classesFields: some View {
        HStack {
            Text("Classes:")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.leading)
            Spacer()
            VStack(spacing: 10) {
                // The classes are arranged in two rows.
                // Each CustomTextField is bound to a different class string.
                HStack(spacing: 10) {
                    CustomTextField(placeholder: "CIS115", text: $newClass1)
                    CustomTextField(placeholder: "ECON500", text: $newClass2)
                    CustomTextField(placeholder: "MRK367", text: $newClass3)
                }
                HStack(spacing: 10) {
                    CustomTextField(placeholder: "MATH222", text: $newClass4)
                    CustomTextField(placeholder: "ARCH435", text: $newClass5)
                    CustomTextField(placeholder: "BIO349", text: $newClass6)
                }
            }
        }.padding(.horizontal).background(Color.black.opacity(0.8))
    }
    
    // This function returns a TextField with a label.
    private func field(_ label: String, text: Binding<String>) -> some View {
        HStack {
            // The label for the TextField.
            Text(label)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.leading)
            Spacer()
            // The TextField. The text of this TextField is bound to the supplied string.
            TextField("Placeholder", text: text)
                .padding(.vertical, 12)
                .padding(.horizontal,3)
                .background(Color.gray)
                .foregroundColor(.white)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white, lineWidth: 1))
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }.padding(.horizontal)
    }
    
    // This computed property returns a cyan-colored divider.
    private var divider: some View {
        Divider()
            .background(Color.cyan)
            .padding([.leading, .trailing])
    }
}


// a preview for the editprofile view
struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
    }
}

// This struct is a custom SwiftUI View, that wraps a TextField with predefined styling.
struct CustomTextField: View {
    var placeholder: String  // The placeholder string that will be displayed in the TextField when it's empty.
    @Binding var text: String  // A binding to the string that will be updated as the TextField's text changes.
    
    // The SwiftUI body of the view.
    var body: some View {
        TextField(placeholder, text: $text)
            .padding(.vertical, 12)
            .padding(.horizontal,3)
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white, lineWidth: 1))
            .disableAutocorrection(true)
            .autocapitalization(.allCharacters)  // All characters entered into the TextField will be automatically capitalized.
    }
}

// This class manages the state and behavior of the search filter.
class SearchFilter: ObservableObject {
    var allColleges: [String] = []  // A list of all colleges.
    
    @Published var searchQuery = ""  // The current search query.
    @Published var colleges: [String] = []  // The list of colleges that match the current search query.
    @Published var lastValidCollege = ""  // The last valid college that was entered into the search field.
    
    private var searchTimer: Timer? = nil  // A timer used to delay the execution of the search query.
    
    init() {
        allColleges = parseUniversityList()
        colleges = allColleges
        print("Count:  \(allColleges.count)")
    }
    
    // This function sets the search query and then updates the list of matching colleges after a delay of 0.5 seconds.
    func setSearchQuery(to newValue: String) {
        searchQuery = newValue
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            
            if self.searchQuery.isEmpty {
                // If the search query is empty, show all colleges.
                self.colleges = self.allColleges
                self.lastValidCollege = ""
            } else {
                // Filter colleges based on the search query.
                let filteredColleges = self.allColleges.filter { college in
                    college.lowercased().contains(self.searchQuery.lowercased())
                }
                self.colleges = filteredColleges
                
                // If the search query matches exactly one college, store it as the last valid college.
                if filteredColleges.count == 1 && filteredColleges[0].lowercased() == self.searchQuery.lowercased() {
                    self.lastValidCollege = filteredColleges[0]
                }
            }
        }
    }
    
    // This function validates the search query. If the search query doesn't match a valid college, it reverts the search query to the last valid college.
    func validateSearchQuery() {
        if !self.allColleges.contains(self.searchQuery) {
            // If the search query is not a valid college, revert to the last valid college.
            self.searchQuery = self.lastValidCollege
        }
    }
}

// This function reads a list of universities from a text file and returns an array of university names.
func parseUniversityList() -> [String] {
    guard let fileURL = Bundle.main.url(forResource: "List", withExtension: "txt") else {
        print("File not found")
        return []
    }
    
    do {
        let content = try String(contentsOf: fileURL, encoding: .utf8)
        let lines = content.split(whereSeparator: \.isNewline)
        
        return lines.compactMap { line in
            let components = line.split(separator: "\t")
            return components.count >= 2 ? String(components[1]) : nil
        }
    } catch {
        print("Error reading file: \(error)")
        return []
    }
}

