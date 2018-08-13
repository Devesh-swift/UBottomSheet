//
//  BottomSheetViewController.swift
//  NestedScrollView
//
//  Created by ugur on 12.08.2018.
//  Copyright © 2018 me. All rights reserved.
//

import UIKit

enum SheetLevel{
    case top, bottom, middle
}

protocol BottomSheetDelegate {
    func updateBottomSheet(frame: CGRect)
}

class BottomSheetViewController: UIViewController{

    @IBOutlet var panView: UIView!
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var collectionView: UICollectionView! //header view
    
    var lastY: CGFloat = 0
    var pan: UIPanGestureRecognizer!
    
    var bottomSheetDelegate: BottomSheetDelegate?
    var parentView: UIView!
    
    var initalFrame: CGRect!
    let topY: CGFloat = 80
    var middleY: CGFloat = 400
    var bottomY: CGFloat = 600
    let bottomOffset: CGFloat = 64
    var lastLevel: SheetLevel = .middle
    var disableTableScroll = false
    
    var listItems: [Any] = []
    var headerItems: [Any] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        
        self.tableView.panGestureRecognizer.addTarget(self, action: #selector(handlePan(_:)))
        self.panView.addGestureRecognizer(pan)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initalFrame = UIScreen.main.bounds
        self.middleY = initalFrame.height * 0.6
        self.bottomY = initalFrame.height - bottomOffset
        self.lastY = self.middleY
        
        bottomSheetDelegate?.updateBottomSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: self.middleY))
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.parentView.frame.minY > topY){
            self.tableView.contentOffset.y = 0
        }
    }


    //this stops unintended tableview scrolling while animating to top
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if disableTableScroll{
            targetContentOffset.pointee = scrollView.contentOffset
            disableTableScroll = false
        }
    }
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer){

        let dy = recognizer.translation(in: self.parentView).y
        switch recognizer.state {
        case .changed:
            if self.tableView.contentOffset.y <= 0{
                let maxY = max(topY, lastY + dy)
                let y = min(bottomY, maxY)
//                self.panView.frame = self.initalFrame.offsetBy(dx: 0, dy: y)
                bottomSheetDelegate?.updateBottomSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: y))
            }
            
            if self.parentView.frame.minY > topY{
                self.tableView.contentOffset.y = 0
            }
        case .failed, .ended, .cancelled:
            self.panView.isUserInteractionEnabled = false

            self.disableTableScroll = self.lastLevel != .top
            
            self.lastY = self.parentView.frame.minY
            self.lastLevel = self.nextLevel(recognizer: recognizer)
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.9, options: .curveEaseOut, animations: {
                
                switch self.lastLevel{
                case .top:
//                    self.panView.frame = self.initalFrame.offsetBy(dx: 0, dy: self.topY)
                    self.bottomSheetDelegate?.updateBottomSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: self.topY))
                    self.tableView.contentInset.bottom = self.topY + 50
                case .middle:
//                    self.panView.frame = self.initalFrame.offsetBy(dx: 0, dy: self.middleY)
                    self.bottomSheetDelegate?.updateBottomSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: self.middleY))
                case .bottom:
//                    self.panView.frame = self.initalFrame.offsetBy(dx: 0, dy: self.bottomY)
                    self.bottomSheetDelegate?.updateBottomSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: self.bottomY))
                }
                
            }) { (_) in
                self.panView.isUserInteractionEnabled = true
                self.lastY = self.parentView.frame.minY
            }
            
        default:
            break
        }
    }
    
    func nextLevel(recognizer: UIPanGestureRecognizer) -> SheetLevel{
      let y = self.lastY
        let velY = recognizer.velocity(in: self.view).y
        if velY < -200{
            return y > middleY ? .middle : .top
        }else if velY > 200{
            return y < (middleY + 1) ? .middle : .bottom
        }else{
            if y > middleY {
                return (y - middleY) < (bottomY - y) ? .middle : .bottom
            }else{
                return (y - topY) < (middleY - y) ? .top : .middle
            }
        }
    }
}


//extension BottomSheetViewController: UICollectionViewDelegate, UICollectionViewDataSource{
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 8
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "topCell", for: indexPath)
//        return cell
//    }
//}


extension BottomSheetViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }
}

extension BottomSheetViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
