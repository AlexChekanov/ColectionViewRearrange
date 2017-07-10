//
//  ProcessCollectionViewController.swift
//  ColectionViewRearrange
//
//  Created by Alexey Chekanov on 7/10/17.
//  Copyright © 2017 Alexey Chekanov. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ProcessCollectionViewController: UICollectionViewController, UIGestureRecognizerDelegate, UICollectionViewDelegateFlowLayout {
    
    
    // MARK: - Data
    
    var labels: [String] = []
    var titleFont = UIFont.systemFont(ofSize: 14, weight: UIFontWeightThin)
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.dataSource = self
        collectionView?.delegate = self
        
        labels = [
            "Check",
            "Find problem",
            "Repair",
            "Sell"
        ]
        
    }

    
    // MARK: - Gestures handeling
    
    func addLongPressObserver() {
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delegate = self
        lpgr.delaysTouchesBegan = false
        self.collectionView?.addGestureRecognizer(lpgr)
    }
    
    func handleLongPress(_ gesture: UILongPressGestureRecognizer){
        
        switch(gesture.state) {
            
        case UIGestureRecognizerState.began:
            
            
            guard let selectedIndexPath = self.collectionView?.indexPathForItem(at: gesture.location(in: self.collectionView)) else {
                break
            }
            
            collectionView?.beginInteractiveMovementForItem(at: selectedIndexPath)
            
            
        case UIGestureRecognizerState.changed:
            
            collectionView?.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
            
        case UIGestureRecognizerState.ended:
            
            
            collectionView?.endInteractiveMovement()
            
            
        default:
            
            collectionView?.cancelInteractiveMovement()
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return labels.count
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
        guard let cell = cell as? Cell else { return }
        
        cell.label.text = labels[indexPath.row]
        cell.label.font = titleFont
        cell.label.numberOfLines = 0
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath,
                                 to destinationIndexPath: IndexPath) {
        
        
        let label = labels.remove(at: sourceIndexPath.row)
        labels.insert(label, at: destinationIndexPath.row)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        var cellSize = CGSize()
        
        let cellHeight = (self.collectionView?.bounds.height)!
        
        let textToCalculate = labels[indexPath.row]
            
        let maxWordsCharacterCount = textToCalculate.maxWord.characters.count
        let allLongWords: [String] = textToCalculate.wordList.filter {$0.characters.count == maxWordsCharacterCount}
            
        var sizes: [CGFloat] = []
        
        let textAttributes = [
                NSFontAttributeName: titleFont
            ]
            
         allLongWords.forEach {sizes.append($0.size(attributes: textAttributes).width)}
            
         cellSize = CGSize(width: (sizes.max()! + 1), height: cellHeight)
        
        return cellSize
            
    }
}


class Cell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    
}


extension String {
    var wordList: [String] {
        return Array(Set(components(separatedBy: .punctuationCharacters).joined(separator: "").components(separatedBy: " "))).filter {$0.characters.count > 0}
    }
}

extension String {
    var maxWord: String {
        
        if let max = self.wordList.max(by: {$1.characters.count > $0.characters.count}) {
            return max
        } else {return ""}
    }
}


//MARK: one little trick from http://nshint.io/blog/2015/07/16/uicollectionviews-now-have-easy-reordering/, that doesn't work for UICollectionViewFlowLayout. Or I do something wrong

extension UICollectionViewFlowLayout {
    
    override open func invalidationContext(forInteractivelyMovingItems targetIndexPaths: [IndexPath], withTargetPosition targetPosition: CGPoint, previousIndexPaths: [IndexPath], previousPosition: CGPoint) -> UICollectionViewLayoutInvalidationContext {
        
        let context = super.invalidationContext(forInteractivelyMovingItems: targetIndexPaths, withTargetPosition: targetPosition, previousIndexPaths: previousIndexPaths, previousPosition: previousPosition)
        
        collectionView?.moveItem(at: previousIndexPaths[0], to: targetIndexPaths[0])
        
        //(self.collectionView!, moveItemAt: previousIndexPaths[0], to: targetIndexPaths[0])
        
        return context
    }
}

