//
//  AddPostView.swift
//  NightOut
//
//  Created by Kyle Zeller on 5/17/23.
//

import SwiftUI

struct AddPostView: View {
    @State private var postBody:String = ""
    
    
    
    var body: some View {
        ZStack{
            Color.Black
                .ignoresSafeArea()
            VStack{
                
                Text("Add A Post To Your Class!")
                    .padding()
                    .background(Color.Purple)
                    .foregroundColor(.white)
                    .cornerRadius(5.0)
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
                    
                    Text("\(400-postBody.count)")
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                        .background(Color.Purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .font(.headline)
                     
                }
                Spacer()
                Button(action: {
                    //logout method
                   
                }) {
                    
                      
                }
                
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
