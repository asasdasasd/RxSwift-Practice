//
//  TableViewWithEditingCommandsController.swift
//  Practice
//
//  Created by shen on 2017/2/17.
//  Copyright © 2017年 asasdasasd. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct TableViewEditingCommandsViewModel {
    let favoriteUsers: [User]
    let users: [User]
    
    //any difference between this two funcs?
//    func executeCommamd(_ command: TableViewEditingCommand) -> TableViewEditingCommandsViewModel {
//        switch command {
//        case let .setUsers(users):
//            return TableViewEditingCommandsViewModel(favoriteUsers: favoriteUsers, users: users)
//        case let .setFavoriteUsers(favoriteUsers):
//            return TableViewEditingCommandsViewModel(favoriteUsers: favoriteUsers, users: users)
//        case let .deleteUser(IndexPath):
//            var all = [self.favoriteUsers, self.users]
//            all[IndexPath.section].remove(at: IndexPath.row)
//            return TableViewEditingCommandsViewModel(favoriteUsers: all[0], users: all[1])
//        case let .moveUser(from, to):
//            var all = [self.favoriteUsers, self.users]
//            let user = all[from.section][from.row]
//            all[from.section].remove(at: from.row)
//            all[to.section].insert(user, at: to.row)
//            
//            return TableViewEditingCommandsViewModel(favoriteUsers: all[0], users: all[1])
//        }
//    }
    func executeCommand(_ command: TableViewEditingCommand) -> TableViewEditingCommandsViewModel {
        switch command {
        case let .setUsers(users):
            return TableViewEditingCommandsViewModel(favoriteUsers: favoriteUsers, users: users)
        case let .setFavoriteUsers(favoriteUsers):
            return TableViewEditingCommandsViewModel(favoriteUsers: favoriteUsers, users: users)
        case let .deleteUser(indexPath):
            var all = [self.favoriteUsers, self.users]
            all[indexPath.section].remove(at: indexPath.row)
            return TableViewEditingCommandsViewModel(favoriteUsers: all[0], users: all[1])
        case let .moveUser(from, to):
            var all = [self.favoriteUsers, self.users]
            let user = all[from.section][from.row]
            all[from.section].remove(at: from.row)
            all[to.section].insert(user, at: to.row)
            
            return TableViewEditingCommandsViewModel(favoriteUsers: all[0], users: all[1])
        }
    }


}

enum TableViewEditingCommand {
    case setUsers(users: [User])
    case setFavoriteUsers(favoriteUsers: [User])
    case deleteUser(IndexPath: IndexPath)
    case moveUser(from: IndexPath, to: IndexPath)
}

class TableViewWithEditingCommandsController: ViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let dataSource = TableViewWithEditingCommandsController.configDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let superMan = User(
            firstName: "Super",
            lastName: "Man",
            imageURL: "http://nerdreactor.com/wp-content/uploads/2015/02/Superman1.jpg"
        )
        
        let watMan = User(
            firstName: "Wat",
            lastName: "Man",
            imageURL: "http://www.iri.upc.edu/files/project/98/main.GIF"
        )
        
        let loadFavoriteUsers = RandomUserAPI.sharedAPI
                        .getExampleUserResultSet()
                        .map (TableViewEditingCommand.setUsers)
        
        
        let initialLoadCommand = Observable.just(TableViewEditingCommand
            .setFavoriteUsers(favoriteUsers: [superMan, watMan]))
            .concat(loadFavoriteUsers)
            .observeOn(MainScheduler.instance)
        
        let deleteUserCommand = tableView.rx.itemDeleted.map(TableViewEditingCommand.deleteUser)
       
        let moveUserCommand = tableView.rx.itemMoved.map(TableViewEditingCommand.moveUser)
        
        let initialState = TableViewEditingCommandsViewModel(favoriteUsers: [], users: [])
        
        let viewModel = Observable.of(initialLoadCommand, deleteUserCommand, moveUserCommand)
            .merge()
            .scan(initialState){ $0.executeCommand($1) }
            .shareReplay(1)
        
        viewModel.map {
                [
                    SectionModel(model: "Favorite Users", items: $0.favoriteUsers),
                    SectionModel(model: "Normal Users", items: $0.users)
                ]
            }
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposebag)
        

        tableView.rx.itemSelected
            .withLatestFrom(viewModel) { i, viewModel in
                let all = [viewModel.favoriteUsers, viewModel.users]
                return all[i.section][i.row]
            }
            .subscribe(onNext: { [weak self] user in
                self?.showDetailsForUser(user)
            })
            .disposed(by: disposebag)

        tableView.rx.setDelegate(self)
            .disposed(by: disposebag)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.isEditing = editing
    }
    
    private func showDetailsForUser(_ user: User) {
        let storyboard = UIStoryboard(name: "TableViewWithEditingCommands", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        viewController.user = user
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    static func configDataSource() -> RxTableViewSectionedReloadDataSource<SectionModel<String, User>> {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, User>>()
        
        dataSource.configureCell = { (_, tv, ip, user: User) in
            let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = user.firstName + "  " + user.lastName
            return cell
        }
        
        dataSource.titleForHeaderInSection = { dataSource, sectionIndex in
            return dataSource[sectionIndex].model
        }
        
        dataSource.canEditRowAtIndexPath = { ds, ip in
            return true
        }
        
        dataSource.canMoveRowAtIndexPath = { _ in
            return true
        }
        
        return dataSource
    }
}

// table veiw delegate
extension TableViewWithEditingCommandsController {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = dataSource[section]
        
        let label = UILabel(frame: CGRect.zero)
        
        label.text = "  \(title)"
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.darkGray
        label.alpha = 0.9
        
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}
