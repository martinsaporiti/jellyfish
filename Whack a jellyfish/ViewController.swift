//
//  ViewController.swift
//  Whack a jellyfish
//
//  Created by Martin Saporiti on 07/05/2018.
//  Copyright © 2018 Martin Saporiti. All rights reserved.
//

import UIKit
import ARKit
class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var playButton: UIButton!
    
    let configuration = ARWorldTrackingConfiguration();
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,
                                       ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.session.run(configuration);
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    @IBAction func play(_ sender: Any) {
        self.addNode()
        self.playButton.isEnabled = false
    }
    
    
    
    @IBAction func reset(_ sender: Any) {
    
    }
    
    
    /**
     
     
    */
    func addNode(){
//        let node = SCNNode(geometry: SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0))
//        node.position = SCNVector3(0, 0, -1)
//        node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
//        node.name = "Sapo"
//        self.sceneView.scene.rootNode.addChildNode(node)
        
        let jellyFishScene = SCNScene(named: "art.scnassets/Jellyfish.scn")
        let jellyFishNode = jellyFishScene?.rootNode.childNode(withName: "jellyfish", recursively: false)
        jellyFishNode?.position = SCNVector3(0, 0, -1)
        self.sceneView.scene.rootNode.addChildNode(jellyFishNode!)
    }
    
    
    /**
        Evento que se ejecuta cuando tocamos la pantalla
     
        * Parameters:
            + sender: UITapGestureRecognizer
    */
    @objc func handleTap(sender: UITapGestureRecognizer){
        
        // Aquí validamos que la positicón si se hizo "tap" sobre la medusa.
        let sceneViewTappedOn = sender.view as! SCNView
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        // hitest tendra información sobre el objeto que se encontraba en la posición
        // sobre la que se hizo tap.
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        
        
        if(hitTest.isEmpty){
            print(("didn't tocuh anything"))
        } else {
            let results = hitTest.first!
            let node = results.node
            
            // Se valida que no esté ejecutando una animación previa
            if(node.animationKeys.isEmpty){
                self.animateNode(node: node)
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
}

