import SwiftUI

struct AddPostView: View {
    @State private var postBody:String = ""
    @FocusState private var focused:Bool
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: inAppViewVM
    
    
    init() {
        UITextView.appearance().backgroundColor = .clear
        setFocus()
    }
    func setFocus() {
        focused = true
    }
    var body: some View {
        
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("Add a Post to \(viewModel.selectedClass)")
                    .foregroundColor(.cyan)
                    .font(.largeTitle)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading,20)
                
                VStack {
                   
                    TextEditor(text: $postBody)
                        .frame(height: 300)
                        .background(Color.Black)
                        .foregroundColor(Color.White)
                        .cornerRadius(10)
                        .padding(.leading,10)
                        .padding(.trailing,10)
                        .scrollContentBackground(.hidden)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.cyan, lineWidth: 2)
                                .padding(.leading,10)
                                .padding(.trailing,10)
                        )
                        .font(.headline)
                        .onChange(of: postBody) { newValue in
                            if newValue.count > 400 {
                                postBody = String(newValue.prefix(400))
                            }
                        }

                                            
                    
                    HStack {
                        Text("\(400 - postBody.count)")
                            .foregroundColor(.cyan)
                            .padding(.trailing, 10)
                        
                        Spacer()
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Cancel")
                                .foregroundColor(.cyan)
                        }
                        .padding(.trailing, 10)
                        
                        Button(action: {
                            let trimmedString = postBody.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmedString.isEmpty {
                                viewModel.addNewPost(postBody)
                            }
                            
                            presentationMode.wrappedValue.dismiss()
                            // Add your post submission logic here
                        }) {
                            Text("Send")
                                .foregroundColor(.white)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.cyan, lineWidth: 2)
                                )
                        }
                        .padding(.trailing, 10)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
                
                Spacer()
            }
            
        }

        
        
        
    }
    
}

struct AddPostView_Previews: PreviewProvider {
    static var previews: some View {
        AddPostView()
    }
}
