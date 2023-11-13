//
//  DoCatchTryThrowsBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Negin Zahedi on 2023-11-13.
//

// do-catch
// try
// throws

import SwiftUI

class DoCatchTryThrowsBootcampDataManager{
    
    let isActive: Bool = true
    
    func getTitle() -> (title: String?, error: Error?) {
        if isActive{
            return ("New text!", nil)
        } else{
            return (nil,URLError(.badURL))
        }
    }
    
    func getTitleWithResult() -> Result<String, Error> {
        if isActive{
            return .success("New text!")
        } else{
            return .failure(URLError(.unknown))
        }
    }
    
    func getTitleWithThrows() throws -> String {
        if isActive{
            return "New text!"
        } else{
            throw URLError(.badServerResponse)
        }
    }
    
    func getFinalTitleWithThrows() throws -> String{
        if !isActive{
            return "Final text!"
        } else{
            throw URLError(.badServerResponse)
        }
    }
}

class DoCatchTryThrowsBootcampViewModel: ObservableObject{
    
    @Published var text : String = "Starting text..."
    let manager = DoCatchTryThrowsBootcampDataManager()
    
    func fetchTitle(){
        /*
         let returnedValue = manager.getTitle()
         if let newTitle = returnedValue.title{
         self.text = newTitle
         } else if let error = returnedValue.error{
         self.text = error.localizedDescription
         }
         */
        
        /*
         let result = manager.getTitleWithResult()
         switch result {
         case .success(let newTitle):
         self.text = newTitle
         case .failure(let error):
         self.text = error.localizedDescription
         }
         */
        
        do {
            let newTitle = try manager.getTitleWithThrows()
            self.text = newTitle
            
            let finalTitle = try? manager.getFinalTitleWithThrows()
            if let finalTitle = finalTitle{
                self.text = finalTitle
            }
        } catch let error{
            self.text = error.localizedDescription
        }
        
    }
}

struct DoCatchTryThrowsBootcamp: View {
    
    @StateObject private var viewModel = DoCatchTryThrowsBootcampViewModel()
    
    var body: some View {
        Text(viewModel.text)
            .frame(width: 300, height: 300)
            .background(.blue)
            .onTapGesture {
                viewModel.fetchTitle()
            }
    }
}

#Preview {
    DoCatchTryThrowsBootcamp()
}
