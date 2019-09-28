//
//  AppDelegate.swift
//  Unboxer
//
//  Created by Brendan Molloy on 2019-09-28.
//  Copyright © 2019 Brendan Molloy. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        NSApp.terminate(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        do {
            let parentPath = URL(fileURLWithPath: filename).deletingLastPathComponent().path
            print("Parent path: \(parentPath)")
            let boxFile = try BoxFileReader.open(path: filename)
            print("Extract")
            try boxFile.extractAll(to: parentPath)
        } catch {
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.messageText = "Extraction Failed"
            if let error = error as? BoxError {
                alert.informativeText = error.message
            } else {
                alert.informativeText = "\(error)"
            }
            alert.runModal()
            print("\(error)")
            return false
        }
        
        return true
    }
}

struct BoxError: Error {
    let message: String
}

fileprivate func checkForBoxError() throws {
    if box_file_err != nil {
        defer {
            box_error_free()
        }
        throw BoxError(message: String(cString: box_file_err))
    }
}

class BoxFileReader {
    private let handle: UnsafeMutableRawPointer
    
    private init(handle: UnsafeMutableRawPointer) {
        self.handle = handle
    }
    
    static public func open(path: String) throws -> BoxFileReader {
        let bytes = path.utf8CString
        let response = bytes.withUnsafeBufferPointer {
            return box_file_reader_open($0.baseAddress!, box_error_callback)
        }
        try checkForBoxError()
        if let response = response {
            return BoxFileReader(handle: response)
        } else {
            throw BoxError(message: "BoxFileReader pointer was null")
        }
    }
    
    public func extractAll(to path: String) throws {
        let bytes = path.utf8CString
        bytes.withUnsafeBufferPointer {
            box_file_reader_extract_all(self.handle, $0.baseAddress!, box_error_callback)
        }
        try checkForBoxError()
    }
}
