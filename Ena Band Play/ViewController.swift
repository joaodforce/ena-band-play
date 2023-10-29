//
//  ViewController.swift
//  Ena Band Play
//
//  Created by João Eduardo on 21/09/22.
//

import UIKit
import AVKit
import AVFoundation


class ViewController: UIViewController {

    private lazy var jsonDecoder = JSONDecoder()
    private var urlSession: URLSession?
    private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicator()
        // Do any additional setup after loading the view.
    }
    
    // Function to set up the activity indicator
        func setupActivityIndicator() {
            activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.center = view.center
            activityIndicator.hidesWhenStopped = true
            view.addSubview(activityIndicator)
        }
    
    @IBAction func abrirBand(_ sender: Any) {
        
        
        activityIndicator.startAnimating()
        
        urlSession = URLSession(configuration: URLSessionConfiguration.default)
        
        let streamGetterURL = URL(string: "https://www.dailymotion.com/player/metadata/video/k13IYIS4xdgaFOxaX2y?GK_PV5_PHOTON=1&geo=1&player-id=x9fev&dmV1st=D10BAED60308AD97D213EC4CF3098272&dmTs=743277&is_native_app=0&customConfig%5BcustomParams%5D=8804%2Fparceiros%2Fband%2Fao_vivo")
        
        var request = URLRequest(url: streamGetterURL!)
        request.httpMethod = "GET"

//        request.addValue(jwtToken, forHTTPHeaderField: "Authorization")
        
        let task = self.urlSession!.dataTask(with: request) { (data, response, error) in
            
            // Dismiss the activity indicator on the main queue
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
            
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
                            var qualities: StreamQualities?
                        }
                        
//                        let jsonStr = String(data: _data, encoding: .utf8)
                        
                        let objs = try self.jsonDecoder.decode(DecoderedThing.self, from: _data)
                        
                        DispatchQueue.main.async {
                            if let qualities = objs.qualities {
                                self.openStream(stream: qualities.auto.first!.url)
                            } else {
                                let alert = UIAlertController(title: "API did not give any Streaming URL SMH", message: nil, preferredStyle: .alert)
                                self.present(alert, animated: true)
                            }
                        }
                        
                        
                    } else {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Falha ao carregar Stream", message: error?.localizedDescription, preferredStyle: .alert)
                            self.present(alert, animated: true)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Falha Ao carregar URL", message: error.localizedDescription, preferredStyle: .alert)
                        self.present(alert, animated: true)
                    }
                }
            }
        }
        task.resume()
        
    }
    
    func openStream(stream: URL) {

        // Create an AVPlayerItem
        let playerItem = AVPlayerItem(url: stream)

        // Create metadata items for title, description, and thumbnail
        let titleItem = AVMutableMetadataItem()
        titleItem.identifier = AVMetadataIdentifier.commonIdentifierTitle
        titleItem.value = "Band Ao Vivo" as NSString

//        let descriptionItem = AVMutableMetadataItem()
//        descriptionItem.identifier = AVMetadataIdentifier.commonIdentifierDescription
//        descriptionItem.value = "" as NSString
        
        // Create a metadata item for the thumbnail (artwork)
        let thumbnailImage = UIImage(named: "band-play")
        let thumbnailData = thumbnailImage?.pngData() as NSData?
        let thumbnailItem = AVMutableMetadataItem()
        thumbnailItem.identifier = AVMetadataIdentifier.commonIdentifierArtwork
        thumbnailItem.value = thumbnailData
        
        
        // Add the metadata items to the player item's metadata
        playerItem.externalMetadata = [titleItem, thumbnailItem]

        // Create an AVPlayer with the player item
        let player = AVPlayer(playerItem: playerItem)

        // Create an AVPlayerViewController and set the player
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
//        player.seek = false
        
        // Present the player view controller
        present(playerViewController, animated: true) {
            player.play()
        }

    }
    
//    func openStreame(stream: URL) {
//        
//        
//        let playerVC = self.storyboard?.instantiateViewController(withIdentifier: "playerVC") as? AVPlayerViewController
//        
//        let pl = AVPlayer(url: stream)
//        
////        pl.meta
//        // Indicate that the stream is not seekable
//        pl.currentItem?.isSeekable = false
//
//        playerVC?.player = pl
//        
//        self.present(playerVC!, animated: true)
//        
//        pl.play()
//    }


}

