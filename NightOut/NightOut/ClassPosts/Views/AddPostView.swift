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
        
        ZStack{
            Color.Black
                .ignoresSafeArea()
            VStack{
                
                Text("Add A Post to \(viewModel.selectedClass)")
                    .padding()
                    .background(Color.Purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                    .font(.headline)
                
                
                VStack(alignment: .leading){
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
                        .focused($focused)
                    HStack{
                        Text("\(400-postBody.count)")
                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                            .background(Color.Purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .font(.headline)
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                           
                        }) {
                            Text("Cancel")
                                .font(.headline)
                                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                                .background(Color.Purple)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                              
                        }
                        Spacer()
                        Button(action: {
                            let trimmedString = postBody.trimmingCharacters(in: .whitespacesAndNewlines)
                                                       if !trimmedString.isEmpty {
                                                           viewModel.addNewPost(postBody)
                                                       }
                                                       presentationMode.wrappedValue.dismiss()
                           
                           
                        }) {
                            Text("Send")
                                .font(.headline)
                                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                                .background(Color.Purple)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                              
                        }
                        
                    }
                    
                     
                }
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
