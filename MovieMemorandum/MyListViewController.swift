//
//  MyListViewController.swift
//  MovieMemorandum
//
//  Created by 藤田えりか on 2019/01/03.
//  Copyright © 2019 com.erica. All rights reserved.
//

import UIKit
import NCMB
import Kingfisher
import KafkaRefresh
import SVProgressHUD

class MyListViewController: UIViewController {
    
    @IBOutlet var baseView: UIView!
    @IBOutlet var movieTableView : UITableView!
    
    var memoArray = [NCMBObject]()
    var movies = [Movie]()
    var starOneMovies = [Movie]()
    var starTwoMovies = [Movie]()
    var starThreeMovies = [Movie]()
    var starFourMovies = [Movie]()
    var starFiveMovies = [Movie]()
    var selectedMemo: Movie?
    var selectedNumber: Int!
    var selectedTag: Int!
    var tag: Int = 0
    var starCount: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUser = NCMBUser.current() else {
            
            //ログインに戻る
            
            //ログアウト登録成功
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let RootViewController = storyboard.instantiateViewController(withIdentifier: "rootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = RootViewController
            
            //ログアウト状態の保持
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
            
            return
        }
        
        
        self.navigationItem.title = "ホーム"
        
        //ファイル内処理
        movieTableView.dataSource = self
        movieTableView.delegate = self
        
        movieTableView.tableFooterView = UIView()
        
        movieTableView.bindHeadRefreshHandler({
            self.loadData()
        }, themeColor: .white, refreshStyle: .native)
        
        let nib = UINib(nibName: "MyListTableViewCell", bundle: Bundle.main)
        movieTableView.register(nib, forCellReuseIdentifier: "Cell")
        loadData()
        
        let orangeColor = UIColor(red: 154/255, green: 215/255,  blue: 50/255, alpha: 1.0)
        UINavigationBar.appearance().barTintColor = orangeColor
        UINavigationBar.appearance().tintColor = UIColor.white
        
    }
    
    // 画面遷移先のViewControllerを取得し、データを渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            let vc = segue.destination as! toDetailViewController
            
            vc.selectedMemo = selectedMemo
            vc.selectedTag = selectedTag
            vc.selectedNumber = selectedNumber
            
            switch selectedTag {
            case 0:
                vc.movies = starFiveMovies
            case 1:
                vc.movies = starFourMovies
            case 2:
                vc.movies = starThreeMovies
            case 3:
                vc.movies = starTwoMovies
            case 4:
                vc.movies = starOneMovies
            default:
                break
            }
            //vc.memoTextView1.text = "sample"
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        let orangeColor = UIColor(red: 154/255, green: 215/255,  blue: 50/255, alpha: 1.0)
        UINavigationBar.appearance().barTintColor = orangeColor
        UINavigationBar.appearance().tintColor = UIColor.white
    }
    
    @IBAction func plusButton() {
        let user = NCMBUser.current()
        if user!.object(forKey: "displayName") == nil{
            
            let alert = UIAlertController(title: "ユーザーネーム登録", message: "ユーザーネームを新規登録しましょう", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
                SVProgressHUD.show()
                
                
                
                user?.setObject(alert.textFields?.first?.text, forKey: "displayName")
                user?.saveInBackground({ (error) in
                    if error != nil {
                        SVProgressHUD.showError(withStatus: "エラーです")
                    } else {
                        SVProgressHUD.showSuccess(withStatus: "ユーザーネーム登録完了！プラスボタンから投稿しよう！")
                        
                    }
                })
            }
            
            //アラートが消えるのと画面遷移が重ならないように0.5秒後に画面遷移するようにしてる
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // 0.5秒後に実行したい処理
                self.performSegue(withIdentifier: "toAdd", sender: nil)
                
            }
            
            alert.addAction(okAction)
            alert.addTextField { (textField) in
                textField.placeholder = "ここに入力"
            }
            
            
            self.present(alert, animated: true, completion: nil) //アラートが現れるために必要
        }else{
            self.performSegue(withIdentifier: "toAdd", sender: nil)
        }
        
        
    }
    
    
    func loadData() {
        
        let query = NCMBQuery(className: "Memo")
        
        //最新順
        //query?.order(byDescending: "createDate")
        query?.includeKey("user")
        
        //検索して情報を取ってくる
        query?.findObjectsInBackground({ (result, error) in
            if error != nil{
                //エラーが起きてる場合
            } else {
                //エラーが起きてない場合
                //result: [Any]
                self.starOneMovies = []
                self.starTwoMovies = []
                self.starThreeMovies = []
                self.starFourMovies = []
                self.starFiveMovies = []
                let objects = result as! [NCMBObject]
                
                for object in objects {
                    // 投稿したユーザー情報
                    let user = object.object(forKey: "user") as! NCMBUser
                    
                    if user.objectId == NCMBUser.current()?.objectId {
                        let title = object.object(forKey: "title") as! String
                        let review = object.object(forKey: "review") as! String
                        let supervisor = object.object(forKey: "supervisor") as! String
                        let date = object.object(forKey: "date") as! String
                        let star = object.object(forKey: "star") as! Int
                        let displayName = user.object(forKey: "displayName") as? String
                        
                        
                        let objectID = object.objectId
                        
                        let userImageUrl = user.object(forKey: "imageUrl") as? String
                        //imageUrl取得
                        let imageUrl = object.object(forKey: "imageUrl") as! String
                        
                        let userModel = User(objectId: user.objectId, userName: user.userName)
                        
                        let movie = Movie(title: title, imageUrl: imageUrl, star: star, user: userModel, objectID: objectID!)
                        //呼び出す
                        movie.review = review
                        movie.supervisor = supervisor
                        movie.date = date
                        movie.imageUrl = imageUrl
                        movie.user.userImageUrl = userImageUrl
                        movie.user.displayName = displayName
                        
                        if movie.star == 1 {
                            self.starOneMovies.append(movie)
                        } else if movie.star == 2 {
                            self.starTwoMovies.append(movie)
                        }else if movie.star == 3 {
                            self.starThreeMovies.append(movie)
                        }else if movie.star == 4 {
                            self.starFourMovies.append(movie)
                        }else if movie.star == 5 {
                            self.starFiveMovies.append(movie)
                        }
                        self.movies.append(movie)
                    }else{
                        
                    }
                    
                }
            }
            //tableviewにデータを表示
            self.movieTableView.reloadData()
            self.movieTableView.headRefreshControl.endRefreshing()
        })
    }
}

extension MyListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView.tag == 0 {
            return starFiveMovies.count
        } else if collectionView.tag == 1 {
            return starFourMovies.count
        }else if collectionView.tag == 2{
            return starThreeMovies.count
        }else if collectionView.tag == 3{
            return starTwoMovies.count
        }else if collectionView.tag == 4{
            return starOneMovies.count
        }else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        if collectionView.tag == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! MyListCollectionViewCell
            cell.textLabel.text = starFiveMovies[indexPath.row].title
            cell.imageView.kf.setImage(with: URL(string: starFiveMovies[indexPath.row].imageUrl))
            let imageUrl = starFiveMovies[indexPath.row].imageUrl
            
            
            cell.imageView.kf.setImage(with: URL(string: imageUrl))
            return cell
        } else if collectionView.tag == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! MyListCollectionViewCell
            cell.textLabel.text = starFourMovies[indexPath.row].title
            cell.imageView.kf.setImage(with: URL(string: starFourMovies[indexPath.row].imageUrl))
            let imageUrl = starFourMovies[indexPath.row].imageUrl
            
            
            cell.imageView.kf.setImage(with: URL(string: imageUrl))
            return cell
        }else if collectionView.tag == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! MyListCollectionViewCell
            cell.textLabel.text = starThreeMovies[indexPath.row].title
            cell.imageView.kf.setImage(with: URL(string: starThreeMovies[indexPath.row].imageUrl))
            let imageUrl = starThreeMovies[indexPath.row].imageUrl
            
            cell.imageView.kf.setImage(with: URL(string: imageUrl))
            return cell
        }else if collectionView.tag == 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! MyListCollectionViewCell
            cell.textLabel.text = starTwoMovies[indexPath.row].title
            cell.imageView.kf.setImage(with: URL(string: starTwoMovies[indexPath.row].imageUrl))
            let imageUrl = starTwoMovies[indexPath.row].imageUrl
            
            //print(imageUrl)
            cell.imageView.kf.setImage(with: URL(string: imageUrl))
            return cell
        }else if collectionView.tag == 4 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! MyListCollectionViewCell
            cell.textLabel.text = starOneMovies[indexPath.row].title
            cell.imageView.kf.setImage(with: URL(string: starOneMovies[indexPath.row].imageUrl))
            let imageUrl = starOneMovies[indexPath.row].imageUrl
            
            
            cell.imageView.kf.setImage(with: URL(string: imageUrl))
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! MyListCollectionViewCell
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 140, height: 200)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        tag = collectionView.tag
        // Identifierが"Segue"のSegueを使って画面遷移する関数
        if tag == 0 {
            selectedMemo = starFiveMovies[indexPath.row]
        }else if tag == 1{
            selectedMemo = starFourMovies[indexPath.row]
        }else if tag == 2{
            selectedMemo = starThreeMovies[indexPath.row]
        }else if tag == 3{
            selectedMemo = starTwoMovies[indexPath.row]
        }else if tag == 4{
            selectedMemo = starOneMovies[indexPath.row]
        }
        
        self.selectedTag = tag
        self.selectedNumber = indexPath.row
        
        performSegue(withIdentifier: "toDetail", sender: nil)
    }
    
    
    
}

extension MyListViewController:  UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let cell = cell as? MyListTableViewCell else { return }
        
        //ShopTableViewCell.swiftで設定したメソッドを呼び出す
        cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.section)
    }
    
    // セクションの背景とテキストの色を変更する
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        switch section {
            
        case 0:
            let color =  UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
            view.tintColor = color
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = .black
            
        case 1:
            let color =  UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
            view.tintColor = color
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = .black
        case 2:
            let color =  UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
            view.tintColor = color
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = .black
        case 3:
            let color =  UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
            view.tintColor = color
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = .black
        case 4:
            let color =  UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
            view.tintColor = color
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = .black
            
        default:
            let color =  UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
            view.tintColor = color
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = .blue
        }
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MyListTableViewCell
        
        cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
        cell.collectionView.reloadData()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "星\(5 - section)"
    }
    
}

