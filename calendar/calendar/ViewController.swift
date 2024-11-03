//
//  ViewController.swift
//  calendar
//
//  Created by user@79 on 28/10/24.
//

import UIKit

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource{


    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var monthLabel: UILabel!
    
    var selelctedDate = Date()
    var totalSquares = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setCellsView()
        setMonthView()
        // Do any additional setup after loading the view.
    }
func setCellsView()
    {
    let width = (collectionView.frame.size.width - 2) / 8
    let height = (collectionView.frame.size.height - 2) / 8
        
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        flowLayout.itemSize = CGSize(width: width, height: height)
    }
    func setMonthView(){
        totalSquares.removeAll()
        
        let daysInmonth = CalendarHelper().daysInMonth(date: selelctedDate)
        let firstDayOfMonth = CalendarHelper().firstOfMonth(date: selelctedDate)
        let startingSpaces = CalendarHelper().weekDay(date: firstDayOfMonth)
        
        var count: Int = 1
        while(count <= 42){
            if(count <= startingSpaces || count - startingSpaces > daysInmonth){
                totalSquares.append("")
            }
            else {
                totalSquares.append(String(count - startingSpaces))
            }
            count += 1
        }
        monthLabel.text = CalendarHelper().monthString(date: selelctedDate) + " " + CalendarHelper().yearString(date: selelctedDate)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calCell", for: indexPath) as! CalendarFile
        
        cell.dayofMonth.text = totalSquares[indexPath.item]
        
        return cell
    }
    
    
    @IBAction func nextMonth(_ sender: Any) {
        selelctedDate = CalendarHelper().plusMonth(date: selelctedDate)
        setMonthView()
    }
    
    @IBAction func previousMonth(_ sender: Any) {
        selelctedDate = CalendarHelper().minusMonth(date: selelctedDate)
        setMonthView()
    }
    override open var shouldAutorotate: Bool {
        return false
    }
        
}

