//
//  BlocksViewController.swift
//  drag_and_drop
//
//  Created by Morris Uhlenbrauck on 5/15/23.
//

import UIKit
import Combine

class BlocksViewController: UIViewController {

    var blocksViewModel: BlocksViewModel?
    var cancellables = Set<AnyCancellable>()
    var screenSize: CGRect {
        return self.view.bounds
    }

    var randomColor: UIColor {
        return UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1.0)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear

        blocksViewModel = BlocksViewModel(viewBounds: screenSize)
        blocksViewModel?.getAPIRectangles()
        blocksViewModel?.viewLoaded()
        blocksViewModel?.viewBlocks.sink { [weak self] blocks in
            for block in blocks {
                self?.drawBlock(for: block)
            }
        }.store(in: &cancellables)
    }

    func drawBlock(for block: Block) {
        DispatchQueue.main.async {
            let movableView = UIView()
            let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.touched(_:)))

            movableView.frame = CGRect(x: block.xCoordinate, y: block.yCoordinate, width: block.width, height: block.height)
            movableView.backgroundColor = self.randomColor
            movableView.addGestureRecognizer(gestureRecognizer)
            self.view.addSubview(movableView)
        }

    }
    var beginningPosition: CGPoint?
    @objc private func touched(_ gestureRecognizer: UIGestureRecognizer) {
        if let touchedView = gestureRecognizer.view {
            switch gestureRecognizer.state {
            case .began:
                beginningPosition = gestureRecognizer.location(in: touchedView)
            case .changed:
                guard let beginningPosition = beginningPosition else { break }
                let locationInView = gestureRecognizer.location(in: touchedView)
                touchedView.frame.origin = CGPoint(x: touchedView.frame.origin.x + locationInView.x - beginningPosition.x, y: touchedView.frame.origin.y + locationInView.y - beginningPosition.y)
            case .ended:
                let blocks = view.subviews.compactMap {
                    let xCoord = $0.frame.minX
                    let yCoord = $0.frame.minY
                    return Block(xCoordinate: xCoord, yCoordinate: yCoord, height: $0.bounds.height, width: $0.bounds.width)
                }
                blocksViewModel?.saveBlocks(blocks)
            case .cancelled, .failed, .possible:
                break
            @unknown default:
                break
            }
        }
    }
}

