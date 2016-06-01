

import UIKit

class ListDetailViewController: UITableViewController,UITextFieldDelegate , IconPickerViewControllerDelegate{
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var iconImageView: UIImageView!
    var delegate:ListDetailViewControllerDelegate?
    var checklistToEdit:Checklist?
    //保存图标名称
    var iconName:String = "提醒"
    override func viewDidLoad() {
        super.viewDidLoad()
        //通过checklistToEdit是否为nil来判断是增加数据还是编辑数据
        //从而设置导航栏的标题
        if checklistToEdit != nil {
            self.title = "编辑任务类型"
            textField.text = checklistToEdit!.name
            doneButton.enabled = true
            //设置图标
            iconImageView.image=UIImage(named: checklistToEdit!.iconName)
            iconName = checklistToEdit!.iconName
        }else{
            iconImageView.image=UIImage(named: "提醒")
        }
        textField.delegate = self

    }

    //切换界面后，让文本框获得焦点
    func viewVillApprear(animated:Bool){
        super.viewWillAppear(animated)
        self.textField.becomeFirstResponder()
    }

    //与静态的cell相对应
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    //Done按钮响应方法
    @IBAction func done(sender: AnyObject) {
        //如果checklistToEdit为nil，说明是增加数据
        if self.checklistToEdit == nil {
            let checklist = Checklist(name: textField.text!)
            checklist.iconName = iconName
            delegate?.listDetailViewController(self, didFinishAddingChecklist: checklist)
        }else{
            //如果checklistToEdit不为nil，说明是编辑数据
            checklistToEdit?.name = self.textField.text!
            checklistToEdit?.iconName = iconName
            delegate?.listDetailViewController(self, didFinishEditingChecklist: checklistToEdit!)
        }
    }
    //Cancel按钮响应方法
    @IBAction func cancel(sender: AnyObject) {
        delegate?.listDetailViewControllerDidCancel(self)
    }
    
    //响应文本框变化
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        //获取到文本框内最新的文本
        let newText = textField.text!.stringByReplacingCharactersInRange(range.toRange(textField.text!), withString: string)
        //通过计算文本框内的字符数来决定done按钮是否激活
        doneButton.enabled = newText.characters.count > 0
        return true
    }
    
    //iconpicker代理需要实现的方法
    func iconPicker(picker:IconPickerViewController, didPickIcon iconName:String){
        //修改当前的iconName的图标name
        self.iconName = iconName
        //设置缩略图
        self.iconImageView.image = UIImage(named: iconName)
        //关闭选择图标界面
        self.navigationController?.popViewControllerAnimated(true)
    }
    //检测界面切换
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //如果segue的标识是PickIcon，就是往选择图标跳转
        if segue.identifier == "PickIcon" {
            //获取切换目标
            let controller = segue.destinationViewController as! IconPickerViewController
            //设置代理
            controller.delegate = self
        }
    }
}
//协议
protocol ListDetailViewControllerDelegate{
    func listDetailViewControllerDidCancel(controller:ListDetailViewController)
    func listDetailViewController(controller:ListDetailViewController,didFinishAddingChecklist checklist:Checklist)
    func listDetailViewController(controller:ListDetailViewController,didFinishEditingChecklist checklist:Checklist)
}