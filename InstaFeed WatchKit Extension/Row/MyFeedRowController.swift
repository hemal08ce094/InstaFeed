//
//  MyFeedRowController.swift
//  InstaFeed WatchKit Extension
//
//  Created by Hemal on 09/01/2021.
//

import WatchKit

import ComposableRequestCrypto
import Swiftagram
import SwiftagramCrypto
import WatchConnectivity
import SwiftWatchConnectivity
import Kingfisher

class MyFeedRowController: NSObject {
    @IBOutlet var separator: WKInterfaceSeparator!
    
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var detailLabel: WKInterfaceLabel!
    @IBOutlet var userImage: WKInterfaceImage!
    @IBOutlet weak var feedPostTime: WKInterfaceLabel!
    
    @IBOutlet weak var moviePlayer: WKInterfaceMovie!
    
    @IBOutlet var feedImage: WKInterfaceImage!
    @IBOutlet weak var feedCaptionLabel: WKInterfaceLabel!
    
    @IBOutlet weak var feedLikeButton: WKInterfaceButton!
    @IBOutlet weak var commentButton: WKInterfaceButton!
    @IBOutlet weak var shareButton: WKInterfaceButton!
    
    var feedLikeButtonState = true
    
    public var model: AnyObject? {
        didSet {
            guard let model = model else { return }

            if let videoVersions = ((model as? [String : Any])?["video_versions"] as? [Any])?.first,
                let imageData = (model as? [String : Any])?["image_versions2"] as? [String : Any],
                  let candidates = imageData["candidates"] as? [Any],
                  let videoURL = (videoVersions as? [String : Any])?["url"] as? String,
                  let candidateURLString =  (candidates.first as? [String : Any])?["url"] as? String,
                  let feedCaption = (model as? [String : Any])?["caption"] as? [String : Any],
                  let createdAtTime = feedCaption["created_at_utc"] as? Int64,
                  let captionText = feedCaption["text"] as? String,
                  let userObject = (model as? [String : Any])?["user"],
                  let userName = (userObject as? [String : Any])?["username"] as? String,
                  let userProfileURLString = (userObject as? [String : Any])?["profile_pic_url"] as? String {
                let localDate = NSDate(timeIntervalSince1970: TimeInterval(createdAtTime)).timeAgoDisplay()
                
                userImage.kf.setImage(with: URL(string: userProfileURLString))
                feedImage.kf.setImage(with: URL(string: candidateURLString))
                
                
                moviePlayer.setHidden(false)
                
                guard let videoPlayBackURL = URL(string: videoURL) else {
                      return
              }
                
                moviePlayer.setMovieURL(videoPlayBackURL)
                
                guard let aURL = URL(string: candidateURLString) else {
                    return
                }
                
                URLSession.shared.dataTask(with: aURL) { aData, reponse, error in
                    DispatchQueue.main.async {
                        self.moviePlayer.setPosterImage(WKImage(imageData: (aData ?? Data()) as Data))
                    }
                }.resume()
                
                feedCaptionLabel.setText(captionText)
                feedPostTime.setText(localDate)
                titleLabel.setText(userName)
                
                if let isLikedByUser = (model as? [String : Any])?["has_liked"] as? Bool, isLikedByUser {
                    feedLikeButton.setBackgroundImageNamed("Liked.png")
                    feedLikeButtonState = true
                } else {
                    feedLikeButton.setBackgroundImageNamed("Unlicked.png")
                    feedLikeButtonState = false
                }
                
                
                if let likeCount = (model as? [String : Any])?["like_count"] as? Int64 {
                    feedLikeButton.setTitle(String(likeCount))
                }
                
                if let commentCount = (model as? [String : Any])?["comment_count"] as? Int64 {
                    commentButton.setTitle(String(commentCount))
                }
                
            }
            else if let imageData = (model as? [String : Any])?["image_versions2"] as? [String : Any],
               let candidates = imageData["candidates"] as? [Any],
               let candidateURLString =  (candidates.first as? [String : Any])?["url"] as? String,
               let feedCaption = (model as? [String : Any])?["caption"] as? [String : Any],
               let createdAtTime = feedCaption["created_at_utc"] as? Int64,
               let captionText = feedCaption["text"] as? String,
               let userObject = (model as? [String : Any])?["user"],
               let userName = (userObject as? [String : Any])?["username"] as? String,
               let userProfileURLString = (userObject as? [String : Any])?["profile_pic_url"] as? String
            {
                let localDate = NSDate(timeIntervalSince1970: TimeInterval(createdAtTime)).timeAgoDisplay()
                
                userImage.kf.setImage(with: URL(string: userProfileURLString))
                feedImage.kf.setImage(with: URL(string: candidateURLString))
                
                feedCaptionLabel.setText(captionText)
                feedPostTime.setText(localDate)
                titleLabel.setText(userName)
                
                feedImage.setHidden(false)
                moviePlayer.setHidden(true)
                
                if let isLikedByUser = (model as? [String : Any])?["has_liked"] as? Bool, isLikedByUser {
                    feedLikeButton.setBackgroundImageNamed("Liked.png")
                    feedLikeButtonState = true
                } else {
                    feedLikeButton.setBackgroundImageNamed("Unlicked.png")
                    feedLikeButtonState = false
                }
                
                
                if let likeCount = (model as? [String : Any])?["like_count"] as? Int64 {
                    feedLikeButton.setTitle(String(likeCount))
                }
                
                if let commentCount = (model as? [String : Any])?["comment_count"] as? Int64 {
                    commentButton.setTitle(String(commentCount))
                }
                
            }
        }
    }
    
    func utcToLocal(dateStr: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = dateFormatter.date(from: dateStr) {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "h:mm a"
        
            return dateFormatter.string(from: date)
        }
        return nil
    }

    @IBAction func likeButtonClicked() {
        if feedLikeButtonState {
            feedLikeButton.setBackgroundImageNamed("Unlicked.png")
            feedLikeButtonState = false
        } else {
            feedLikeButton.setBackgroundImageNamed("Liked.png")
            feedLikeButtonState = true
        }
    }

    
    override init() {

    }
}


