//
//  ElementsAnalyzer.swift
//  CertOSX
//
//  Created by Yannick Heinrich on 30.01.16.
//  Copyright © 2016 Yannick Heinrich. All rights reserved.
//


import Cocoa


struct SimulatorWindow {
    let ownerName: String
    let windowName: String
    let PID: Int
    var bounds: CGRect
    var windowID: Int
}

class ElementsAnalyzer {
    

        
    
    class func rawSimulatorWindows() -> [[String:AnyObject]]{
        
        if let windowsList = CGWindowListCopyWindowInfo(.OptionOnScreenOnly, 0){
            
            let count = CFArrayGetCount(windowsList)
            
            var infos: [[String:AnyObject]] = []
            
            for index in 0..<count{
                if let info = unsafeBitCast(CFArrayGetValueAtIndex(windowsList, index), NSDictionary.self) as? [String:AnyObject] {
                    
                    infos.append(info)
                }
            }
            return infos
        }
        
        
        fatalError("Unpredictable behaviour")
    }
    
    func simulatorWindows() -> [SimulatorWindow] {
        
        
        let allWindows = ElementsAnalyzer.rawSimulatorWindows()
        let simulatorWindows = allWindows.filter { (info) -> Bool in
            if let ownerName = info[kCGWindowOwnerName as String] as? String {
               return ownerName.containsString("Simulator")
            }
            return false
        }
        
        var uniqWindowsID:[Int] = []
        return simulatorWindows.map({ (info) -> SimulatorWindow in
            
            if let ownerName = info[kCGWindowOwnerName as String] as? String,
                   windowsName = info[kCGWindowName as String] as? String,
                   pid  = info[kCGWindowOwnerPID as String] as? Int,
                   boundsDict = info[kCGWindowBounds as String] as? NSDictionary,
                   windowID = info[kCGWindowNumber as String] as? Int

            {
                var rect = CGRect()
                CGRectMakeWithDictionaryRepresentation(boundsDict, &rect)
                return SimulatorWindow(ownerName: ownerName, windowName: windowsName, PID: pid, bounds: rect, windowID: windowID)
            }
    
            fatalError("Could not retrieve value")
            
        }).filter({ (sim) -> Bool in
            
            let pid = sim.windowID
            let windowsName = sim.windowName
            
            if !uniqWindowsID.contains(pid) && windowsName != "" {
                uniqWindowsID.append(pid)
                return true
            }
            
            return false
            
        })
    }
}