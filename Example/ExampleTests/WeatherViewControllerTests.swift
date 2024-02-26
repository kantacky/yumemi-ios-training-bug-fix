//
//  WeatherViewControllerTests.swift
//  ExampleTests
//
//  Created by 渡部 陽太 on 2020/04/01.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import XCTest
import YumemiWeather
@testable import Example

class WeatherViewControllerTests: XCTestCase {

    var weahterViewController: WeatherViewController!
    var weahterModel: WeatherModelMock!
    var disasterModel: DisasterModelMock!

    override func setUpWithError() throws {
        weahterModel = WeatherModelMock()
        disasterModel = DisasterModelMock()
        disasterModel.fetchDisasterImpl = {
            "只今、災害情報はありません。"
        }
        weahterViewController = R.storyboard.weather.instantiateInitialViewController()!
        weahterViewController.weatherModel = weahterModel
        weahterViewController.disasterModel = disasterModel
        _ = weahterViewController.view
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_天気予報がsunnyだったらImageViewのImageにsunnyが設定されること_TintColorがredに設定されること() throws {
        weahterModel.fetchWeatherImpl = { _ in
            Response(weather: .sunny, maxTemp: 0, minTemp: 0, date: Date())
        }

        weahterViewController.loadWeather(nil)
        DispatchQueue.main.async {
            XCTAssertEqual(self.weahterViewController.weatherImageView.tintColor, R.color.red())
            XCTAssertEqual(self.weahterViewController.weatherImageView.image, R.image.sunny())
        }
    }
    
    func test_天気予報がcloudyだったらImageViewのImageにcloudyが設定されること_TintColorがgrayに設定されること() throws {
        weahterModel.fetchWeatherImpl = { _ in
            Response(weather: .cloudy, maxTemp: 0, minTemp: 0, date: Date())
        }
        
        weahterViewController.loadWeather(nil)
        DispatchQueue.main.async {
            XCTAssertEqual(self.weahterViewController.weatherImageView.tintColor, R.color.gray())
            XCTAssertEqual(self.weahterViewController.weatherImageView.image, R.image.cloudy())
        }
    }
    
    func test_天気予報がrainyだったらImageViewのImageにrainyが設定されること_TintColorがblueに設定されること() throws {
        weahterModel.fetchWeatherImpl = { _ in
            Response(weather: .rainy, maxTemp: 0, minTemp: 0, date: Date())
        }
        
        weahterViewController.loadWeather(nil)
        DispatchQueue.main.async {
            XCTAssertEqual(self.weahterViewController.weatherImageView.tintColor, R.color.blue())
            XCTAssertEqual(self.weahterViewController.weatherImageView.image, R.image.rainy())
        }
    }
    
    func test_最高気温_最低気温がUILabelに設定されること() throws {
        weahterModel.fetchWeatherImpl = { _ in
            Response(weather: .rainy, maxTemp: 100, minTemp: -100, date: Date())
        }
        
        weahterViewController.loadWeather(nil)
        DispatchQueue.main.async {
            XCTAssertEqual(self.weahterViewController.minTempLabel.text, "-100")
            XCTAssertEqual(self.weahterViewController.maxTempLabel.text, "100")
        }
    }
}

class WeatherModelMock: WeatherModel {
    
    var fetchWeatherImpl: ((Request) throws -> Response)!
    
    func fetchWeather(_ request: Request) throws -> Response {
        return try fetchWeatherImpl(request)
    }

    func fetchWeather(at area: String, date: Date, completion: @escaping (Result<Example.Response, Example.WeatherError>) -> Void) {
        let request = Request(area: area, date: date)
        if let response = try? fetchWeather(request) {
            completion(.success(response))
        } else {
            completion(.failure(WeatherError.unknownError))
        }
    }
}

class DisasterModelMock: DisasterModel {

    var fetchDisasterImpl: (() -> String)!

    func fetchDisaster(completion: ((String) -> Void)?) {
        completion?(fetchDisasterImpl())
    }
}
