import UIKit

final class PXOneTapInstallmentsSelectorView: PXComponentView {
    private var model: PXOneTapInstallmentsSelectorViewModel
    let tableView = UITableView()
    let shadowView = UIImageView(image: ResourceManager.shared.getImage("one-tap-installments-shadow"))
    weak var delegate: PXOneTapInstallmentsSelectorProtocol?
    var tableViewHeightConstraint: NSLayoutConstraint?

    init(viewModel: PXOneTapInstallmentsSelectorViewModel) {
        model = viewModel
        super.init()
        render()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(viewModel: PXOneTapInstallmentsSelectorViewModel) {
        model = viewModel
        tableView.reloadData()
    }
}

extension PXOneTapInstallmentsSelectorView {
    func render() {
        removeAllSubviews()
        pinContentViewToTop()
        addSubviewToBottom(tableView)
        backgroundColor = .clear
        tableView.backgroundColor = UIColor.Andes.graySolid040
        tableViewHeightConstraint = PXLayout.setHeight(owner: tableView, height: 125)
        tableViewHeightConstraint?.isActive = true
        PXLayout.pinLeft(view: tableView).isActive = true
        PXLayout.pinRight(view: tableView).isActive = true
        tableView.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView?.layoutIfNeeded()
        tableView.reloadData()

        self.layoutIfNeeded()

        if let selectedInstallmentIndex = model.installmentData.payerCosts.firstIndex(where: { payerCost -> Bool in
            return model.selectedPayerCost?.installments == payerCost.installments
        }) {
            self.tableView.scrollToRow(at: IndexPath(row: selectedInstallmentIndex, section: 0), at: .middle, animated: false)
        }
    }
}

// MARK: UITableViewDelegate & DataSource
extension PXOneTapInstallmentsSelectorView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfRowsInSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return model.cellForRowAt(indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return model.heightForRowAt(indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        if let selectedPayerCost = model.getPayerCostForRowAt(indexPath) {
            delegate?.payerCostSelected(selectedPayerCost)
        }
    }
}
