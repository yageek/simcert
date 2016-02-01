//
//  AppDelegate.swift
//  SimCert
//
//  Created by Yannick Heinrich on 29.01.16.
//  Copyright © 2016 Yannick Heinrich. All rights reserved.
//

import Cocoa
import ApplicationServices.HIServices

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    
    var analyzer: ElementsAnalyzer?
    var statusBarItem: NSStatusItem?
        
    @IBOutlet weak var statusItem: NSMenuItem!
    @IBOutlet weak var iconMenu: NSMenu!

    //!MARK: - App lifecycle
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        print("Starting agent...")
        
        buildMenu()
        // Check if API Enabled
        
        let value = kAXTrustedCheckOptionPrompt.takeUnretainedValue()
        let options: [String:AnyObject] = [value as String: (true as CFBooleanRef)]
        if(AXIsProcessTrustedWithOptions(options)){
            
            startAnalyzer()
        }
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    

    //!MARK: - App Menu
    
    func buildMenu() {
        
        // Status item
        let item = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        
        item.image = NSImage(named: "sim_cert")
        item.image?.template = true
        item.highlightMode = true
        
        item.toolTip = "Tool tip"
        item.action = "actionItemTriggered:"
        
        item.menu = iconMenu
        
        statusBarItem = item
    }
    
    @IBAction func aboutItemTriggered(sender: AnyObject?){
        print("About")
        
    }
    
    func actionItemTriggered(sender: AnyObject?){
        print("Triggered")
    }
    
    
    @IBAction func quitItemTriggered(sender: AnyObject) {
        shutdown()
    }
    
    func shutdown(){
        NSApp.terminate(nil)
    }

    //!MARK: - Analyzer
    
    func startAnalyzer() {
        self.analyzer = ElementsAnalyzer()
        
        if let windows = self.analyzer?.simulatorWindows() {
            
            for w in windows {
                print("Window: \(w)")
                
                let actor = SimulatorOperator(simulator: w)
                actor.makeSimulatorVisible()
                // First Install
                actor.searchButtonAndClick("Install")
                
                NSThread.sleepForTimeInterval(3.0)
                actor.searchButtonAndClick("Install")

                // Need to be done two time
                NSThread.sleepForTimeInterval(3.0)
                //actor.searchButtonAndClick("Install")
                actor.searchButtonAndClickQuartzCore("Install")
                
                NSThread.sleepForTimeInterval(3.0)
                actor.searchButtonAndClick("Done")

                
            }
        }
    }

}
