//
//  PMPhotoHeaderView.swift
//  PrismaSimpleImagePicker
//
//  Created by Roy lee on 16/7/25.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

import UIKit

private var kContentOffsetContext = 0

class PMPhotoHeaderView: UIView {

    var imageView: PMPhotoHeaderItem = PMPhotoHeaderItem.init()
    var tapAction: ((view: PMPhotoHeaderView)->Void)?
    var gridMask: PMPhotoGridView = PMPhotoGridView()
    var alwaysShowGrid: Bool = false
    private var _editEnabled: Bool = true
    var editEnabled: Bool {
        set {
            _editEnabled = newValue
            gridMask.hidden = !newValue
            imageView.scrollEnabled = newValue
        }
        get {
            return _editEnabled
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configSubviews()
    }
    
    func configSubviews() {
        
        imageView.frame = bounds
        addSubview(imageView)
        
        // Grid
        gridMask.frame = bounds
        gridMask.alpha = alwaysShowGrid ?1:0
        gridMask.userInteractionEnabled = false
        addSubview(gridMask)
        imageView.addObserver(self, forKeyPath: "contentOffset", options: .New, context: &kContentOffsetContext)
        
        // Tap
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(PMPhotoHeaderView.tap(_:)))
        tap.numberOfTapsRequired = 1
        addGestureRecognizer(tap)
        
        // Zoom action
        imageView.scrollViewDidZoom = { (scrollView: UIScrollView) in
            self.scrollViewDidZoom(scrollView)
        }
        imageView.scrollViewBeganDragging = { (scrollView: UIScrollView) in
            if self.alwaysShowGrid {
                return
            }
            self.showGrid(true)
        }
        imageView.scrollViewEndDragging = { (scrollView: UIScrollView) in
            if self.alwaysShowGrid {
                return
            }
            self.showGrid(false)
        }
    }
    
    override func layoutSubviews() {
        if imageView.bounds.size.width != bounds.size.width {
            imageView.frame = bounds
            gridMask.frame = bounds
        }
    }
    
    func setImage(image: UIImage) {
        imageView.setImage(image)
    }
    
    func tap(tap: UITapGestureRecognizer) {
        if let tap = tapAction {
            tap(view: self)
        }
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        // Reset grid
        let imageContainerView = imageView.imageContainerView
        let containerFrame = convertRect(imageContainerView.frame, fromView: imageContainerView.superview)
        
        let x = fmax(0, containerFrame.origin.x)
        let y = fmax(0, containerFrame.origin.y)
        
        var width = CGFloat(0)
        if x > 0 {
            width = fmin(containerFrame.size.width, bounds.size.width - x)
        }else {
            width = fmin(containerFrame.size.width + containerFrame.origin.x, bounds.size.width)
        }
        var height = CGFloat(0)
        if y > 0 {
            height = fmin(containerFrame.size.height, bounds.size.height - y)
        }else {
            height = fmin(containerFrame.size.height + containerFrame.origin.y, bounds.size.height)
        }
        
        gridMask.frame = CGRectMake(x, y, width, height)
    }
    
    func showGrid(show: Bool) {
        if show {
            UIView.animateWithDuration(0.3, animations: {
                self.gridMask.alpha = 1
            })
        }else {
            UIView.animateWithDuration(0.35, animations: {
                self.gridMask.alpha = 0
            })
        }
    }
    
    // MARK: KVO
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &kContentOffsetContext {
            
            if let scrollView = object as? UIScrollView {
                guard !scrollView.zooming && !scrollView.zoomBouncing else {
                    return
                }
                
                let imageContainerView = imageView.imageContainerView
                let containerFrame = convertRect(imageContainerView.frame, fromView: imageContainerView.superview)
                
                let x = fmax(0, containerFrame.origin.x)
                let y = fmax(0, containerFrame.origin.y)
                
                var width = CGFloat(0)
                if x > 0 {
                    width = fmin(containerFrame.size.width, bounds.size.width - x)
                }else {
                    width = fmin(containerFrame.size.width + containerFrame.origin.x, bounds.size.width)
                }
                var height = CGFloat(0)
                if y > 0 {
                    height = fmin(containerFrame.size.height, bounds.size.height - y)
                }else {
                    height = fmin(containerFrame.size.height + containerFrame.origin.y, bounds.size.height)
                }
                
                gridMask.frame = CGRectMake(x, y, width, height)
            }
        }else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    deinit {
        removeObserver(self, forKeyPath: "contentOffset", context: &kContentOffsetContext)
    }
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
