import UIKit

class OverviewViewController3: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var overview: UITableView!
    @IBOutlet weak var footer: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var btnPreviousMonth: UIButton!
    @IBOutlet weak var btnNextMonth: UIButton!
    @IBOutlet weak var monthText: UILabel!
    
    
    @IBOutlet weak var totalExpensesText: UILabel!
    @IBOutlet weak var totalRevenuesText: UILabel!
    
    private var model = CategoryRepository()
    private var currentType : TransactionType = TransactionType.expense
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overview.delegate = self
        overview.dataSource = self
        updateFooter()
    }
    
    
    
    
    @IBAction func OnChangeType(_ sender: UISegmentedControl) {
        
        switch segmentControl.selectedSegmentIndex
        {
        case 0:
            currentType = .expense
        case 1:
            currentType = .revenue
        default:
            break;
        }
        overview.reloadData()
    }
    
    private func updateFooter() {
        totalExpensesText.text = " \(model.getTotalExpenses())"
        totalRevenuesText.text = "\(model.getTotalRevenues())"
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func viewWillAppear(_ animated: Bool) {
        overview.rowHeight = 95
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(model.expenses.count)
        print(model.revenues.count)
        return currentType == .expense ? model.expenses.count : model.revenues.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "previewTransactionCell", for: indexPath) as! PreviewTransactionCell
        var category:Category
        
        category = currentType == .expense ? model.expenses[indexPath.row] : model.revenues[indexPath.row]
        
        cell.categegoryName.text = "\(category.name)"
        cell.amount.text = "€ \(model.getTotalAmount(of: category))"
        let represenation = model.calcRepresentation(category: category)
        cell.representation.text = "Represens \(represenation.value)%"
        //cell.progressView.transform = cell.progressView.transform.scaledBy(x: 1, y: 10)
        cell.progressView.setProgress(Float(represenation.percent), animated: false)
        cell.progressView.progressTintColor = UIColor().rgbToUIColor(category.color)
        return cell
    }
    /* Overriding this method triggers swipe actions (e.g. swipe to delete) */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            if currentType == .expense {
                model.removeCategoryFromDb(model.expenses[indexPath.row])
                model.expenses.remove(at: indexPath.row)
                
            }
            else {
                model.removeCategoryFromDb(model.revenues[indexPath.row])
                model.revenues.remove(at: indexPath.row)
            }
            updateFooter()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "add":
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.topViewController as! AddViewController
            destination.categoryRepository = model
            print("Go to addViewController")
            
        case "detail":
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.topViewController as! DetailViewController
            let selectedIndex = overview.indexPathForSelectedRow!.row
            destination.category = currentType == .expense ? model.expenses[selectedIndex] : model.revenues[selectedIndex]
            destination.model = model
            print("Go to detailViewController")
        default:
            break
        }
    }
    
    
    @IBAction func unwindFromAdd(_ segue: UIStoryboardSegue){
        let source = segue.source as! AddViewController
        if let category = source.category{
            overview.beginUpdates()
            if(category.type == .expense){
                model.addCategory(category, of: .expense)
                overview.insertRows(at: [IndexPath(row: model.expenses.count - 1, section: 0)], with: .automatic)
                overview.reloadSections(IndexSet(integer: 0), with: .automatic)
            }
            else{
                model.addCategory(category, of: .revenue)
                print(model.revenues.count)
                overview.insertRows(at: [IndexPath(row: model.revenues.count - 1, section: 0)], with: .automatic)
                overview.reloadSections(IndexSet(integer: 0), with: .automatic)
            }
            overview.endUpdates()
            updateFooter()
            overview.reloadData()
        }
    }
    @IBAction func unwindFrommDetail(_ segue: UIStoryboardSegue){
        updateFooter()
        overview.reloadData()
        print("Detail")
    }
    
    
}

