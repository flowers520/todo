
import UIKit

class MainListController: UITableViewController ,UITextFieldDelegate{
    
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var switchControl: UISwitch!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var delegate : MainListControllerDelegate?
    
    var itemToEdit:MainItem?
    
    var dueDate:NSDate?

    //日期选择器显示状态
    var datePickerVisible:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置文本框的代理为当前类，以便响应文本框内容的变化
        textField.delegate = self
        
        //通过itemToEdit是否接收了参数来判断是添加新数据还是修改数据
        if itemToEdit != nil {
            self.title = "编辑任务"
            self.textField.text = itemToEdit?.text
            self.doneButton.enabled = true
            switchControl.on=itemToEdit!.shouldRemind
            dueDate = self.itemToEdit?.dueDate
        }else{
            //生成数据时switch控件默认是关闭状态
            self.switchControl.on = false
            dueDate = NSDate()
        }
        //默认显示当前时间
        upDateDueDateLabel()

    }
    //显示日期选择器
    func showDatePicker(){
        //日期选择器的状态设为打开
        datePickerVisible = true
        
        let indexPathDatePicker = NSIndexPath(forRow: 2, inSection: 1)
        self.tableView.insertRowsAtIndexPaths([indexPathDatePicker], withRowAnimation: UITableViewRowAnimation.Automatic)

    }
    //关闭日期选择器
    func hideDatePicker(){
        if datePickerVisible {
            //日期选择器的状态设为关闭
            datePickerVisible = false
            
            let indexPathDatePicker = NSIndexPath(forRow: 2, inSection: 1)
            self.tableView.deleteRowsAtIndexPaths([indexPathDatePicker], withRowAnimation: UITableViewRowAnimation.Fade)

        }
    }
    
    //Cancel按钮响应方法
    @IBAction func cancel(sender: AnyObject) {
        delegate?.addItemDidCancel(self)
        
    }
    //Done按钮响应方法
    @IBAction func done(sender: AnyObject) {
        if self.itemToEdit == nil {
            //itemToEdit为nil执行新增数据代码
            let item = MainItem(text: textField.text!,checked: false,dueDate:self.dueDate!,shouldRemind:self.switchControl.on)
            item.scheduleNotification()
            delegate?.addItem(self, didFinishAddingItem: item)
        }else{
            //itemToEdit不是nil，执行编辑数据代码
            //同时修改数据中的text为文本框编辑后的内容
            self.itemToEdit?.text = self.textField.text!
            self.itemToEdit?.shouldRemind = self.switchControl.on
            self.itemToEdit?.dueDate = self.dueDate!
             self.itemToEdit?.scheduleNotification()
            delegate?.addItem(self, didFinishEditingItem: self.itemToEdit!)
        }
    }

    //为了对应静态的cell，由于有两个section，所以要分别判断
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1  && datePickerVisible{
            return 3
        }else{
            return super.tableView(tableView, numberOfRowsInSection: section)
            
        }
    }
    //设置cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //因为日期选择器的位置在日期显示Label下面。它的位置就是第2个section  和第3个row
        if indexPath.section == 1 && indexPath.row == 2{
            //用重用的方式获取标识为DatePickerCell的cell
            var cell = tableView.dequeueReusableCellWithIdentifier("DatePickerCell") 
            //如果没找到就创建一个
            if cell == nil {
                //创建一个标识为DatePickerCell的cell
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "DatePickerCell")
                //设置cell的样式
                cell?.selectionStyle = UITableViewCellSelectionStyle.None
                //创建日期选择器
                let datePicker = UIDatePicker(frame: CGRectMake(0.0, 0.0, 320.0, 216.0))
                //给日期选择器的tag
                datePicker.tag = 100
                //将日期选择器加入cell
                cell?.contentView.addSubview(datePicker)
                //注意：action里面的方法名后面需要加个冒号“：”
                datePicker.addTarget(self, action: "dateChanged:", forControlEvents: UIControlEvents.ValueChanged)
            }
            return cell!
        }else{
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    
    func dateChanged(datePicker : UIDatePicker){
        //改变dueDate
        self.dueDate = datePicker.date
        //更新提醒时间文本框
        upDateDueDateLabel()
    }
    //选择cell的row之后
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        textField.resignFirstResponder()
        //当执行到日期选择器上一行的时候，可以判断是否要显示日期选择器了
        if indexPath.section == 1 && indexPath.row == 1{
            if !datePickerVisible{
                self.showDatePicker()
            }else{
                self.hideDatePicker()
            }
        }
    }
    //因为日期选择器插入后会引起cell高度的变化，所以要重新设置
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //当渲染到达日期选择器所在的cell的时候将cell的高度设为217
        if indexPath.section == 1 && indexPath.row == 2{
            return 217.0
        }else{
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    //当覆盖了静态的cell数据源方法时需要提供一个代理方法。因为数据源对新加进来的日期选择器的cell一无所知，所以要使用这个代理方法
    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        if indexPath.section == 1 && indexPath.row == 2{
            let newIndexPath = NSIndexPath(forRow: 0, inSection: indexPath.section)
            return super.tableView(tableView, indentationLevelForRowAtIndexPath: newIndexPath)
        }else{
            return super.tableView(tableView, indentationLevelForRowAtIndexPath: indexPath)
        }
    }
    
    
    //此方法是当界面跳转到当前界面但还没有显示其中内容是执行的任务
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //让文本框称为当前的焦点（第一响应者）
        textField.becomeFirstResponder()
    }
    //textfield将要改变的时候响应的函数
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        //获取到文本框内最新的文本
        let newText = textField.text!.stringByReplacingCharactersInRange(range.toRange(textField.text!), withString: string)
        //通过计算文本框内的字符数来决定done按钮是否激活
        doneButton.enabled = newText.characters.count > 0
        return true
    }
    //更新显示时间的Label
    func upDateDueDateLabel(){
        let formatter = NSDateFormatter()
        //日期样式
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        self.dueDateLabel.text = formatter.stringFromDate(self.dueDate!)
    }
    //当编辑任务名称时关闭日期选择器
    func textFieldDidBeginEditing(textField: UITextField) {
        self.hideDatePicker()
    }


}

//写个代理协议，用于回调
protocol MainListControllerDelegate {
    func addItemDidCancel(controller:MainListController)
    func addItem(controller:MainListController,didFinishAddingItem item:MainItem)
    func addItem(controller:MainListController,didFinishEditingItem item:MainItem)
}
//扩展NSRange，让swift的string能使用stringByReplacingCharactersInRange
extension NSRange {
    func toRange(string: String) -> Range<String.Index> {
        let startIndex = string.startIndex.advancedBy(self.location)
        let endIndex = startIndex.advancedBy(self.length)
        return startIndex..<endIndex
    }
}
