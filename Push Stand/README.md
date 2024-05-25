#  README

- Main Screen [X]
    - Join Now [X]
        - Background during process [X]
        - Design Decision to start over with 
        - Step 1 Phone
            - Back [X]
            - Terms of Service [X]
            - Privacy Policy [X]
            - Sign-In with Phone
                - OnboardingData Object
                - Back
                - Enter Phone Number
                    - Next Button State
                        - Textfield Validation [X]
                            - Will not work without valid phone number [X]
                    - Step 2 Email/Password 
                        - OnboardingData Object
                            - Phone Number
                        - Back
                            - Keeps phone number [X]
                        - Email
                            - Textfield Validation [X]
                                - Email Validation [X]
                        - Password
                            - Textfield Validation [X]
                                - Password Validation [X]
                        - Combination
                            - Email + Password Validation [X]
                        - Next Button State
                        - Step 3 Birthday [X]
                            - OnboardingData Object
                                - Phone
                                - Email
                                - Password 
                                    - Ensure salted/kept secure
                            - Date Selection
                                - Validation
                                    - Date Check (18 years old)
                                    - Alert
                            - Check Swipe
                            - Next Button
                            - Step 4 Reminder Time
                                - OnboardingData Object
                                    - Phone
                                    - Email
                                    - Password 
                                    - Birthdate
                                - Time Selection
                                    - UTC
                                    - Check Local Timezone
                                - Next
                                    - Firebase Persist
                                        - OnboardingData Object
                                            - Phone
                                            - Email
                                            - Password 
                                            - Birthdate
                                            - Reminder Time
                                            - UUID
                                        - Alert if Firebase error
                                            - Retry
                                        - AWS Persist (After Firebase Confirmation)
                                            - OnboardingData Object
                                            - Phone
                                            - Email
                                            - Password 
                                            - Birthdate
                                            - Reminder Time
                                            - UUID
                                            - Alert if AWS error
                                                - Retry
                                    - Presented with Push Stand
                                        - Home View Controller
    - Login
        - Email
        - Password
        - Retry Limit Error Catch
            - Graceful Alert
        - Forgot Password
        - Incorrect Login
        - Successful Login
            - In-Memory User Object
                - Phone
                - Email
                - Password 
                - Birthdate
                - Reminder Time
                - UUID
            - Check if they have stood day
                - Present Push Stand Button, if no
                - Present Home Screen, if yes
                    - Stats Load
                        - Consolidate
                        - My Points
                    - Streak Loads
                    - Streak transitions
                    - Circular Bar Load
            - Share Button
                - Cancel
                - Send State
                    - Auto Closes
            - Settings
                - Load
                    - Birthdate
                        - Need to add age validation
                        - Allow Change
                            - Present Update
                                - Disappear Update
                    - Reminder Time
                        - Allow Change
                            - Normalize to UTC Local
                            - Present Update
                                - Disappear Update
                - Email
                    - New Email
                    - Current Password (Needs constraints)
                    - Has to Validate
                    - Alert For
                        - Password Validation
                        - Email Validation
                    - Change Email
                        - Firebase
                            - AWS
                - Password
                    - Enter Current
                    - Forgot Password
                    - Enter New
                    - Confirm New
                    - Change Password
                        - Firebase
                    - Alerts
                - Phone
                    - New Phone
                        - Validation
                    - Submit
                        - AWS
                - Logout
                    - Flush In-Memory Data
                    - Present Main Screen
            - Tab Bar
                - Sweepstakes
                - Daily Question Toast
                    - Shows
                    - Disappear
            - Terms of Service
            - Privacy Policy
            - Help Center
                - Delete Account
                    - Firebase
                        - AWS
            - Daily Question
                - Present
                    - Load Question
                        - Answer
                        - Submit button loads after tap
                            - Switch between answers
                                - Hit Submit
                    - No Question
                    - Yesterday's Result's
                        - Percentages
                    - Suggest Question
                    - Streak Bar
                        - Add
                    - Display Points
                    - Display Bonus
                - Pre-load Results
                - Persist, if already answered for quickload
    - Learn More [X]
        - Modal [X]
        
        
- Need to add delete account
- Daily Question
    - Move the Daily Question answer check earlier
- Check if we can keep the notification on the screen until addressed

### View Controller Structure

1. **Properties Section:** 
   - All properties, including outlets and other variables, are declared at the top.

2. **Lifecycle Methods:**
   - `viewDidLoad`, `viewWillAppear`, etc., are implemented next. These methods set up initial configurations and view states.

3. **Setup Methods:**
   - `setupView` and `setupBindings` handle the initial setup for views and bindings. These methods are called within the lifecycle methods to keep them clean and focused.

4. **Action Methods:**
   - Any user interaction methods like button taps or gesture recognizers are defined here.

5. **Helper Methods:**
   - Additional methods that support the functionality of the view controller are included in this section.

6. **Extensions:**
   - Extensions are used to separate the implementation of protocols, which improves readability and organization.

By following this structure, you ensure that your `UIViewController` files are well-organized, making them easier to read, understand, and maintain.
