//
//  SearchTrainInteractor.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import Foundation
import XMLParsing
import Alamofire

class SearchTrainInteractor: ServiceManager, PresenterToInteractorProtocol {
    var _sourceStationCode = String()
    var _destinationStationCode = String()
    var presenter: InteractorToPresenterProtocol?

    func fetchallStations() {
        if Reach().isNetworkReachable() == true {
           /* Alamofire.request(GET_ALL_STATION_XML_URL)
                .response { (response) in
                let station = try? XMLDecoder().decode(Stations.self, from: response.data!)
                self.presenter!.stationListFetched(list: station!.stationsList)
            }*/
            
            let urlString = GET_ALL_STATION_XML_URL

            requestServer(strUrl: urlString, params: nil, completionBlock: {response in
                switch response{
                case .success(let data):
                    print(data)
                    let station = try? XMLDecoder().decode(Stations.self, from: data)
                    self.presenter!.stationListFetched(list: station!.stationsList)
                case .failure(let error):
                    print(error as Any)
                    self.presenter!.showNoInterNetAvailabilityMessage()
                }
            })
            
        } else {
            self.presenter!.showNoInterNetAvailabilityMessage()
        }
    }

    func fetchTrainsFromSource(sourceCode: String, destinationCode: String) {
        _sourceStationCode = sourceCode
        _destinationStationCode = destinationCode
        let urlString = "\(GET_STATION_DATA_BY_CODE_XML)\(sourceCode)"
        if Reach().isNetworkReachable() {
            
            /*Alamofire.request(urlString).response { (response) in
                let stationData = try? XMLDecoder().decode(StationData.self, from: response.data!)
                if let _trainsList = stationData?.trainsList {
                    self.proceesTrainListforDestinationCheck(trainsList: _trainsList)
                } else {
                    self.presenter!.showNoTrainAvailbilityFromSource()
                }
            }*/
            

            requestServer(strUrl: urlString, params: nil, completionBlock: {response in
                switch response{
                case .success(let data):
                    print(data)
                    let stationData = try? XMLDecoder().decode(StationData.self, from: data)
                    if let _trainsList = stationData?.trainsList {
                        self.proceesTrainListforDestinationCheck(trainsList: _trainsList)
                    } else {
                        self.presenter!.showNoTrainAvailbilityFromSource()
                    }
                   
                case .failure(let error):
                    print(error as Any)
                    self.presenter!.showNoInterNetAvailabilityMessage()
                }
            })
        } else {
            self.presenter!.showNoInterNetAvailabilityMessage()
        }
    }
    
    private func proceesTrainListforDestinationCheck(trainsList: [StationTrain]) {
        var _trainsList = trainsList
        let today = Date()
        let group = DispatchGroup()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let dateString = formatter.string(from: today)
        
        for index  in 0...trainsList.count-1 {
            group.enter()
            let _urlString = "\(GET_TRAIN_MOVEMENTS_XML)\(trainsList[index].trainCode)&TrainDate=\(dateString)"
            if Reach().isNetworkReachable() {
                /*Alamofire.request(_urlString).response { (movementsData) in
                    let trainMovements = try? XMLDecoder().decode(TrainMovementsData.self, from: movementsData.data!)

                    if let _movements = trainMovements?.trainMovements {
                        let sourceIndex = _movements.firstIndex(where: {$0.locationCode!.caseInsensitiveCompare(self._sourceStationCode) == .orderedSame})
                        let destinationIndex = _movements.firstIndex(where: {$0.locationCode!.caseInsensitiveCompare(self._destinationStationCode) == .orderedSame})
                        let desiredStationMoment = _movements.filter{$0.locationCode!.caseInsensitiveCompare(self._destinationStationCode) == .orderedSame}
                        let isDestinationAvailable = desiredStationMoment.count == 1

                        if isDestinationAvailable  && sourceIndex! < destinationIndex! {
                            _trainsList[index].destinationDetails = desiredStationMoment.first
                        }
                    }
                    group.leave()
                }*/
                requestServer(strUrl: _urlString, params: nil, completionBlock: {response in
                    switch response{
                    case .success(let data):
                        print(data)
                        let trainMovements = try? XMLDecoder().decode(TrainMovementsData.self, from: data)

                        if let _movements = trainMovements?.trainMovements {
                            let sourceIndex = _movements.firstIndex(where: {$0.locationCode!.caseInsensitiveCompare(self._sourceStationCode) == .orderedSame})
                            let destinationIndex = _movements.firstIndex(where: {$0.locationCode!.caseInsensitiveCompare(self._destinationStationCode) == .orderedSame})
                            let desiredStationMoment = _movements.filter{$0.locationCode!.caseInsensitiveCompare(self._destinationStationCode) == .orderedSame}
                            let isDestinationAvailable = desiredStationMoment.count == 1

                            if isDestinationAvailable  && sourceIndex! < destinationIndex! {
                                _trainsList[index].destinationDetails = desiredStationMoment.first
                            }
                        }
                        group.leave()
                       
                    case .failure(let error):
                        print(error as Any)
                        self.presenter!.showNoInterNetAvailabilityMessage()
                    }
                })
            } else {
                self.presenter!.showNoInterNetAvailabilityMessage()
            }
        }

        group.notify(queue: DispatchQueue.main) {
            let sourceToDestinationTrains = _trainsList.filter{$0.destinationDetails != nil}
            self.presenter!.fetchedTrainsList(trainsList: sourceToDestinationTrains)
        }
    }
}
