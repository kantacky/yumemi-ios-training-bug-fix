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

    var weatherViewController: WeatherViewController!
    var weatherModel: WeatherModelMock!
    var disasterModel: DisasterModelMock!

    override func setUpWithError() throws {
        weatherModel = WeatherModelMock()
        disasterModel = DisasterModelMock()
        disasterModel.fetchDisasterImpl = {
            "只今、災害情報はありません。"
        }
        weatherViewController = R.storyboard.weather.instantiateInitialViewController()!
        weatherViewController.weatherModel = weatherModel
        weatherViewController.disasterModel = disasterModel
        _ = weatherViewController.view
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_天気予報がsunnyだったらImageViewのImageにsunnyが設定されること_TintColorがredに設定されること() async throws {
        weatherModel.fetchWeatherImpl = { _ in
            Response(weather: .sunny, maxTemp: 0, minTemp: 0, date: Date())
        }

        await weatherViewController.loadWeather(nil)
        await MainActor.run {
            XCTAssertEqual(self.weatherViewController.weatherImageView.tintColor, R.color.red())
            XCTAssertEqual(self.weatherViewController.weatherImageView.image, R.image.sunny())
        }
    }
    
    func test_天気予報がcloudyだったらImageViewのImageにcloudyが設定されること_TintColorがgrayに設定されること() async throws {
        weatherModel.fetchWeatherImpl = { _ in
            Response(weather: .cloudy, maxTemp: 0, minTemp: 0, date: Date())
        }
        
        await weatherViewController.loadWeather(nil)
        await MainActor.run {
            XCTAssertEqual(self.weatherViewController.weatherImageView.tintColor, R.color.gray())
            XCTAssertEqual(self.weatherViewController.weatherImageView.image, R.image.cloudy())
        }
    }
    
    func test_天気予報がrainyだったらImageViewのImageにrainyが設定されること_TintColorがblueに設定されること() async throws {
        weatherModel.fetchWeatherImpl = { _ in
            Response(weather: .rainy, maxTemp: 0, minTemp: 0, date: Date())
        }
        
        await weatherViewController.loadWeather(nil)
        await MainActor.run {
            XCTAssertEqual(self.weatherViewController.weatherImageView.tintColor, R.color.blue())
            XCTAssertEqual(self.weatherViewController.weatherImageView.image, R.image.rainy())
        }
    }
    
    func test_最高気温_最低気温がUILabelに設定されること() async throws {
        weatherModel.fetchWeatherImpl = { _ in
            Response(weather: .rainy, maxTemp: 100, minTemp: -100, date: Date())
        }
        
        await weatherViewController.loadWeather(nil)
        await MainActor.run {
            XCTAssertEqual(self.weatherViewController.minTempLabel.text, "-100")
            XCTAssertEqual(self.weatherViewController.maxTempLabel.text, "100")
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
