//
//  IntroPageViewController.swift
//  i2tocr-iOS
//
//  Created by bardouei on 8/17/24.
//

import UIKit

class IntroPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private var loginRouter = LoginNavigator.shared
    
    let images = ["intro1", "intro2", "intro3"]
    let descriptions = ["Easily convert any image containing text into fully editable and selectable text using advanced OCR technology.", "After converting the image to text, you can export your results directly as a PDF file for easy sharing and storing.", "Enjoy unlimited and free OCR processing for documents in English, ensuring you can convert as many texts as needed without limitations."]
    var currentIndex = 0
    var pageControl = UIPageControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewConfig()
        configurePageControl()
    }
    
    private func viewConfig() {
        self.dataSource = self
        self.delegate = self
        if let startingViewController = viewControllerAtIndex(index: 0) {
            setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    private func configurePageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0, y: UIScreen.main.bounds.maxY - 100, width: UIScreen.main.bounds.width, height: 50))
        pageControl.numberOfPages = images.count
        pageControl.currentPage = currentIndex
        pageControl.tintColor = UIColor.red
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = Colors.white
        self.view.addSubview(pageControl)
    }
    
    private func viewControllerAtIndex(index: Int) -> IntroViewController? {
        if index >= images.count || index < 0 { return nil }
        
        let introVC = IntroViewController(nibName: "IntroViewController", bundle: nil)
        
        introVC.imageName = images[index]
        introVC.descriptionText = descriptions[index]
        introVC.currentPage = index
        introVC.totalPages = images.count
        return introVC
    }
    
    // MARK: - UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = currentIndex
        index -= 1
        return viewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = currentIndex
        index += 1
        return viewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let viewController = pageViewController.viewControllers?.first as? IntroViewController, let index = images.firstIndex(of: viewController.imageName ?? "") {
                currentIndex = index
                pageControl.currentPage = currentIndex
            }
        }
    }
}
