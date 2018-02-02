//
//  NowPlayingTableViewController.swift
//  ReactiveArchitecture
//
//  Created by leonardis on 11/14/17.
//  Copyright 2017 LEO LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
//  associated documentation files (the "Software"), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, merge, publish, distribute,
//  sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or
//  substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
//  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit
import RxSwift
import RxCocoa
import AlamofireImage

/**
 Shows the list of Now Playing Movie Items
*/
class NowPlayingTableViewController: UITableViewController {
    private var objectList = Array<MovieViewInfo>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
     Add passed in list to table view with animation for each entry to add
     Parameters: listToAdd - list to add
    */
    func addAll(listToAdd: Array<MovieViewInfo>!) {
        for movieViewInfo: MovieViewInfo in listToAdd {
            objectList.append(movieViewInfo)
            
            let indexPath = IndexPath.init(row: self.objectList.count - 1, section: 0)
            let indexPathArray: [IndexPath] = [indexPath]
            
            tableView.insertRows(at: indexPathArray, with: UITableViewRowAnimation.left)
        }
    }

    /**
     Add passed in value to table view
     Parameters: listToAdd - list to add
     */
    func add(itemToAdd: MovieViewInfo!) {
        objectList.append(itemToAdd!)
        
        let indexPath = IndexPath.init(row: self.objectList.count - 1, section: 0)
        let indexPathArray : [IndexPath] = [indexPath]
        tableView.insertRows(at: indexPathArray, with: UITableViewRowAnimation.left)
    }
    
    /**
     * Get the count of items in the table
     *
     * Returns: item count of table backed data
     */
    func getItemCount() -> Int {
        return objectList.count
    }
    
    /**
    Get an item at a specific position
    Returns: MovieViewInfo at given position or nil
    */
    func getItem(position: Int) -> MovieViewInfo? {
        if objectList.count > position {
            return objectList[position]
        } else {
            return nil
        }
    }
    
    /**
    Remove an item at a specific position.
    */
    func remove(objectToRemove: MovieViewInfo) {
        let index = objectList.indexOf(element: objectToRemove)
        objectList.removeObject(element: objectToRemove)
        
        let indexPath = IndexPath.init(row: index, section: 0)
        let indexPathArray : [IndexPath] = [indexPath]
        tableView.deleteRows(at: indexPathArray, with: UITableViewRowAnimation.left)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objectList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //Load Data
        let movieViewInfo: MovieViewInfo = objectList[indexPath.row]
        
        //Load & Address Cell (no longer returns nil when using storyboard)
        if movieViewInfo is MovieViewInfoImpl {
            let movieCell: MovieCell = tableView.dequeueReusableCell(withIdentifier: "MovieCellIdentifier", for: indexPath) as! MovieCell
            
            //Address Cell
            movieCell.nameLabel.text = movieViewInfo.getTitle()
            movieCell.releaseDateLabel.text = movieViewInfo.getReleaseDate()
            movieCell.ratingLabel.text = movieViewInfo.getRating()
            
            if movieViewInfo.isHighRating() {
                movieCell.highRatingImageView.isHidden = false
            } else {
                movieCell.highRatingImageView.isHidden = true
            }
            
            let url = URL(string: movieViewInfo.getPictureUrl())!
            movieCell.moviePosterImageView.af_setImage(withURL: url)
            
            return movieCell
        } else {
            let progressCell: ProgressCell = tableView.dequeueReusableCell(withIdentifier: "ProgressCellIdentifier", for: indexPath) as! ProgressCell
            progressCell.progressActivityIndicatorView.startAnimating()
            return progressCell
        }
    }
}

protocol LoadMoreListener {
    func loadMore()
}


