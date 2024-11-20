//import UIKit
//
//class AddEventViewController: UIViewController {
//    @IBOutlet weak var titleTextField: UITextField!
//    @IBOutlet weak var datePicker: UIDatePicker!
//
//    weak var delegate: AddEventDelegate?
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//    }
//    @IBAction func cancelButtonTapped(_ sender: UIButton) {
//        self.dismiss(animated: true, completion: nil) // If presented modally
//   }
//    @IBAction func saveButtonTapped(_ sender: UIButton) {
//        guard let title = titleTextField.text, !title.isEmpty else { return }
//        let newEvent = Event(title: title, date: datePicker.date)
//        EventManager.shared.addEvent(newEvent)
//        delegate?.didAddEvent(newEvent)
//        dismiss(animated: true, completion: nil)
//        self.navigationController?.popViewController(animated: true)
//    }
//}
//
//protocol AddEventDelegate: AnyObject {
//    func didAddEvent(_ event: Event)
//}
import UIKit

class AddEventViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var yourTextField: UITextField!// Connect this to your grey view in the storyboard

    weak var delegate: AddEventDelegate?
    var selectedDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let selectedDate = selectedDate {
            datePicker.date = selectedDate
        }
        
        backgroundView.layer.cornerRadius = 15
        backgroundView.layer.masksToBounds = false
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.shadowOpacity = 0.20
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 0)
        backgroundView.layer.shadowRadius = 5

        yourTextField.frame.size.height = 50  // Set desired height
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
//    @IBAction func saveButtonTapped(_ sender: UIButton) {
//        guard let title = titleTextField.text, !title.isEmpty else { return }
//        let newEvent = Event(title: title, date: datePicker.date)
//        EventManager.shared.addEvent(newEvent)
//        delegate?.didAddEvent(newEvent)
//        dismiss(animated: true, completion: nil)
//        self.navigationController?.popViewController(animated: true)
//    }
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let title = titleTextField.text, !title.isEmpty else { return }
        let newEvent = Event(title: title, date: datePicker.date)
        EventManager.shared.addEvent(newEvent)
        delegate?.didAddEvent(newEvent)
        dismiss(animated: true, completion: nil)
    }
}

protocol AddEventDelegate: AnyObject {
    func didAddEvent(_ event: Event)
}
