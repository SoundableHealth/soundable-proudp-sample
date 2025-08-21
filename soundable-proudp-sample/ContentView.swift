//
//  ContentView.swift
//  soundable-proudp-sample
//
//  Created by Tony Kim on 10/5/24.
//

import SwiftUI
import SoundableProudpLib

class RecordingDelegate: NSObject, SoundableProudpLibDelegate {
    var onCallInterrupt: (() -> Void)?
    
    func recordingDidCancelDueToCallInterrupt() {
        DispatchQueue.main.async {
            self.onCallInterrupt?()
        }
    }
}

struct ContentView: View {
    @State private var isButtonPressed = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var recordTime = "00:00"
    let soundableProudpLib = SoundableProudpLib()
    let recordingDelegate = RecordingDelegate()

    var body: some View {
        VStack {
            Text(recordTime)
                .padding()
                .onAppear {
                    _ = timer.upstream.connect()
                }
                .onReceive(timer) { _ in
                    recordTime = SoundableProudpLib.recordTime
                }
            Button(action: {
                withAnimation {
                    isButtonPressed.toggle()
                }
                if isButtonPressed {
                    // TODO, need to change userId, gender, clinic
                    // gender: "m"(male), "f"(female, not support)
                    // clinic: company or clinic name
                    soundableProudpLib.startRecording(userId: "soundableTest", gender: "m", clinic: "soundable")
                } else {
                    soundableProudpLib.stopRecording()
                }
                
            }) {
                Circle()
                    .fill(isButtonPressed ? Color.red : Color.gray)
                    .frame(width: 100, height: 100)
                    .scaleEffect(isButtonPressed ? 1.1 : 1)
                    .overlay(
                        Text(isButtonPressed ? "Rec" : "Start")
                            .foregroundColor(.white)
                    )
            }
            .onAppear {
                print("onAppear")
                // TODO, Add "microphone usage description" in info.plist
                soundableProudpLib.checkPermission()
                soundableProudpLib.setServerConfig(serverUrl: serverApiUrl, apiKey: xApiKey, websocketUrl: webSocketUrl)
                recordingDelegate.onCallInterrupt = { [self] in
                    handleCallInterrupt()
                }
                soundableProudpLib.delegate = recordingDelegate
                
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("SoundableProudpLib"))) { notification in
                // TODO, handle the result
                if let result = notification.userInfo?["result"] as? String {
                    print("received result", result)
                }
            }
            
            // appear cancel button
            if isButtonPressed {
                Button("Cancel") {
                    isButtonPressed = false
                    soundableProudpLib.cancelRecording()
                }
                .padding()
            }
        }
    }
    
    func handleCallInterrupt() {
        // TODO, Close recording UI, show an alert or notification to the user, etc.
        isButtonPressed = false
        print("Recording was cancelled due to incoming call")
    }
    
}


#Preview {
    ContentView()
}
