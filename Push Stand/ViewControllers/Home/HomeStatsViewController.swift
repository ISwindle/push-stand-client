import UIKit
import Combine
import MessageUI

class HomeStatsViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
    // MARK: - Properties
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var sessionViewModel: SessionViewModel!
    
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
    ///Added for Daily Goal Achieved
    @IBOutlet weak var shareNow: UIButton! //action already linked, but still needs to dismiss view once done
    @IBOutlet weak var skipSharing: UIButton! //action not linked, if tapped, should dismiss dailyGoalAchievedView
    @IBOutlet weak var dailyGoalAchievedView: UIVisualEffectView! //hidden, also behind bonus standing view so if we have a day where both happens, bonus stand view shows first then dailygoalachieved view
    
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
    
    // To hold StandBonusView, DailyGoalAchievedView, BuildUpPointsView
    @IBOutlet weak var popupContainerView: UIView!
    
    @IBOutlet weak var pushStandTimer: UILabel!
    var countdownTimer: Timer?
    
    private var goal: Float = Defaults.zeroFloat
    private var current: Float = Defaults.zeroFloat
    private var questionAnswerStreak: Int = Defaults.int
    private var standStreak = Defaults.int
    private var pointsCount = Defaults.int
    
    // MARK: - Dependencies
    let gestureHandler = GestureHandler() //
    //private var userManager: UserManager
    
    var currentUser = CurrentUser.shared
    let userDefault = UserDefaults.standard
    var should_not_rev = false
    
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewComponents()
        // Update the UI every second
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimerLabel), userInfo: nil, repeats: true)
        setupGestures()
        let dateString = Time.getDateFormatted()
        if !UserDefaults.standard.bool(forKey: dateString){
            loadHome()            
        }
        
        presentLoadingIcons()
        bindUI()
        
        // Add tap gesture recognizer to standProgressBar
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(standProgressBarTapped))
        standProgressBar.addGestureRecognizer(tapGesture)
        standProgressBar.isUserInteractionEnabled = true
    }
    
    
    @objc func updateTimerLabel() {
            let remainingTime = CountdownTimerManager.shared.remainingTime
            if remainingTime > 0 {
                let hours = Int(remainingTime) / 3600
                let minutes = Int(remainingTime) % 3600 / 60
                let seconds = Int(remainingTime) % 60
                
                // Update the label
                pushStandTimer.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            } else {
                pushStandTimer.text = "00:00:00"
            }
    }

    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Invalidate the timer if the view disappears
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
    
    @objc func standProgressBarTapped() {
        standProgressBar.isUserInteractionEnabled = false
        standProgressBar.animateQuickColorChange()
        should_not_rev = false
        fetchDataAndUpdateUI()
        
        //Timed delay where user interaction is NOT enabled
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.standProgressBar.isUserInteractionEnabled = true
        }
    }
    
    func presentLoadingIcons(){
        // loading false or true test
        dailyGoalLoading.isHidden = false
        myCurrentStreakLoading.isHidden = false
        myTotalStandsLoading.isHidden = false
        usaTotalStandsLoading.isHidden = false
        globalStandingTodayLoading.isHidden = false
    }
    
    private func bindUI() {
        // Bindings for daily data
        SessionViewModel.shared.standModel.$dailyGoal
            .map { "\($0)" }
            .assign(to: \.text, on: dailyGoalCount)
            .store(in: &cancellables)
        
        SessionViewModel.shared.standModel.$americansStandingToday
            .map { "\($0)" }
            .assign(to: \.text, on: globalStandCount)
            .store(in: &cancellables)
        
        SessionViewModel.shared.standModel.$yesterdaysStanding
            .map {"      Yesterday: \($0)      "}
            .assign(to: \.text, on: yesterdayLabel)
            .store(in: &cancellables)
        
        // Bindings for aggregate stats
        SessionViewModel.shared.standModel.$myStandStreak
            .map { "\($0)" }
            .assign(to: \.text, on: myCurrentStreakLabel)
            .store(in: &cancellables)
        
        SessionViewModel.shared.standModel.$myTotalStands
            .map { "\($0)" }
            .assign(to: \.text, on: myTotalStandsLabel)
            .store(in: &cancellables)
        
        SessionViewModel.shared.standModel.$usaTotalStands
            .map { "\(Formatter.formatLargeNumber($0))" }
            .assign(to: \.text, on: usaTotalStandsLabel)
            .store(in: &cancellables)
        
        SessionViewModel.shared.standModel.$myPoints
            .map { "\($0) Points" }
            .assign(to: \.text, on: myPointsLabel)
            .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.alpha = 0
        let dateString = Time.getDateFormatted()
        if UserDefaults.standard.bool(forKey: dateString) {
            updateForStandStats()
            appDelegate.appStateViewModel.setAppBadgeCount(to: 1)
        } else {
            appDelegate.appStateViewModel.setAppBadgeCount(to: 2)
            updateUIForLoad()
            checkStandToday()
        }
        loadHome()
        fetchDailyQuestion()
        // Initially set the label to "Push Stand"
        pushStandTimer.text = "PUSH STAND"
        
        // Animate transition after 2 seconds with a fade effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.fadeOutLabel {
                CountdownTimerManager.shared.startCountdown()
                self.fadeInLabel()
            }
        }
        
    }
    
    // Helper functions to handle fade in and fade out effects
        func fadeOutLabel(completion: @escaping () -> Void) {
            UIView.animate(withDuration: 0.5, animations: {
                self.pushStandTimer.alpha = 0.0
            }) { _ in
                completion()
            }
        }
        
        func fadeInLabel() {
            UIView.animate(withDuration: 0.5, animations: {
                self.pushStandTimer.alpha = 1.0
            })
        }
    
    private func fetchDailyQuestion() {
        let dailyQuestionsQueryParams = [Constants.UserDefaultsKeys.userId: CurrentUser.shared.uid!, "Date": Time.getDateFormatted()]
        NetworkService.shared.request(endpoint: .questions, method: HTTPVerbs.get.rawValue, queryParams: dailyQuestionsQueryParams) { (result: Result<[String: Any], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let json):
                    if let answer = json["UserAnswer"] as? String,
                       let question = json["Question"] as? String {
                        if !answer.isEmpty {
                            self.appDelegate.appStateViewModel.setAppBadgeCount(to: 0)
                            if let tabBarController = self.tabBarController as? RootTabBarController {
                                tabBarController.updateQuestionBadge(addBadge: false)
                            }
                            return
                        } else {
                            if let tabBarController = self.tabBarController as? RootTabBarController {
                                tabBarController.updateQuestionBadge(addBadge: true)
                            }
                        }
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    func loadHome() {
        NetworkService.shared.request(endpoint: .stand, method: HTTPVerbs.get.rawValue, queryParams: ["user_id": CurrentUser.shared.uid!]) { (result: Result<[String: Any], Error>) in
            DispatchQueue.main.async {
                self.fetchDataAndUpdateUI()
            }
        }
    }
    
    // MARK: - Interactions
    
    private func setupGestures() {
        gestureHandler.addLongPressGesture(to: pushStandButton, target: self, action: #selector(handleLongPress(_:)), minimumPressDuration: 0.0)
        gestureHandler.addTapGesture(to: standStreakIcon, target: self, action: #selector(standStreakTapped))
        gestureHandler.addTapGesture(to: standStreakTitle, target: self, action: #selector(standStreakTapped))
        gestureHandler.addTapGesture(to: questionStreakIcon, target: self, action: #selector(questionStreakTapped))
        gestureHandler.addTapGesture(to: questionStreakTitle, target: self, action: #selector(questionStreakTapped))
        gestureHandler.addTapGesture(to: pointsIcon, target: self, action: #selector(pointsTapped))
        gestureHandler.addTapGesture(to: pointsTitle, target: self, action: #selector(pointsTapped))
        gestureHandler.addTapGesture(to: accountButton, target: self, action: #selector(accountsTapped))
        gestureHandler.addTapGesture(to: shareIcon, target: self, action: #selector(sendMessage))
        gestureHandler.addTapGesture(to: shareNow, target: self, action: #selector(sendMessage))
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
            if !should_not_rev {
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
            SessionViewModel.shared.standModel.americansStandingToday = Int(currentValue)!
        } else {
            globalStandCount.text = Defaults.zeroString
            SessionViewModel.shared.standModel.americansStandingToday = 0
        }
        goal = Float(goals["Goal"] as? String ?? Defaults.zeroString)!
        current = Float(goals["Current"] as? String ?? Defaults.zeroString)!
    }
    
    private func handleYesterdayGoals(_ goals: [String: Any]) {
        if let currentValue = goals["Current"] as? String {
            SessionViewModel.shared.standModel.yesterdaysStanding = Int(currentValue)!
        }
    }
    
    private func handleDailyStandsCount(_ count: Int) {
        self.usaTotalStandsLoading.isHidden = true
        if !UserDefaults.standard.bool(forKey: Time.getDateFormatted()) {
            self.pushStandButton.isHidden = false
        }
        self.globalStandCount.alpha = 1
        SessionViewModel.shared.standModel.usaTotalStands = count
    }
    
    private func handleDailyStandsUserCount(_ count: Int) {
        self.myTotalStandsLoading.isHidden = true
        SessionViewModel.shared.standModel.myTotalStands =  count
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
        SessionViewModel.shared.standModel.myPoints = points
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
        yesterdayLabel.layer.borderColor = UIColor.darkGray.cgColor
        yesterdayLabel.layer.borderWidth = 1.0
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
                        self.appDelegate.appStateViewModel.setAppBadgeCount(to: 1)
                        self.updateForStandStats()
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
    
    private func updateForStandStats() {
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
        pushStandButton.isHidden = true
        dailyGoalLoading.isHidden = true
        globalStandCount.alpha = 0
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
        
        current += 1
        standStreak += 1
        SessionViewModel.shared.standModel.americansStandingToday += 1
        let pushStandQueryParams = ["UserId": CurrentUser.shared.uid!, "Date": dateString]
        let unixTimestamp = Date().timeIntervalSince1970
        let pointsAwarded = (standStreak % 10 == 0) ? Constants.standStreakHitPoints : Constants.standPoints
        let postPointQueryParams = ["UserId": CurrentUser.shared.uid!, "Timestamp": String(unixTimestamp), "Points": pointsAwarded]
        
        postStand(queryParams: pushStandQueryParams) { result in
            
        }
        NetworkService.shared.request(endpoint: .points, method: HTTPVerbs.post.rawValue, data: postPointQueryParams) { result in
            
        }
        appDelegate.appStateViewModel.setAppBadgeCount(to: 1)
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
        should_not_rev = true
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
        let labels = [myCurrentStreakLabel, myTotalStandsLabel, usaTotalStandsLabel]
        
        labels.forEach { label in
            if let currentCount = Int(label?.text ?? Defaults.zeroString) {
                label?.text = String(currentCount + 1)
            }
        }
    }
    
    private func updateUIForNewStand() {
        if standStreak > Constants.standStreakMin && standStreak % Constants.standStreakMax == Constants.streakBarMin {
            segmentedStreakBar.value = Constants.standStreakMax
            bonusStandView.isHidden = false
            streakFillView.isHidden = false
            SessionViewModel.shared.standModel.myPoints += 10
        } else {
            segmentedStreakBar.value = standStreak % Constants.standStreakMax
            SessionViewModel.shared.standModel.myPoints += 1
        }
        
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
