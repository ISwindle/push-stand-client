import UIKit
import MessageUI

class HomeStatsViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
    // MARK: - Properties
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var accountButton: UIImageView!
    @IBOutlet weak var pushStandButton: UIImageView!
    @IBOutlet weak var landingViewWithButton: UIView!
    @IBOutlet weak var landingViewWithPicture: UIView!
    @IBOutlet weak var pushStandTitle: UIView!
    @IBOutlet var pushStandLongPressGesture: UILongPressGestureRecognizer!
    @IBOutlet weak var standProgressBar: CircularProgressBar!
    @IBOutlet weak var dailyGoalCount: UILabel!
    @IBOutlet weak var globalStandCount: UILabel!
    @IBOutlet weak var standStreakLabel: UILabel!
    @IBOutlet weak var yesterdayLabel: UILabel!
    @IBOutlet weak var standStreakTitle: UILabel!
    @IBOutlet weak var questionStreakTitle: UILabel!
    @IBOutlet weak var pointsTitle: UILabel!
    @IBOutlet weak var myPointsLabel: UILabel!
    @IBOutlet weak var standStreakIcon: UIImageView!
    @IBOutlet weak var questionStreakIcon: UIImageView!
    @IBOutlet weak var pointsIcon: UIImageView!
    @IBOutlet weak var shareIcon: UIImageView!
    @IBOutlet weak var segmentedStreakBar: SegmentedBar!
    @IBOutlet weak var streakImage: UIImageView!
    @IBOutlet weak var myCurrentStreakLabel: UILabel!
    @IBOutlet weak var myTotalStandsLabel: UILabel!
    @IBOutlet weak var usaTotalStandsLabel: UILabel!
    @IBOutlet weak var bonusStandView: UIVisualEffectView!
    @IBOutlet weak var streakFillView: UIView!
    @IBOutlet weak var streakFillButton: UIButton!
    @IBOutlet weak var dailyGoalLoading: UIActivityIndicatorView!
    @IBOutlet weak var myCurrentStreakLoading: UIActivityIndicatorView!
    @IBOutlet weak var myTotalStandsLoading: UIActivityIndicatorView!
    @IBOutlet weak var usaTotalStandsLoading: UIActivityIndicatorView!
    @IBOutlet weak var globalStandingTodayLoading: UIActivityIndicatorView!
    
    private var goal: Float = 0.0
    private var current: Float = 0.0
    private var questionAnswerStreak: Int = 0
    private var standStreak = 0
    private var pointsCount = 0
    
    let dailyGoalsEndpoint = NetworkService.Endpoint.dailyGoals.rawValue
    let userTotalStandsEndpoint = NetworkService.Endpoint.userStands.rawValue
    let usTotalStandsEndpoint = NetworkService.Endpoint.stands.rawValue
    let currentStandStreakEndpoint = NetworkService.Endpoint.streaks.rawValue
    let currentAnswerStreakEndpoint = NetworkService.Endpoint.streaksAnswers.rawValue
    let userPointsEndpoint = NetworkService.Endpoint.points.rawValue
    let pushStandEndpoint = NetworkService.Endpoint.stand.rawValue
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewComponents()
        setupGestureRecognizers()
        let dateString = getDateFormatted()
        if !UserDefaults.standard.bool(forKey: dateString) {
            loadHome()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.alpha = 0
        let dateString = getDateFormatted()
        if UserDefaults.standard.bool(forKey: dateString) {
            updateUIForPushStand()
            loadHome()
        }
    }

    func loadHome() {
        NetworkService.shared.request(endpoint: .stand, method: "GET", queryParams: ["user_id": CurrentUser.shared.uid!]) { (result: Result<[String: Any], Error>) in
            DispatchQueue.main.async {
                self.fetchDataAndUpdateUI()
            }
        }
    }

    // MARK: - Data Fetching and UI Update

    private func fetchDataAndUpdateUI() {
        let dateString = getCurrentDateFormatted()
        let yesterdayString = getYesterdayDateFormatted()
        
        let queryParams = [
            "userId": CurrentUser.shared.uid!,
            "StartDate": "2024-01-01",  // Example start date
            "EndDate": "2024-05-25"     // Example end date
        ]
        
        NetworkService.shared.request(endpoint: .home, method: "GET", queryParams: queryParams) { result in
            print("Returned!!!")
            DispatchQueue.main.async {
                self.handleAPIResponse(result, handler: self.handleUnifiedResponse)
            }
        }
    }

    // MARK: - API Response Handlers

    private func handleAPIResponse(_ result: Result<[String: Any], Error>, handler: @escaping (Result<[String: Any], Error>) -> Void) {
        DispatchQueue.main.async {
            handler(result)
        }
    }

    // MARK: - Unified API Response Handler

    private func handleUnifiedResponse(_ result: Result<[String: Any], Error>) {
        switch result {
        case .success(let json):
            if let dailyGoals = json["daily_goals"] as? [String: Any],
               let todayGoals = dailyGoals["today"] as? [String: Any] {
                self.handleDailyGoals(todayGoals)
            }
            if let dailyGoals = json["daily_goals"] as? [String: Any],
               let yesterdayGoals = dailyGoals["yesterday"] as? [String: Any] {
                self.handleYesterdayGoals(yesterdayGoals)
            }
            if let dailyStandsCount = json["daily_stands_count"] as? Int {
                self.handleDailyStandsCount(dailyStandsCount)
            }
            if let dailyStandsUserCount = json["daily_stands_user_count"] as? Int {
                self.handleDailyStandsUserCount(dailyStandsUserCount)
            }
            if let standStreak = json["daily_stands_streak"] as? Int {
                self.handleStandStreak(standStreak)
            }
            if let answerStreak = json["daily_question_answers_streak"] as? Int {
                self.handleAnswerStreak(answerStreak)
            }
            if let userPoints = json["user_points"] as? [String: Any],
               let totalPoints = userPoints["total_points"] as? Int {
                self.handleUserPoints(totalPoints)
            }
        case .failure(let error):
            print("Error: \(error.localizedDescription)")
            // Handle the error appropriately
        }
    }

    // MARK: - Specific Response Handlers

    private func handleDailyGoals(_ goals: [String: Any]) {
        self.dailyGoalLoading.isHidden = true
        self.globalStandingTodayLoading.isHidden = true
        if let goalValue = goals["Goal"] as? String, let goalInt = Int(goalValue) {
            let formattedGoal = formatLargeNumber(goalInt)
            let attributedString = NSMutableAttributedString(string: "\(formattedGoal)\nDaily Goal")
            let fontSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 30 : 18
            attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: fontSize), range: NSRange(location: attributedString.length - 10, length: 10))
            dailyGoalCount.attributedText = attributedString
        } else {
            dailyGoalCount.text = "0\nDaily Goal"
        }
        if let currentValue = goals["Current"] as? String {
            globalStandCount.text = "\(currentValue)"
        } else {
            globalStandCount.text = "0"
        }
        goal = Float(goals["Goal"] as? String ?? "0")!
        current = Float(goals["Current"] as? String ?? "0")!
    }

    private func handleYesterdayGoals(_ goals: [String: Any]) {
        if let currentValue = goals["Current"] as? String {
            yesterdayLabel.text = "      Yesterday: \(currentValue)      "
        } else {
            yesterdayLabel.text = "      N/A      "
        }
    }

    private func handleDailyStandsCount(_ count: Int) {
        self.usaTotalStandsLoading.isHidden = true
        usaTotalStandsLabel.text = "\(count)"
    }

    private func handleDailyStandsUserCount(_ count: Int) {
        self.myTotalStandsLoading.isHidden = true
        myTotalStandsLabel.text = "\(count)"
    }

    private func handleStandStreak(_ streak: Int) {
        self.myCurrentStreakLoading.isHidden = true
        myCurrentStreakLabel.text = "\(streak)"
        segmentedStreakBar.value = streak % 10
        standStreak = streak
    }

    private func handleAnswerStreak(_ streak: Int) {
        questionAnswerStreak = streak
    }

    private func handleUserPoints(_ points: Int) {
        print(points)
        myPointsLabel.text = "\(points) Points"
    }
    // MARK: - View Configuration
    
    private func configureViewComponents() {
        let interactableViews = [
            pushStandButton, accountButton, standStreakIcon, standStreakTitle,
            questionStreakIcon, questionStreakTitle, pointsIcon, pointsTitle, shareIcon
        ]
        interactableViews.forEach { $0?.isUserInteractionEnabled = true }
        
        yesterdayLabel.layer.cornerRadius = 16
        yesterdayLabel.layer.masksToBounds = true
        yesterdayLabel.layer.borderColor = UIColor.white.cgColor
        yesterdayLabel.layer.borderWidth = 1.0
    }
    
    // MARK: - Gesture Setup
    
    private func setupGestureRecognizers() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.0
        pushStandButton.addGestureRecognizer(longPressGesture)
        
        addTapGestureRecognizer(to: standStreakIcon, action: #selector(standStreakTapped))
        addTapGestureRecognizer(to: standStreakTitle, action: #selector(standStreakTapped))
        addTapGestureRecognizer(to: questionStreakIcon, action: #selector(questionStreakTapped))
        addTapGestureRecognizer(to: questionStreakTitle, action: #selector(questionStreakTapped))
        addTapGestureRecognizer(to: pointsIcon, action: #selector(pointsTapped))
        addTapGestureRecognizer(to: pointsTitle, action: #selector(pointsTapped))
        addTapGestureRecognizer(to: accountButton, action: #selector(accountsTapped))
        addTapGestureRecognizer(to: shareIcon, action: #selector(sendMessage))
    }
    
    private func addTapGestureRecognizer(to view: UIView?, action: Selector) {
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        view?.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Helper Methods
    
    private func getCurrentDateFormatted() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }
    
    private func getYesterdayDateFormatted() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: getCurrentDateFormatted()),
           let newDate = Calendar.current.date(byAdding: .day, value: -1, to: date) {
            return dateFormatter.string(from: newDate)
        }
        return ""
    }
    
    private func updateUIForPushStand() {
        landingViewWithButton.isHidden = true
        pushStandTitle.isHidden = true
        landingViewWithPicture.isHidden = true
        accountButton.isHidden = false
        tabBarController?.tabBar.alpha = 1
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        print("handleLongPress")
        if gesture.state == .began {
            UIView.animate(withDuration: 0.1) {
                self.pushStandButton.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                self.pushStandButton.alpha = 0.85
            }
        } else if gesture.state == .ended || gesture.state == .cancelled {
            UIView.animate(withDuration: 0.1) {
                self.pushStandButton.transform = .identity
                self.pushStandButton.alpha = 1.0
            }
            tapHaptic()
            print("ended")
            pushStand(gesture)
        }
    }
    
    @objc private func accountsTapped() {
        performSegue(withIdentifier: "account", sender: self)
    }
    
    @objc private func standStreakTapped() {
        updateStreakUI(
            selectedIcon: standStreakIcon,
            selectedIconImage: "red-star-icon",
            selectedTitle: standStreakTitle,
            selectedColor: .systemRed,
            selectedStreakValue: standStreak % 10
        )
    }
    
    @objc private func questionStreakTapped() {
        updateStreakUI(
            selectedIcon: questionStreakIcon,
            selectedIconImage: "cyan-star-icon",
            selectedTitle: questionStreakTitle,
            selectedColor: .systemCyan,
            selectedStreakValue: questionAnswerStreak % 10
        )
    }
    
    @objc private func pointsTapped() {
        updateStreakIconsForPoints()
        updateTitles(
            standStreakColor: .white,
            standStreakFontWeight: .light,
            questionStreakColor: .white,
            questionStreakFontWeight: .light,
            pointsColor: UIColor.systemBrown,
            pointsFontWeight: .bold
        )
        segmentedStreakBar.alpha = 0
        streakImage.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.myPointsLabel.alpha = 1
        }
    }
    
    @IBAction private func acknowledgeStreakFilled(_ sender: Any) {
        bonusStandView.isHidden = false
        streakFillView.isHidden = false
        segmentedStreakBar.value = 0
    }
    
    @IBAction private func pushStand(_ sender: UILongPressGestureRecognizer?) {
        let uuidString = UUID().uuidString
        let dateString = getDateFormatted()
        tabBarController?.tabBar.isHidden = false
        tapHaptic()
        
        let pushStandQueryParams = ["UserId": CurrentUser.shared.uid!, "Date": dateString]
        let unixTimestamp = Date().timeIntervalSince1970
        let pointsAwarded = (questionAnswerStreak % 10 == 0) ? "5" : "1"
        let postPointQueryParams = ["UserId": CurrentUser.shared.uid!, "Timestamp": String(unixTimestamp), "Points": pointsAwarded]
        
        postStand(queryParams: pushStandQueryParams) { result in
            self.postPoints(queryParams: postPointQueryParams) { result in
                // Handle result if needed
            }
        }
        
        savePushStandToUserDefaults(for: dateString)
        animatePushStandButtonFadeOut()
    }
    
    private func savePushStandToUserDefaults(for dateString: String) {
        UserDefaults.standard.set(true, forKey: dateString)
        appDelegate.userDefault.set(true, forKey: dateString)
        appDelegate.userDefault.synchronize()
    }
    
    private func animatePushStandButtonFadeOut() {
        UIView.animate(withDuration: 0.0, delay: 0.2, animations: {
            self.pushStandButton.alpha = 0
        }) { _ in
            self.animateLandingViewsFadeOut()
        }
    }
    
    private func animateLandingViewsFadeOut() {
        UIView.animate(withDuration: 1.0, delay: 1.5, animations: {
            self.landingViewWithPicture.alpha = 0
            self.pushStandTitle.alpha = 0
            self.landingViewWithButton.alpha = 0
            self.tabBarController?.tabBar.alpha = 1
        }) { finished in
            if finished {
                self.landingViewWithButton.isHidden = true
                self.pushStandTitle.isHidden = true
                self.landingViewWithPicture.isHidden = true
                self.accountButton.isHidden = false
                self.shareIcon.isHidden = false
                self.animateStandStreakLabel()
            }
            self.updateProgressBar()
        }
    }
    
    private func animateStandStreakLabel() {
        UIView.animate(withDuration: 1.0, animations: {
            if self.standStreak > 0 && self.standStreak % 10 == 0 {
                self.standStreakLabel.text = "5 Points"
            }
            self.standStreakLabel.alpha = 1.0
        }) { finished in
            if finished {
                UIView.animate(withDuration: 1.0, delay: 1.0, options: [], animations: {
                    self.standStreakLabel.alpha = 0.0
                }, completion: nil)
            }
        }
    }
    
    private func updateProgressBar() {
        let progressAmount = current / goal
        standProgressBar.progress = CGFloat(progressAmount)
    }
    
    private func updateStreakUI(selectedIcon: UIImageView, selectedIconImage: String, selectedTitle: UILabel, selectedColor: UIColor, selectedStreakValue: Int) {
        let icons = [standStreakIcon, questionStreakIcon, pointsIcon]
        
        icons.forEach { $0?.alpha = 0.5 }
        selectedIcon.alpha = 1.0
        selectedIcon.image = UIImage(named: selectedIconImage)
        
        updateTitles(
            standStreakColor: selectedColor == .systemRed ? selectedColor : .white,
            standStreakFontWeight: selectedColor == .systemRed ? .bold : .light,
            questionStreakColor: selectedColor == .systemCyan ? selectedColor : .white,
            questionStreakFontWeight: selectedColor == .systemCyan ? .bold : .light,
            pointsColor: selectedColor == .systemBrown ? selectedColor : .white,
            pointsFontWeight: selectedColor == .systemBrown ? .bold : .light
        )
        
        myPointsLabel.alpha = 0
        segmentedStreakBar.alpha = 1
        streakImage.alpha = 1
        segmentedStreakBar.selectedColor = selectedColor
        segmentedStreakBar.value = selectedStreakValue
        streakImage.image = UIImage(named: selectedIconImage)
    }
    
    private func updateTitles(standStreakColor: UIColor, standStreakFontWeight: UIFont.Weight, questionStreakColor: UIColor, questionStreakFontWeight: UIFont.Weight, pointsColor: UIColor, pointsFontWeight: UIFont.Weight) {
        standStreakTitle.textColor = standStreakColor
        standStreakTitle.font = UIFont.systemFont(ofSize: standStreakTitle.font.pointSize, weight: standStreakFontWeight)
        
        questionStreakTitle.textColor = questionStreakColor
        questionStreakTitle.font = UIFont.systemFont(ofSize: questionStreakTitle.font.pointSize, weight: questionStreakFontWeight)
        
        pointsTitle.textColor = pointsColor
        pointsTitle.font = UIFont.systemFont(ofSize: pointsTitle.font.pointSize, weight: pointsFontWeight)
    }
    
    private func updateStreakIconsForPoints() {
        standStreakIcon.image = UIImage(named: "red-star-icon")
        standStreakIcon.alpha = 0.5
        questionStreakIcon.image = UIImage(named: "cyan-star-icon")
        questionStreakIcon.alpha = 0.5
        pointsIcon.image = UIImage(named: "gold-star-icon")
        pointsIcon.alpha = 1.0
    }
    
    private func postStand(queryParams: [String: String], completion: @escaping (Result<[String: Any], Error>) -> Void) {
        // Call the request method of NetworkService
        NetworkService.shared.request(endpoint: .stand, method: "POST", data: queryParams) {result in
            
            print(result)
            self.updateStandCounts()
            self.updateUIForNewStand()
        }
        
    }
    
    private func updateStandCounts() {
        let labels = [globalStandCount, myCurrentStreakLabel, myTotalStandsLabel, usaTotalStandsLabel]
        
        labels.forEach { label in
            if let currentCount = Int(label?.text ?? "0") {
                label?.text = String(currentCount + 1)
            }
        }
    }
    
    private func updateUIForNewStand() {
        current += 1
        standStreak += 1
        
        if standStreak > 0 && standStreak % 10 == 0 {
            segmentedStreakBar.value = 10
            bonusStandView.isHidden = false
            streakFillView.isHidden = false
        } else {
            segmentedStreakBar.value = standStreak % 10
        }
        
        pointsCount += 1
        myPointsLabel.text = "\(pointsCount) Points"
    }
    
    @objc private func sendMessage() {
        if MFMessageComposeViewController.canSendText() {
            let messageVC = MFMessageComposeViewController()
            messageVC.body = "Join me on the app that is uniting Americans one STAND at a time! \n\n Follow us! \n Insta: pushstand_now \n X: @pushstand_now \n\n https://pushstand.com/"
            messageVC.recipients = [] // Enter the phone number here
            messageVC.messageComposeDelegate = self
            present(messageVC, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
