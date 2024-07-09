import UIKit
import Combine
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
    @IBOutlet weak var standingTodayView: UIStackView!
    
    private var goal: Float = Defaults.zeroFloat
    private var current: Float = Defaults.zeroFloat
    private var questionAnswerStreak: Int = Defaults.int
    private var standStreak = Defaults.int
    private var pointsCount = Defaults.int
    
    let dailyGoalsEndpoint = NetworkService.Endpoint.dailyGoals.rawValue
    let userTotalStandsEndpoint = NetworkService.Endpoint.userStands.rawValue
    let usTotalStandsEndpoint = NetworkService.Endpoint.stands.rawValue
    let currentStandStreakEndpoint = NetworkService.Endpoint.streaks.rawValue
    let currentAnswerStreakEndpoint = NetworkService.Endpoint.streaksAnswers.rawValue
    let userPointsEndpoint = NetworkService.Endpoint.points.rawValue
    let pushStandEndpoint = NetworkService.Endpoint.stand.rawValue
    var currentUser = CurrentUser.shared
    let userDefault = UserDefaults.standard
    var initial_rev = false
    
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewComponents()
        setupGestureRecognizers()
        let dateString = Time.getDateFormatted()
        if !UserDefaults.standard.bool(forKey: dateString) {
            loadHome()
        }
        
        presentLoadingIcons()
        bindUI()
        
    }
    
    func presentLoadingIcons(){
        // loading false or true test
        dailyGoalLoading.isHidden = false
        myCurrentStreakLoading.isHidden = false
        myTotalStandsLoading.isHidden = false
        usaTotalStandsLoading.isHidden = false
        globalStandingTodayLoading.isHidden = false
    }
    
    func bindUI() {
        // Bindings for daily data
        appDelegate.standModel.$dailyGoal
            .map { "\($0)" }
            .assign(to: \.text, on: dailyGoalCount)
            .store(in: &cancellables)
        
        appDelegate.standModel.$americansStandingToday
            .map { "\($0)" }
            .assign(to: \.text, on: globalStandCount)
            .store(in: &cancellables)
        
        appDelegate.standModel.$yesterdaysStanding
            .map {"      Yesterday: \($0)      "}
            .assign(to: \.text, on: yesterdayLabel)
            .store(in: &cancellables)
        
        // Custom binding for yesterday's standing with loading state
        appDelegate.standModel.$yesterdaysStanding
            .receive(on: DispatchQueue.main)
            .sink { [weak self] standing in
                guard let self = self else { return }
                if standing != 0 { // Check if standing has a value
                    self.yesterdayLabel.text = "      Yesterday: \(standing)      "
                }
                // else, display storyboard's initial text
                // doing this to avoid yesterday displaying "0" when loading
            }
            .store(in: &cancellables)
        
        // Bindings for aggregate stats
        appDelegate.standModel.$myStandStreak
            .map { "\($0)" }
            .assign(to: \.text, on: myCurrentStreakLabel)
            .store(in: &cancellables)
        
        appDelegate.standModel.$myTotalStands
            .map { "\($0)" }
            .assign(to: \.text, on: myTotalStandsLabel)
            .store(in: &cancellables)
        
        appDelegate.standModel.$usaTotalStands
            .map { "\(Formatter.formatLargeNumber($0))" }
            .assign(to: \.text, on: usaTotalStandsLabel)
            .store(in: &cancellables)
        
        appDelegate.standModel.$myPoints
            .map { "\($0) Points" }
            .assign(to: \.text, on: myPointsLabel)
            .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.alpha = 0
        let dateString = Time.getDateFormatted()
        if UserDefaults.standard.bool(forKey: dateString) {
            updateUIForPushStand()
        } else {
            updateUIForLoad()
            checkStandToday()
        }
        loadHome()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func loadHome() {
        NetworkService.shared.request(endpoint: .stand, method: HTTPVerbs.get.rawValue, queryParams: ["user_id": CurrentUser.shared.uid!]) { (result: Result<[String: Any], Error>) in
            DispatchQueue.main.async {
                self.fetchDataAndUpdateUI()
            }
        }
    }
    
    // MARK: - Data Fetching and UI Update
    
    private func fetchDataAndUpdateUI() {
        let dateString = Time.getCurrentDateFormatted()
        let yesterdayString = Time.getPreviousDateFormatted()
        
        let queryParams = [
            "userId": CurrentUser.shared.uid!,
        ]
        
        NetworkService.shared.request(endpoint: .home, method: HTTPVerbs.get.rawValue, queryParams: queryParams) { result in
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
            if let userPoints = json["user_points"] as? Int {
                self.handleUserPoints(userPoints)
            }
            if !initial_rev {
                updateProgressBar()
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
            let formattedGoal = Formatter.formatLargeNumber(goalInt)
            let attributedString = NSMutableAttributedString(string: "\(goalInt)")
            dailyGoalCount.attributedText = attributedString
        } else {
            dailyGoalCount.text = Defaults.zeroString
        }
        if let currentValue = goals["Current"] as? String {
            globalStandCount.text = "\(currentValue)"
        } else {
            globalStandCount.text = Defaults.zeroString
        }
        goal = Float(goals["Goal"] as? String ?? Defaults.zeroString)!
        current = Float(goals["Current"] as? String ?? Defaults.zeroString)!
    }
    
    private func handleYesterdayGoals(_ goals: [String: Any]) {
        if let currentValue = goals["Current"] as? String {
            appDelegate.standModel.yesterdaysStanding = Int(currentValue)!
        }
    }
    
    private func handleDailyStandsCount(_ count: Int) {
        self.usaTotalStandsLoading.isHidden = true
        appDelegate.standModel.usaTotalStands = count
    }
    
    private func handleDailyStandsUserCount(_ count: Int) {
        self.myTotalStandsLoading.isHidden = true
        appDelegate.standModel.myTotalStands =  count
    }
    
    private func handleStandStreak(_ streak: Int) {
        self.myCurrentStreakLoading.isHidden = true
        myCurrentStreakLabel.text = "\(streak)"
        segmentedStreakBar.value = streak % Constants.streakBarMax
        standStreak = streak
    }
    
    private func handleAnswerStreak(_ streak: Int) {
        questionAnswerStreak = streak
    }
    
    private func handleUserPoints(_ points: Int) {
        myPointsLabel.isHidden = false
        appDelegate.standModel.myPoints = points
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
    
    func addTapGestureRecognizer(to view: UIView?, action: Selector) {
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        view?.addGestureRecognizer(tapGesture)
    }
    
    
    // MARK: - Helper Methods
    
    private func checkStandToday() {
        currentUser.uid = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.userId)
        let queryParams = ["user_id": currentUser.uid!]
        NetworkService.shared.request(endpoint: .stand, method: HTTPVerbs.get.rawValue, queryParams: queryParams) { result in
            switch result {
            case .success(let json):
                if let hasTakenAction = json["has_taken_action"] as? Bool {
                    if hasTakenAction {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let dateString = dateFormatter.string(from: Date())
                        UserDefaults.standard.set(true, forKey: dateString)
                        self.userDefault.set(true, forKey: dateString)
                        self.userDefault.synchronize()
                        self.updateUIForPushStand()
                    } else {
                        self.updateUIForPushStandButton()
                    }
                } else {
                    print(result)
                    print("Invalid response format")
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                // Handle the error appropriately
            }
        }
    }
    
    private func updateUIForLoad() {
        landingViewWithButton.isHidden = false
        standingTodayView.isHidden = true
        pushStandTitle.isHidden = false
        pushStandButton.isHidden = true
        dailyGoalLoading.isHidden = true
        globalStandingTodayLoading.isHidden = true
        landingViewWithPicture.isHidden = false
        accountButton.isHidden = true
        tabBarController?.tabBar.alpha = 0
    }
    
    private func updateUIForPushStand() {
        landingViewWithButton.isHidden = true
        pushStandTitle.isHidden = true
        standingTodayView.isHidden = false
        landingViewWithPicture.isHidden = true
        accountButton.isHidden = false
        tabBarController?.tabBar.alpha = 1
        
    }
    
    private func updateUIForPushStandButton() {
        landingViewWithButton.isHidden = false
        standingTodayView.isHidden = false
        pushStandTitle.isHidden = false
        pushStandButton.isHidden = false
        dailyGoalLoading.isHidden = true
        globalStandingTodayLoading.isHidden = false
        landingViewWithPicture.isHidden = false
        accountButton.isHidden = true
        tabBarController?.tabBar.alpha = 0
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
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
            Haptic.heavyTap()
            pushStand(gesture)
        }
    }
    
    @objc private func accountsTapped() {
        performSegue(withIdentifier: Segues.account, sender: self)
    }
    
    @objc private func standStreakTapped() {
        updateStreakUI(
            selectedIcon: standStreakIcon,
            selectedIconImage: Constants.redStarImg,
            selectedTitle: standStreakTitle,
            selectedColor: .systemRed,
            selectedStreakValue: standStreak % Constants.standStreakMax
        )
    }
    
    @objc private func questionStreakTapped() {
        updateStreakUI(
            selectedIcon: questionStreakIcon,
            selectedIconImage: Constants.blueStarImg,
            selectedTitle: questionStreakTitle,
            selectedColor: .systemBlue,
            selectedStreakValue: questionAnswerStreak % Constants.questionStreakMax
        )
    }
    
    @objc private func pointsTapped() {
        updateStreakIconsForPoints()
        updateTitles(
            standStreakColor: .white,
            standStreakFontWeight: .light,
            questionStreakColor: .white,
            questionStreakFontWeight: .light,
            pointsColor: UIColor.white,
            pointsFontWeight: .bold
        )
        segmentedStreakBar.alpha = Constants.zeroAlpha
        streakImage.alpha = Constants.zeroAlpha
        UIView.animate(withDuration: 0.5) {
            self.myPointsLabel.alpha = Constants.fullAlpha
        }
    }
    
    @IBAction private func acknowledgeStreakFilled(_ sender: Any) {
        bonusStandView.isHidden = true
        streakFillView.isHidden = true
        segmentedStreakBar.value = Constants.streakBarMin
    }
    
    @IBAction private func pushStand(_ sender: UILongPressGestureRecognizer?) {
        let uuidString = UUID().uuidString
        let dateString = Time.getDateFormatted()
        tabBarController?.tabBar.isHidden = false
        Haptic.heavyTap()
        
        let pushStandQueryParams = ["UserId": CurrentUser.shared.uid!, "Date": dateString]
        let unixTimestamp = Date().timeIntervalSince1970
        let pointsAwarded = (standStreak % 10 == 0) ? Constants.standStreakHitPoints : Constants.standPoints
        let postPointQueryParams = ["UserId": CurrentUser.shared.uid!, "Timestamp": String(unixTimestamp), "Points": pointsAwarded]
        
        postStand(queryParams: pushStandQueryParams) { result in
            
        }
        NetworkService.shared.request(endpoint: .points, method: HTTPVerbs.post.rawValue, data: postPointQueryParams) { result in
            
        }
        UIApplication.shared.applicationIconBadgeNumber =  UIApplication.shared.applicationIconBadgeNumber - 1
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
            self.pushStandButton.alpha = Constants.zeroAlpha
        }) { _ in
            self.animateLandingViewsFadeOut()
        }
    }
    
    private func animateLandingViewsFadeOut() {
        UIView.animate(withDuration: 1.0, delay: 1.5, animations: {
            self.landingViewWithPicture.alpha = Constants.zeroAlpha
            self.pushStandTitle.alpha = Constants.zeroAlpha
            self.landingViewWithButton.alpha = Constants.zeroAlpha
            self.tabBarController?.tabBar.alpha = Constants.fullAlpha
        }) { finished in
            if finished {
                self.landingViewWithButton.isHidden = true
                self.pushStandTitle.isHidden = true
                self.landingViewWithPicture.isHidden = true
                self.accountButton.isHidden = false
                self.shareIcon.isHidden = false
                self.animateStandStreakLabel()
                
                // Half-second delay before updating the progress bar
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.updateProgressBar()
                }
            }
        }
        
    }
    
    private func animateStandStreakLabel() {
        UIView.animate(withDuration: 1.0, animations: {
            if self.standStreak > 0 && self.standStreak % Constants.standStreakMax == Constants.streakBarMin {
                self.standStreakLabel.text = Constants.fivePoints
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
        initial_rev = true
    }
    
    private func updateStreakUI(selectedIcon: UIImageView, selectedIconImage: String, selectedTitle: UILabel, selectedColor: UIColor, selectedStreakValue: Int) {
        let icons = [standStreakIcon, questionStreakIcon, pointsIcon]
        
        icons.forEach { $0?.alpha = 0.5 }
        selectedIcon.alpha = Constants.fullAlpha
        selectedIcon.image = UIImage(named: selectedIconImage)
        
        updateTitles(
            standStreakColor: selectedColor == .systemRed ? selectedColor : .white,
            standStreakFontWeight: selectedColor == .systemRed ? .bold : .light,
            questionStreakColor: selectedColor == .systemBlue ? selectedColor : .white,
            questionStreakFontWeight: selectedColor == .systemBlue ? .bold : .light,
            pointsColor: selectedColor == .white ? selectedColor : .white,
            pointsFontWeight: selectedColor == .white ? .bold : .light
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
        standStreakIcon.image = UIImage(named: Constants.redStarImg)
        standStreakIcon.alpha = 0.5
        questionStreakIcon.image = UIImage(named: Constants.blueStarImg)
        questionStreakIcon.alpha = 0.5
        pointsIcon.image = UIImage(named: Constants.whiteStarImg)
        pointsIcon.alpha = 1.0
    }
    
    private func postStand(queryParams: [String: String], completion: @escaping (Result<[String: Any], Error>) -> Void) {
        // Call the request method of NetworkService
        NetworkService.shared.request(endpoint: .stand, method: HTTPVerbs.post.rawValue, data: queryParams) {result in
            
            self.updateStandCounts()
            self.updateUIForNewStand()
        }
        
    }
    
    private func updateStandCounts() {
        let labels = [globalStandCount, myCurrentStreakLabel, myTotalStandsLabel, usaTotalStandsLabel]
        
        labels.forEach { label in
            if let currentCount = Int(label?.text ?? Defaults.zeroString) {
                label?.text = String(currentCount + 1)
            }
        }
    }
    
    private func updateUIForNewStand() {
        current += 1
        standStreak += 1
        
        if standStreak > Constants.standStreakMin && standStreak % Constants.standStreakMax == Constants.streakBarMin {
            segmentedStreakBar.value = Constants.standStreakMax
            bonusStandView.isHidden = false
            streakFillView.isHidden = false
        } else {
            segmentedStreakBar.value = standStreak % Constants.standStreakMax
        }
        
        pointsCount += 1
        appDelegate.standModel.myPoints = pointsCount
    }
    
    @objc private func sendMessage() {
        if MFMessageComposeViewController.canSendText() {
            let messageVC = MFMessageComposeViewController()
            messageVC.body = "Join me on the app that is uniting Americans one STAND at a time! \n\n Follow us! \n Insta: pushstand_now \n X: @pushstand_now \n\n https://pushstand.com/"
            messageVC.recipients = []
            messageVC.messageComposeDelegate = self
            present(messageVC, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
