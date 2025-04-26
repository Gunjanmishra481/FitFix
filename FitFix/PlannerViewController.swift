import UIKit

class PlannerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddEventDelegate {
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundView: UIView! // Connect this from your storyboard.

    var events: [Event] = []
    var noEventsLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGradientBackground()
        setupTableViewStyle()
        
        tableView.delegate = self
        tableView.dataSource = self
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        setupCustomBackButton()
    }

    private func setupTableViewStyle() {
        let containerView = UIView()
        containerView.frame = tableView.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = containerView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(blurView)
        
        let messageLabel = UILabel()
        messageLabel.text = "Click '+' to add new event"
        messageLabel.textColor = .gray
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        messageLabel.numberOfLines = 0
        containerView.addSubview(messageLabel)
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -20)
        ])
        
        tableView.backgroundView = containerView
        self.noEventsLabel = messageLabel
        messageLabel.isHidden = true
        
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = 20
        tableView.layer.masksToBounds = true
        tableView.layer.shadowOffset = CGSize(width: 0, height: 2)
        tableView.layer.shadowOpacity = 0.4
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .gray
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }

    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.95, green: 0.92, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 0.78, green: 0.72, blue: 1.0, alpha: 1.0).cgColor

        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.frame = backgroundView.bounds
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupCustomBackButton() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(backButtonTapped))
        backButton.tintColor = .label
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        EventManager.shared.loadEvents {
            self.events = EventManager.shared.events
            self.tableView.reloadData()
            self.noEventsLabel?.isHidden = !self.events.isEmpty
        }
    }

    func didAddEvent(_ event: Event) {
        events.append(event)
        tableView.reloadData()
        noEventsLabel?.isHidden = !events.isEmpty
    }

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
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let addEventVC = storyboard.instantiateViewController(withIdentifier: "AddEventViewController") as? AddEventViewController {
                addEventVC.delegate = self
                addEventVC.selectedDate = selectedDate
                addEventVC.modalPresentationStyle = .fullScreen
                self.present(addEventVC, animated: true, completion: nil)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            EventManager.shared.deleteEvent(at: indexPath.row)
            events.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            noEventsLabel?.isHidden = !events.isEmpty
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventTableViewCell
        let event = events[indexPath.row]
        cell.configure(with: event)
        
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        cell.contentView.frame = cell.contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedEvent = events[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "EventDetailViewController") as? EventDetailViewController {
            detailVC.event = selectedEvent
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }

    @IBAction func addEventButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showAddEvent", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddEvent", let addEventVC = segue.destination as? AddEventViewController {
            addEventVC.delegate = self
            addEventVC.selectedDate = datePicker.date
        }
    }
}
