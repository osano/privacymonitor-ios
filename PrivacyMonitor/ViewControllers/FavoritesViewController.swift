//
//  FavoritesViewController.swift
//  PrivacyMonitor
//
//  Copyright © 2019 Osano, Inc., A Public Benefit Corporation. All rights reserved.
//

import Foundation
import UIKit

protocol FavoritesViewControllerDelegate: AnyObject {
    func favoriteUrlDidTap(_ urlString: String)
}

class FavoritesViewController: UITableViewController {

    weak var delegate: FavoritesViewControllerDelegate?

    fileprivate let cellIdentifier = "cellIdentifier"

    fileprivate lazy var favorites: [String] = {
        let favorites = UserSettingsHelper.favoritesUrls()
        return favorites ?? []
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Favorites"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(closeButtonTapped(sender:)))

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }

    // MARK: - User Interaction

    @objc
    fileprivate func closeButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table View Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = favorites[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let urlString = favorites[indexPath.row]
            UserSettingsHelper.removeFavoriteURL(urlString)

            favorites.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let urlString = favorites[indexPath.row]

        dismiss(animated: true) {
            self.delegate?.favoriteUrlDidTap(urlString)
        }
    }

}
