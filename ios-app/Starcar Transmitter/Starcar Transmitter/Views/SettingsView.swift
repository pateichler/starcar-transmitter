//
//  SettingsView.swift
//  Starcar Transmitter
//
//  Created by Patrick Eichler on 2/27/25.
//

import SwiftUI
import PopupView

struct SettingsView: View {
    @StateObject private var settings = Settings.instance
    @StateObject private var apiKeyManager = APIKeyManager.instance
    @State private var showAPI = false
    @State private var deleteKeyConfirmation = false
    @State private var setKeyPopUp = false;
    
    var body: some View {
        ZStack{
            VStack{
                Text("Settings")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .padding(.bottom, 50)
                //            Spacer()
                VStack(spacing: 20){
                    Toggle(isOn: $settings.mockDevice, label: {
                        Text("Mock Bluetooth Device")
                    })
                    VStack{
                        HStack{
                            Text("API Key")
                            Spacer()
                            if(apiKeyManager.apiKey != nil){
                                Button(showAPI ? "Hide" : "Show"){
                                    showAPI.toggle()
                                }
                                Button("Delete"){
                                    deleteKeyConfirmation = true
                                }
                            }else{
                                Button("Set key"){
                                    setKeyPopUp = true
                                }
                            }
                        }.buttonStyle(.bordered)
                        if(showAPI && apiKeyManager.apiKey != nil){
                            ClipboardText(text: apiKeyManager.apiKey ?? "")
                        }
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .confirmationDialog("test", isPresented: $deleteKeyConfirmation, actions: {
            Button("Delete key", role: .destructive){
                do{
                    try apiKeyManager.deleteKey()
                }catch{
                    print("Error could not delete key!")
                }
            }
            Button("Cancel", role: .cancel){
                deleteKeyConfirmation = false
            }
        })
        .popup(isPresented: $setKeyPopUp){
            SetAPIKeyView()
        }customize: { $0
            .position(.bottom)
            .backgroundColor(.black.opacity(0.4))
            .closeOnTap(false)
            .useKeyboardSafeArea(true)
        }
        
    }
}

struct ClipboardText: View{
    let text: String
    @State private var copied = false

    var body: some View {
        HStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                Text(text)
                    .font(.system(size: 12, design: .monospaced))
                    .lineLimit(1)
                    .padding(.vertical, 12)
            }
            
            Button(action: {
                UIPasteboard.general.string = text
                withAnimation {
                    copied = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation { copied = false }
                }
            }) {
                Image(systemName: copied ? "checkmark" : "doc.on.clipboard")
                    .foregroundColor(.blue)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.horizontal, 12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }
}

#Preview {
    SettingsView()
}
