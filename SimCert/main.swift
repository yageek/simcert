//
//  main.swift
//  simcert
//
//  Created by Yannick Heinrich on 05.02.16.
//  Copyright © 2016 Yannick Heinrich. All rights reserved.
//

import Foundation


let UUIDArgument = "-uuid";
let CertificateArgument = "-certificate";

var args  = NSProcessInfo().arguments

//!MARK: - Helpers

func printUsage() {
    print("Usage: SimCert.app -uuid <UUID> -certificate <path> ")
}


func getArgumentWithOption(opt: String) -> String? {
    
    if let index = args.indexOf(opt) where args.count >= (index + 1) {
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
    
    let installer = SimulatorInstaller(uuid: UUID, certificate: NSURL(fileURLWithPath: filePath))
    
    installer.install()
    installer.closeSimulator()
    exit(1)
}

//!MARK: - Main

let value = kAXTrustedCheckOptionPrompt.takeUnretainedValue()
let options: [String:AnyObject] = [value as String: (true as CFBooleanRef)]

if(!AXIsProcessTrustedWithOptions(options)){
    
    print("You need to give access to accessibility API")
    exit(1)
}


guard let uuid = getArgumentWithOption(UUIDArgument), let certificate = getArgumentWithOption(CertificateArgument) else {
    print("Missing parameters")
    printUsage()
    exit(1)
}


install(uuid, path: certificate)




