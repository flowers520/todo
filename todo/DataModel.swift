import UIKit

class DataModel: NSObject {
    //数据源
    var lists = [Checklist]()
    override init() {
        super.init()
        self.loadChecklistItems()
        self.registerDefaults()
        
    }
    //保存数据文件
    func saveCheckLists(){
        let data = NSMutableData()
        /*
            申明一个归档处理对象
            将lists以对应checklist关键字进行编码
            编译结束
            数据写入
        */
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject( lists, forKey: "Checklist")
        archiver.finishEncoding()
        data.writeToFile(dataFilePath(), atomically: true)
    }
    //获取沙盒文件夹路径
    func documentsDirectory()->String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentationDirectory,NSSearchPathDomainMask.UserDomainMask,true)
        let documentsDirectory: String = paths.first! as String
        return documentsDirectory
    }
    //获取数据文件地址
    func dataFilePath ()->String{
        return self.documentsDirectory().stringByAppendingString("Checklists.plist")
    }

    
    //读取数据文件
    func loadChecklistItems(){
        //获取本地数据文件地址
        let path = self.dataFilePath()
        //声明文件管理器
        let defaultManager = NSFileManager()
        //通过文件地址判断数据文件是否存在
        if defaultManager.fileExistsAtPath(path) {
            //读取文件数据
            let data = NSData(contentsOfFile: path)
            //解码器
            let unarchiver = NSKeyedUnarchiver(forReadingWithData: data!)
            //通过归档时设置的关键字Checklist还原lists
            lists = unarchiver.decodeObjectForKey("Checklist") as! Array
            //结束解码
            unarchiver.finishDecoding()
        }else{
            //如果文件不存在，则是第一次安装该应用，创建一个checklist
            let checklist = Checklist(name: "你猜我猜不猜")
            lists.append(checklist)
            saveCheckLists()
        }
    }
    //给“ChecklistIndex” 设置默认值，防止奔溃
    func registerDefaults(){
        let dictionary : Dictionary<String,Int> = ["ChecklistIndex":-1]
        NSUserDefaults.standardUserDefaults().registerDefaults(dictionary)
        
    }

    //获取ChecklistIndex的值
    func indexOfSelectedChecklist()->Int{
        return NSUserDefaults.standardUserDefaults().integerForKey("ChecklistIndex")
    }
    //设置ChecklistIndex的值
    func setIndexOfSelectedChecklist(index:Int){
        NSUserDefaults.standardUserDefaults().setInteger(index, forKey: "ChecklistIndex")
    }
    
    //对lists进行排序
    func sortCheckLists(){
        lists.sortInPlace(onSort)
    }
    //字符比较排序法
    func onSort(s1:Checklist,s2:Checklist)->Bool{
        return s1.name > s2.name
    }
    
    //获得itemid
    class func nextChecklistItemId()->Int{
        let userDefaults = NSUserDefaults.standardUserDefaults()
        //获取ChecklistItemId值
        let itemId = userDefaults.integerForKey("ChecklistItemId")
        //+1后保存ChecklistItemId值
        userDefaults.setInteger(itemId+1, forKey: "ChecklistItemId")
        //强制要求userDefaults立即保存
        userDefaults.synchronize()
        return itemId
    }
}
