//
//  PartialUpdatesViewController.swift
//  Practice
//
//  Created by asasdasasd on 2017/2/15.
//  Copyright © 2017年 asasdasasd. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

let generateCustomSize = true
let runAutomatically = false
let useAnimatedUpdateForCollectionView = false


class PartialUpdatesViewController: ViewController {

    @IBOutlet weak var reloadTableViewOutlet: UITableView!
    @IBOutlet weak var partialUpdatesTableViewOutlet: UITableView!
    @IBOutlet weak var partialUpdatesCollectionViewOutlet: UICollectionView!
    
    var timer: Foundation.Timer? = nil
    
    static let initalValue: [AnimatableSectionModel<String, Int>] = [
        NumberSection(model: "section 1", items: [1, 2, 3]),
        NumberSection(model: "section 2", items: [4, 5, 6]),
        NumberSection(model: "section 3", items: [7, 8, 9]),
        NumberSection(model: "section 4", items: [10, 11, 12]),
        NumberSection(model: "section 5", items: [13, 14, 15]),
        NumberSection(model: "section 6", items: [16, 17, 18]),
        NumberSection(model: "section 7", items: [19, 20, 21]),
        NumberSection(model: "section 8", items: [22, 23, 24]),
        NumberSection(model: "section 9", items: [25, 26, 27]),
        NumberSection(model: "section 10", items: [28, 29, 30])
    ]
    
    static let firstChange: [AnimatableSectionModel<String, Int>]? = nil
    
    var generator = Randomizer(rng: PseudoRandomGenerator(4, 3), sections: initalValue)
    
    var sections = Variable([NumberSection]())

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if generateCustomSize {
            let nSections = 10
            let nItems = 100
        
            var sections = [AnimatableSectionModel<String, Int>]()
            
            for i in 0..<nSections {
                sections.append(AnimatableSectionModel(model: "Section \(i + 1)", items: Array(i * nItems ..< (i + 1) * nItems)))
            }
            
            generator = Randomizer(rng: PseudoRandomGenerator(4, 3), sections: sections)
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(randomize(_:)), userInfo: nil , repeats: true)
        
        self.sections.value = generator.sections
        
        let tvAnimatedDataSource = RxTableViewSectionedAnimatedDataSource<NumberSection>()
        let reloadDataSource = RxTableViewSectionedReloadDataSource<NumberSection>()
        
        skinTableViewDataSource(tvAnimatedDataSource)
        skinTableViewDataSource(reloadDataSource)
        
        self.sections.asObservable()
            .bindTo(partialUpdatesTableViewOutlet.rx.items(dataSource: tvAnimatedDataSource))
            .disposed(by: disposebag)
        
        self.sections.asObservable()
            .bindTo(reloadTableViewOutlet.rx.items(dataSource: reloadDataSource))
            .disposed(by: disposebag)
        
        //with some bugs that author thinks its system bugs
//        let cvAnimatedDataSource = RxCollectionViewSectionedAnimatedDataSource<NumberSection>()
//        skinCollectionViewDataSource(cvAnimatedDataSource)
//        updates
//            .bindTo(partialUpdatesCollectionViewOutlet.rx.itemsWithDataSource(cvAnimatedDataSource))
//            .disposed(by: disposeBag)
        
        let cvReloadDataSource = RxCollectionViewSectionedAnimatedDataSource<NumberSection>()
        skinCollectionViewDataSource(cvReloadDataSource)
        self.sections.asObservable()
            .bindTo(partialUpdatesCollectionViewOutlet.rx.items(dataSource: cvReloadDataSource))
            .disposed(by: disposebag)
        
        //touches
        partialUpdatesCollectionViewOutlet.rx.itemSelected
            .subscribe(onNext: { [weak self] i in
                print("Let me guess, it's .... It's \(self?.generator.sections[i.section].items[i.item]), isn't it? Yeah, I've got it.")
            })
            .disposed(by: disposebag)
        
        Observable.of(partialUpdatesTableViewOutlet.rx.itemSelected, reloadTableViewOutlet.rx.itemSelected).merge().subscribe(onNext: { [weak self] i in
            print("touch table view \(self?.generator.sections[i.section].items[i.item])")
        })
            .disposed(by: disposebag)
    }
    
    func skinTableViewDataSource(_ dataSource: TableViewSectionedDataSource<NumberSection>)  {
        dataSource.configureCell = {(_, tv, ip, i) in
            let cell = tv.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
            
            cell.textLabel?.text = "\(i)"
            
            return cell
        }
        dataSource.titleForHeaderInSection = { (ds, section: Int) -> String in
            return dataSource[section].model
            
        }
    }
    
    func skinCollectionViewDataSource(_ dataSource: CollectionViewSectionedDataSource<NumberSection>) {
        dataSource.configureCell = { (_, cv, ip, i) in
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "Cell", for: ip) as! NumberCell
            cell.value.text = "\(i)"
            
            return cell
        }
        
        dataSource.supplementaryViewFactory = { (dataSource, cv, kind, ip) in
            let section = cv.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Section", for: ip) as! NumberSectionView
            section.value.text = "\(dataSource[ip.section].model)"
            return section
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.timer?.invalidate()
    }
    
  
    @IBAction func randomize(_ sender: Any) {
        generator.randomize()
        
        var values = generator.sections
        if PartialUpdatesViewController.firstChange != nil  {
            values = PartialUpdatesViewController.firstChange!
        }
        sections.value = values
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}




























