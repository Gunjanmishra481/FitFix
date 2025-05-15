
import UIKit

class AddEventViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var yourTextField: UITextField!// Connect this to your grey view in the storyboard
//    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var backgroundView: UIView!
    
    weak var delegate: AddEventDelegate?
    var selectedDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        setupGradientBackground()
        if let selectedDate = selectedDate {
            datePicker.date = selectedDate
        }
        
        yourTextField.frame.size.height = 50  // Set desired height

    }

    private func setupUI() {
          // Setup corner radius for text fields
        titleTextField.layer.cornerRadius = 12
        contentView.layer.cornerRadius = 12  // Change 12 to your desired radius
        contentView.clipsToBounds = true      // Ensures that subviews are clipped to the rounded corners

          // Clip to bounds ensures the corner radius is visible
        titleTextField.clipsToBounds = true
          
          // Set delegates for text fields
        titleTextField.delegate = self
          // Add some padding to text fields
          let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        titleTextField.layoutMargins = padding

          // Initial border setup (no border)
        titleTextField.layer.borderWidth = 0
          
          // Optional: Add background color to text fields for better visibility
        titleTextField.backgroundColor = .white
      }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Add border when text field becomes active
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor(red: 0.333, green: 0.275, blue: 0.392, alpha: 1.0).cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Remove border when text field is no longer active
        textField.layer.borderWidth = 0
        textField.layer.borderColor = nil
    }
    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.95, green: 0.92, blue: 1.0, alpha: 1.0).cgColor,  // Light purple
            UIColor(red: 0.78, green: 0.72, blue: 1.0, alpha: 1.0).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.frame = backgroundView.bounds
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
    }


    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let title = titleTextField.text, !title.isEmpty else { return }

        let selectedDate = datePicker.date
        let defaultImageName = "birthday" // Change this if needed
        let newEvent = EventManager.shared.addEvent(title: title, date: selectedDate, imageName: defaultImageName)
        delegate?.didAddEvent(newEvent)
        dismiss(animated: true, completion: nil)
    }

}

protocol AddEventDelegate: AnyObject {
    func didAddEvent(_ event: Event)
}
