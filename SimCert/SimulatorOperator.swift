//
//  WindowsOperator.swift
//  SimCert
//
//  Created by Yannick Heinrich on 31.01.16.
//  Copyright © 2016 Yannick Heinrich. All rights reserved.
//

import Foundation

import ApplicationServices.HIServices
import CoreGraphics

class SimulatorOperator {
    
    let simulatorWindow: SimulatorWindow
    let uxElement: Unmanaged<AXUIElement>
    
    init(simulator: SimulatorWindow) {

        uxElement = AXUIElementCreateApplication(Int32(simulator.PID))
        simulatorWindow = simulator
        
        uxElement.retain()
    }
    
    deinit {
        uxElement.release()
    }
    
    func makeSimulatorVisible () {
        
        let visibleError: AXError = AXUIElementSetAttributeValue(uxElement.takeUnretainedValue(), kAXFrontmostAttribute, kCFBooleanTrue)
        
        if visibleError != .Success {
            print("Error:\(visibleError.rawValue)")
        }
    }
    
    func searchButtonAndClick (title: String) {
        
        guard let element = SimulatorOperator.findElement(uxElement.takeUnretainedValue(), role: kAXButtonRole, title: title) else {
            return
        }
        
       let clickError =  AXUIElementPerformAction(element, kAXPressAction)
        
        if clickError != .Success {
            print("Could not click:\(clickError.rawValue)")
        }
        
    }
    
    func searchButtonAndClickQuartzCore(title: String) {
        guard let element = SimulatorOperator.findElement(uxElement.takeUnretainedValue(), role: kAXButtonRole, title: title) else {
            return
        }
        

        let positionPointer : UnsafeMutablePointer<AnyObject?> = UnsafeMutablePointer<AnyObject?>.alloc(1)
        AXUIElementCopyAttributeValue(element, kAXPositionAttribute, positionPointer)
        
        let position = positionPointer.memory as! AXValue

        var pt = CGPoint()
        AXValueGetValue(position, .CGPoint, &pt)
        
        
        let sizePointer : UnsafeMutablePointer<AnyObject?> = UnsafeMutablePointer<AnyObject?>.alloc(1)
        AXUIElementCopyAttributeValue(element, kAXSizeAttribute, sizePointer)
        
        let size = sizePointer.memory as! AXValue
        var siz = CGSize()
        AXValueGetValue(size, .CGSize, &siz)
        
        
        let elementFrame = CGRect(origin: pt, size: siz)
        let clickPosition = CGPoint(x: CGRectGetMidX(elementFrame), y: CGRectGetMidY(elementFrame))
        
        let clickDownEvent = CGEventCreateMouseEvent(nil, .LeftMouseDown, clickPosition, .Left)
        let clickUpEvent = CGEventCreateMouseEvent(nil, .LeftMouseUp, clickPosition, .Left)
        
        CGEventPost(.CGHIDEventTap, clickDownEvent)
        
        NSThread.sleepForTimeInterval(1.0)

        CGEventPost(.CGHIDEventTap, clickUpEvent)
    }
    
    class func findElement(root:AXUIElement, role: String, title: String) -> AXUIElement? {
        let rolePointer : UnsafeMutablePointer<AnyObject?> = UnsafeMutablePointer<AnyObject?>.alloc(1)
        let titlePointer : UnsafeMutablePointer<AnyObject?> = UnsafeMutablePointer<AnyObject?>.alloc(1)

        AXUIElementCopyAttributeValue(root, kAXRoleAttribute, rolePointer)
        AXUIElementCopyAttributeValue(root, kAXTitleAttribute, titlePointer)
        
        guard let currentRole = rolePointer.memory as? String,
              let currentTitle = titlePointer.memory as? String else { return nil }
        
        print("<\(currentRole): \(currentTitle)>")
        
        if role == currentRole && currentTitle == title {
            return root
        } else {
            let childrenPointer : UnsafeMutablePointer<AnyObject?> = UnsafeMutablePointer<AnyObject?>.alloc(1)
            AXUIElementCopyAttributeValue(root, kAXChildrenAttribute, childrenPointer)
            
            guard let children = childrenPointer.memory as? [AXUIElement] else { return nil }
            
            var element: AXUIElement?
            
            for child in children {
                element = SimulatorOperator.findElement(child, role: role, title: title)
                
                if let element = element {
                    return element
                }
            }
            
            return nil
            
        }
    }
    
}