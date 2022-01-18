import Foundation
import MercadoPagoSDKV4
import UIKit

enum PostPaymentTestCase {
    case cancelled
    case rejected
    case approved

    var genericPayment: PXGenericPayment? {
        switch self {
        case .approved:
            return PXGenericPayment(
                paymentStatus: .APPROVED,
                statusDetail: "PostPayment Approved"
            )
        case .rejected:
            return PXGenericPayment(
                paymentStatus: .REJECTED,
                statusDetail: "PostPayment Rejected"
            )
        case .cancelled:
            return nil
        }
    }
}

final class PostPaymentViewController: UIViewController {
    private let resultBlock: MercadoPagoCheckout.PostPayment.ResultBlock

    init(with resultBlock: @escaping MercadoPagoCheckout.PostPayment.ResultBlock) {
        self.resultBlock = resultBlock
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        self.navigationItem.leftBarButtonItem = .init(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(didTapCancel)
        )

        let rejectedButton = UIButton()
        rejectedButton.backgroundColor = UIColor.Andes.red500
        rejectedButton.setTitle("Rechazar", for: .normal)
        rejectedButton.addTarget(self, action: #selector(didTapRejected), for: .touchUpInside)

        let approvedButton = UIButton()
        approvedButton.backgroundColor = UIColor.Andes.green500
        approvedButton.setTitle("Aprobar", for: .normal)
        approvedButton.addTarget(self, action: #selector(didTapApproved), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [rejectedButton, approvedButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.distribution = .fillEqually
        stack.axis = .vertical

        self.view.backgroundColor = .white
        self.view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])

        // Handling modal dismiss
        self.navigationController?.presentationController?.delegate = self
    }

    @objc
    func didTapCancel() {
        dismissWithResult(.cancelled)
    }

    @objc
    func didTapRejected() {
        dismissWithResult(.rejected)
    }

    @objc
    func didTapApproved() {
        dismissWithResult(.approved)
    }

    private func dismissWithResult(_ testCase: PostPaymentTestCase) {
        let payment = testCase.genericPayment
        self.dismiss(animated: true) { [resultBlock] in
            resultBlock(payment)
        }
    }
}

extension PostPaymentViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        didTapCancel()
    }
}
