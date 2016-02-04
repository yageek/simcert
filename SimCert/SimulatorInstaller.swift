//
//  SimulatorInstaller.swift
//  SimCert
//
//  Created by Yannick Heinrich on 04.02.16.
//  Copyright © 2016 Yannick Heinrich. All rights reserved.
//

import Foundation

class SimulatorInstaller {
    
    static let WAIT_STEP_SEC = 5.0
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
        
        simulatorWindow = self.analyzer.waitUntilSimulatorLaunched()
        print("Windows:\(simulatorWindow)")

    }
    
    func openURL(){
        
        guard let simulatorWindow = self.simulatorWindow else { print("Simulator does not seems to be launched"); return }
        
        let op = SimulatorOperator(simulator: simulatorWindow)
        op.makeSimulatorVisible()
        
        if(!op.waitForHomeScreen()){
            print("Could not reach home screen")
            return
        }

        
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
        op.makeSimulatorVisible()
        
        if(!op.waitForInstallScreen()){
            print("Could not find install screen")
            return
        }
        
        // First Install
        op.searchButtonAndClick("Install")
        
        NSThread.sleepForTimeInterval(3.0)
        op.searchButtonAndClick("Install")
        
        // Need to be done two time
        NSThread.sleepForTimeInterval(3.0)
        //actor.searchButtonAndClick("Install")
        op.searchButtonAndClickQuartzCore("Install")
        
        NSThread.sleepForTimeInterval(3.0)
        op.searchButtonAndClick("Done")

        NSThread.sleepForTimeInterval(3.0)
    }
    
    func closeSimulator() {
        
        let task = NSTask()
        task.launchPath = "/usr/bin/osascript"
        task.arguments = ["-e", "quit app \"Calendar\""]
        task.launch()
        task.waitUntilExit()
        
        print("Close Simulator Termination: \(task.terminationStatus)")

    }
}