//
//  AppearanceChanger.swift
//  SunSwitch
//
//  Created by Jack Wiig on 3/21/19.
//  Copyright © 2019 Jack Wiig. All rights reserved.
//

import Foundation
import Cocoa

class AppearanceChanger {
 
    // MARK: - Properties

    // Timer to keep track of next change. Initialize to not fire
    var timer: Timer = Timer()
    
    // DateFormatter that will be used to take a string and convert it to an absolute date
    let sunDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()
    
    
    let lightPath = Bundle.main.url(forResource: "setLightMode",
                                    withExtension: "scpt",
                                    subdirectory: "AppleScripts")!
    
    let darkPath = Bundle.main.url(forResource: "setDarkMode",
                                   withExtension: "scpt",
                                   subdirectory: "AppleScripts")!
    
    // MARK: - Methods
    
    // INIT: Start the cycle
    init() {
        
        // Create a notification to update the timer when the computer wakes from sleep mode
        NSWorkspace.shared.notificationCenter.addObserver(self,
                                                          selector: #selector(setCurrentMode),
                                                          name: NSWorkspace.didWakeNotification,
                                                          object: nil)
        setCurrentMode()
    }
    
    // Change the mode to what it currently should be (in case of wake from sleep or first launch)
    @objc func setCurrentMode() {
        
        let nextAction = getNextSunAction()
        
        // Here, we want to set the mode to the OPPOSITE of what is next.
        // So check if sunrise is next, and if so, set it to dark mode (as sunset has passed)
        let path = nextAction.0 == "sunrise" ? darkPath : lightPath
        
        // Run AppleScript to Set Mode
        let script = NSAppleScript(contentsOf: path, error: nil)
        script?.executeAndReturnError(nil)
        
        // Set a timer to change to the next mode
        setNextSwitch(nextAction)
    }
    
    // Set the next time the theme will switch
    func setNextSwitch(_ nextAction: (String, Date)) {
        
        // If the next switch is sunrise, set the path to lightmode, but if next path is sunset, set to dark
        let path = nextAction.0 == "sunrise" ? lightPath : darkPath
        
        // Create the timer to fire the next action
        timer = Timer(fireAt: nextAction.1,
                      interval: 0,
                      target: self, selector: #selector(setMode(sender:)),
                      userInfo: path,
                      repeats: false)
    }

    
    // Gets the sunrise and sunset times and returns whichever will occur next
    func getNextSunAction() -> (String, Date) {
    
        let data = runSunSchedule()
        
        // Convert the data to a string and split it to isolate time values
        guard let sunScheduleString = String(data: data, encoding: .utf8) else { fatalError() }
        let splitString = sunScheduleString.split(separator: "\"")
        
        // Isolate sunrise and sunset times
        var sunrise = sunDateFormat.date(from: String(splitString[9]))!
        var sunset = sunDateFormat.date(from: String(splitString[11]))!

        let time = Date()
        
        // First make sure both times haven't passed
        if time > sunrise && time > sunset {
            // Set the sunrise to the next sunrise and next sunset
            sunrise = sunDateFormat.date(from: String(splitString[1]))!
            sunset = sunDateFormat.date(from: String(splitString[3]))!
            
            // If setting these is not enough, then keep adding days until something is in the future
            // This is a best estimate of sunrise that should only occur if the user has not connected to
            // Wi-Fi in over two days.
            while time > sunrise && time > sunset {
                sunrise = Calendar.current.date(byAdding: .day, value: 1, to: sunrise)!
                sunset = Calendar.current.date(byAdding: .day, value: 1, to: sunset)!
            }
        }
        
        // Check if the following conditions are met:
        // Sunrise is before Sunset OR Sunset has already passed
        // AND check that sunrise has also not yet passed
        // NOTE: current time is stored in new instance of Date()
        if (sunrise < sunset || sunset < time) && sunrise > time {
            return ("sunrise", sunrise)
        }
        
        return ("sunset", sunset)
    }

    // This function creates a process and executes it to get sunrise and sunset times
    func runSunSchedule() -> Data {

        // Create the process and set the parameters
        let sunProcess = Process()
        sunProcess.launchPath = "/usr/bin/corebrightnessdiag"
        sunProcess.arguments = ["sunschedule"]
        
        // Create the pipe
        let pipe = Pipe()
        sunProcess.standardOutput = pipe
        sunProcess.launch()
        
        // Get the output of the process in data
        return pipe.fileHandleForReading.readDataToEndOfFile()
    }
    
    // Runs the Applescript to set the mode
    @objc func setMode(sender: Timer) {
        let script = NSAppleScript(contentsOf: sender.userInfo as! URL, error: nil)
        script?.executeAndReturnError(nil)
        setNextSwitch(getNextSunAction())
    }
}
