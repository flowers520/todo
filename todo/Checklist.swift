import UIKit

class Checklist: NSObject {
    var name:String = ""
    var items = [MainItem]()
    var iconName:String = "记录"
    init(name:String){
        super.init()
        self.name = name
    }
    //从nsobject解析回来
    init(coder aDecoder:NSCoder!){
        self.name=aDecoder.decodeObjectForKey("Name") as! String
        self.items=aDecoder.decodeObjectForKey("Items") as! [MainItem]
        self.iconName=aDecoder.decodeObjectForKey("IconName") as! String
    }
    //编码成object
    func encodeWithCoder(aCoder:NSCoder!){
        aCoder.encodeObject(name,forKey:"Name")
        aCoder.encodeObject(items,forKey:"Items")
        aCoder.encodeObject(iconName,forKey:"IconName")
    }
    //计算Checklist 还有多少item没有勾选，也就是还没办需要提醒
    func countUncheckedItems()->Int{
        var count = 0
        for item in items {
            if item.checked != true {
                count++
            }
        }
        return count
    }
}
