import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var orientationManager = DeviceOrientationManager()
    @State private var isFocusing = false
    @State private var focusTime: TimeInterval = 0
    @State private var timer: Timer?
    
    let feedbackGenerator = UINotificationFeedbackGenerator()
    
    var body: some View {
        VStack {
            if isFocusing {
                Text(timeString(from: focusTime))
                    .font(.largeTitle)
            } else {
                Button(action: {
                    isFocusing = true
                    startFocusing()
                }) {
                    Text("开始专注")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 200)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                .shadow(radius: 10)
            }
        }
        .onChange(of: orientationManager.isScreenFacingDown) { oldValue, newValue in
            if isFocusing {
                if newValue {
                    startTimer()
                    provideFeedback()
                } else {
                    stopTimer()
                }
            }
        }
    }
    
    func startFocusing() {
        UIApplication.shared.isIdleTimerDisabled = true
        if orientationManager.isScreenFacingDown {
            startTimer()
            provideFeedback()
        } else {
            // 提示用户翻转手机
            print("请将手机屏幕朝下放置")
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            focusTime += 1
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    func provideFeedback() {
        feedbackGenerator.prepare()
        feedbackGenerator.notificationOccurred(.success)
    }
}
