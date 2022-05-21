//
//  AppDelegate.swift
//  puzzlefiveteen
//
//  Created by Magnus Muru on 21.05.2022.
//

import UIKit

class ViewController: UIViewController {
    // Switch from Standard Editor to Assistant Editor
    // Control-Click-Drag BoardView
    @IBOutlet weak var boardView: BoardView!
    // Assistant Editor
    // Control-Click-Drag Button
    // Change to Action to return function
    // outlet collection for tileSelected
    @IBOutlet weak var shuffleButton: UIBarButtonItem!
    
    @IBOutlet weak var moveLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var timeCount: Int = 0
    var gameTimer: Timer = Timer()
    
    var moveCount: Int = 0
    
    @objc func timerAction(_ timer: Timer) {
        timeCount += 1
        timeLabel.text = timeFormatted(totalSeconds: timeCount)
    }
    
    func timeFormatted(totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = totalSeconds / 60
        return String(format: "%02d:%02d", minutes, seconds)
     }
    
    func _foregroundTimer(repeated: Bool) -> Void {
        gameTimer.invalidate()
        timeCount = 0
        moveCount = 0
        moveLabel.text = String(format: "%d slides", moveCount)
        self.gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerAction(_:)), userInfo: nil, repeats: true);
    }
    
    
    @IBAction func tileSelected(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let board = appDelegate.board
        let pos = board!.getRowAndColumn(forTile: sender.tag)
        let buttonBounds = sender.bounds
        var buttonCenter = sender.center
        var slide = true
        if board!.canSlideTileUp(atRow: pos!.row, Column: pos!.column) {
            buttonCenter.y -= buttonBounds.size.height
        } else if board!.canSlideTileDown(atRow: pos!.row, Column: pos!.column) {
            buttonCenter.y += buttonBounds.size.height
        } else if board!.canSlideTileLeft(atRow: pos!.row, Column: pos!.column) {
            buttonCenter.x -= buttonBounds.size.width
        } else if board!.canSlideTileRight(atRow: pos!.row, Column: pos!.column) {
            buttonCenter.x += buttonBounds.size.width
        } else {
            slide = false
        }
        if slide {
            board!.slideTile(atRow: pos!.row, Column: pos!.column)
            // sender.center = buttonCenter // or animate the change
            UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: {sender.center = buttonCenter})
            moveCount += 1
            moveLabel.text = String(format: "%d slides", moveCount)
            if (board!.isSolved()) {
                gameTimer.invalidate()
                let alertController = UIAlertController(title: "You Win!", message:
                        "Play again?", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                    self.resetBoard()
                    }))
                alertController.addAction(UIAlertAction(title: "No", style: .destructive))
                self.present(alertController, animated: true, completion: nil)
            }
        } // end if slide
    } // end tileSelected
    

    func resetBoard() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let board = appDelegate.board!
        board.scramble(numTimes: appDelegate.numShuffles)
        shuffleButton.tag = 31
        shuffleButton.title = "Solve"
        self._foregroundTimer(repeated: true)
        self.boardView.setNeedsLayout()
    }
    
    @IBAction func shuffleTiles(_ sender: UIBarButtonItem) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let board = appDelegate.board!
        let shuffle = (sender.tag == 30)
        
        if (shuffle) {
            self._foregroundTimer(repeated: true)
            board.scramble(numTimes: appDelegate.numShuffles)
            sender.tag = 31
            sender.title = "Solve"
            self.boardView.setNeedsLayout()
        } else {
            gameTimer.invalidate()
            moveCount = 0
            sender.tag = 30
            sender.title = "Shuffle"
            board.resetBoard()
            self.boardView.setNeedsLayout()
        }
    }  // end shuffleTiles()
    
    @IBAction func switchView(_ sender: UIBarButtonItem) {
        let viewOff = (sender.tag == 20)
        
        if (viewOff) {
            sender.tag = 21
            sender.title = "Image"
            boardView.switchTileImages(false)
        } else {
            sender.tag = 20
            sender.title = "Numbers"
            boardView.switchTileImages(true)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        moveLabel.center.x = self.view.center.x
        timeLabel.center.x = self.view.center.x
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

