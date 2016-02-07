//
//  ViewController.swift
//  Flicks
//
//  Created by Aditya Balwani on 1/31/16.
//  Copyright © 2016 Aditya Balwani. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    var data:[NSDictionary]?
    
    @IBOutlet weak var moviesLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var moviesCollection: UICollectionView!
    @IBOutlet weak var networkErrorLabel: UILabel!
    
    let refreshControl = UIRefreshControl()
    
    var filteredData : [NSDictionary]?
    
    var searchBar:UISearchBar = UISearchBar(frame: CGRectMake(0, 0, 0, 00))
    
    var endpoint : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        moviesCollection.dataSource = self
        moviesCollection.delegate = self;
        searchBar.delegate = self
        
        searchBar.placeholder = "Search..."
                self.navigationItem.titleView = searchBar
        
        
        
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        
        moviesCollection.insertSubview(refreshControl, atIndex: 0)
        
        moviesLayout.scrollDirection = .Vertical
        moviesLayout.minimumLineSpacing = 0
        moviesLayout.minimumInteritemSpacing = 0
        moviesLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        loadMovies()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.hidden = false
    }
    
    @IBAction func onTap(sender: AnyObject) {
        searchBar.endEditing(false)
    }

    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        let _ = MBProgressHUD.showHUDAddedTo(self.moviesCollection, animated: true)
        loadMovies()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadMovies() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(self.endpoint!)?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            print("response: \(responseDictionary)")
                            self.data = responseDictionary["results"] as? [NSDictionary]
                            self.filteredData = responseDictionary["results"] as? [NSDictionary]
                            self.moviesCollection.reloadData()
                            MBProgressHUD.hideAllHUDsForView(self.moviesCollection, animated: true)
                            self.refreshControl.endRefreshing()
                    }
                } else {
                    self.networkErrorLabel.hidden = false
                }
        })
        task.resume()
    }
    
//    @IBAction func onTap(sender: AnyObject) {
//        view.endEditing(false)
//    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if filteredData != nil {
            return filteredData!.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCellCollectionViewCell
        
        let movie = filteredData?[indexPath.row]
        let posterURL = movie?["poster_path"]! as? String
        
        if let imageUrl = posterURL {
            cell.movieImage.setImageWithURLRequest(NSURLRequest(URL: NSURL(string: "https://image.tmdb.org/t/p/w342" + imageUrl)!), placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        cell.movieImage.alpha = 0.0
                        cell.movieImage.image = image
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            cell.movieImage.alpha = 1.0
                        })
                    } else {
                        cell.movieImage.image = image
                    }
                }, failure: { (imageRequest, imageResponse, error) -> Void in })
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout methods
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let totalwidth = collectionView.bounds.size.width;
        let numberOfCellsPerRow = 2
        let dimensions = CGFloat(Int(totalwidth) / numberOfCellsPerRow)
        return CGSizeMake(dimensions, dimensions * 1.5877)
        
    }
    
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data

        if searchText.isEmpty {
            filteredData = data
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            var tempFiltered = [NSDictionary]()
            
            for movie in data! {
                if (movie["title"]!.lowercaseString.rangeOfString(searchText.lowercaseString) != nil) {
                    tempFiltered.append(movie)
                }
            }
            
            filteredData = tempFiltered
        }
        moviesCollection.reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! MovieDetailViewController
        let indexPath = moviesCollection.indexPathForCell(sender as! UICollectionViewCell)
        let photo = filteredData?[indexPath!.row]
        vc.movie = photo
    }
    
}
