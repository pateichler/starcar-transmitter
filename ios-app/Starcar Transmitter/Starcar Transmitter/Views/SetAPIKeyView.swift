//
//  SetAPIKeyView.swift
//  Starcar Transmitter
//
//  Created by Patrick Eichler on 2/27/25.
//

import SwiftUI

struct SetAPIKeyView: View{
//    @Binding var isPresented: Bool
    @Environment(\.popupDismiss) var dismiss
    
    @State private var apiKey: String = ""
    
    var body: some View {
        VStack(spacing: .zero){
            Color.primary
                .opacity(0.2)
                .frame(width: 30, height: 6)
                .clipShape(Capsule())
                .padding(.top, 15)
                .padding(.bottom, 20)
            
            Text("Set API Key")
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            Text("Description text of API key")
                .padding(.bottom, 20)
            VStack(spacing: 20){
                TextField("API key", text: $apiKey)
                    .autocorrectionDisabled()
                    .border(.secondary)
                
                Button("Set key"){
                    do{
                        try APIKeyManager.instance.addKey(apiKey: apiKey)
                        dismiss?()
//                        isPresented = false
                    }catch{
                        print("Error in setting key! \(error)")
                    }
                    
                }.buttonStyle(BorderedButtonStyle())
            }.padding(.horizontal, 20)
        }
        .padding(EdgeInsets(top: 0, leading: 24, bottom: 100, trailing: 24))
        .background(Color(UIColor.secondarySystemBackground)
            .cornerRadius(20))
//        .shadow(color: Color.white, radius: 20)
//        UIColor.secondarySystemBackground
        
//        .background(Color.white.cornerRadius(20))
//        .background(Color.red.cornerRadius(20))
        
    }
}

struct SetAPIKeyView_Previews: PreviewProvider{
    static var previews: some View{
        SetAPIKeyView()
            .background(.blue)
            .previewLayout(.sizeThatFits)
    }
}

//#Preview {
//    SetAPIKeyView()
//        .background(.blue)
//        .previewLayout(.sizeThatFits)
//}

