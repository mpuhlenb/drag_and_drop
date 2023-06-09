//
//  BlocksViewModel.swift
//  drag_and_drop
//
//  Created by Morris Uhlenbrauck on 5/15/23.
//

import Foundation
import Combine

class BlocksViewModel {
    private let lastUseDateUserDefault = "LastUseDate"
    private let savedBlocksUserDefault = "SavedBlocks"
    
    private let apiRectangleFileName = "api_rectangles"
    
    var viewBounds: CGRect
    
    var cancellables = Set<AnyCancellable>()
    
    private var apiRectangles = CurrentValueSubject<APIRectangles, Never>(APIRectangles(rectangles: []))
    
    var viewBlocks = CurrentValueSubject<[Block], Never>([])
    
    private var isBlockDataStale: Bool {
        let lastUseDate = getLastUseDate()
        let today = Date()
        return !Calendar.current.isDate(lastUseDate, equalTo: today, toGranularity:  .weekOfYear)
    }
    
    init(viewBounds: CGRect) {
        self.viewBounds = viewBounds
    }
    
    /**
     Gets rectangle data from API rectangle service
     */
    private func getAPIRectangles() {
        if let url = Bundle.main.url(forResource: apiRectangleFileName, withExtension: "json") {
            // Setting last use date whenever we get rectangles from the API
            setLastUseDate()
            let rectangleService = PeakRectangleService(baseURLString: url.absoluteString)
            rectangleService.getPublisherForResponse(endpoint: "").sink { completion in
                // Do Nothing
            } receiveValue: { [weak self] apiRectangles in
                self?.apiRectangles.send(apiRectangles)
            }.store(in: &cancellables)
        }
    }
    
    /**
     Creates block data for the view controller to build ui blocks
     */
    func viewLoaded() {
        if let savedBlocks = fetchSavedBlocks(), !savedBlocks.isEmpty, !isBlockDataStale {
            viewBlocks.send(savedBlocks)
        } else {
            // Fetch rectangles from API if we have no saved blocks or the data is stale
            getAPIRectangles()
            apiRectangles.sink { [weak self] rectangles in
                guard let self = self else { return }
                let blocks = rectangles.rectangles.compactMap {
                    let height = self.viewBounds.height * CGFloat($0.size)
                    let width = self.viewBounds.width * CGFloat($0.size)
                    let xCoord = (CGFloat($0.x) * self.viewBounds.width) - width/2
                    let yCoord = (CGFloat($0.y) * self.viewBounds.height) - height/2
                    return Block(xCoordinate: xCoord, yCoordinate: yCoord, height: height, width: width)
                }
                let result: Result<[Block], Never> = .success(blocks)
                switch result {
                case .success(_):
                    self.viewBlocks.send(blocks)
                    self.saveBlocks(blocks)
                }
            }.store(in: &cancellables)
        }
    }
    
    // TODO: Refactor to pass in key for testability
    func saveBlocks(_ blocks: [Block]) {
        let defaults = UserDefaults.standard
        let encoder = JSONEncoder()
        let data = try? encoder.encode(blocks)
        defaults.set(data, forKey: savedBlocksUserDefault)
    }
    
    // TODO: Refactor to pass in key for testability
    func fetchSavedBlocks() -> [Block]? {
        if let data = UserDefaults.standard.data(forKey: savedBlocksUserDefault) {
            do {
                let decoder = JSONDecoder()
                guard let blocks = try? decoder.decode(([Block].self), from: data) else { return nil }
                return blocks
            }
        } else {
            return nil
        }
    }
    
    // TODO: Refactor to pass in key for testability
    private func setLastUseDate() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(Date(), forKey: lastUseDateUserDefault)
    }
    
    // TODO: Refactor to pass in key for testability
    private func getLastUseDate() -> Date {
        let userDefaults = UserDefaults.standard
        guard let lastUseDate = userDefaults.object(forKey: lastUseDateUserDefault) as? Date else { return Date() }
        return lastUseDate
    }
}
