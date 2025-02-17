//import Foundation
//
//class PlaidService {
//    private let baseURL = "https://api.plaid.com"
//    private let apiKey = "YOUR_API_KEY" // Consider storing this securely
//
//    // Example method to fetch transactions
//    func fetchTransactions(completion: @escaping (Result<[Transaction], Error>) -> Void) {
//        guard let url = URL(string: "\(baseURL)/transactions/get") else {
//            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
//
//        // Add any necessary request body or parameters here
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//
//            guard let data = data else {
//                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
//                return
//            }
//
//            do {
//                let transactions = try JSONDecoder().decode([Transaction].self, from: data)
//                completion(.success(transactions))
//            } catch {
//                completion(.failure(error))
//            }
//        }
//
//        task.resume()
//    }
//} 
