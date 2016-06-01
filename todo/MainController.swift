import UIKit

class MainController: UITableViewController ,MainListControllerDelegate{
    //tableView的数据
    var checklist:Checklist?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.checklist?.name
        print("mainController")

    }
    
    //设置check勾选
    func configureCheckmarkForCell(cell:UITableViewCell,item:MainItem){
        //根据Tag获取cell中的Label
        let label = cell.viewWithTag(1001) as! UILabel
        //通过item中的checked属性来控制勾号是否显示
        if item.checked {
            label.text = "√"
        }else{
            label.text = ""
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //设置table的行数
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return checklist!.items.count
    }
    //设置table的单元格
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //获取cell对应的数据
        let item = checklist!.items[indexPath.row]
        //获取cell
        let cell = tableView.dequeueReusableCellWithIdentifier("maincell", forIndexPath: indexPath) 
        //获取label
        let label = cell.viewWithTag(1000) as! UILabel
        //设置label内容。
        label.text = item.text
        //设置cell的勾选状态
        configureCheckmarkForCell(cell, item:item)
        return cell
    }
    //点击cell的响应方法
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //获得row数据
        let item = checklist!.items[indexPath.row]
        //check属性取反
        item.toggleChecked()
        // 设置cell的勾选框
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        configureCheckmarkForCell(cell!, item:item)
        //取消选中状态
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //滑动删除
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //删除数据
        checklist!.items.removeAtIndex(indexPath.row)
        let indexPaths = [indexPath]
        //通知视图删除的数据，同时显示删除动画
        tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    //返回删除
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "删"
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        })
    }
    
    //界面跳转时
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let segueStr = "\(segue.identifier!)"
        print("segue:\(segueStr)")
        if segueStr == "AddItem" {
            //通过segue的标识获得导航控制器
            let navigationController = segue.destinationViewController as! UINavigationController
            //通过导航控制器的topViewController属性获得跳转目标
            let controller = navigationController.topViewController as! MainListController
            //设置代理
            controller.delegate = self
            print("\(controller)|\(self)")
        }else if segueStr == "EditItem" {
            //如果是通过EditItem的segue跳转则
            //获取导航控制器
            let navigationController = segue.destinationViewController as! UINavigationController
            //获取MainListController
            let controller = navigationController.topViewController as! MainListController
            //设置代理
            controller.delegate = self
            //获取indexPath
            let indexPath = self.tableView.indexPathForCell(sender! as! UITableViewCell)
            //将要编辑的Model传给新界面
            controller.itemToEdit = checklist!.items[indexPath!.row]
            
        }
    }
    //关闭添加/编辑任务类别界面
    func addItemDidCancel(controller:MainListController){
        controller.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    //新增数据
    func addItem(controller:MainListController,didFinishAddingItem item:MainItem){
        //获得新数据的索引
        let newRowIndex = checklist!.items.count
        //将数据加入数据源
        checklist!.items.append(item)
        //通过新数据的索引获得indexPath
        let indexPath = NSIndexPath(forRow: newRowIndex, inSection: 0)
        //根据insertRowsAtIndexPaths的参数需求，将indexPath放入一个数组中
        let indexPaths = [indexPath]
        //通知视图，有新增数据。UITableViewRowAnimation有很多动画方式，可以体验一下
        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
        //关闭新界面
        controller.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
    }
    //编辑数据
    func addItem(controller:MainListController,didFinishEditingItem item:MainItem){
        //重载数据
        self.tableView.reloadData()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
