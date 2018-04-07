# LXFProtocolTool
[![Version](https://img.shields.io/cocoapods/v/LXFProtocolTool.svg?style=flat)](http://cocoapods.org/pods/LXFProtocolTool)
[![License](https://img.shields.io/cocoapods/l/LXFProtocolTool.svg?style=flat)](http://cocoapods.org/pods/LXFProtocolTool)
[![Platform](https://img.shields.io/cocoapods/p/LXFProtocolTool.svg?style=flat)](http://cocoapods.org/pods/LXFProtocolTool)

通过协议的方式来方便快捷地实现一些的实用功能，目前功能不多，往后会逐渐增加，喜欢的来个Star吧 : )

对Swift协议不熟悉的同学可以阅读以下两篇文章做下了解:

[iOS - Swift 面向协议编程（一）](https://juejin.im/post/59ee05346fb9a0452845a7e8)

[iOS - Swift 面向协议编程（二）](https://juejin.im/post/59ee05846fb9a0451329dd52)

## Update

版本 | 更新内容
-|-
0.1.0| * xib便捷加载<br> * scrollView空白页显示(依赖DZNEmptyDataSet)

## CocoaPods

LXFProtocolTool 支持CocoaPods:

- 完全安装
```ruby
pod 'LXFProtocolTool'
```

当然，也可以根据自己的需要安装指定子库

- Xib加载
```
pod 'LXFProtocolTool/LXFNibloadable'
```

- 空白视图
```
pod 'LXFProtocolTool/LXFEmptyDataSetable'
```

## Example

- LXFNibloadable

1、View遵守协议LXFNibloadable
```
class LXFXibTestView: UIView, LXFNibloadable {
}
```
2、通过静态方法`loadFromNib()`创建View
```
let view = LXFXibTestView.loadFromNib()
```

- LXFEmptyDataSetable

1、UIViewControllor或UIView遵守协议LXFEmptyDataSetable
```
extension LXFEmptyDemoController: LXFEmptyDataSetable {
}
```

2、调用方法`lxf_EmptyDataSet()`
```
// 简单方式
lxf_EmptyDataSet(tableView)

// 定制方式
lxf_EmptyDataSet(tableView) { () -> ([LXFEmptyDataSetAttributeKeyType : Any]) in
    return [
        .tipStr:"数据不见了",
        .verticalOffset:-150,
        .allowScroll: false
    ]
}
```


## License

LXFProtocolTool is available under the MIT license. See the LICENSE file for more info.

## Author
- LinXunFeng
- email: [598600855@qq.com](mailto:598600855@qq.com)
- Blogs
    - [linxunfeng.top](http://linxunfeng.top/)
    - [掘金](https://juejin.im/user/58f8065e61ff4b006646c72d/posts)
    - [简书](https://www.jianshu.com/u/31e85e7a22a2)