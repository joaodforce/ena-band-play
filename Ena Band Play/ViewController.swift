//
//  ViewController.swift
//  Ena Band Play
//
//  Created by João Eduardo on 21/09/22.
//

import UIKit
import AVKit

class ViewController: UIViewController {

    private lazy var jsonDecoder = JSONDecoder()
    private var urlSession: URLSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        urlSession = URLSession(configuration: URLSessionConfiguration.default)
        
        let streamGetterURL = URL(string: "https://www.dailymotion.com/player/metadata/video/k13IYIS4xdgaFOxaX2y?GK_PV5_PHOTON=1&geo=1&player-id=x9fev&dmV1st=D10BAED60308AD97D213EC4CF3098272&dmTs=743277&is_native_app=0&customConfig%5BcustomParams%5D=8804%2Fparceiros%2Fband%2Fao_vivo")
        
        var request = URLRequest(url: streamGetterURL!)
        request.httpMethod = "GET"

//        request.addValue(jwtToken, forHTTPHeaderField: "Authorization")
        
        let task = self.urlSession!.dataTask(with: request) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                do {
                    let _data = data ?? Data()
                    if (200...399).contains(statusCode) {
                        
                        struct StreamURL: Decodable {
                            var type: String
                            var url: URL
                        }
                        
                        struct StreamQualities: Decodable {
                            var auto: [StreamURL]
                        }
                        
                        struct DecoderedThing: Decodable {
                            var qualities: StreamQualities
                        }
                        
                        let objs = try self.jsonDecoder.decode(DecoderedThing.self, from: _data)
                        
                        DispatchQueue.main.async {
                            self.openStreame(stream: objs.qualities.auto.first!.url)
                        }
                        
                        
                    } else {
                        let alert = UIAlertController(title: "Falha ao carregar Stream", message: error?.localizedDescription, preferredStyle: .alert)
                        self.present(alert, animated: true)
                    }
                } catch {
                    let alert = UIAlertController(title: "Falha Ao carregar URL", message: error.localizedDescription, preferredStyle: .alert)
                    self.present(alert, animated: true)
                }
            }
        }
        task.resume()
        
        
        
        // Do any additional setup after loading the view.
    }
    
    func openStreame(stream: URL) {
        
        let playerVC = self.storyboard?.instantiateViewController(withIdentifier: "playerVC") as? AVPlayerViewController
        
        let pl = AVPlayer(url: stream)
        
//        pl.meta
        
        playerVC?.player = pl
        
        self.present(playerVC!, animated: true)
        
        pl.play()
    }


}

