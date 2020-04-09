//
//  ViewController.swift
//  SignLanguage
//
//  Created by Joao Flores on 21/02/20.
//  Copyright © 2020 Joao Flores. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    enum State {
        case welcome
        case running
    }
    //    MARK: - Variables
    var pickerData: [String] = ["-", "A", "B", "C", "D", "E", "F", "G", "H", "I", "L"]
    var state = State.welcome
    var lastLocation = CGPoint.zero
    var initLocation = CGPoint.zero
    var handNode: SCNNode!
    var animateTimer: Timer?
    
    var XvalueAnimate: Double = 0
    var YvalueAnimate: Double = 0
    var valueAnimate = 0
    var YpositionsAnimate: [Double] = [0.5,0.5,0,0,-0.5,-0.5]
    
    var currentScale = SCNVector3(1.3,1.3,1.3)
    var currentAngle = SCNVector3(0, 0, 0)
    
    //    MARK: - IBOutlets
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var pickerViewAlphabet: UIPickerView!
    
    @IBOutlet weak var viewInitButton: UIView!
    
    @IBAction func initButton(_ sender: Any) {
        state = State.running
        updateHand(row: 0)
        viewInitButton.alpha = 0
    }
    
    //    MARK: - Life Cycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pickerViewAlphabet.delegate = self as UIPickerViewDelegate
        self.pickerViewAlphabet.dataSource = self as UIPickerViewDataSource
    
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.pinch(_:)))
        self.view.addGestureRecognizer(pinch)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    //    MARK: - 3DHand Functions
    
    func updateHand(row: Int) {
        if(state == State.running) {
            let valueSelected = pickerData[row] as String
            
            var position = SCNVector3(0, 0, -0.5)
            
            if(pickerData[pickerViewAlphabet.selectedRow(inComponent: 0)] == "C") {
                position = SCNVector3(0.05, 0, -0.5)
            }
            
            let scene = SCNScene(named:
                "\(valueSelected)-Hand.scn")
            
            handNode = scene!.rootNode.childNode(withName: "hand", recursively: true)
            handNode?.removeFromParentNode()
            handNode?.position = position
            handNode?.scale = SCNVector3(1.3, 1.3, 1.3)
            for x in sceneView.scene.rootNode.childNodes {
                x.removeFromParentNode()
            }
            
            sceneView.scene.rootNode.addChildNode(handNode!)
            
            if(valueSelected == "H") {
                handNode.eulerAngles =
                    SCNVector3(0, -1, 0)
                animateTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(playAnimate), userInfo: nil, repeats: true)
            }
        }
    }
    
    @objc func playAnimate() {
        XvalueAnimate = XvalueAnimate + 0.3
        YvalueAnimate = YvalueAnimate + YpositionsAnimate[valueAnimate]
        valueAnimate = valueAnimate + 1
        if(valueAnimate > 5) {
            valueAnimate = 0
            handNode.eulerAngles =
            SCNVector3(0, 0, 0)
            XvalueAnimate = 0
            YvalueAnimate = 0
            animateTimer?.invalidate()
        }
        
        handNode.eulerAngles =
            SCNVector3(Double(YvalueAnimate), Double(Double(XvalueAnimate) + 0.3), 0)
    }
    
    
    //    MARK: - Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        initLocation = (touches.first?.location(in: nil))!
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: nil)
            
            handNode.eulerAngles = SCNVector3(CGFloat(currentAngle.x) + (location.y - initLocation.y)*0.02, CGFloat(currentAngle.y) + (location.x - initLocation.x)*0.05, 0)
            
            lastLocation = location
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentAngle = handNode.eulerAngles
    }
    
    @objc func pinch(_ gesture:UIPinchGestureRecognizer) {
        handNode.scale = SCNVector3(CGFloat(currentScale.x) + CGFloat(gesture.scale/2), CGFloat(currentScale.y) + CGFloat(gesture.scale/2), CGFloat(currentScale.z) + CGFloat(gesture.scale/2))
    }
    
//    MARK: - PickerView
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
 
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent  component: Int) {
        updateHand(row: row)
    }
    
    //    MARK: - Style
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
