import MLCardDrawer

final class PXTermsAndConditionsTextView: UITextView {
    init(terms: PXTermsDto, selectedInstallments: Int?, textColor: UIColor, linkColor: UIColor) {
        super.init(frame: .zero, textContainer: nil)
        linkTextAttributes = [.foregroundColor: linkColor]
        let attributedString = getTermsAndConditionsText(terms: terms, selectedCreditsInstallments: selectedInstallments)
        attributedText = attributedString
        self.textColor = textColor
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        isEditable = false
        textAlignment = .center
        backgroundColor = .clear
        isUserInteractionEnabled = true
        translatesAutoresizingMaskIntoConstraints = false
    }

    private func getTermsAndConditionsText(terms: PXTermsDto, selectedCreditsInstallments: Int?) -> NSMutableAttributedString {
        let tycText = terms.text
        let attributedString = NSMutableAttributedString(string: tycText)

        var phrases: [PXLinkablePhraseDto] = [PXLinkablePhraseDto]()
        if let remotePhrases = terms.linkablePhrases {
            phrases = remotePhrases
        }

        for linkablePhrase in phrases {
            var customLink = linkablePhrase.link
            if customLink == nil, let customHtml = linkablePhrase.html {
                customLink = HtmlStorage.shared.set(customHtml)
            } else if let links = terms.links {
                guard let installmentsSelected = selectedCreditsInstallments else { return attributedString }
                let key = linkablePhrase.installments?[String(installmentsSelected)]
                if let htmlKey = key, let customHtml = links[htmlKey] {
                    customLink = HtmlStorage.shared.set(customHtml)
                }
            }
            if let customLink = customLink {
                let tycLinkRange = (tycText as NSString).range(of: linkablePhrase.phrase)
                attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: tycLinkRange)
                attributedString.addAttribute(NSAttributedString.Key.link, value: customLink, range: tycLinkRange)
            }
        }

        return attributedString
    }
}
