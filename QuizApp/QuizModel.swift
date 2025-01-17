//
//  QuizModel.swift
//  QuizApp
//
//  Created by Taijaun Pitt on 05/03/2023.
//

import Foundation

protocol QuizProtocol {
    
    func questionsRetrieved(_ question: [Question])
}

class QuizModel {
    
    var delegate: QuizProtocol?
    
    func getQuestions() {
        
        //Fetch the questions
        getRemoteJsonFile()
        
    }
    
    func getLocalJsonFile() {
        
        // Get bundle path to json file
        let path = Bundle.main.path(forResource: "QuestionData", ofType: "json")
        
        // Double check that the path isnt nil
        guard path != nil else {
            print("Couldn't find the json data file")
            return
        }
        
        // Create URL object from the path
        let url = URL(filePath: path!)
        
        do {
            // Get the data from the url
            let data = try Data(contentsOf: url)
            
            // Try to decode the data into objects
            let decoder = JSONDecoder()
            let array = try decoder.decode([Question].self, from: data)
            
            // Notify the delegate of the parsed objects
            delegate?.questionsRetrieved(array)
            
        } catch {
            // Error: Couldn't download/read the data at that url
        }
        
    }
    
    func getRemoteJsonFile() {
        
        // Get a URL Object
        let urlString = "https://codewithchris.com/code/QuestionData.json"
        
        let url = URL(string: urlString)
        
        guard url != nil else {
            print("Couldn't create the URL object")
            return
        }
        
        // Get a URL Session object
        let session = URLSession.shared
        
        // Get a data task object
        let dataTask = session.dataTask(with: url!) { data, response, error in
            
            // Check that there wasn't an error
            if error == nil && data != nil {
                
                do {
                    
                    // Create a JSON Decoder object
                    let decoder = JSONDecoder()
                    
                    // Parse the JSON
                    let array = try decoder.decode([Question].self, from: data!)
                    
                    // Use the main thread to notify the view controller for UI Work
                    DispatchQueue.main.async {
                        
                        // Notify the view delegate
                        self.delegate?.questionsRetrieved(array)
                    }
                    
                    
                    
                } catch {
                    print("Couldn't parse JSON")
                }
                
            }
            
            
            
        }
        
        // Call resume on the data task
        dataTask.resume()
        
    }
    
}
