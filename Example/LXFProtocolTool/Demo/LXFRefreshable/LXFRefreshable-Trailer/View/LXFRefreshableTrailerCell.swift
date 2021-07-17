//
//  LXFRefreshableTrailerCell.swift
//  LXFProtocolTool_Example
//
//  Created by LinXunFeng on 2021/7/17.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import ReactorKit
import RxSwift

class LXFRefreshableTrailerCell: UICollectionViewCell, View {
    
    var disposeBag = DisposeBag()
    
    // MARK:- UI
    fileprivate let picView = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.contentMode = .scaleAspectFill
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(picView)
        picView.frame = self.bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: LXFRefreshableCellReactor) {
        reactor.state.map { $0.model.url }
            .map { URL(string: $0) }
            .bind(to: self.picView.rx.image(options: []))
            .disposed(by: disposeBag)
    }
}
