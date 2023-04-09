//
//  CoinManager.swift
//  CoinConverter
//
//  Created by Can Kanbur on 9.04.2023.
//

import CoreLocation
import Foundation
import UIKit

protocol CoinManagerDelegate {
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    var delegate: CoinManagerDelegate?
    let currencyArray = ["AUD", "BRL", "CAD", "CNY", "EUR", "GBP", "HKD", "IDR", "ILS", "INR", "JPY", "MXN", "NOK", "NZD", "PLN", "RON", "RUB", "SEK", "SGD", "USD", "ZAR"]
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"

    let apiKey = "985797D9-333A-486D-A6D7-5FA2F6FB8933"

    func getCoin(for currency: String) {
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        print(urlString)

        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, _, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                }

                if let safeData = data {
                    if let bitcoinPrice = self.jsonParse(safeData) {
                        let priceString = String(format: "%.2f", bitcoinPrice)
                        self.delegate?.didUpdatePrice(price: priceString, currency: currency)
                    }
                }
            }
            task.resume()
        }
    }

    func jsonParse(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            return decodedData.rate

        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
