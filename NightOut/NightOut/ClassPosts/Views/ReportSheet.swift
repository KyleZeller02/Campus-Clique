//
//  ReportSheet.swift
//  Campus Clique
//
//  Created by Kyle Zeller on 8/9/23.
//

import SwiftUI

struct ReportSheet: View {
    @State private var description:String = ""
    @State private var selectedReportType: ReportType? = nil
    @Environment(\.presentationMode) var presentationMode
    @State private var shouldBlockUser: Bool = false
    @EnvironmentObject var vm: inAppViewVM
    let postable: Any
    
    @State private var showingAlertNoReportChosen: Bool = false
    var body: some View {
        ZStack{
            Color.Black
                .ignoresSafeArea(.all)
            ScrollView{
                
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
                    
                    Spacer()
                    
                    Button {
                        guard let selectedType = selectedReportType else {
                            self.showingAlertNoReportChosen = true
                            return
                        }

                        vm.handleReportOnPost(for: postable, description: description, reportType: selectedType)

                        
                        // Dismiss the modal view when this button is tapped.
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Done")
                            .foregroundColor(.cyan)
                            .bold()
                            .font(.system(size: 18))
                    }
                }
                .padding(.vertical,20)
                .padding(.horizontal,20)
                   
                VStack(alignment: .center, spacing: 10){
                    Text("Report Inappropriate Content")
                        .font(.largeTitle)
                        .foregroundColor(.White)
                        .lineLimit(1)
                        .minimumScaleFactor(0.2)
                        .padding(.horizontal,20)
                        .padding(.bottom,20)
                    
                    Text("Please select why you are reporting this content:")
                        .foregroundColor(.White)
                     
                                            
                    
                    List(ReportType.allCases, id: \.self) { reportType in
                        HStack {
                            Text(reportType.displayText)
                                .foregroundColor(.white)
                            Spacer()
                            if reportType == selectedReportType {
                                Image(systemName: "checkmark") // Checkmark for the selected option
                                    .foregroundColor(.cyan)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // If the selected report type is already selected, set it to nil (deselect), else set to the tapped report type
                            if selectedReportType == reportType {
                                selectedReportType = nil
                            } else {
                                selectedReportType = reportType
                            }
                        }
                        .listRowBackground(Color.Gray) // Set the background color of each row to black
                    }
                    .padding(.bottom,20)
                    .frame(height: 200)
                    .listStyle(PlainListStyle())
                    
                    
                    Text("Please give a brief description (Optional)")
                        .foregroundColor(.White)
                       
                    
                    TextEditor(text: $description)
                        .frame(height: 100)
                        .background(Color.Black)
                        .foregroundColor(.White)
                        .cornerRadius(10)
                        .multilineTextAlignment(.leading)
                        .padding(.leading,10)
                        .padding(.trailing,10)
                        .scrollContentBackground(.hidden)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.cyan, lineWidth: 2)
                                .padding(.leading,10)
                                .padding(.trailing,10)
                        )
                        
                        .onChange(of: description) { newValue in
                            if newValue.count > 400 {
                                description = String(newValue.prefix(400))
                            }
                        }
                        .padding(.bottom,30)
                   
                    Spacer()
                }
            }
        }
        .alert(isPresented: $showingAlertNoReportChosen) {
            Alert(title: Text("No Reason Chosen"), message: Text("Please Select Report Reason"), dismissButton: .default(Text("Got it!")))
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}

enum ReportType: CaseIterable, Identifiable {
    var id: Self { self }
    
    case InappropriateProfilePicture
    case Bullying
    case Spam
    case Harassment
    case OffensiveLanguage
    case CopyrightViolation
    case PrivacyInvasion
    case Impersonation
    case FalseInformation
    case SellingIllegalSubstances
    case Other
    
    var displayText: String {
        switch self {
        case .InappropriateProfilePicture: return "Inappropriate Profile Picture"
        case .Bullying: return "Bullying"
        case .Spam: return "Spam"
        case .Harassment: return "Harassment"
        case .OffensiveLanguage: return "Offensive Language"
        case .CopyrightViolation: return "Copyright Violation"
        case .PrivacyInvasion: return "Privacy Invasion"
        case .Impersonation: return "Impersonation"
        case .FalseInformation: return "False Information"
        case .SellingIllegalSubstances: return "Selling Illegal Substances"
        case .Other: return "Other"
        }
    }
}



//struct ReportSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        ReportSheet()
//    }
//}
