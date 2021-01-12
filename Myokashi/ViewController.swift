//
//  ViewController.swift
//  Myokashi
//
//  Created by 立岡力 on 2021/01/10.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Search Barのdelegate通知先の設定
        searchText.delegate = self
        // 入力のヒントとなる、プレースホルダーを設定
        searchText.placeholder = "お菓子の名前を入力してください"
        
    }

    @IBOutlet weak var searchText: UISearchBar!
    
    
    
    @IBOutlet weak var tableView: UITableView!
    // 検索ボタンをクリック時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // キーボードを閉じる
        view.endEditing(true)
        
        if let searchWord = searchBar.text {
            // デバックエリアに出力
            print(searchWord)
        }
    }
    
    func searchOkashi(keyword : String){
        
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        guard let req_url = URL(string:
        "https://sysbird.jp/toriko/api/?apikey=guest&")
        
        
    }
    
    
    
}

