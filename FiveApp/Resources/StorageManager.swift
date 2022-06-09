//
//  StorageManager.swift
//  FiveApp
//
//  Created by Barbara Kos on 02.06.2022..
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public func uploadProfilePic(with data: Data, fileName: String, completionHandler: @escaping (Result<String, Error>) -> Void) {
        storage.child("images/\(fileName)").putData(data, completion: { [weak self] metadata, error in
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                completionHandler(.failure(StorageErrors.failedToUpload))
                return
            }
            
            strongSelf.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    completionHandler(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                completionHandler(.success(urlString))
            })
        })
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadURL))
                return
            }
            completion(.success(url))
        })
    }
    
    public func uploadDocument(with data: Data, fileName: String, completionHandler: @escaping (Result<String, Error>) -> Void) {
        storage.child("\(fileName)").putData(data, completion: { [weak self] metadata, error in
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                completionHandler(.failure(StorageErrors.failedToUpload))
                return
            }
            
            strongSelf.storage.child("\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    completionHandler(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                completionHandler(.success(urlString))
            })
        })
    }
    
    public func downloadURLS(for path: String, completion: @escaping (Result<[URL], Error>) -> Void) {
        let reference = storage.child(path)
        var urls = [URL]()
        reference.listAll(completion: { result, error in
            guard let paths = result?.items, error == nil else {
                print("No Results found")
                return
            }
            var count = 0
            for path in paths {
                path.downloadURL(completion: { url, error in
                    guard let url = url, error == nil else {
                        completion(.failure(StorageErrors.failedToGetDownloadURL))
                        return
                    }
                    urls.append(url)
                    print("Appendam URL: \(urls) \(count)")
                    count += 1
                    if (count == paths.count) {
                        completion(.success(urls))
                    }
                })
                
            }
        })
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadURL
    }
}


