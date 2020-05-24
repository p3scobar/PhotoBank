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
    var type: TransactionType
    var amount: Decimal
    var price: Decimal
    var subtotal: Decimal
    var total: Decimal
    
    
    init(token: Token, type: TransactionType, amount: Decimal, price: Decimal, subtotal: Decimal) {
        self.token = token
        self.type = type
        self.amount = amount
        self.price = price
        self.subtotal = subtotal
        self.total = subtotal
        super.init(style: .grouped)
    }

    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = token.assetCode
            //type.rawValue.capitalized
        tableView.isScrollEnabled = true
        tableView.alwaysBounceVertical = true
        tableView.backgroundColor = Theme.black
        tableView.separatorColor = Theme.border
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
        switch indexPath {
        case 0:
            cell.textLabel?.text = "Amount"
            cell.valueInput.text = "\(amount)"
        case 1:
            cell.textLabel?.text = "Price"
            cell.valueInput.text = price.rounded(4)
        case 2:
            cell.textLabel?.text = "Total"
            cell.valueInput.text = total.rounded(4) + " \(baseAsset.assetCode ?? "")"
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
        switch type {
        case .buy:
            handleBuy()
        case .sell:
            handleSell()
        default:
            break
        }
    }
    
    func handleBuy() {
        let value = price*100
        let result = NSDecimalNumber(decimal: value)
//        print(Int(result)) // testing the cast to Int
        
        guard let n: Int32 = Int32("100") else {
            ErrorPresenter.showError(message: "Value is incorrect", on: self)
            return
        }
        let d: Int32 = Int32(truncating: result)
        let p = Price(numerator: n, denominator: d)
        let amount = total
        
        let buyAsset = token.toRawAsset()
        let sellAsset = baseAsset.toRawAsset()
        
        submitOffer(buy: buyAsset, sell: sellAsset, amount: amount, price: p)
    }
    
    
    func handleSell() {
        guard let n: Int32 = Int32("\(price*100)"),
            let d: Int32 = Int32("100") else {
                ErrorPresenter.showError(message: "Value is incorrect", on: self)
                return
            }
        let p = Price(numerator: n, denominator: d)
        let buyAsset = baseAsset.toRawAsset()
        let sellAsset = token.toRawAsset()
        submitOffer(buy: buyAsset, sell: sellAsset, amount: amount, price: p)
    }
    
    
    
    func submitOffer(buy: Asset, sell: Asset, amount: Decimal, price: Price) {
        
        OrderService.offer(buy: buy, sell: sell, amount: amount, price: price) { success in
            if success == true {
                self.dismiss(animated: true, completion: nil)
            } else {
                ErrorPresenter.showError(message: "Order Failed", on: self)
            }
            self.footer.isLoading = false
        }
    }
    
    
}



extension OrderConfirmController: ButtonTableFooterDelegate {
    func didTapButton(_ button: UIButton?) {
        footer.isLoading = true
        handleConfirm()
    }
}
