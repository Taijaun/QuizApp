//
//  ViewController.swift
//  QuizApp
//
//  Created by Taijaun Pitt on 05/03/2023.
//

import UIKit

class ViewController: UIViewController, QuizProtocol, UITableViewDelegate, UITableViewDataSource, ResultViewControllerProtocol {
    

    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var stackViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var stackViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var rootStackView: UIStackView!
    
    
    var model = QuizModel()
    var questions = [Question]()
    var currentQuestionIndex = 0
    var numCorrect = 0
    
    var resultDialog: ResultViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialise the result dialog
        resultDialog = storyboard?.instantiateViewController(withIdentifier: "ResultVC") as? ResultViewController
        resultDialog?.modalPresentationStyle = .overCurrentContext
        resultDialog?.delegate = self
        
        // set self as the delegate and datasource for the table view
        tableView.delegate = self
        tableView.dataSource = self
        
        // Dynamic row heights
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        
        // set up the model
        model.delegate = self
        model.getQuestions()
    }
    
    func slideInQuestion() {
        
        // Set the initial s tate
        
        // Animate it to the end state
    }
    
    func slideOutQuestion() {
        
        // Set the initial s tate
        stackViewTrailingConstraint.constant = 0
        stackViewLeadingConstraint.constant = 0
        // tells the layout system to update based on the new constraints
        view.layoutIfNeeded()
        
        // Animate it to the end state
        UIView.animate(withDuration: 0.4, delay: 0,options: .curveEaseOut) {
            
            self.stackViewLeadingConstraint.constant = -1000
            self.stackViewTrailingConstraint.constant = 1000
            self.view.layoutIfNeeded()
            
        }

    
    }
    
    func displayQuestion() {
        // Check if there are questions and check that the currentQuestionIndex is not out of bounds
        guard questions.count > 0 && currentQuestionIndex < questions.count else {
            return
        }
        
        // Display the question text
        questionLabel.text = questions[currentQuestionIndex].question
        
        // Reload the answers table
        tableView.reloadData()
        
        // Slide in the next question animation
        slideInQuestion()
        
    }
    
    // MARK: - QuizProtocol Methods
    
    func questionsRetrieved(_ questions: [Question]) {
        // Get a reference to the questions
        self.questions = questions
        
        // Check if we should restore the state, before showing question #1
        let savedIndex = StateManager.retrieveValue(key: StateManager.questionIndexKey) as? Int
        
        if savedIndex != nil && savedIndex! < self.questions.count {
            
            // Set the curren question to the saved index
            currentQuestionIndex = savedIndex!
            
            // Retrieve the number correct from storage
            let savedNumCorrect = StateManager.retrieveValue(key: StateManager.numCorrectKey) as? Int
            
            if savedNumCorrect != nil {
                numCorrect = savedNumCorrect!
            }
            
        }
        
        // Display the first question
        displayQuestion()

    }
    
    
    
    // MARK: - UITableView Delegate Methods
    
    // How many rows will be displayed
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Make sure that the questions array actually contains a question
        guard questions.count > 0 else {
            return 0
        }
        
        // Return the number of answers for this question
        let currentQuestion = questions[currentQuestionIndex]
        
        if currentQuestion.answers != nil {
            return currentQuestion.answers!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell", for: indexPath)
        
        // Customise it
        let label = cell.viewWithTag(1) as? UILabel
        
        if label != nil {
            
            let question = questions[currentQuestionIndex]
            
            if question.answers != nil && indexPath.row < question.answers!.count {
                // set the text for the label
                label!.text = question.answers![indexPath.row]
            }
            
        }
        
        // Return the cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var titleText = ""
        
        // User has tapped on a row, check if it is the right answer
        let question = questions[currentQuestionIndex]
        
        if question.correctAnswerIndex! == indexPath.row {
            
            //User got it right
            print("User got it right")
            titleText = "Correct!"
            numCorrect += 1
            
        } else {
            
            // User got it wrong
            print("user got it wrong")
            titleText = "Wrong"
        }
        
        // Slide out the question
        DispatchQueue.main.async {
            self.slideOutQuestion()
        }
        
        // Show the popup
        if resultDialog != nil {
            
            // Customise the dialog text
            resultDialog!.titleText = titleText
            resultDialog!.feedbackText = question.feedback!
            resultDialog?.buttonText = "Next"
            
            // Present it in the main thread
            DispatchQueue.main.async {
                self.present(self.resultDialog!, animated: true)
            }
            
        }
    }
    
    // MARK: - ResultViewControllerProtocol Methods
    
    func dialogDismissed() {
        
        
        // Increment the currentQuestionIndex
        currentQuestionIndex += 1
        
        if currentQuestionIndex == questions.count {
            
            // The user has just asnwered the last question
            // Show a summary dialog
            if resultDialog != nil {
                
                // Customise the dialog text
                resultDialog!.titleText = "Summary"
                resultDialog!.feedbackText = "You got \(numCorrect) correct out of \(questions.count) questions"
                resultDialog?.buttonText = "Restart"
                
                present(resultDialog!, animated: true)
                // Clear state
                StateManager.clearState()
                
            }
            
        } else if currentQuestionIndex > questions.count {
            // Restart
            numCorrect = 0
            currentQuestionIndex = 0
            
            // Display and animate the question
            displayQuestion()
            
        } else if currentQuestionIndex < questions.count {
            // There are still more questions to show
            
            // Display the next question
            displayQuestion()
            
            
            // Save state
            StateManager.saveState(numCorrect: numCorrect, questionIndex: currentQuestionIndex)
            
        }
        
        
        
    }
    


}

