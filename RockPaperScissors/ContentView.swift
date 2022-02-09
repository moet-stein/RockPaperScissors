//
//  ContentView.swift
//  RockPaperScissors
//
//  Created by Moe Steinmüller on 2022/01/31.
//

import SwiftUI

struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color(red: 1.0, green: 0.2, blue: 0.2, opacity: 0.6))
            .font(.largeTitle)
            .foregroundColor(.white)
    }
}



struct ContentView: View {
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    @State private var appChoice = choices.randomElement()
    @State private var time = 0.0
    @State private var started = false
    @State private var animationAmount = 1.0
    @State private var showingNext = false
    @State private var gameIsDone = false
    @State private var win = Bool.random()
    @State private var correctPoints = 0
    @State private var wrontPoints = 0
    @State private var userAnswer: String?
    @State private var result = ""
    
    static var choices = ["Rock", "Paper", "Scissors"]
    
    
    var correctAnswer: String {
        switch appChoice {
        case "Rock":
            switch win {
            case true:
                return "Paper"
            case false:
                return "Scissors"
            }
        case "Paper":
            switch win {
            case true:
                return "Scissors"
            case false:
                return "Rock"
            }
        case "Scissors":
            switch win {
            case true:
                return "Rock"
            case false:
                return "Paper"
            }
        default:
            return "Rock"
        }
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0, blue: 1.0, opacity: 0.2)
                .ignoresSafeArea()
            
            VStack {
                Spacer()

                Button(started ? "Playing.." : "Start", action: startBtnPushed)
                        .buttonStyle(GrowingButton())
                        .disabled(started == true)
                        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                .stroke(.red)
                                .scaleEffect(animationAmount)
                                .opacity(2 - animationAmount)
                                .animation(
                                    .easeInOut(duration: 1)
                                        .repeatForever(autoreverses: true),
                                    value: animationAmount)
                        )
                        .opacity(started ? 0 : 1)
                        .onAppear {
                            animationAmount = 2
                        }
                
                
                
                HStack {
                    Text(String(format: "%.1f seconds", time))
                        .onReceive(timer) { _ in
                            if gameIsDone {
                                time = time
                            } else if !gameIsDone && !started {
                                time = 0.0
                            } else {
                                time += 0.1
                            }
                        }
                        .font(.largeTitle)
                        .foregroundColor(.purple)
                }
                
                Spacer()
                
                VStack {
                    Image(appChoice!)
                        .resizable()
                        .frame(width: 120, height: 120)
                        .padding(.bottom, 30)
                    Text(win ? "WIN" : "LOSE")
                        .font(.largeTitle)
                        .bold()
                        .frame(width: 250, height: 32, alignment: .center)
                        .padding()
                        .background(.teal)
                        .foregroundColor(.white)
                    
                }
                .padding(.bottom, 20)
                
                
                VStack {
                    Text("Tap the correct answer")
                        .font(.title)
                        .foregroundColor(.purple)
                        .frame(width: 300, height: 32, alignment: .center)
                        .padding(.bottom, 35)
                    
                    HStack {
                        ForEach(ContentView.choices, id: \.self) { choice in
                            Button {
                                answerTapped(choice)
                            } label: {
                                Image(choice)
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .padding(.horizontal, 8)
                            }
                            .disabled(started == false)
                        }
                    }
                }
                .padding(.vertical, 30)
                
                Spacer()
                
                HStack {
                    VStack {
                        Text("CORRECT")
                        Text(String(correctPoints))
                            .font(.largeTitle)
                    }
                    .padding(.horizontal)
                    .foregroundColor(.blue)
                    
                    VStack {
                        Text("WRONG")
                        Text(String(wrontPoints))
                            .font(.largeTitle)
                    }
                    .padding(.horizontal)
                    .foregroundColor(.pink)
                }
                .padding(.bottom, 50)
                
                
            }
        }
        .alert(result, isPresented: $showingNext) {
            Button("Continue", action: askQuestion)
        } message: {
            if result == "WRONG" {
                Text("Wrong! The correct answer is \(correctAnswer)")
            } else {
                Text("Correct! Your current score is \(correctPoints)")
            }
            
        }
        .alert("Finished!", isPresented: $gameIsDone) {
            Button("Retry", action: reset)
        } message: {
            VStack {
                Text("Correctly answered \(correctPoints) / \(correctPoints + wrontPoints). \n Time: \(String(format: "%.1f seconds", time))")
            }
        }
    }
    
    func answerTapped(_ userAnswer: String) {
        ContentView.choices.shuffle()
        if userAnswer == correctAnswer {
            correctPoints += 1
            result = "CORRECT"
        } else {
            wrontPoints += 1
            result = "WRONG"
        }
        showingNext = true
    }
    
    func askQuestion() {
        if correctPoints + wrontPoints >= 8 {
            gameIsDone = true
        } else {
            appChoice = ContentView.choices[Int.random(in: 0..<ContentView.choices.count)]
            win = Bool.random()
        }
    }
    
    func reset() {
        correctPoints = 0
        wrontPoints = 0
        appChoice = ContentView.choices[Int.random(in: 0..<ContentView.choices.count)]
        win = Bool.random()
        time = 0.0
        started = false
        animationAmount = 2.0
    }
    
    func startBtnPushed() {
        appChoice = ContentView.choices[Int.random(in: 0..<ContentView.choices.count)]
        win = Bool.random()
        started = true
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
