//
//  ViewController.swift
//  Whack a jellyfish
//
//  Created by Martin Saporiti on 07/05/2018.
//  Copyright © 2018 Martin Saporiti. All rights reserved.
//

import UIKit
import ARKit
import Each
class ViewController: UIViewController {

   
    
    let seconds : Int = 10
    let node_name = "jelly"
    
    var timer = Each(1).seconds
    var countdown : Int = 10
    var score = 0
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var labelScore: UILabel!
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var playButton: UIButton!
    
    let configuration = ARWorldTrackingConfiguration();
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,
                                       ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.session.run(configuration);
        self.restoreTimer()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    @IBAction func play(_ sender: Any) {
        self.setTimer()
        self.initScore()
        self.addNode()
        let count = self.sceneView.scene.rootNode.childNodes.count
        print("cantidad de nodos en el play", count)
        self.playButton.isEnabled = false
    }
    
    
    
    @IBAction func reset(_ sender: Any) {
        self.timer.stop()
        self.restoreTimer()
        self.playButton.isEnabled = true
        self.sceneView.scene.rootNode.enumerateChildNodes{ (node, _) in
            node.removeFromParentNode()
        }
    }
    
    func initScore(){
        self.score = 0
        self.labelScore.text = String(self.score)
    }
    
    func addPoint(){
        self.score += 1
        self.labelScore.text = String(self.score)
    }
    
    
    /**
     
     
    */
    func addNode(){
        let jellyFishScene = SCNScene(named: "art.scnassets/Jellyfish.scn")
        let jellyFishNode = jellyFishScene?.rootNode.childNode(withName: "jellyfish", recursively: false)
        jellyFishNode?.position = SCNVector3(self.randomNumbers(firstNum: -1, secondNum: 1), self.randomNumbers(firstNum: -0.5, secondNum: 0.5), self.randomNumbers(firstNum: -1, secondNum: 1))
        jellyFishNode?.name = self.node_name
        self.sceneView.scene.rootNode.addChildNode(jellyFishNode!)
    }
    
    
    /**
        Evento que se ejecuta cuando tocamos la pantalla
     
        * Parameters:
            + sender: UITapGestureRecognizer
    */
    @objc func handleTap(sender: UITapGestureRecognizer){
        
        if (sender.state == UIGestureRecognizerState.ended){
        
            if (playButton.isEnabled == false) {
                // Aquí validamos que la positicón si se hizo "tap" sobre la medusa.
                let sceneViewTappedOn = sender.view as! SCNView
                let touchCoordinates = sender.location(in: sceneViewTappedOn)
                // hitest tendra información sobre el objeto que se encontraba en la posición
                // sobre la que se hizo tap.
                let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)

                let count = self.sceneView.scene.rootNode.childNodes.count
                if(hitTest.isEmpty){
                    print(("didn't tocuh anything"))
                    print("cantidad de nodos", count)
                } else {
                    if countdown > 0 {
                        let results = hitTest.first!
                        let node = results.node
                        if(node.name == self.node_name){
                            print("cantidad de nodos por el else", count)
                            // Se valida que no esté ejecutando una animación previa
                            if(node.animationKeys.isEmpty){
                                SCNTransaction.begin()
                                self.animateNode(node: node)

                                SCNTransaction.completionBlock = {
                                    self.addPoint()
                                    node.removeFromParentNode()
                                    self.addNode()
                                    self.restoreTimer()
                                }
                                SCNTransaction.commit()
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    /**
        Esta función craa la animación de la medusa basada en su posición y
        se la agrega al nodo que recibe como parámtro.
     
        * Parameters:
            + node: SCNNode - nodo al que se le agrega la animación.
     
    */
    func animateNode(node: SCNNode){
        let spin = CABasicAnimation(keyPath: "position")
        // obtenemos la posición actual del nodo.
        spin.fromValue = node.presentation.position
        spin.toValue = SCNVector3(node.presentation.position.x - 0.2, node.presentation.position.y - 0.2, node.presentation.position.z - 0.2)
        spin.duration = 0.07
        spin.repeatCount = 5
        spin.autoreverses = true
        node.addAnimation(spin, forKey: "position")
    }
 
    
    func setTimer(){
        self.timer.perform{ () -> NextStep in
            self.countdown -= 1
            self.timerLabel.text = String(self.countdown)
            if self.countdown == 0{
                self.timerLabel.text = "You Lose"
                return .stop
            } else {
                return .continue
            }
        }
    }
    
    
    func restoreTimer(){
        self.countdown = self.seconds
        self.timerLabel.text = String(self.countdown)
    }
    
    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
}



