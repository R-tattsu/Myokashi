//
//  ViewController.swift
//  Myokashi
//
//  Created by 立岡力 on 2021/01/10.
//

// オブジェクト　物
// クラス　設計書
// インスタンス　実際に生成されたもの  インスタンスの初期化とは「クラス定義から実際のインスタンスを生成すること」
// プロパティ 状態　消費電力　パワー　速度 let ver
// メソッド　振る舞い　歩く　つかむ　func　　　インスタンス.メソッド()
// 軽装
// カプセル化
// 多様性　ポリモルフィズム


// フレームワーク
import UIKit
import SafariServices

// クラス
class ViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, SFSafariViewControllerDelegate {

    override func viewDidLoad() {  // 上書き　メソッド()
        super.viewDidLoad()  // インスタンス.メソッド()
        
        // Search Barのdelegate通知先の設定
        searchText.delegate = self
        // 入力のヒントとなる、プレースホルダーを設定
        searchText.placeholder = "お菓子の名前を入力してください"
        // TableViewのdatasourceを設定
        tableView.dataSource = self
        // TableViewのdeligateを設定
        tableView.delegate = self
        
    }

    @IBOutlet weak var searchText: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    // お菓子のリスト（タプル配列）
    var okashiList : [(name:String , maker:String , link:URL , image:URL)] = []
    // 検索ボタンをクリック時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // キーボードを閉じる
        view.endEditing(true)
        
        if let searchWord = searchBar.text {
            // デバックエリアに出力
            print(searchWord)
            // 入力されていたらお菓子を検索
            searchOkashi(keyword: searchWord)
        }
    }
    // JSONのitem内のデータ構造
    struct ItemJson: Codable{
        // お菓子の名称
        let name: String?
        // メーカー
        let maker: String?
        // 掲載URL
        let url: URL?
        // 画像URL
        let image: URL?
    }
    // JSONのデータ構造
    struct ResultJson: Codable {
        // 複数要素
        let item:[ItemJson]?
    }
    
    
    // searchOkashiメソッド
    // 第一引数：keyword　検索したいワード
    func searchOkashi(keyword : String){
        // お菓子の検索キーワードをURLエンコードする
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        // リクエストURLの組み立て
        guard let req_url = URL(string:
            "https://sysbird.jp/toriko/api/?apikey=guest&format=json&keyword=\(keyword_encode)&max=10&order=r") else {
            return
        }
        print(req_url)
        
        // リクエストに必要な情報を生成
        let req = URLRequest(url: req_url)
        // データ転送を管理するためのセッションを生成
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        // リクエストをタスクとして登録
        let task = session.dataTask(with: req, completionHandler: {
            (data, response, error) in
            // セッションを終了
            session.finishTasksAndInvalidate()
            // do try catch エラーハンドリング
            do {
                // JSONDecoderのインスタンス取得
                let decoder = JSONDecoder()
                // 受け取ったJSONデータを解析して格納
                let json = try decoder.decode(ResultJson.self, from: data!)
                
                // print(json)
                // お菓子の情報が取得できているか確認
                if let items = json.item{
                    // お菓子のリストを初期化
                    self.okashiList.removeAll()
                    // 取得しているお菓子の数だけ処理
                    for item in items{
                        // お菓子の名称、メーカー名、掲載URL、画像URLをアンラップ
                        if let name = item.name , let maker = item.maker , let link = item.url , let image = item.image{
                            // 一つのお菓子をタプルでまとめて管理
                            let okashi = (name,maker,link,image)
                            // お菓子の配列へ追加
                            self.okashiList.append(okashi)
                        }
                    }
                    // TableViewを更新する
                    self.tableView.reloadData()
                    
                    if let okashidbg = self.okashiList.first {
                        print ("----------------")
                        print ("okashiList[0] = \(okashidbg)")
                    }
                }
            } catch {
                // エラー処理
                print("エラーが出ました")
            }
        })
        // ダウンロード開始
        task.resume()
    }
    // Cellの総数を返すdatasourceメソッド。必ず記述する必要あり
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // お菓子リストの総数
        return okashiList.count
    }
    // Cellに値を設定するdatasourceメソッド。必ず記述する必要あり
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 今回表示を行う、Cellオブジェクト（１行）を取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "okashiCell", for: indexPath)
        // お菓子のタイトル設定
        cell.textLabel?.text = okashiList[indexPath.row].name
        // お菓子の画像を取得
        if let imageData = try? Data(contentsOf: okashiList[indexPath.row].image) {
            // 正常に取得できた場合は、UIImageで画像オブジェクトを生成して、Cellにお菓子画像を設定
            cell.imageView?.image = UIImage(data: imageData)
        }
        // 設定済みのCellオブジェクトを画面に反映
        return cell
    }
    // Cellが選択された際に呼び出されるdelegateメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // ハイライト解除
        tableView.deselectRow(at: indexPath, animated: true)
        // SFSafariViewを開く
        let safariViewController = SFSafariViewController(url: okashiList[indexPath.row].link)
        // delegateの通知先を自分自身
        safariViewController.delegate = self
        // SafariViewが開かれる
        present(safariViewController, animated: true, completion: nil)
    }
    
    // SafariViewが閉じられた時に呼ばれるdelegateメソッド
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // SafariViewを閉じる
        dismiss(animated: true, completion: nil)
    }
}

