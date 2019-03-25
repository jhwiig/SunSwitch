//
//  main.swift
//  
//
//  Created by Jack Wiig on 3/24/19.
//

import AppKit

let application = NSApplication.shared
let delegate = AppDelegate()

application.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
