//
//  ViewController.swift
//  NumberIdentifier
//
//  Created by Karl McPhee on 11/30/23.
//

import UIKit
import CoreML
import Vision
import PencilKit

class ViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {

    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var identificationLabel: UILabel!
    
    let canvasWidth: CGFloat = 768
    let canvasOverscrollHeight: CGFloat = 500
    var drawing = PKDrawing()
    let toolPicker = PKToolPicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        canvasView.delegate = self
        canvasView.drawing = drawing
        canvasView.alwaysBounceVertical = true
        canvasView.allowsFingerDrawing = true
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.marker, color: .green, width: 30.0)

    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    
    @IBAction func identifyDrawing(_ sender: Any) {
        
        var image = canvasView.drawing.image(from: canvasView.drawing.bounds, scale: 10.0)
        
        let newSize = CGSize(width: 28, height: 28) //Resizing is important for accuracy
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y:0, width: newSize.width, height: newSize.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        defer { UIGraphicsEndImageContext() }
        let newimage = CIImage(image: UIGraphicsGetImageFromCurrentImageContext()!)
 
        if let model = try? VNCoreMLModel(for: MNISTClassifier().model) {
            let request = VNCoreMLRequest(model: model) {(vnrequest, error) in
                if let results = vnrequest.results as? [VNClassificationObservation] {
                    if results.count > 0 {
                        let topResult = results.first
                        
                        DispatchQueue.main.async {
                            let confidenceLevel = (topResult?.confidence ?? 0)*100
                            
                            self.identificationLabel.text = topResult?.identifier
                        }
                    }
                }
            }
            let handler = VNImageRequestHandler(ciImage: newimage!)
                  DispatchQueue.global(qos: .userInteractive).async {
                    do {
                    try handler.perform([request])
                    } catch {
                        print("error")
                    }
            }
        }
    }
    @IBAction func clearCanvas(_ sender: Any) {
        canvasView.drawing = PKDrawing()
    }
}
