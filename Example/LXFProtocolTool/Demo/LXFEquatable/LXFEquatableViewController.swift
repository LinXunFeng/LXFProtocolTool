//
//  LXFEquatableViewController.swift
//  LXFProtocolTool_Example
//
//  Created by LinXunFeng on 2021/9/3.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import LXFProtocolTool

class LXFEquatableViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        
        let bcc = BCC()
        print("bcc -- \(bcc.lxf.randomId) -- \(bcc)")
        print("bcc -- \(bcc.lxf.randomId) -- \(bcc)")
        bcc.lxf.updateRandomId()
        print("bcc -- \(bcc.lxf.randomId) -- \(bcc)")
        print("bcc -- \(bcc.lxf.randomId) -- \(bcc)")
        
        
        let bdd = BDD()
        print("bdd -- \(bdd.lxf.randomId) -- \(bdd)")
        print("bdd -- \(bdd.lxf.randomId) -- \(bdd)")
        bdd.lxf.updateRandomId()
        print("bdd -- \(bdd.lxf.randomId) -- \(bdd)")
        print("bdd -- \(bdd.lxf.randomId) -- \(bdd)")

        let bee = BEE()
        print("bee -- \(bee.lxf.randomId) -- \(bee)")
        print("bee -- \(bee.lxf.randomId) -- \(bee)")
        bee.lxf.updateRandomId()
        print("bee -- \(bee.lxf.randomId) -- \(bee)")
        print("bee -- \(bee.lxf.randomId) -- \(bee)")
    }
}


struct BCC: LXFEquatable {
    var lxf_randomId: String = Self.generateRandomId()
}

class BDD: LXFEquatable {
    
}

class BEE: NSObject, LXFEquatable {
    
}
