# LXFProtocolTool
[![Version](https://img.shields.io/cocoapods/v/LXFProtocolTool.svg?style=flat)](http://cocoapods.org/pods/LXFProtocolTool)
[![License](https://img.shields.io/cocoapods/l/LXFProtocolTool.svg?style=flat)](http://cocoapods.org/pods/LXFProtocolTool)
[![Platform](https://img.shields.io/cocoapods/p/LXFProtocolTool.svg?style=flat)](http://cocoapods.org/pods/LXFProtocolTool)

通过协议的方式来方便快捷地实现一些的实用功能，目前功能不多，往后会逐渐增加，喜欢的来个Star吧 : )

对Swift协议不熟悉的同学可以阅读以下两篇文章做下了解:

[iOS - Swift 面向协议编程（一）](https://juejin.im/post/59ee05346fb9a0452845a7e8)

[iOS - Swift 面向协议编程（二）](https://juejin.im/post/59ee05846fb9a0451329dd52)

## CocoaPods

LXFProtocolTool 支持CocoaPods:

- 完全安装
```ruby
pod 'LXFProtocolTool'
```

当然，也可以根据自己的需要安装指定子库

- Xib加载
```ruby
pod 'LXFProtocolTool/LXFNibloadable'
```

- 空白视图
```ruby
pod 'LXFProtocolTool/EmptyDataSetable'
```

- 刷新控件

```ruby
pod 'LXFProtocolTool/Refreshable'
```

- 关联属性

```ruby
pod 'LXFProtocolTool/AssociatedObjectStore'
```



## Usage

详细使用请打开Example工程查看，以下只做简要使用说明

- LXFNibloadable

1、~~View遵守协议LXFNibloadable~~  不用自己手动遵守，这步跳过
```swift
class LXFXibTestView: UIView, LXFNibloadable { }
```
2、通过静态方法`loadFromNib()`创建View
```swift
let view = LXFXibTestView.loadFromNib()
```



** 新增tableView和collectionView的与xib相关的方法，如

```swift
// 注册 cell
tableView.registerCell(LXFCustomCell.self)
// 注册 headerFooterView
tableView.registerHeaderFooterView(LXFCustomHeaderView.self)

// 其它方法请自己去 LXFNibloadable.swift 中查看吧
```



<br>

- EmptyDataSetable

1、UIViewControllor或UIView遵守协议 `EmptyDataSetable`
```swift
extension LXFEmptyDemoController: EmptyDataSetable {
}
```

2、调用方法 `updateEmptyDataSet`

```swift
// 定制方式
// config 不传值时使用默认配置
self.lxf.updateEmptyDataSet(tableView, config: EmptyConfig.noData)
```
![lxf_EmptyDataSet](https://github.com/LinXunFeng/LXFProtocolTool/raw/master/Screenshots/lxf_EmptyDataSet.png)



3、 更新定制

```swift
// 更新空白页数据
var config = EmptyConfig.normal
config.tipStr = tipStrArr[randomInt]
config.tipImage = UIImage(named: "tipImg\(randomInt)")

self.lxf.updateEmptyDataSet(tableView, config: config)
```

![lxf_EmptyDataSet_update](https://github.com/LinXunFeng/LXFProtocolTool/raw/master/Screenshots/lxf_EmptyDataSet.gif)

- Refreshable

1、遵守协议 `Refreshable`

```swift
class LXFRefreshableController: UIViewController, View, Refreshable {}
```

2、配置与绑定

```swift
// 自定义配置
/* 
initRefresh<T: RefreshControllable>(
	_ vm: T, 
	_ scrollView: UIScrollView, 
	headerConfig: RefreshableHeaderConfig? = nil, 
	footerConfig: RefreshableFooterConfig? = nil, 
	headerAction: (() -> Void)? = nil, footerAction: (() -> Void)? = nil
)
*/

// 注：vm 需要传入一个遵守了 RefreshControllable 协议的对象

lxf.initRefresh(reactor, tableView, headerConfig: RefreshConfig.normalHeader, headerAction: { 
    reactor.action.onNext(.fetchList(true))
}) {
    reactor.action.onNext(.fetchList(false))
}.disposed(by: disposeBag)
```

3、viewModel 遵守协议 

```swift
final class LXFRefreshableReactor: Reactor, RefreshControllable {}
```

遵守协议  `RefreshControllable` 后便拥有 `refreshStatus` 属性，可以用来控制刷新控件的状态

```swift
self.lxf.refreshStatus.value = .noMoreData
self.lxf.refreshStatus.value = .resetNoMoreData
```

![lxf_EmptyDataSet_update](https://github.com/LinXunFeng/LXFProtocolTool/raw/master/Screenshots/lxf_Refreshable.gif)




## License

LXFProtocolTool is available under the MIT license. See the LICENSE file for more info.

## Author
- LinXunFeng
- email: [598600855@qq.com](mailto:598600855@qq.com)
- Blogs
    - [linxunfeng.top](http://linxunfeng.top/)
    - [掘金](https://juejin.im/user/58f8065e61ff4b006646c72d/posts)
    - [简书](https://www.jianshu.com/u/31e85e7a22a2)

