//
//  DownloadImageAsync.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Negin Zahedi on 2023-11-13.
//

import SwiftUI
import Combine

class DownloadImageAsyncManager {
    
    let url = URL(string: "https://picsum.photos/200")!
    
    func downloadWithEscaping(completionHandler: @escaping (_ image: UIImage?, _ error: Error?)-> Void){
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let image = UIImage(data: data),
                  let response = response as? HTTPURLResponse,
                  response.statusCode >= 200 && response.statusCode < 300 else {
                completionHandler(nil, error)
                return
            }
            completionHandler(image, nil)
        }
        .resume()
    }
    
    func downloadWithCombine()-> AnyPublisher<UIImage?, Error>{
        URLSession.shared.dataTaskPublisher(for: url)
            .map({ (data: Data?, response: URLResponse?) in
                guard
                    let data = data,
                    let image = UIImage(data: data),
                    let response = response as? HTTPURLResponse,
                    response.statusCode >= 200 && response.statusCode < 300 else {
                    return nil
                }
                return image
            })
            .mapError({$0})
            .eraseToAnyPublisher()
    }
    
    func downloadWithAsyncAwait() async throws -> UIImage?{
        do{
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            let image = UIImage(data: data)
            return image
        } catch{
            throw error
        }
    }
}

class DownloadImageAsyncViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    let imageManager = DownloadImageAsyncManager()
    var cancellables = Set<AnyCancellable>()
    func fetchImage() async{
        
        // escaping
        /*
         imageManager.downloadWithEscaping {[weak self] image, error in
         DispatchQueue.main.async {
         self?.image = image
         }
         */
        
        // Combine
        /*
         imageManager.downloadWithCombine()
         .receive(on: DispatchQueue.main)
         .sink { _ in
         
         } receiveValue: {[weak self] image in
         self?.image = image
         }
         .store(in: &cancellables)
         */
        
        // async-await
        let image = try? await imageManager.downloadWithAsyncAwait()
        await MainActor.run {
            self.image = image
            
        }
    }
}

struct DownloadImageAsync: View {
    @StateObject private var viewModel = DownloadImageAsyncViewModel()
    
    var body: some View {
        ZStack{
            if let image = viewModel.image{
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }
        .onAppear {
            Task{
                await viewModel.fetchImage()
            }
        }
    }
}

#Preview {
    DownloadImageAsync()
}
