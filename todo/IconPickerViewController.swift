import UIKit

class IconPickerViewController: UITableViewController {
    //协议代理
    var delegate:IconPickerViewControllerDelegate?
    var icons = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        //所有的图标名称
        icons.append("分享")
        icons.append("货运")
        icons.append("记录")
        icons.append("旅行")
        icons.append("提醒")
        icons.append("天气")
        icons.append("卫生")
        icons.append("文件")
        icons.append("心情")
        icons.append("无图")

    }

    //返回数据行数
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return icons.count
    }
    //设置cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //获取cell
        let cell = tableView.dequeueReusableCellWithIdentifier("iconCell")
        //获取图标名称
        let icon = icons[indexPath.row]
        //设置标题为图标名称
        cell!.textLabel!.text = icon
        //根据图标名称设置缩略图
        cell!.imageView!.image = UIImage(named: icon)
        return cell!
    }
    
    //选择图标后
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //获取图标name
        let iconName = icons[indexPath.row]
        self.delegate?.iconPicker(self, didPickIcon: iconName)
    }
    
    //cell动画
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }

}


//用于回调选择了图标的方法
protocol IconPickerViewControllerDelegate{
    func iconPicker(picker:IconPickerViewController, didPickIcon iconName:String)
}
