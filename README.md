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
0.2.0 | *  AssociatedObjectStore 动态存储属性协议 
0.1.2| *  LXFNibloadable 不再需要手动遵守协议，增加了多种nib加载 
0.1.1| * LXFEmptyDataSetable 添加点击事件回调方法，提供更新数据入口 
0.1.0| * xib便捷加载<br> * scrollView空白页显示(依赖DZNEmptyDataSet) 

## CocoaPods

LXFProtocolTool 支持CocoaPods:

- 完全安装
```ruby
pod 'LXFProtocolTool'
```

当然，也可以根据自己的需要安装指定子库

- Xib加载
```
pod 'LXFProtocolTool/LXFNibloadable'
```

- 空白视图
```
pod 'LXFProtocolTool/LXFEmptyDataSetable'
```

## Example

详细使用请打开Example工程查看，以下做简要使用说明

- LXFNibloadable

1、~~View遵守协议LXFNibloadable~~  不用自己手动遵守，这步跳过
```
class LXFXibTestView: UIView, LXFNibloadable {
}
```
2、通过静态方法`loadFromNib()`创建View
```
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
        .tipStr:"哟哟哟",
        .verticalOffset:-150,
        .allowScroll: false
    ]
}
```
![lxf_EmptyDataSet](https://github.com/LinXunFeng/LXFProtocolTool/raw/master/Screenshots/lxf_EmptyDataSet.png)



3、 更新定制

```swift
lxf_updateEmptyDataSet(tableView) { () -> ([LXFEmptyDataSetAttributeKeyType : Any]) in
    return [
        .tipStr:"更新提示语"
    ]
}
```

![lxf_EmptyDataSet_update](https://github.com/LinXunFeng/LXFProtocolTool/raw/master/Screenshots/lxf_EmptyDataSet.gif)



**占位图可以使用定制方式的`.tipImage`来指定，也可以丢指定名字`LXFEmptyDataPic`的图片到工程的Images.xcassets中 




## License

LXFProtocolTool is available under the MIT license. See the LICENSE file for more info.

## Author
- LinXunFeng
- email: [598600855@qq.com](mailto:598600855@qq.com)
- Blogs
    - [linxunfeng.top](http://linxunfeng.top/)
    - [掘金](https://juejin.im/user/58f8065e61ff4b006646c72d/posts)
    - [简书](https://www.jianshu.com/u/31e85e7a22a2)