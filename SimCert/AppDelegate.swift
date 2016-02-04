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
    
    
    static let UUIDArgument = "-uuid";
    static let CertificateArgument = "-certificate";
    
    lazy var args  = NSProcessInfo().arguments
    
    
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
            
            parseArgument()
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
    
    //!MARK: - Arguments
    func parseArgument() {
        guard let uuid = getArgumentWithOption(AppDelegate.UUIDArgument), let certificate = getArgumentWithOption(AppDelegate.CertificateArgument) else {
            print("Missing parameters")
            printUsage()
            shutdown()
            return
        }
        

        install(uuid, path: certificate)
    }
    
    func printUsage() {
        print("Usage: SimCert.app -uuid <UUID> -certificate <path> ")
    }
    
    func getArgumentWithOption(opt: String) -> String? {

        if let index = self.args.indexOf(opt) where args.count >= (index + 1) {
            return args[index + 1];
        }
        return nil;
    }
    
    //!MARK: - Installation
    func install(uuidString: String, path: String){
        
        guard let UUID = NSUUID(UUIDString: uuidString) else {
            
            print("Invalid UUID parameters")
            return
        }
    
        var filePath = path
        if filePath.containsString("~"){
            filePath = (filePath as NSString).stringByExpandingTildeInPath
        }
        
        if !NSFileManager.defaultManager().fileExistsAtPath(filePath) {
            print("Invalid path");
            return
        }
        
        let installer = SimulatorInstaller(uuid: UUID, certificate: NSURL(fileURLWithPath: path))
        
        installer.install()
        installer.closeSimulator()
        shutdown()
    }
    

}
