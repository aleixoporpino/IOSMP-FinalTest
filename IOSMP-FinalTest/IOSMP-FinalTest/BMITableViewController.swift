//  BMITableViewController.swift
//  IOSMP-FinalTest
//  App Description: A simple BMI Calculator using core data
//
//  Created by Jose Aleixo Porpino Filho on 2018-12-13.
//  Student ID 301005491
//
//  Version 1.0.0


import UIKit
import CoreData

class BMITableViewController: UITableViewController {

    // Results of the calculations in coredata
    var resultsController: NSFetchedResultsController<Calculation>!
    let coreDataStack = CoreDataStack()
    
    // Bi Dimensional
    var calculations:[Calculation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Populate all the core data in the array calculations.
        populateCalculationsInArray()
        reloadTableView()
    }
    //Reload the tableview with the new data.
    func reloadTableView() {
        UIView.transition(with: tableView,
                          duration: 0.35,
                          options: .transitionCrossDissolve,
                          animations: { self.tableView.reloadData() })
    }
    
    // Get the core data with sort and push to calculations array
    func populateCalculationsInArray() {
        calculations = []
        let request: NSFetchRequest<Calculation> = Calculation.fetchRequest()
        // sort calculations by date
        let sortDescriptors = NSSortDescriptor(key: "date", ascending: true)
        
        request.sortDescriptors = [sortDescriptors]
        resultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: coreDataStack.manageContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        do {
            try resultsController.performFetch()
            if resultsController.fetchedObjects != nil {
                for c in resultsController.fetchedObjects! {
                    calculations.append(c)
                }
            }
        } catch {
            print("Fetch error ocurred: \(error)")
            return
        }
    }
    
    // Number of sections that the table view will have
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Number of the calculations per section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calculations.count
    }
    
    // Return the cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "calculationCell", for: indexPath)
        
        let calculation = calculations[indexPath.row]
        populate(cell: cell, calculation: calculation)
        return cell
    }
    
    // When swipe to the right will show the Delete button
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") {
            (action, view, completion) in
            
            let calculationselected:Calculation = self.calculations[indexPath.row]
            
            self.resultsController.managedObjectContext.delete(calculationselected)
            do {
                try self.resultsController.managedObjectContext.save()
                self.calculations.remove(at: indexPath.row)
                self.reloadTableView()
                completion(true)
            } catch {
                print("Error when try to delete: \(error)")
                completion(false)
            }
        }
        action.backgroundColor = UIColor(rgb:0x941100)
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    // Show the details or add new calculation screen
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowAddNewBMICalculation", sender: tableView.cellForRow(at: indexPath))
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = sender as? UIBarButtonItem, let vc = segue.destination as? AddBMIViewController {
            vc.managedContext = resultsController.managedObjectContext
        }
        
        if let cell = sender as? UITableViewCell, let vc = segue.destination as? AddBMIViewController {
            vc.managedContext = resultsController.managedObjectContext
            if let indexPath = tableView.indexPath(for: cell) {
                let calculation = calculations[indexPath.row]
                vc.calculation = calculation
            }
        }
    }
    
    // set the cell components according to the calculation
    func populate(cell: UITableViewCell, calculation:Calculation) {
        
        cell.textLabel!.font = UIFont(name:"System", size: 17.0)
        cell.detailTextLabel!.font = UIFont(name:"System", size: 13.0)
        
        cell.textLabel?.text = calculation.name ?? ""
        cell.detailTextLabel?.text = calculation.category
        
        if let date = calculation.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            dateFormatter.locale = Locale(identifier: "en_CA")
            dateFormatter.dateFormat = "d MMM yyyy"
            
            let label = UILabel.init(frame: CGRect(x:0,y:0,width:100,height:20))
            label.text = dateFormatter.string(from: date)
            label.font = UIFont(name:"System", size: 13.0)
            label.textColor = .white
            cell.accessoryView = label
        } else {
            cell.accessoryView = nil
        }
    }
}


// RGB converter
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }

}
