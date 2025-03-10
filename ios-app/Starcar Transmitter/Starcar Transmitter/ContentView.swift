//
//  ContentView.swift
//  Starcar Transmitter
//
//  Created by Patrick Eichler on 2/14/25.
//

import SwiftUI
import PopupView

struct ContentView: View {
    @StateObject private var dataController = DataController.instance
    @State private var setKeyPopUp = false;
    
    func checkAPIKey() async {
        try? await Task.sleep(for: .seconds(2))
        if !APIKeyManager.instance.hasKey() {
            self.setKeyPopUp = true
        }
    }
    
    var body: some View {
        if dataController.recording {
            RecordingView()
        }else{
            if dataController.isRecap{
                RecapView()
            }else{
                NavigationStack{
                    VStack{
                        NavigationLink(destination: {
                            SettingsView()
                        }, label: {
                            Text("Settings")
                        })
                        Spacer()
                        CreateRecordingView()
                        Spacer()
                    }
                }
                .popup(isPresented: $setKeyPopUp){
                    SetAPIKeyView()
                }customize: { $0
                    .position(.bottom)
                    .backgroundColor(.black.opacity(0.4))
                    .closeOnTap(false)
                    .useKeyboardSafeArea(true)
                }.task(checkAPIKey)
            }
        }
    }
}

struct CreateRecordingView: View {
    @StateObject private var dataController = DataController.instance
    @StateObject private var bluetoothReader = DataController.instance.bluetoothReader
    @StateObject private var apiKeyManager = APIKeyManager.instance
    @StateObject private var settings = Settings.instance
    
    var body: some View {
        VStack {
            Text("Create your recording")
            Button("Start", action: dataController.newRecording)
                .disabled((bluetoothReader.ready == false && settings.mockDevice == false) || !apiKeyManager.hasKey())
        }
        .padding()
    }
}

struct RecordingView: View {
    @StateObject private var dataController = DataController.instance
    @StateObject private var bluetoothReader = DataController.instance.bluetoothReader
    @StateObject private var motionReader = DataController.instance.motionReader
    
    var body: some View {
        VStack {
            Text("Recording")
            HStack{
                if dataController.isPaused{
                    Button("Resume", action: dataController.resumeRecording)
                }else{
                    Button("Pause", action: dataController.pauseRecording)
                }
                Button("Stop", action: dataController.stopRecording)
            }.padding()
            
            HStack{
                Text("Gauge 1: \(bluetoothReader.gauge1)")
                Spacer()
                Text("Gauge 2: \(bluetoothReader.gauge2)")
            }
            HStack{
                Text("X: \(String(format: "%.3f", motionReader.accel.x))")
                Text("Y: \(String(format: "%.3f", motionReader.accel.y))")
                Text("Z: \(String(format: "%.3f", motionReader.accel.z))")
            }
        }
        .padding(.horizontal, 20)
    }
}

struct RecapView: View {
    @StateObject private var dataController = DataController.instance
    var body: some View {
        VStack{
            if dataController.isFinished{
                Text("Submitted recording!")
                Button("Done", action: dataController.backToHome)
            }else{
                Text("Submitting recording...")
            }
            
        }
    }
}

#Preview {
    ContentView()
}
