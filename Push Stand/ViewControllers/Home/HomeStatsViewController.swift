import UIKit
import Combine
import MessageUI

class HomeStatsViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
    // MARK: - Properties
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var sessionViewModel: SessionViewModel!
    let defaultTitleLabel = "PUSH STAND"
    
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
    
    @IBOutlet weak var segmentedStreakBar: SegmentedBar!
    @IBOutlet weak var streakImage: UIImageView!
    @IBOutlet weak var myCurrentStreakLabel: UILabel!
    @IBOutlet weak var myTotalStandsLabel: UILabel!
    @IBOutlet weak var usaTotalStandsLabel: UILabel!
    @IBOutlet weak var streakFillButton: UIButton!
    @IBOutlet weak var dailyGoalLoading: UIActivityIndicatorView!
    @IBOutlet weak var myCurrentStreakLoading: UIActivityIndicatorView!
    @IBOutlet weak var myTotalStandsLoading: UIActivityIndicatorView!
    @IBOutlet weak var usaTotalStandsLoading: UIActivityIndicatorView!
    @IBOutlet weak var globalStandingTodayLoading: UIActivityIndicatorView!
    @IBOutlet weak var standingTodayView: UIStackView!
    
    // To hold StandBonusView, DailyGoalAchievedView, BuildUpPointsView
    @IBOutlet weak var popupContainerView: UIView!
    
    @IBOutlet weak var popUpContainer: UIView!
    
    @IBOutlet weak var pushStandTimer: UILabel!
    var standBonusView: StandBonusView? // Reference to the loaded XIB view
    var dailyGoalAchievedView: DailyGoalAchievedView?
    var buildsUpPointView: BuildUpPointsView?
    var answerBonusView: AnswerBonusView?
    var countdownTimer: Timer?
    
    private var goal: Float = Defaults.zeroFloat
    private var current: Float = Defaults.zeroFloat
    private var pointsCount = Defaults.int
    
    // MARK: - Dependencies
    let gestureHandler = GestureHandler() //

    var currentUser = CurrentUser.shared
    let userDefault = UserDefaults.standard
    var should_not_rev = false
    var dailyGoalMet = false
    
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewComponents()
        pushStandTimer.text = defaultTitleLabel
        setupGestures()
        //let dateString = Time.getDateFormatted()
        //        if !UserDefaults.standard.bool(forKey: dateString){
        //            loadHome()
        //        }
//        checkDailyStand { metGoal in
//            if let metGoal = metGoal {
//                // Use the 'metGoal' value
//                print("Did meet goal: \(metGoal)")
//                // Perform actions based on the result
//                // Perform actions based on the result
//                if metGoal {
//                    self.showDailyGoalAchievedView()
//                } else {
//                    // Goal was not met
//                }
//            } else {
//                // Handle error
//                print("Failed to retrieve goal status.")
//            }
//        }
        presentLoadingIcons()
        bindUI()
        
        // Add tap gesture recognizer to standProgressBar
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(standProgressBarTapped))
        standProgressBar.addGestureRecognizer(tapGesture)
        standProgressBar.isUserInteractionEnabled = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.alpha = 0
        let dateString = Time.getPacificDateFormatted()
        updateUIForLoad()
        if UserDefaults.standard.bool(forKey: dateString) {
            if SessionViewModel.shared.standModel.americansStandingToday >= 1 {
                globalStandingTodayLoading.isHidden = true
                dailyGoalLoading.isHidden = true
            } else {
                globalStandingTodayLoading.isHidden = false
                dailyGoalLoading.isHidden = false
            }
            updateForStandStats()
            if UIApplication.shared.applicationIconBadgeNumber < 1 {
                appDelegate.appStateViewModel.setAppBadgeCount(to: 0)
            } else {
                appDelegate.appStateViewModel.setAppBadgeCount(to: 1)
            }
        } else {
            updateUIForPushStandButton()
            appDelegate.appStateViewModel.setAppBadgeCount(to: 2)
        }
        loadHome()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Animate transition after 2 seconds with a fade effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.fadeOutLabel {
                self.fadeInLabel()
            }
        }
    }
    
    func setupDailyTimer() {
        // Update the UI every second
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimerLabel), userInfo: nil, repeats: true)
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
        pushStandTimer.text = defaultTitleLabel
    }
    
    @objc func standProgressBarTapped() {
        standProgressBar.isUserInteractionEnabled = false
        standProgressBar.animateQuickColorChange()
        should_not_rev = false
        fetchHomeStats()
        
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
    
    // Helper functions to handle fade in and fade out effects
    func fadeOutLabel(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.5, animations: {
            self.pushStandTimer.alpha = 0.0
        }) { _ in
            completion()
        }
    }
    
    func fadeInLabel() {
        self.setupDailyTimer()
        UIView.animate(withDuration: 3.5, animations: {
            self.pushStandTimer.alpha = 1.0
        })
    }
    
    func loadHome() {
        DispatchQueue.main.async {
            self.fetchHomeStats()
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
    }
    
    // MARK: - View Configuration
    
    private func configureViewComponents() {
        configureInteractableViews()
        configureYesterdayLabel()
    }
    
    private func configureInteractableViews() {
        let interactableViews = [
            pushStandButton, accountButton, standStreakIcon, standStreakTitle,
            questionStreakIcon, questionStreakTitle, pointsIcon, pointsTitle, shareIcon
        ]
        interactableViews.forEach { $0?.isUserInteractionEnabled = true }
    }
    
    private func configureYesterdayLabel() {
        yesterdayLabel.layer.cornerRadius = 16
        yesterdayLabel.layer.masksToBounds = true
        yesterdayLabel.layer.borderColor = UIColor.darkGray.cgColor
        yesterdayLabel.layer.borderWidth = 1.0
    }
    
    // MARK: - Helper Methods
    
    private func checkStandToday() {
        // Safely unwrap the user ID from UserDefaults
        guard let userId = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.userId) else {
            return
        }
        
        // Update the current user's UID
        currentUser.uid = userId
        
        // Prepare query parameters
        let queryParams = ["user_id": userId]
        
        // Make the network request
        NetworkService.shared.request(endpoint: .stand, method: HTTPVerbs.get.rawValue, queryParams: queryParams) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let json):

                // Directly access the value in `json`
                if let hasTakenAction = json["has_taken_action"] as? Int {
                    let hasTakenActionBool = hasTakenAction == 1
                    
                    if hasTakenActionBool {
                        // Get the current date formatted as a string
                        let dateString = Time.getPacificDateFormatted()
                        
                        // Save the action status to UserDefaults
                        UserDefaults.standard.set(true, forKey: dateString)
                        UserDefaults.standard.synchronize()
                        
                        // Update the app badge count
                        self.appDelegate.appStateViewModel.setAppBadgeCount(to: 1)
                        
                        // Update the UI on the main thread
                        DispatchQueue.main.async {
                            self.updateForStandStats()
                        }
                    } else {
                        // Update the UI to show the push stand button on the main thread
                        DispatchQueue.main.async {
                            self.updateUIForPushStandButton()
                        }
                    }
                } else {
                    _ = ""
                }
                
            case .failure(let error):
                _ = "Network error: \(error.localizedDescription)"
                // Handle the error appropriately, e.g., show an alert to the user
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
        //accountButton.isHidden = true
        tabBarController?.tabBar.alpha = 0
    }
    
    private func updateForStandStats() {
        landingViewWithButton.isHidden = true
        pushStandTitle.isHidden = true
        standingTodayView.isHidden = false
        landingViewWithPicture.isHidden = true
        //dailyGoalLoading.isHidden = false
        //globalStandingTodayLoading.isHidden = false
        //accountButton.isHidden = false
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
        //accountButton.isHidden = true
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
            selectedStreakValue: SessionViewModel.shared.standModel.myStandStreak % Constants.standStreakMax
        )
    }
    
    @objc private func questionStreakTapped() {
        updateStreakUI(
            selectedIcon: questionStreakIcon,
            selectedIconImage: Constants.blueStarImg,
            selectedTitle: questionStreakTitle,
            selectedColor: .systemBlue,
            selectedStreakValue: SessionViewModel.shared.standModel.myAnswerStreak % Constants.questionStreakMax
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
        segmentedStreakBar.value = Constants.streakBarMin
    }
    
    @IBAction private func pushStand(_ sender: UILongPressGestureRecognizer?) {
        let dateString = Time.getPacificDateFormatted() // Because a Push Stand date crosses midnight for timezones east of Pacific
        tabBarController?.tabBar.isHidden = false
        Haptic.heavyTap()
        
        current += 1
        SessionViewModel.shared.standModel.myStandStreak += 1
        SessionViewModel.shared.standModel.americansStandingToday += 1
        SessionViewModel.shared.standModel.myTotalStands += 1
        SessionViewModel.shared.standModel.usaTotalStands += 1
        let pushStandQueryParams = ["UserId": UserDefaults.standard.string(forKey: "userId")!, "Date": dateString]
        let unixTimestamp = Date().timeIntervalSince1970
        let pointsAwarded = (SessionViewModel.shared.standModel.myStandStreak % 10 == 0) ? Constants.standStreakHitPoints : Constants.standPoints
        let postPointQueryParams = ["UserId": UserDefaults.standard.string(forKey: "userId")!, "Timestamp": String(unixTimestamp), "Points": pointsAwarded]
        
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
    
    private func checkDailyStand(completion: @escaping (Bool?) -> Void) {
        NetworkService.shared.request(endpoint: .dailyGoalsCheck, method: HTTPVerbs.get.rawValue, data: [:]) { result in
            switch result {
            case .success(let json):
                if let statusCode = json["statusCode"] as? Int,
                   let bodyString = json["body"] as? String {
                    // Process the bodyString, which is a JSON string
                    if let bodyData = bodyString.data(using: .utf8) {
                        do {
                            if let bodyJson = try JSONSerialization.jsonObject(with: bodyData, options: []) as? [String: Any] {
                                // Access fields in bodyJson
                                if let date = bodyJson["Date"] as? String,
                                   let currentString = bodyJson["Current"] as? String,
                                   let goalString = bodyJson["Goal"] as? String,
                                   let metGoal = bodyJson["MetGoal"] as? Bool,
                                   let current = Int(currentString),
                                   let goal = Int(goalString) {

                                    // Return the 'metGoal' value via the completion handler
                                    completion(metGoal)

                                } else {
                                    completion(nil)
                                }
                            } else {
                                completion(nil)
                            }
                        } catch {
                            completion(nil)
                        }
                    } else {
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            case .failure(let error):
                completion(nil)
            }
        }
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
            if SessionViewModel.shared.standModel.myStandStreak > 0 && SessionViewModel.shared.standModel.myStandStreak % Constants.standStreakMax == Constants.streakBarMin {
                // Dispatching to the main thread for UI updates
                DispatchQueue.main.async {
                    self.standStreakLabel.text = Constants.fivePoints
                    self.showStandBonusView()
                }
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
            
            //self.updateStandCounts()
            self.updateUIForNewStand()
        }
        
    }
    
    private func updateUIForNewStand() {
        
        if SessionViewModel.shared.standModel.myTotalStands == 1 {
            self.showBuildUpPointsView()
        }
        
        if SessionViewModel.shared.standModel.myStandStreak > Constants.standStreakMin && SessionViewModel.shared.standModel.myStandStreak % Constants.standStreakMax == Constants.streakBarMin {
            segmentedStreakBar.value = Constants.standStreakMax
            SessionViewModel.shared.standModel.myPoints += 10
        } else {
            segmentedStreakBar.value = SessionViewModel.shared.standModel.myStandStreak % Constants.standStreakMax
            SessionViewModel.shared.standModel.myPoints += 1
        }
        
    }
    
    @objc private func sendMessage() {
        if MFMessageComposeViewController.canSendText() {
            let messageVC = MFMessageComposeViewController()
            messageVC.body = "Join me on the app that is uniting Americans one STAND at a time! \n\n Follow us! \n Insta: pushstand_now \n X: @pushstand_now \n\n https://apps.apple.com/app/6469620853"
            messageVC.recipients = []
            messageVC.messageComposeDelegate = self
            present(messageVC, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func onShareNow() {
        if MFMessageComposeViewController.canSendText() {
            let messageVC = MFMessageComposeViewController()
            messageVC.body = "Join the \(Int(SessionViewModel.shared.standModel.yesterdaysStanding)) Americans that stood yesterday! \n\n Follow us! \n Insta: pushstand_now \n X: @pushstand_now \n\n https://apps.apple.com/app/6469620853"
            messageVC.messageComposeDelegate = self
            present(messageVC, animated: true, completion: nil)
        } else {
            // Handle the case where SMS is not available
            let alert = UIAlertController(title: "Cannot Send Message", message: "Your device is not configured to send SMS.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    func loadViewIntoContainer<T: DismissableView>(_ viewType: T.Type, xibName: String) {
        // Load the XIB
        let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! T
        
        // Define the closure for the dismiss action
        view.onDismiss = {
            self.removeViewFromContainer(view)
        }
        
        // Assign the onShareNow closure if the view has it
        if var shareableView = view as? ShareableView {
            shareableView.onShareNow = onShareNow
        }
        
        // Add the view to the popUpContainer
        popUpContainer.addSubview(view)
        
        // Disable autoresizing mask translation so we can use Auto Layout
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up Auto Layout constraints to center the view in the container
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: popUpContainer.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: popUpContainer.centerYAnchor),
            
            // Width and height proportional to the parent container
            view.widthAnchor.constraint(equalTo: popUpContainer.widthAnchor, multiplier: 0.925),
            view.heightAnchor.constraint(equalTo: popUpContainer.heightAnchor, multiplier: 1.0)
        ])
        
        popUpContainer.isUserInteractionEnabled = true
        
    }
    
    func removeViewFromContainer(_ view: UIView) {
        // Remove the XIB view from the parent container
        view.removeFromSuperview()
        
        popUpContainer.isUserInteractionEnabled = false
    }
    
    func showStandBonusView() {
        loadViewIntoContainer(StandBonusView.self, xibName: "StandBonusView")
    }
    
    func showDailyGoalAchievedView() {
        loadViewIntoContainer(DailyGoalAchievedView.self, xibName: "DailyGoalAchievedView")
    }
    
    func showBuildUpPointsView() {
        loadViewIntoContainer(BuildUpPointsView.self, xibName: "BuildUpPointsView")
    }
    
    func showAnswerBonusView() {
        loadViewIntoContainer(AnswerBonusView.self, xibName: "AnswerBonusView")
    }
    
    // MARK: - Data Fetching and UI Update
    
    private func fetchHomeStats() {
        let queryParams = [
            "userId": UserDefaults.standard.string(forKey: "userId")!,
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
            _ = "Error: \(error.localizedDescription)"
            // Handle the error appropriately
        }
    }
    
    // MARK: - Specific Response Handlers
    
    private func handleDailyGoals(_ goals: [String: Any]) {
        
        if let goalValue = goals["Goal"] as? String, let goalInt = Int(goalValue) {
            self.dailyGoalLoading.isHidden = true
            let formattedGoal = Formatter.formatLargeNumber(goalInt)
            let attributedString = NSMutableAttributedString(string: "\(goalInt)")
            dailyGoalCount.attributedText = attributedString
        } else {
            self.dailyGoalLoading.isHidden = true
            dailyGoalCount.text = Defaults.zeroString
        }
        if let currentValue = goals["Current"] as? String {
            self.globalStandingTodayLoading.isHidden = true
            globalStandCount.text = "\(currentValue)"
            SessionViewModel.shared.standModel.americansStandingToday = Int(currentValue)!
        } else {
            self.globalStandingTodayLoading.isHidden = true
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
        if !UserDefaults.standard.bool(forKey: Time.getPacificDateFormatted()) {
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
        SessionViewModel.shared.standModel.myStandStreak = streak
    }
    
    private func handleAnswerStreak(_ streak: Int) {
        SessionViewModel.shared.standModel.myAnswerStreak = streak
    }
    
    private func handleUserPoints(_ points: Int) {
        myPointsLabel.isHidden = false
        SessionViewModel.shared.standModel.myPoints = points
    }
    
    
}
