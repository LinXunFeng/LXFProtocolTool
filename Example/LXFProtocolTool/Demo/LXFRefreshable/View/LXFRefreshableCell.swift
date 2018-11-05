//
//  LXFRefreshableCell.swift
//  LXFProtocolTool_Example
//
//  Created by LinXunFeng on 2018/8/1.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import ReactorKit
import RxSwift

class LXFRefreshableCell: UITableViewCell, View {
    
    var disposeBag = DisposeBag()
    
    // MARK:- UI
    fileprivate let picView = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.contentMode = .scaleAspectFit
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(picView)
        picView.frame = CGRect(x: 0, y: 10, width: UIScreen.main.bounds.size.width, height: 250)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: LXFRefreshableCellReactor) {
        reactor.state.map { $0.model.url }
            .subscribe(onNext: { [weak self] url in
            self?.picView.setImage(with: URL(string: url))
        }).disposed(by: disposeBag)
    }
}
