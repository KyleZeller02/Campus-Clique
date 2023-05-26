import SwiftUI

struct AddPostView: View {
    @State private var postBody:String = ""
    @FocusState private var focused:Bool
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ClassPostsViewModel
    
    
    init(viewModel: ClassPostsViewModel) {
        UITextView.appearance().backgroundColor = .clear
        self.viewModel = viewModel
    }
    func setFocus() {
        focused = true
    }
    var body: some View {
        
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("Add A Post to \(viewModel.selectedClass)")
                    .foregroundColor(.cyan)
                    .font(.largeTitle)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading,20)
                
                VStack {
                   
                    TextEditor(text: $postBody)
                                            .frame(height: 300)
                                            .colorMultiply(.gray)
                                            .cornerRadius(10)
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
        .onAppear(perform: setFocus)
        
        
        
    }
    
}

//struct AddPostView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddPostView()
//    }
//}
