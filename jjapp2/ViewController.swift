//
//  ViewController.swift
//  jjapp2
//
//  Created by Forest Lim on 7/30/24.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    var mapView: MKMapView!
    var timer: Timer!
    var latitude: Double = 0
    var longitude: Double = 0
    var notiButton: UIButton!
    var moveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notiButton = UIButton(frame: CGRect(x: 100, y: 100, width: 50, height: 50))
        notiButton.backgroundColor = .black
        notiButton.addTarget(self, action: #selector(sendNoti), for: .touchUpInside)
        
        moveButton = UIButton(frame: CGRect(x: 160, y: 100, width: 50, height: 50))
        moveButton.backgroundColor = .black
        moveButton.addTarget(self, action: #selector(moveAction), for: .touchUpInside)
        
        mapView = MKMapView(frame: view.bounds)
        view.addSubview(mapView)
        view.addSubview(notiButton)
        view.addSubview(moveButton)
        
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(fetchData), userInfo: nil, repeats: true)
    }
    
    @objc func fetchData() {
        guard let url = URL(string: "http://211.44.188.113:54000/last-entry") else { return }
        
        networkWithGet(url: url, completion: { result in
            switch result {
            case .success(let rowData):
                self.latitude = rowData["latitude"] as! Double
                self.longitude = rowData["longitude"] as! Double
            case .failure(let error):
                print("Error Fetched data: \(error)")
            }
        })
        
        // 지도에 위치 표시
        showLocationOnMap(latitude: latitude, longitude: longitude)
    }
    
    @objc func sendNoti() {
        guard let url = URL(string: "http://211.44.188.113:54000/send-notification") else { return }
        
        networkWithGet(url: url, completion: { result in
            switch result {
            case .success(let rowData):
                print("Success SendNoti")
            case .failure(let error):
                print("Error SendNoti: \(error)")
            }
        })
    }
    
    func networkWithGet(url: URL, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(.success(json))
                } else {
                    completion(.failure(NSError(domain: "Invalid JSON", code: -1, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func showLocationOnMap(latitude: Double, longitude: Double) {
        // 위치 좌표 설정
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // 주석(annotation) 설정
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "AOS"
        
        // 지도에 주석 추가
        mapView.addAnnotation(annotation)
    }
    
    @objc func moveAction() {
        // 지도의 중심을 위치 좌표로 이동
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
}
