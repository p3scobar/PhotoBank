//
//  OrderConfirmController.swift
//  Sparrow
//
//  Created by Hackr on 9/9/19.
//  Copyright © 2019 Sugar. All rights reserved.
//

import UIKit
import stellarsdk

class OrderConfirmController: UITableViewController {
    
    var numberCell = "numberCell"
    var token: Token
    var side: TransactionType
    var amount: Decimal
    var price: Decimal
    var total: Decimal
    
    
    init(token: Token, side: TransactionType, amount: Decimal, price: Decimal, total: Decimal) {
        self.token = token
        self.side = side
        self.amount = amount
        self.price = price
        self.total = total
        super.init(style: .grouped)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = side.rawValue.capitalized
        tableView.isScrollEnabled = true
        tableView.alwaysBounceVertical = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.register(InputNumberCell.self, forCellReuseIdentifier: numberCell)
        tableView.tableFooterView = footer
        
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: numberCell, for: indexPath) as! InputNumberCell
        cell.key = indexPath.row
        setupCell(indexPath: indexPath.row, cell: cell)
        return cell
    }
    
    
    func setupCell(indexPath: Int, cell: InputNumberCell) {
        cell.key = indexPath
        cell.valueInput.isEnabled = false
        let assetCode = baseAsset.assetCode ?? ""
        switch indexPath {
        case 0:
            cell.textLabel?.text = "Amount"
            cell.valueInput.text = "\(amount)"
        case 1:
            cell.textLabel?.text = "Price"
            cell.valueInput.text = price.rounded(2) + " \(assetCode)"
        case 2:
            cell.textLabel?.text = "Total"
            cell.valueInput.text = total.rounded(2) + " \(assetCode)"
        default:
            break
        }
        
    }
    
    
    func calculateTotals() {
        total = amount*price
        tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    
    func presentAlertController(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let done = UIAlertAction(title: "Done", style: .default, handler: nil)
        alert.addAction(done)
        present(alert, animated: true, completion: nil)
    }
    
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    lazy var footer: ButtonTableFooterView = {
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100)
        let view = ButtonTableFooterView(frame: frame, title: "Submit Order")
        view.delegate = self
        return view
    }()
    
    
    @objc func handleConfirm() {
        if side == .buy {
            handleBuy()
        }
        
        if side == .sell {
            handleSell()
        }
    }
    
    func handleBuy() {
        guard let n: Int32 = Int32("100"),
            let d: Int32 = Int32("\(price*100)") else { return }
        let p = Price(numerator: n, denominator: d)
        let amount = total
        
        submitOffer(buy: token, sell: baseAsset, amount: amount, price: p)
    }
    
    
    func handleSell() {
        guard let n: Int32 = Int32("\(price*100)"),
            let d: Int32 = Int32("100") else { return }
        let p = Price(numerator: n, denominator: d)
        
        submitOffer(buy: baseAsset, sell: token, amount: amount, price: p)
    }
    
    
    func submitOffer(buy: Token, sell: Token, amount: Decimal, price: Price) {
        
        let buying = buy.toRawAsset()
        let selling = sell.toRawAsset()

        OrderService.offer(buy: buying, sell: selling, amount: amount, price: price) { success in
            DispatchQueue.main.async {
                if success == true {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    ErrorPresenter.showError(message: "Order Failed", on: self)
                }
                self.footer.isLoading = false
            }
        }
    }
    
    
}



extension OrderConfirmController: ButtonTableFooterDelegate {
    
    func didTapButton(_ button: UIButton?) {
        footer.isLoading = true
        handleConfirm()
    }

}

