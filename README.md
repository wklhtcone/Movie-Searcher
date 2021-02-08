## 0. 效果
- 输入电影名搜索得到结果列表，包含电影封面、标题、年份
- 点击行进入相应的IMDb详情页
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210208172524313.JPEG?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM1MDg3NDI1,size_16,color_FFFFFF,t_70)

## 1. 简介
### 1.1 API
- [https://www.omdbapi.com/](https://www.omdbapi.com/)是一个获取电影数据的API网站
- 获取的Json如下：
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210208155629446.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM1MDg3NDI1,size_16,color_FFFFFF,t_70)
### 1.2 数据结构
- 根据Json设计数据结构如下：
- Swift 4引入了`Codable`协议，与`NSCoding`协议不同的是：如果自定义的类中全都是基本数据类型、基本对象类型，无需再实现编解码，只需要在自定义的类声明它遵守`Codable`协议即可
- 原Json中的`Type`与Swift的关键字冲突了，使用`CodingKeys`替换变量名

```swift
struct MovieResult: Codable {
    let Search: [Movie]
}

struct Movie: Codable {
    let Title: String
    let Year: String
    let imdbID: String
    let _Type: String
    let Poster: String
    
    enum CodingKeys: String, CodingKey {
        case Title, Year, imdbID, _Type = "Type", Poster
    }
}
```

## 2. UI![在这里插入图片描述](https://img-blog.csdnimg.cn/20210208160827539.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM1MDg3NDI1,size_16,color_FFFFFF,t_70)

### 2.1 组件及方法
1. 搜索框Text Field

```swift
@IBOutlet var field: UITextField!

//按下return调用
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    serachMovies()
    return true
}

//具体实现见Github
func serachMovies() {
	//数据预处理
	//网络请求
	//更新Model与View
}
```


2. 显示搜索结果的Table View

```swift
@IBOutlet var table: UITableView!
var movies = [Movie]()

// Table View 数据源和代理方法，具体实现见Github
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return movies.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //创建自定义的nib cell
}

func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    //跳转到详细页面
}
```

3. 设置数据源和代理

```swift
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        field.delegate = self
    }
}
```

### 2.2 自定义TableViewCell
- 使用`Nib`显示符合结果电影的封面、电影名、年份
- 两个`Label`分别显示`Movie Title`和`Year`，一个`ImageView`显示封面
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210208161758212.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM1MDg3NDI1,size_16,color_FFFFFF,t_70)
- `Nib`数据结构如下

```swift
class MovieTableViewCell: UITableViewCell {
    @IBOutlet var movieTitleLabel: UILabel!
    @IBOutlet var movieYearLabel: UILabel!
    @IBOutlet var moviePosterImageView: UIImageView!

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
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210208162601216.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM1MDg3NDI1,size_16,color_FFFFFF,t_70)

- 数据源方法如下
```swift
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
```

## 3. 网络请求获取数据
### 3.1 预处理
- 将搜索内容转为URL可以识别的字符串

```swift
guard let searchText = field.text, !searchText.isEmpty else {
	return
}
let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
let url = "https://www.omdbapi.com/?apikey=3aea79ac&s=\(encodedText)&type=movie"
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210208163817309.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM1MDg3NDI1,size_16,color_FFFFFF,t_70)


### 3.2 URLSession获取Json并解析

1. 对于基本请求可以使用`URLSession.shared`单例，简单的数据任务使用`dataTask`方法
2. `dataTask(with: URL, completionHandler: (Data?, URLResponse?, Error?) -> Void)`方法
- 获取数据成功时，数据保存在`Data`，`Error`为nil
- 获取失败时，`Error`不为nil
- 不论是否获取成功，`URLResponse`不为nil，存着HTTP响应报文中的数据
3. 获取data后将其转为结构体
- `JSONDecoder().decode()`可能失败`throw`异常，因此放在`do{} catch{}`中，并`try`
- 若转换失败，`revData`就成了`nil`，因此声明为可选型

```swift
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
```

### 3.3 更新Model与View
- 数据获取成功后更新movies数组
- UI更新只在主线程更新，用GCD将UI更新的代码异步派发到主队列

```swift
//更新 movies 数组
let newMovies = finalResult.Search
self.movies.removeAll()
self.movies.append(contentsOf: newMovies)

//更新Table View，UI更新到主线程
DispatchQueue.main.async {
    self.table.reloadData()
}
```

## 4. 点击进入详情
- `https://www.imdb.com/title/"IMDb_ID"/`可以显示根据IMDb ID显示电影的详细内容，这个ID就在请求到的Json数据中

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210208165507930.png)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210208165008102.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM1MDg3NDI1,size_16,color_FFFFFF,t_70)

```swift
import SafariServices
//Table View代理方法
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    //跳转到详细页面
    let url = "https://www.imdb.com/title/\(movies[indexPath.row].imdbID)/"
    let vc = SFSafariViewController(url: URL(string:url)!)
    present(vc,animated: true)
}
```
