import UIKit

class PlannerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddEventDelegate {
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    var events: [Event] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        // Load events from the EventManager shared instance
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
           
           // Optionally, add shadow to make it stand out
        tableView.layer.shadowColor = UIColor.black.cgColor
        tableView.layer.shadowOpacity = 0.2
        tableView.layer.shadowOffset = CGSize(width: 0, height: 2)
        tableView.layer.shadowRadius = 4
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        setupCustomBackButton()
        
    }
    private func setupCustomBackButton() {
        // Create a custom back button
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(backButtonTapped))
        backButton.tintColor = .label // Set the tint color to match the label color
        
        // Assign the custom back button to the navigation item
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true) // Navigate back to the previous screen
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reload events from EventManager every time the view appears
        events = EventManager.shared.events
        tableView.reloadData()
    }

    // MARK: - AddEventDelegate Method
    func didAddEvent(_ event: Event) {
        // Append the new event to the local events array
        events.append(event)
        
        // Reload the table view to show the new event
        tableView.reloadData()
    }

    // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    @objc func dateChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let formattedDate = dateFormatter.string(from: selectedDate)
        
        let alert = UIAlertController(title: "Want to add outfit for \(formattedDate)?", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            // Navigate to AddEventViewController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let addEventVC = storyboard.instantiateViewController(withIdentifier: "AddEventViewController") as? AddEventViewController {
                addEventVC.delegate = self
                addEventVC.selectedDate = selectedDate // Pass the selected date
                addEventVC.modalPresentationStyle = .fullScreen
                self.present(addEventVC, animated: true, completion: nil)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the event from EventManager and the local array
            EventManager.shared.deleteEvent(at: indexPath.row)
            events.remove(at: indexPath.row)
            
            // Update the table view to reflect the deletion
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventTableViewCell
        let event = events[indexPath.row]
        
        // Configure the custom cell with the event title and date
        cell.configure(with: event)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedEvent = events[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "EventDetailViewController") as? EventDetailViewController {
            detailVC.event = selectedEvent // Pass the selected event
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    // MARK: - Add Event Button Action
    @IBAction func addEventButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showAddEvent", sender: self)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddEvent" {
            if let addEventVC = segue.destination as? AddEventViewController {
                addEventVC.delegate = self
                if let selectedDate = datePicker?.date {
                    addEventVC.selectedDate = selectedDate
                }
            }
        }
    }
}
