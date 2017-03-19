//
//  RVFirstViewHeaderCell.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 1/3/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit
protocol RVFirstViewHeaderCellDelegate: class {
    func expandCollapseButtonTouched(view: RVFirstViewHeaderCell) -> Void
}
class RVFirstViewHeaderCell: UITableViewHeaderFooterView {
    static let identifier = "RVFirstViewHeaderCell"
    weak var datasource: RVBaseDataSource? = nil
    var datasourceType: RVBaseDataSource.DatasourceType = .unknown
    var model: RVBaseModel? = nil {
        didSet {
            configureContentView()
        }
    }
    func configureContentView() {
        if let view = actualContentView {
            var section = -1
            var collapsed = false
            if let datasource = self.datasource {
                if datasource.collapsed { collapsed = true }
                if let manager = datasource.manager {
                    section = manager.section(datasource: datasource)
                }
            }
            view.configure(model: self.model, collapsed: collapsed, section: section)
        }
    }
    var delegate: RVFirstViewHeaderCellDelegate? = nil
    @IBOutlet weak var titleLabel: UILabel!
    weak var actualContentView: RVFirstHeaderContentView?
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        loadHeaderFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadHeaderFromNib()
    }
    
    func configure(model: RVBaseModel?, datasource: RVBaseDataSource? = nil) {
        self.datasource = datasource
        self.model = model
        if let datasource = self.datasource {
            if datasource.collapsed {
                
            }
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.datasource = nil
        self.model = nil
        self.datasourceType = .unknown
    }
    func loadHeaderFromNib() {
        let bundle = Bundle(for: RVFirstHeaderContentView.self)
        let nib = UINib(nibName: "RVFirstHeaderContentView", bundle: bundle)
        if let view = nib.instantiate(withOwner: self, options: nil)[0] as? RVFirstHeaderContentView {
            view.frame = self.contentView.bounds
            self.contentView.addSubview(view)
            view.delegate = self
            self.actualContentView = view
        }
    }
    
}
extension RVFirstViewHeaderCell: RVFirstHeaderContentViewDelegate {
    func expandCollapseButtonTouched(button: UIButton) -> Void {
        //print("In \(self.classForCoder).expandCollapseButtonTouched")
        if let delegate = delegate {
            delegate.expandCollapseButtonTouched(view: self)
        }
        configureContentView()
    }
}
