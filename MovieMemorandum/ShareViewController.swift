//
//  ShareViewController.swift
//  MovieMemorandum
//
//  Created by 藤田えりか on 2019/01/03.
//  Copyright © 2019 com.erica. All rights reserved.
//

import UIKit
import NCMB
import Kingfisher
import SVProgressHUD
import SwiftDate
import ViewAnimator

public protocol Animation {
    var initialTransform: CGAffineTransform { get }
}

class ShareViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TimelineTableViewCellDelegate {
    
    
    var posts = [Post]()
    var Posts: Post?
    var UserReview : Int = 0
    var movies = [Movie]()
    var selectedMovie : Movie?
    var user = [User]()
    var Users: User?
    var edit = [EditUserinfoViewController]()
    var starOneMovies = [Movie]()
    var starTwoMovies = [Movie]()
    var starThreeMovies = [Movie]()
    var starFourMovies = [Movie]()
    var starFiveMovies = [Movie]()
    var starCount: Int = 0
    var isPost: Bool!
    var blockUserIdArray = [String]()
    var height: CGSize!
    
    @IBOutlet var movieTableView : UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 引っ張って更新
        setRefreshControl()
        self.navigationItem.title = "タイムライン"
        
        self.starCount = self.starOneMovies.count + self.starTwoMovies.count + self.starThreeMovies.count + self.starFourMovies.count + self.starFiveMovies.count
        
        movieTableView.dataSource = self
        movieTableView.delegate = self
        
        //xibの取得cellの取得
        let nib = UINib(nibName: "TimelineTableViewCell", bundle:Bundle.main)
        //nibの登録
        movieTableView.register(nib, forCellReuseIdentifier: "timelineCell")
        
        //textview可変 ▶︎ storyboardの制約 ＆ scroll enableの解除
        movieTableView.estimatedRowHeight = 10000
        movieTableView.rowHeight = UITableView.automaticDimension
        
        //不要な線を消す
        movieTableView.tableFooterView = UIView()
        movieTableView.tableFooterView?.tintColor = UIColor(red: 193/255, green: 225/255, blue: 162/255, alpha: 1.0)
        
        
        movieTableView.bindHeadRefreshHandler({
            self.loadData()
        }, themeColor: .white, refreshStyle: .native)
        
        //tableviewにデータを表示
        loadData()
        
        
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProfile" {
            let othersProfileController = segue.destination as! OthersProfileViewController
            othersProfileController.movie = selectedMovie
            
        }
    }
    
    
    
    func didTapProfileButton(timelineTableviewCell: UITableViewCell, button: UIButton) {
        selectedMovie = movies[timelineTableviewCell.tag]
        
        self.performSegue(withIdentifier: "toProfile", sender: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        getBlockUser()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        animation2()
    }
    
    func textViewDidChange(textView: UITextView) {
        movieTableView.beginUpdates()
        movieTableView.endUpdates()
    }
    
    
    func animation2(){
        //        let fromAnimation = AnimationType.from(direction: .right, offset: 50.0)
        //        let zoomAnimation = AnimationType.zoom(scale: 0.8)
        //        let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/6)
        //        UIView.animate(views: movieTableView.visibleCells,
        //                       animations: [fromAnimation, zoomAnimation,rotateAnimation],
        //                       duration: 2.0)
        let fromAnimation = AnimationType.from(direction: .right, offset: 30.0)
        let zoomAnimation = AnimationType.zoom(scale: 0.7)
        UIView.animate(views: movieTableView.visibleCells,
                       animations: [fromAnimation, zoomAnimation],
                       duration: 0.5)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    
    
    //自分以外ならスワイプして報告・ブロックする
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if movies[indexPath.row].user.objectId != NCMBUser.current()?.objectId {
            let reportButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "報告") { (action, index) -> Void in
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let reportAction = UIAlertAction(title: "報告する", style: .destructive ){ (action) in
                    SVProgressHUD.showSuccess(withStatus: "この投稿を報告しました。ご協力ありがとうございました。")
                    let object = NCMBObject(className: "Report")
                    object?.setObject(self.movies[indexPath.row].objectID, forKey: "reportId")
                    object?.setObject(NCMBUser.current(), forKey: "user")
                    object?.saveInBackground({ (error) in
                        if error != nil {
                            SVProgressHUD.showError(withStatus: "エラーです")
                        } else {
                            SVProgressHUD.dismiss(withDelay: 2)
                            tableView.deselectRow(at: indexPath, animated: true)
                        }
                    })
                }
                let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                    alertController.dismiss(animated: true, completion: nil)
                }
                
                alertController.addAction(reportAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                tableView.isEditing = false
                
            }
            reportButton.backgroundColor = UIColor.red
            let blockButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "ブロック") { (action, index) -> Void in
                //self.comments.remove(at: indexPath.row)
                //tableView.deleteRows(at: [indexPath], with: .fade)
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let blockAction = UIAlertAction(title: "ブロックする", style: .destructive) { (action) in
                    SVProgressHUD.showSuccess(withStatus: "このユーザーをブロックしました。")
                    
                    let object = NCMBObject(className: "Block")
                    object?.setObject(self.movies[indexPath.row].user.objectId, forKey: "blockUserID")
                    object?.setObject(NCMBUser.current(), forKey: "user")
                    object?.saveInBackground({ (error) in
                        if error != nil {
                            SVProgressHUD.showError(withStatus: "エラーです")
                        } else {
                            SVProgressHUD.dismiss(withDelay: 2)
                            tableView.deselectRow(at: indexPath, animated: true)
                            self.getBlockUser()
                        }
                    })
                    
                }
                let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                    alertController.dismiss(animated: true, completion: nil)
                }
                
                alertController.addAction(blockAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                tableView.isEditing = false
            }
            blockButton.backgroundColor = UIColor.blue
            return[blockButton,reportButton]
        } else {
            let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除") { (action, index) -> Void in
                let query = NCMBQuery(className: "Memo")
                query?.getObjectInBackground(withId: self.movies[indexPath.row].objectID, block: { (post, error) in
                    if error != nil {
                        SVProgressHUD.showError(withStatus: "エラーです")
                        SVProgressHUD.dismiss(withDelay: 2)
                    } else {
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(title: "投稿を削除しますか？", message: "マイリストからも削除されます", preferredStyle: .alert)
                            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                                alertController.dismiss(animated: true, completion: nil)
                            }
                            let deleteAction = UIAlertAction(title: "OK", style: .default) { (acrion) in
                                post?.deleteInBackground({ (error) in
                                    if error != nil {
                                        SVProgressHUD.showError(withStatus: "エラーです")
                                        SVProgressHUD.dismiss(withDelay: 2)
                                    } else {
                                        tableView.deselectRow(at: indexPath, animated: true)
                                        self.loadData()
                                        self.movieTableView.reloadData()
                                    }
                                })
                            }
                            alertController.addAction(cancelAction)
                            alertController.addAction(deleteAction)
                            self.present(alertController,animated: true,completion: nil)
                            tableView.isEditing = false
                        }
                        
                    }
                })
            }
            deleteButton.backgroundColor = UIColor.red
            return [deleteButton]
        }
    }
    
    
    func loadData() {
        //NCMBからデータを持ってくる
        let query = NCMBQuery(className: "Memo")
        //最新順
        query?.order(byDescending: "createDate")
        query?.includeKey("user")
        //レビューされているもののみ取ってくる
        query?.whereKeyExists("review")
        query?.whereKeyExists("title")
        query?.whereKeyExists("isPost")
        
        //検索して情報を取ってくる
        query?.findObjectsInBackground({ (result, error) in
            if error != nil{
                //エラーが起きてる場合
            } else {
                //エラーが起きてない場合　//result: [Any]
                self.movies = []
                let objects = result as! [NCMBObject]
                for object in objects {
                    let ispost = object.object(forKey: "isPost") as! Bool
                    
                    if ispost == true{
                        let title = object.object(forKey: "title") as! String
                        let review = object.object(forKey: "review") as! String
                        let supervisor = object.object(forKey: "supervisor") as! String
                        let imageUrl = object.object(forKey: "imageUrl") as! String
                        let star = object.object(forKey: "star") as! Int
                        let user = object.object(forKey: "user") as! NCMBUser
                        let displayName = user.object(forKey: "displayName") as? String
                        let objectID = object.objectId
                        let userImageUrl = user.object(forKey: "imageUrl") as? String
                        let nextWatch = user.object(forKey:"NextWatch") as? String
                        let best1 = user.object(forKey: "Best1") as? String
                        let best2 = user.object(forKey: "Best2") as? String
                        let best3 = user.object(forKey: "Best3") as? String
                        let userModel = User(objectId: user.objectId, userName: user.userName)
                        let movie = Movie(title: title, imageUrl: imageUrl, star: star, user: userModel, objectID: objectID!)
                        movie.review = review
                        movie.supervisor = supervisor
                        movie.title = title
                        movie.imageUrl = imageUrl
                        movie.user.userImageUrl = userImageUrl
                        movie.user = userModel
                        movie.user.best1 = best1
                        movie.user.best2 = best2
                        movie.user.best3 = best3
                        movie.user.userMemo = nextWatch
                        movie.user.displayName = displayName
                        
                        if self.blockUserIdArray.firstIndex(of: movie.user.objectId) == nil{
                            self.movies.append(movie)
                            print(self.blockUserIdArray)
                            
                        }
                    }else{
                        
                    }
                }
            }
            //tableviewにデータを表示
            self.movieTableView.reloadData()
            self.movieTableView.headRefreshControl.endRefreshing()
            self.UserReview = self.movies.count
        })
    }
    
    
    func getBlockUser() {
        
        let query = NCMBQuery(className: "Block")
        query?.includeKey("user")
        query?.whereKey("user", equalTo: NCMBUser.current())
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: "エラーです")
            } else {
                //ブロックされた人のIDが入ってる removeall()は初期化→はデータの重複を防ぐ
                //NCMBのデータを持ってきて、配列に入れて、表示
                self.blockUserIdArray.removeAll()
                for blockObject in result as! [NCMBObject] {
                    self.blockUserIdArray.append(blockObject.object(forKey: "blockUserID") as! String)
                    
                }
                
            }
        })
        loadData()
        //loadDataにはブロックした人のコメントは表示されない
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //selectedMovie = movies[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "timelineCell") as! TimelineTableViewCell
        
        //viewに影をつける
        cell.baseView.layer.cornerRadius = cell.baseView.layer.bounds.width / 25.0
        cell.baseView.layer.shadowColor = UIColor.black.cgColor
        cell.baseView.layer.shadowOffset = CGSize(width: 3, height: 3)
        cell.baseView.layer.shadowOpacity = 0.2
        cell.baseView.layer.masksToBounds = false
        
        //画面遷移させるため＋delegateがnilにならないようにするため
        cell.delegate = self
        cell.tag = indexPath.row
        
        //cellはもともとtextが標準搭載されている
        cell.movienameLabel.text = movies[indexPath.row].title
        cell.userreviewTextView.text = movies[indexPath.row].review
        cell.userreviewTextView.sizeToFit()
        
        cell.userimageView.layer.cornerRadius = cell.userimageView.bounds.width / 2.0
        cell.userimageView.layer.masksToBounds = true
        let user = movies[indexPath.row].user
        
        cell.usernameLabel.text = user.displayName
        
        if  movies[indexPath.row].user.userImageUrl == nil{
            cell.userimageView.image = UIImage(named: "images.png")
        }else{
            cell.userimageView.kf.setImage(with: URL(string: movies[indexPath.row].user.userImageUrl!))
        }
        
        return cell
    }
    
    
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTimeline(refreshControl:)), for: .valueChanged)
        movieTableView.addSubview(refreshControl)
    }
    
    
    @objc func reloadTimeline(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        // 更新が早すぎるので2秒遅延させる
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.movieTableView.reloadData()
            refreshControl.endRefreshing()
        }
        
    }
    
    
}


