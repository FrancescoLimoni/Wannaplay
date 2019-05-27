//
//  RequestViewController.swift
//  Wannaplay
//
//  Created by Francesco Limoni on 19/04/2019.
//  Copyright © 2019 Francesco Limoni. All rights reserved.
//

import UIKit

class RequestViewController: UIViewController {
    
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var trainingBT: UIButton!
    @IBOutlet weak var matchBT: UIButton!
    @IBOutlet weak var friendlyBT: UIButton!
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var daysLabel: UIStackView!
    @IBOutlet weak var mLB: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var playersNeededTF: UITextField!
    @IBOutlet weak var refereeNeededTF: UITextField!
    @IBOutlet weak var fieldView: UIView!
    @IBOutlet weak var fieldLabel: UILabel!
    @IBOutlet weak var fieldButton: UIButton!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var cancelBT: UIButton!
    @IBOutlet weak var requestBT: UIButton!
    
    let cellReusableID = "cell"
    let cellsID = ["training", "friendly", "match"]
    let pickerMax = [1,2,3,4,5,6,7,8,9,10]
    var pickerSelection: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewCornerRadius(view: trainingBT)
        viewCornerRadius(view: friendlyBT)
        viewCornerRadius(view: matchBT)
        viewCornerRadius(view: gameView)
        viewCornerRadius(view: calendarView)
        viewCornerRadius(view: fieldView)
        viewCornerRadius(view: cancelBT)
        viewCornerRadius(view: requestBT)
        
        fetchMonth()
        setupPicker(textField: playersNeededTF)
        setupPicker(textField: refereeNeededTF)
        setupPickerToolBar(textField: playersNeededTF)
        setupPickerToolBar(textField: refereeNeededTF)
    }
    
    func viewCornerRadius(view: UIView) {
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
    }
    
    func fetchMonth() {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        
        let nameOfMonth = dateFormatter.string(from: now)
        self.monthLabel.text = nameOfMonth
    }
    
    func setupDaysLabel() {
        let calendarViewWidth = calendarView.bounds.width
        daysLabel.spacing = (calendarViewWidth - CGFloat(mLB.frame.width * 7) / 7)
    }
    
    func fetchDaysOfMonth() -> Int {
        let calendar = Calendar.current
        //let ymd = calendar.dateComponents([.year, .month, .day], from: Date())
        let range = calendar.range(of: Calendar.Component.day, in: Calendar.Component.month, for: Date())
        guard let daysOfMonth = range?.count else { return 0 }
        
        return daysOfMonth
    }
    
    @IBAction func gameMode(sender: UIButton) {
        switch sender {
            case trainingBT:
                print("trainingBT pressed")
                trainingBT.alpha = 1
                trainingBT.titleLabel?.alpha = 1
                friendlyBT.alpha = 0.6
                friendlyBT.titleLabel?.alpha = 0.6
                matchBT.alpha = 0.6
                matchBT.titleLabel?.alpha = 0.6
            case friendlyBT:
                print("friendly pressed")
                trainingBT.alpha = 0.6
                trainingBT.titleLabel?.alpha = 0.6
                friendlyBT.alpha = 1
                friendlyBT.titleLabel?.alpha = 1
                matchBT.alpha = 0.6
                matchBT.titleLabel?.alpha = 0.6
            case matchBT:
                print("match pressed")
                trainingBT.alpha = 0.6
                trainingBT.titleLabel?.alpha = 0.6
                friendlyBT.alpha = 0.6
                friendlyBT.titleLabel?.alpha = 0.6
                matchBT.alpha = 1
                matchBT.titleLabel?.alpha = 1
            default:
                break
        }
    }
    
    @IBAction func unwindSegue(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension RequestViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemPerRow: CGFloat = 7
        let spaceCell: CGFloat = 12
        let spaceView: CGFloat = 2
    
        let totalSpacing = ((2 * spaceView) + (numberOfItemPerRow * spaceCell))
        
        if let collection = self.collectionView {
            let width = (collection.bounds.width - totalSpacing) / numberOfItemPerRow
            return CGSize(width: width, height: width)
        } else {
            print()
            print("incorrect")
            return CGSize(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let daysOfMonth = fetchDaysOfMonth()
        
        return daysOfMonth
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReusableID, for: indexPath) as! DayCollectionViewCell
        let numbString = String(indexPath.item + 1)
        cell.dayLabel!.text = numbString
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! DayCollectionViewCell
        cell.layer.cornerRadius = cell.layer.bounds.size.width * 0.15
        cell.backgroundColor = UIColor.black
        cell.dayLabel.textColor = UIColor.white
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as? DayCollectionViewCell
        cell?.backgroundColor = UIColor.white
        cell?.dayLabel.textColor = UIColor.black
    }
    
    
}

extension RequestViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func setupPicker(textField: UITextField) {
        let picker = UIPickerView()
        picker.delegate = self
        picker.backgroundColor = .white
        textField.inputView = picker
    }
    
    func setupPickerToolBar(textField: UITextField) {
        let toolBar = UIToolbar()
        let doneBT = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleDismiss))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolBar.sizeToFit()
        toolBar.setItems([flexibleSpace, doneBT, flexibleSpace], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        
        //customization
        toolBar.barTintColor = .white
        toolBar.tintColor = .black
    }
    
    @objc func handleDismiss() {
        view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerMax.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(pickerMax[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if playersNeededTF.isEditing == true {
            playersNeededTF.text = String(pickerMax[row])
        } else if refereeNeededTF.isEditing == true {
            refereeNeededTF.text = String(pickerMax[row])
        }
    }

//    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//        var label: UILabel
//        
//        if let view = view as? UILabel {
//            label = view
//        } else {
//            label = UILabel()
//        }
//        
//        label.textColor = .black
//        label.textAlignment = .center
//        //label.font = UIFont(name: "Helvetica Neue-Light", size: 60)
//        label.text = String(pickerMax[row])
//        
//        return label
//    }
}
