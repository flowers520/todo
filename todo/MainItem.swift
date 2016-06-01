import UIKit

class MainItem:NSObject{
    var text:String
    var checked:Bool
    //提醒时间
    var dueDate:NSDate
    //是否提醒
    var shouldRemind:Bool
    //任务id
    var itemId:Int
    
    init(text:String,checked:Bool,dueDate:NSDate,shouldRemind:Bool){
        self.text=text
        self.checked=checked
        self.dueDate = dueDate
        self.shouldRemind = shouldRemind
        self.itemId = DataModel.nextChecklistItemId()
        print("itemId:\(itemId)")
        super.init()
    }
    func toggleChecked(){
        self.checked = !self.checked
    }
    //从nsobject解析回来
    init(coder aDecoder:NSCoder!){
        self.text=aDecoder.decodeObjectForKey("Text") as! String
        self.checked=aDecoder.decodeObjectForKey("Checked") as! Bool
        self.dueDate = aDecoder.decodeObjectForKey("DueDate") as! NSDate
        self.shouldRemind = aDecoder.decodeObjectForKey("ShouldRemind") as! Bool
        self.itemId = aDecoder.decodeObjectForKey("ItemId") as! Int
    }
    //编码成object
    func encodeWithCoder(aCoder:NSCoder!){
        aCoder.encodeObject(text,forKey:"Text")
        aCoder.encodeObject(checked,forKey:"Checked")
        aCoder.encodeObject(dueDate,forKey:"DueDate")
        aCoder.encodeObject(shouldRemind,forKey:"ShouldRemind")
        aCoder.encodeObject(itemId,forKey:"ItemId")
    }
    
    //发送通知消息
    func scheduleNotification(){
        //通过itemID获取已有的消息推送，然后删除掉，以便重新判断
        let existingNotification = self.notificationForThisItem() as UILocalNotification?
        if existingNotification != nil {
            //如果existingNotification不为nil，就取消消息推送
            UIApplication.sharedApplication().cancelLocalNotification(existingNotification!)
        }

        /*  
            NSComparisonResult.OrderedAscending 表示保存的dueDate比当前时间较早,即过期了
            NSOrderedDescending 保存的dueDate比当前时间晚
            NSOrderedSame 保存的dueDate与当前时间晚相同
        */
        if self.shouldRemind && (self.dueDate.compare(NSDate()) != NSComparisonResult.OrderedAscending ) {
            //创建UILocalNotification来进行本地消息通知
            let localNotification = UILocalNotification()
            //推送时间
            localNotification.fireDate = self.dueDate
            //时区
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            //推送内容
            localNotification.alertBody = self.text
            //声音
            localNotification.soundName = UILocalNotificationDefaultSoundName
            //额外信息
            localNotification.userInfo = ["ItemID":self.itemId]
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            
        }
    }
    //通过遍历所有消息推送，通过itemid的对比，返回UIlocalNotification
    func notificationForThisItem()-> UILocalNotification? {
        let allNotifications = UIApplication.sharedApplication().scheduledLocalNotifications
        for notification in allNotifications! {
            
            var info: Dictionary<String, Int> = notification.userInfo as! Dictionary<String, Int>
            let number = info["ItemID"]
            if number != nil && number == self.itemId {
                return notification
            }
        }
        return nil
    }
    //析构
    deinit{
        //删除该任务的消息推送，如果有的话
        let existingNotification = self.notificationForThisItem() as UILocalNotification?
        if existingNotification != nil {
            UIApplication.sharedApplication().cancelLocalNotification(existingNotification!)
        }
    }
}
