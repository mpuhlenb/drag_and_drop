//
//  PeakRectangleService.swift
//  drag_and_drop
//
//  Created by Morris Uhlenbrauck on 5/15/23.
//

import Foundation
import Combine

struct PeakRectangleService {
    let urlSession: URLSession
    let baseURLString: String
    
    init(urlSession: URLSession = URLSession(configuration: .default), baseURLString: String) {
        self.urlSession = urlSession
        self.baseURLString = baseURLString
    }
    
    func getPublisherForResponse(endpoint: String) -> AnyPublisher<APIRectangles, Never> {
        let urlComponents = NSURLComponents(string: baseURLString + endpoint)
        let emptyResponse = APIRectangles(rectangles: [])
        guard let url = urlComponents?.url else {
            return Just<APIRectangles>(emptyResponse).eraseToAnyPublisher()
        }
        return urlSession.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: APIRectangles.self, decoder: JSONDecoder())
            .replaceError(with: emptyResponse)
            .eraseToAnyPublisher()
    }
}
