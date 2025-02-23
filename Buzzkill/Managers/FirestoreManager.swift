import FirebaseFirestore

class FirestoreManager {
    static let shared = FirestoreManager()
    
    let db: Firestore
    
    private init() {
        db = Firestore.firestore()
    }

    // Create or Update (Upsert)
    func saveDocument(collection: String, documentId: String, data: [String: Any], completion: @escaping (Error?) -> Void) {
        db.collection(collection).document(documentId).setData(data) { error in
            completion(error)
        }
    }

    // Read a single document
    func fetchDocument(collection: String, documentId: String) async throws -> [String: Any] {
        return try await withCheckedThrowingContinuation { continuation in
            db.collection(collection).document(documentId).getDocument { document, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let document = document, document.exists, let data = document.data() {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document not found"]))
                }
            }
        }
    }

    // Read multiple documents with filters
    func fetchDocuments(collection: String, filters: [(String, Any)], completion: @escaping (QuerySnapshot?, Error?) -> Void) {
        var query: Query = db.collection(collection)
        for (field, value) in filters {
            query = query.whereField(field, isEqualTo: value)
        }
        query.getDocuments { querySnapshot, error in
            completion(querySnapshot, error)
        }
    }

    // Update a document
    func updateDocument(collection: String, documentId: String, data: [String: Any], completion: @escaping (Error?) -> Void) {
        db.collection(collection).document(documentId).updateData(data) { error in
            completion(error)
        }
    }

    // Delete a document
    func deleteDocument(collection: String, documentId: String, completion: @escaping (Error?) -> Void) {
        db.collection(collection).document(documentId).delete { error in
            completion(error)
        }
    }

    // Add this method to FirestoreManager
    func logCurrentBudget(forUserId userId: String, completion: @escaping (Double?, Error?) -> Void) {
        let userRef = db.collection("users").document(userId)
        
        userRef.getDocument { document, error in
            if let error = error {
                print("Error fetching current budget: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            if let document = document, document.exists {
                if let currentBudget = document.data()?["currentBudget"] as? Double {
                    print("Current Budget for user \(userId): \(currentBudget)")
                    completion(currentBudget, nil)
                } else {
                    print("Current budget not found in document for user \(userId)")
                    completion(nil, nil)
                }
            } else {
                print("Document does not exist for user \(userId)")
                completion(nil, nil)
            }
        }
    }

    // Add other methods like updateDocument, etc.
} 