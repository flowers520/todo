import UIKit

class AllListViewController: UITableViewController,ListDetailViewControllerDelegate , UINavigationControllerDelegate{
    //tableView数据源
    var dataModel:DataModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        dataModel?.loadChecklistItems()
        print("沙盒文件夹路径：\(dataModel!.documentsDirectory())")
        print("数据文件路径：\(dataModel!.dataFilePath())")

    }

    //视图出现之前
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //tableView重载数据
        tableView.reloadData()
    }
    
    //控制器切换回主界面会调用的方法，在showchecklist后记录checklistIndex 如果非-1（在checklist界面奔溃或者后台运行被清除） 则直接跳转到checklist
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.delegate = self
        let index = dataModel!.indexOfSelectedChecklist()
        //不光检查index = -1 ，还要检查index的编号是否有效，避免跳转时checklist不存在的情况
        if index >= 0 && index < dataModel?.lists.count {
            let checklist = self.dataModel?.lists[index]
            self.performSegueWithIdentifier("ShowChecklist", sender: checklist)
        }
    }
    
    //设置tableview的行数
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel!.lists.count
    }
    //设置cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //为cell设置Identifier
        let cellIdentifier = "Cell"
        //依据Identifier重用Cell
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) 
        //如果cell为nil就生成Identifier为Cell的cell
        if cell == nil {
            //UITableViewCellStyle选择Subtitle可以有子标题
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellIdentifier)
        }
        //设置cell的标题
        cell?.textLabel!.text = dataModel!.lists[indexPath.row].name
        //设置cell的类别
        cell!.accessoryType = UITableViewCellAccessoryType.DetailDisclosureButton
        
        //获取选中任务类别的任务列表数据
        let list = dataModel!.lists[indexPath.row]
        //返回有多少个任务代办需要提醒
        let count = list.countUncheckedItems()
        //根据不同的情况显示不同的副标题
        if list.items.count == 0{
            //如果还没有添加任务
            cell!.detailTextLabel?.text = "还没有添加任务"
        }else{
            if count == 0 {
                cell!.detailTextLabel?.text = "全部搞定"
            }else{
                cell!.detailTextLabel?.text = "还有 \(count) 个任务要完成"
            }
        }
        //设置缩略图
        cell!.imageView!.image = UIImage(named: list.iconName)

        return cell!
    }
    //cell点击跳转
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //将选择的checklist的索引保存进UserDefaults里面
        dataModel!.setIndexOfSelectedChecklist(indexPath.row)
        //获取选中行的数据
        let checklist = dataModel!.lists[indexPath.row]
        //可以将任何东西放入sender,对应prepareForSegue中的sender
        self.performSegueWithIdentifier("ShowChecklist", sender: checklist)
    }
    
    //滑动删除
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //删除数据
        dataModel!.lists.removeAtIndex(indexPath.row)
        let indexPaths = [indexPath]
        //通知视图删除的数据，同时显示删除动画
        tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
        dataModel!.saveCheckLists()
    }
    
    //修改删除按钮文字
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "删"
    }
    
    //设置cell动画
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        /*
            设置cell的显示动画为3d播放
            xy方向缩放的初值为0.1
            设置动画时间为0.25秒， xy方向缩放的最终值为1
        */
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }
    //响应附属按钮
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        //获取导航控制器
        let navigationController = self.storyboard?.instantiateViewControllerWithIdentifier("ListNavigationController") as! UINavigationController
        //获取切换目标
        let controller = navigationController.topViewController as! ListDetailViewController
        //设置目标代理
        controller.delegate=self
        //获取选中行数据
        let checklist = dataModel!.lists[indexPath.row]
        //传递行数据
        controller.checklistToEdit = checklist
        //切换界面
        self.presentViewController(navigationController, animated: true, completion: nil)
        
        
    }
    
    //segue切换，传参
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //判断是否是切换到任务列表
        if segue.identifier == "ShowChecklist" {
            //获取导航控制器
            let navigationController = segue.destinationViewController as! UINavigationController
            //获取切换目标
            let controller = navigationController.topViewController as! MainController
            //给目标赋值
            controller.checklist = sender as? Checklist
        }else if segue.identifier == "AddChecklist" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! ListDetailViewController
            controller.delegate = self
            controller.checklistToEdit = nil
        }
    }
    //取消操作按钮回调的方法
    func listDetailViewControllerDidCancel(controller:ListDetailViewController){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    //增加数据回调的方法
    func listDetailViewController(controller:ListDetailViewController,didFinishAddingChecklist checklist:Checklist){
        
        let newRowIndex = dataModel!.lists.count
        dataModel!.lists.append(checklist)
        dataModel!.sortCheckLists()
        //如果不需要动画可以直接renloadData()
        let indexPath = NSIndexPath(forRow: newRowIndex, inSection: 0)
        //根据insertRowsAtIndexPaths的参数需求，将indexPath放入一个数组中
        let indexPaths = [indexPath]
        //通知视图，有新增数据。UITableViewRowAnimation有很多动画方式，可以体验一下
        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
        
        self.dismissViewControllerAnimated(true, completion: nil)
        dataModel!.saveCheckLists()
    }
    //编辑数据回调的方法
    func listDetailViewController(controller:ListDetailViewController,didFinishEditingChecklist checklist:Checklist){
        dataModel!.sortCheckLists()
        self.tableView.reloadData()
        self.dismissViewControllerAnimated(true, completion: nil)
        dataModel!.saveCheckLists()
    }
    
    /*
    导航控制器要实现的方法
    导航控制器代理所需要的实现的方法
    切回主界面时将ChecklistIndex设为-1
    */
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        //通过判断viewController是否是AllListViewController
        if viewController == self {
            dataModel!.setIndexOfSelectedChecklist(-1)

        }
    }

}
