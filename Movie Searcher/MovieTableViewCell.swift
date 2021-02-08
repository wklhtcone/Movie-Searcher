//
//  MovieTableViewCell.swift
//  Movie Searcher
//
//  Created by 王凯霖 on 2/8/21.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
    @IBOutlet var movieTitleLabel: UILabel!
    @IBOutlet var movieYearLabel: UILabel!
    @IBOutlet var moviePosterImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    

    // configure the nib cell
    func config(with model: Movie){
        self.movieTitleLabel.text = model.Title
        self.movieYearLabel.text = model.Year
        let url = model.Poster
        if let imgData = try? Data(contentsOf: URL(string: url)!){
            self.moviePosterImageView.image = UIImage(data: imgData)
        }
    }
}
