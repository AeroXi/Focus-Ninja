import SwiftUI

struct ContentView: View {
    @StateObject private var orientationManager = DeviceOrientationManager()
    @State private var isFocusing = false
    @State private var focusTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var targetDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var isGoalAchieved = false
    
    let feedbackGenerator = UINotificationFeedbackGenerator()
    
    var targetSeconds: Int {
        let components = Calendar.current.dateComponents([.hour, .minute], from: targetDate)
        return (components.hour ?? 0) * 3600 + (components.minute ?? 0) * 60
    }
    
    var progress: Double {
        guard targetSeconds > 0 else { return 0 }
        return min(Double(focusTime) / Double(targetSeconds), 1.0)
    }
    
    var body: some View {
        VStack(spacing: 30) {
            if isFocusing {
                // 专注时的UI保持不变
                ZStack {
                    Circle()
                        .stroke(lineWidth: 20)
                        .opacity(0.3)
                        .foregroundColor(.blue)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.blue)
                        .rotationEffect(Angle(degrees: -90))
                        .animation(.linear, value: progress)
                    
                    VStack {
                        Text(timeString(from: focusTime))
                            .font(.largeTitle)
                        Text("目标: \(timeString(from: TimeInterval(targetSeconds)))")
                            .font(.subheadline)
                    }
                }
                .frame(width: 250, height: 250)
            } else {
                // 使用DatePicker替换原来的Picker
                DatePicker("", selection: $targetDate, displayedComponents: [.hourAndMinute])
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .frame(width: 200, height: 100)
                    .clipped()
                
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
            
            if isGoalAchieved {
                Text("恭喜！您已达成专注目标！")
                    .font(.headline)
                    .foregroundColor(.green)
            }
        }
        .onChange(of: orientationManager.isScreenFacingDown) { oldValue, newValue in
            if isFocusing {
                if newValue {
                    startTimer()
                    provideFeedback()
                } else {
                    stopTimer()
                    checkGoalAchievement()
                }
            }
        }
    }

    func startFocusing() {
        UIApplication.shared.isIdleTimerDisabled = true
        isGoalAchieved = false
        if orientationManager.isScreenFacingDown {
            startTimer()
            provideFeedback()
        } else {
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
    
    func checkGoalAchievement() {
            if Int(focusTime) >= targetSeconds {
                isGoalAchieved = true
            }
        }
}
