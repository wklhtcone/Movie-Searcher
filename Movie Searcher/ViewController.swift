//
//  ViewController.swift
//  Movie Searcher
//
//  Created by 王凯霖 on 2/8/21.
//

import UIKit
import SafariServices

// UI布局：TableView、搜索框field
// 网络请求获取Movie数据
// 自定义nib cell，显示电影的titke、poster、year
// 点击cell跳转到详细信息


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate {
    @IBOutlet var table: UITableView!
    @IBOutlet var field: UITextField!
    
    var movies = [Movie]()

    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        field.delegate = self
    }
    
    //Text Field搜索框方法
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        serachMovies()
        return true
    }
    func serachMovies() {
        
        guard let searchText = field.text, !searchText.isEmpty else {
            return
        }
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = "https://www.omdbapi.com/?apikey=3aea79ac&s=\(encodedText)&type=movie"

        
        let session = URLSession.shared
        let task = session.dataTask(with: URL(string: url)!,completionHandler: {data, response, error in
            guard let data = data, error == nil else{
                return
            }
            
            //JsonData转为结构体
            var result: MovieResult?
            do {
                result = try JSONDecoder().decode(MovieResult.self, from: data)
            }
            catch {
                print("Json转换结构体失败\(error)")
            }
            
            guard let finalResult = result else {
                return
            }
            print("\(finalResult.Search)")

            //更新 movies 数组
            let newMovies = finalResult.Search
            self.movies.removeAll()
            self.movies.append(contentsOf: newMovies)
            
            //更新Table View，UI更新到主线程
            DispatchQueue.main.async {
                self.table.reloadData()
            }

        })
        task.resume()
    }
    
    
    // Table View 数据源和代理方法
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //根据nib注册cell
        let nibCell = UINib(nibName: "MovieTableViewCell", bundle: nil)
        table.register(nibCell, forCellReuseIdentifier: "MovieTableViewCell")
        //复用cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell", for: indexPath) as! MovieTableViewCell
        //设置cell数据
        cell.config(with: movies[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //跳转到详细页面
        let url = "https://www.imdb.com/title/\(movies[indexPath.row].imdbID)/"
        let vc = SFSafariViewController(url: URL(string:url)!)
        present(vc,animated: true)
    }


}

