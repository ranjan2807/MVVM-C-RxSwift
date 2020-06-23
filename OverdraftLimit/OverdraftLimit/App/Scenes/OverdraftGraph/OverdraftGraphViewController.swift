//
//  OverdraftGraphViewController.swift
//  OverdraftLimit
//
//  Copyright © 2020 Ranjan-iOS. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

final class OverdraftGraphViewController: UIViewController {

    @IBOutlet weak var tblSettings: UITableView?

    var viewModelInitialized = false

    var viewModel: OverdraftGraphViewModelPresenter? {
        didSet {
            if !viewModelInitialized {
                viewModel?.initialize()
                loadTable()
                viewModelInitialized = true
            }
        }
    }

    var timer: Timer?

    private let disposeBag = DisposeBag()

    private lazy var dataSource = RxTableViewSectionedReloadDataSource<SectionModel<Any, Any>>(configureCell: configureCell)

    private lazy var configureCell: RxTableViewSectionedReloadDataSource<SectionModel<Any, Any>>
        .ConfigureCell = { [unowned self] (dataSource, tableView, indexPath, item) in
            if let strItem = item as? String {
                if indexPath.section == 0 {
                    return self.configureCell1(data: strItem, index: indexPath)
                } else {
                    if indexPath.row == 0 {
                        return self.configureCell2(data: strItem, index: indexPath)
                    } else {
                        return self.configureCell3(data: strItem, index: indexPath)
                    }
                }
            } else {
                return UITableViewCell()
            }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addTimer()
    }

    deinit {

    }
}

extension OverdraftGraphViewController {

    private func addTimer() {
        timer = Timer
            .scheduledTimer(withTimeInterval: TimeInterval(withdrawTimerDuration),
                            repeats: true,
                            block: { [unowned self] (_) in
                                if let viewModel = self.viewModel {
                                    viewModel.updateAmount()
                                }
            })
    }

    private func loadTable() {
        tblSettings?.delegate = nil
        tblSettings?.dataSource = nil
        tblSettings?.rx.setDelegate(self).disposed(by: disposeBag)
        tblSettings?.bounces = true

        viewModel?.settingsObservable?.bind(
            to: (tblSettings?.rx.items(dataSource: dataSource))!
        ).disposed(by: disposeBag)
    }

    @objc private func switchChanged(sw: UISwitch?) {
        guard let switchTemp = sw else {
            return
        }

        viewModel?.needNotification = switchTemp.isOn
    }
}

// MARK:- Table view Cell configure
extension OverdraftGraphViewController {
    private func configureSettingsCell(data: String, index: IndexPath, cellIdentifier: String) -> UITableViewCell {
        guard let cell = self.tblSettings?.dequeueReusableCell(withIdentifier: cellIdentifier, for: index) else {
            return UITableViewCell()
        }
        cell.textLabel?.text = data
        return cell
    }

    private func configureCell1 (data: String, index: IndexPath) -> UITableViewCell {
        let cell  = configureSettingsCell(data: data, index: index, cellIdentifier: "cell1")

        cell.detailTextLabel?.text = "Effective annual interest rate".localized + " " + (viewModel?.amountDetailsModel().interestRate)!
        cell.detailTextLabel?.textColor = .lightGray

        let label = UILabel(frame: .zero)
        label.text = viewModel?.amountDetailsModel().interestAmount
        label.textColor = ODColors.danger
        label.textAlignment = .right
        label.frame.size = CGSize(width: 100, height: 20)
        cell.accessoryView = label

        return cell
    }

    private func configureCell2 (data: String, index: IndexPath) -> UITableViewCell {
        let cell  = configureSettingsCell(data: data, index: index, cellIdentifier: "cell2")

        let switchView = UISwitch(frame: .zero)
        switchView.setOn(viewModel!.needNotification, animated: false)
        switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        switchView.onTintColor = ODColors.primary
        cell.accessoryView = switchView

        return cell
    }

    private func configureCell3 (data: String, index: IndexPath) -> UITableViewCell {
        let cell  = configureSettingsCell(data: data, index: index, cellIdentifier: "cell3")
        return cell
    }
}

extension OverdraftGraphViewController: UIScrollViewDelegate, UITableViewDelegate {


    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 80
        } else {
            return 60
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let view = UIView()
            view.frame.size.height = 420

            addPieGraph(view: view)

            return view
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 420
        } else {
            return 0
        }
    }
}

extension OverdraftGraphViewController {

    func addPieGraph(view: UIView) {
        let firstItem: RKPieChartItem = RKPieChartItem(ratio: 20,
                                                       color: ODColors.primary,
                                                       title: "")
        let secondItem: RKPieChartItem = RKPieChartItem(ratio: 40,
                                                        color: ODColors.secondary,
                                                        title: "")

        firstItem.startAngle = viewModel?.getChartStartAngle()
        firstItem.endAngle = viewModel?.calculateEndAngleForOverdraftAmount() //π
        secondItem.startAngle = viewModel?.getChartStartAngle()
        secondItem.endAngle = viewModel?.calculateEndAngleForOverdraftLimit()

        let chartView = RKPieChartView(items: [secondItem, firstItem],
                                       centerTitle: "Current Overdraft \n" + (viewModel?.amountDetailsModel().amount)!)

        chartView.arcWidth = 60
        chartView.isIntensityActivated = false
        chartView.style = .round
        chartView.circleColor = ODColors.tertiary
        chartView.isTitleViewHidden = true
        chartView.isAnimationActivated = true


        chartView.frame = CGRect(x: 40.0, y: 0.0, width: (tblSettings?.frame.size.width)! - 80.0, height: 400)
        view.addSubview(chartView)
    }

    
}
