//
//  ViewController.swift
//  PostCards
//
//  Created by Cristian Sedano Arenas on 28/9/18.
//  Copyright © 2018 Cristian Sedano Arenas. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController,
                      UICollectionViewDataSource,
                      UICollectionViewDelegate,
                      UICollectionViewDragDelegate,
                      UIDropInteractionDelegate,
                      UIDragInteractionDelegate{
    
    @IBOutlet weak var postcardImageView: UIImageView!
    @IBOutlet weak var colorCollectionView: UICollectionView!
    
    var colors = [UIColor]()
    
    var image : UIImage?
    var topText = "Welcome to IOS 11"
    var bottomText = "This is just  an example"
    var topFontName = "Avenir Next"
    var bottomFontName = "Baskerville"
    var topFontColor = UIColor.white
    var bottomFontColor = UIColor.white
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.colors += [.black, .gray, .white, .red, .orange, .yellow,
                        .green, .cyan, .blue, .purple, .magenta]
        
        for hue in 0...9{
            for sat in 1...10{
            
                let color = UIColor(hue: CGFloat(hue)/10, saturation: CGFloat(sat)/10, brightness: 1, alpha: 1)
                
                self.colors.append(color)
            }
        }
        renderPostCard()
        self.colorCollectionView.dragDelegate = self
        self.postcardImageView.isUserInteractionEnabled = true
        let dropInteraction = UIDropInteraction(delegate: self)
        self.postcardImageView.addInteraction(dropInteraction)
        
        let dragInteraction = UIDragInteraction(delegate: self)
        self.postcardImageView.addInteraction(dragInteraction)
        
        self.title = "PostCard"
        splitViewController?.view.backgroundColor = UIColor.black
    }
    
    // Mark: Collection View Data Source
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath)
        
        let color = self.colors[indexPath.row]
        cell.backgroundColor = color
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
        
        return cell
    }
    
    func renderPostCard(){
        
        let drawRect = CGRect(x: 0, y: 0, width: 3000, height: 2400)
        
        let topRect = CGRect(x: 300, y: 200, width: 2400, height: 800)
        let bottomRect = CGRect(x: 300, y: 1800, width: 2400, height: 600)
        
        let topFont = UIFont(name: self.topFontName, size: 250) ?? UIFont.systemFont(ofSize: 240)
        let bottomFont = UIFont(name: self.bottomFontName, size: 120) ?? UIFont.systemFont(ofSize: 80)
                let centered = NSMutableParagraphStyle()
        centered.alignment = .center
        
        let topAttributes : [NSAttributedString.Key : Any] =
            [
                .foregroundColor        : topFontColor,
                .font                   : topFont,
                .paragraphStyle         : centered
            ]
        
        let bottomAttributes : [NSAttributedString.Key : Any] =
            [
                .foregroundColor        : bottomFontColor,
                .font                   : bottomFont,
                .paragraphStyle         : centered
            ]
        
        let rendered = UIGraphicsImageRenderer(size: drawRect.size)
        
        self.postcardImageView.image = rendered.image(actions:
            { (context) in
                
                UIColor.lightGray.set()
                context.fill(drawRect)
                
                self.image?.draw(at: CGPoint(x: 0, y: 0))
                
                self.topText.draw(in: topRect, withAttributes: topAttributes)
                self.bottomText.draw(in: bottomRect, withAttributes: bottomAttributes)
        })
    }
    
    // MARK: UICollectionViewDragDelegate
    func collectionView(_ collectionView: UICollectionView,
                          itemsForBeginning session: UIDragSession,
                          at indexPath: IndexPath) -> [UIDragItem] {
        
        let color = self.colors[indexPath.row]
        let itemProvider = NSItemProvider(object: color)
        let item = UIDragItem(itemProvider: itemProvider)
        
        return [item]
    }
    
    //MARK: UIDropInteractionDelegate
    func dropInteraction(_ interaction: UIDropInteraction,
                           sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        
        let dropLocation = session.location(in: self.postcardImageView)
        
        if session.hasItemsConforming(toTypeIdentifiers: [kUTTypePlainText as String]) {
            session.loadObjects(ofClass: NSString.self) { (items) in
                guard let fontName = items.first as? String else { return }
                
                if dropLocation.y < self.postcardImageView.bounds.midY {
                    self.topFontName = fontName
                } else {
                    self.bottomFontName = fontName
                }
                self.renderPostCard()
            }
        }else if session.hasItemsConforming(toTypeIdentifiers: [kUTTypeImage as String]) {
            session.loadObjects(ofClass: UIImage.self)
            { (items) in
                guard let image = items.first as? UIImage else { return }
                
                self.image = self.resizeImage(image: image, targetSize: CGSize(width: 3000, height: 2400))
                self.renderPostCard()
            }
        }else {
            session.loadObjects(ofClass: UIColor.self) { (items) in
                guard let color = items.first as? UIColor else { return }
                
                if dropLocation.y < self.postcardImageView.bounds.midY{
                    self.topFontColor = color
                } else {
                    self.bottomFontColor = color
                }
                self.renderPostCard()
            }}
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        
        let originalSize = image.size
        let withRatio = targetSize.width / originalSize.width
        let heightRatio = targetSize.height / originalSize.height
        let targetRatio = max(withRatio, heightRatio)
        let newSize = CGSize(width: originalSize.width * targetRatio,
                             height: originalSize.height * targetRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    // MARK: UIDragInteractionDelegate
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        
        guard let image = self.postcardImageView.image else { return [] }
        let provider = NSItemProvider(object: image)
        let item = UIDragItem(itemProvider: provider)
        return [item]
    }
    
    // MARK: Tap Gesture Recognizer
    @IBAction func changeText(_ sender: UITapGestureRecognizer) {
        
        let tapLocation = sender.location(in: self.postcardImageView)
        
        let changeTop = (tapLocation.y < self.postcardImageView.bounds.midY) ? true : false
        
        let alert = UIAlertController(title: "Change Text", message: "Write new text", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "What do you want to put here?"
            
            if changeTop {
                textField.text = self.topText
            } else {
                textField.text = self.bottomText
            }
        }
        
        let changeAction = UIAlertAction(title: "Change text", style: .default)
        { (_) in
            guard let newText = alert.textFields?[0].text else { return }
            
            if changeTop {
                self.topText = newText
            } else {
                self.bottomText = newText
            }
            self.renderPostCard()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(changeAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}


