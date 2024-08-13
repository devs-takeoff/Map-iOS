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
        notiButton.addTarget(self, action: #selector(sendNotification), for: .touchUpInside)
        
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
        fetchLastData { result in
            switch result {
            case .success(let rowData):
                self.latitude = rowData["latitude"] as! Double
                self.longitude = rowData["longitude"] as! Double
            case .failure(let error):
                print("Error Fetched data: \(error)")
            }
        }
        
        // 지도에 위치 표시
        showLocationOnMap(latitude: latitude, longitude: longitude)
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
    
    func fetchLastData(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: "http://211.44.188.113:54000/last-entry") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
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
    
    @objc func sendNotification() {
        let url = URL(string: "http://211.44.188.113:54000/send-notification")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer ya29.a0AcM612wBlqUpafyxypGjSkNSllyT93ic2NKhdYimNWczv0JsDfBT33N06UBWD0rDl6ckijlv9-H4BCCwNjcRwVv1vMmYrencnS0pe4Es0aagFRgMUNrWtvdWynqZtI5ehvV5NuXHlCCLtsY5hVtnK8Bihx0HbIGe7l2_aCgYKARkSARISFQHGX2MiPnLobsCVELpWGfX568AwtQ0171", forHTTPHeaderField: "Authorization")
        
        let message: [String: Any] = [
            "message": [
                "token": "eTsT38p-T6upt1ORdgxF6I:APA91bFi8S7uGzfU86NYFow2DUFx5Z0HS3djEfC_I-XpG_85Ncgj_Pus254hQG6xC18eUCxzAAML3pEtwpG4XOVY1DddjeJPTg74ykhpSABLrb9ikHvea6VTpTG5BjiixSccsbu_qAk0", // Android 기기의 토큰
                "notification": [
                    "title": "Hello",
                    "body": "World"
                ]
            ]
        ]
        
        let json: [String: Any] = [
            "token": "eTsT38p-T6upt1ORdgxF6I:APA91bFi8S7uGzfU86NYFow2DUFx5Z0HS3djEfC_I-XpG_85Ncgj_Pus254hQG6xC18eUCxzAAML3pEtwpG4XOVY1DddjeJPTg74ykhpSABLrb9ikHvea6VTpTG5BjiixSccsbu_qAk0", // Android 기기의 토큰
            "title": "Hello",
            "body": "This is a test notification"
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(String(describing: error))")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print("Response: \(responseJSON)")
            }
        }
        
        task.resume()
    }
    
    @objc func moveAction() {
//         지도의 중심을 위치 좌표로 이동
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
}
