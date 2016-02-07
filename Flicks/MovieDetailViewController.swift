//
//  MovieDetailViewController.swift
//  Flicks
//
//  Created by Aditya Balwani on 2/7/16.
//  Copyright © 2016 Aditya Balwani. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var moviePosterImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieDetailView: UIView!
    @IBOutlet weak var moveDateLabel: UILabel!
    @IBOutlet weak var movieDescriptionLabel: UILabel!
    @IBOutlet weak var movieRatingLabel: UILabel!
    
    var movie : NSDictionary!
    
    override func viewDidLoad() {
        self.tabBarController?.tabBar.hidden = true
        super.viewDidLoad()
        print(movie)
        // Do any additional setup after loading the view.
        
        let posterURL = movie?["poster_path"]! as? String
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: movieDetailView.frame.origin.y + movieDetailView.frame.height)
        
        if let imageUrl = posterURL {
            moviePosterImageView.setImageWithURLRequest(NSURLRequest(URL: NSURL(string: "https://image.tmdb.org/t/p/w342" + imageUrl)!), placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    self.moviePosterImageView.image = image
                }, failure: { (imageRequest, imageResponse, error) -> Void in })
        }
        
        if let title = movie["original_title"] as? String {
            movieTitleLabel.text = title
            self.title = title
        }
        
        if let date = movie["release_date"] as? String {
            moveDateLabel.text = date
        }
        
        if let vote = movie["vote_average"] as? Double {
            movieRatingLabel.text = vote.description
        }
        
        if let overview = movie["overview"] as? String {
            movieDescriptionLabel.text = overview
        }
        
        movieDescriptionLabel.sizeToFit()


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
