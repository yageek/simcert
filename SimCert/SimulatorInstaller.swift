//
//  SimulatorInstaller.swift
//  SimCert
//
//  Created by Yannick Heinrich on 04.02.16.
//  Copyright © 2016 Yannick Heinrich. All rights reserved.
//

import Foundation

class SimulatorInstaller {
    
    static let WAIT_STEP_SEC = 10.0
    static let deltaTime = dispatch_time(DISPATCH_TIME_NOW, Int64(SimulatorInstaller.WAIT_STEP_SEC * Double(NSEC_PER_SEC)))

    let UUID: NSUUID
    let certificate: NSURL
    
    var simulatorWindow: SimulatorWindow?
    
    let analyzer = ElementsAnalyzer()
    
    init(uuid:NSUUID, certificate: NSURL){
        self.UUID = uuid
        self.certificate = certificate
    }
 
    
    func install(){
            print("=== Start installing \(self.UUID.UUIDString) with \(self.certificate)")
        
            startSimulator()
            openURL()
            installCertificateSequence()
    }

    func startSimulator(){
        
        let task = NSTask()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["-a",  "Simulator",  "--args",  "-CurrentDeviceUDID", self.UUID.UUIDString]
        task.launch()
        task.waitUntilExit()
        
        print("Start Simulator Termination: \(task.terminationStatus)")
        
        NSThread.sleepForTimeInterval(15.0)
        simulatorWindow = self.analyzer.simulatorWindows()[0]
        print("Windows:\(simulatorWindow)")

    }
    
    func openURL(){
        
        NSThread.sleepForTimeInterval(5.0)
        
        let task = NSTask()
        task.launchPath = "/usr/bin/xcrun"
        task.arguments = ["simctl", "openurl", "booted", certificate.absoluteString]
        task.launch()
        task.waitUntilExit()
        
        print("Open URL Termination: \(task.terminationStatus)")
    }
    
    func installCertificateSequence(){
        guard let simulatorWindow = self.simulatorWindow else { print("Simulator does not seems to be launched"); return }
        
        let op = SimulatorOperator(simulator: simulatorWindow)
        
        // First Install
        NSThread.sleepForTimeInterval(5.0)
        print("=== First Page ")
        op.searchButtonAndClick("Install")
        NSThread.sleepForTimeInterval(1.0) //Don't know why but needs to be done two times OR start the simulator first
        op.searchButtonAndClick("Install")
        
        NSThread.sleepForTimeInterval(5.0)
        print("=== Second Page ")
        op.searchButtonAndClick("Install")
        
        // Need to be done two time
        NSThread.sleepForTimeInterval(5.0)
        //actor.searchButtonAndClick("Install")
        print("=== Popup Page ")
        op.searchButtonAndClickQuartzCore("Install")
        
        NSThread.sleepForTimeInterval(5.0)
        print("=== Done Page ")
        op.searchButtonAndClick("Done")

        NSThread.sleepForTimeInterval(3.0)
    }
    
    func closeSimulator() {
        
        let task = NSTask()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", "quit app \"Simulator\""]
        task.launch()
        task.waitUntilExit()
        
        print("Close Simulator Termination: \(task.terminationStatus)")

    }
}