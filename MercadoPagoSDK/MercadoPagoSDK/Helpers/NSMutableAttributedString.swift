extension NSMutableAttributedString {
    func with(font: UIFont) -> NSMutableAttributedString {
        self.enumerateAttribute(.font, in: NSRange(location: 0, length: self.length), options: .longestEffectiveRangeNotRequired) { value, range, _ in
            if let oldFont = value as? UIFont,
              let newFontDescriptor = oldFont.fontDescriptor
                .withFamily(font.familyName)
                .withSymbolicTraits(oldFont.fontDescriptor.symbolicTraits) {
                let newFont = UIFont(
                    descriptor: newFontDescriptor,
                    size: font.pointSize
                )
                removeAttribute(.font, range: range)
                addAttribute(.font, value: newFont, range: range)
            }
        }
        return self
    }

    func applyTraitsFromFont(_ f1: UIFont, to f2: UIFont) -> UIFont? {
        let originalTrait = f1.fontDescriptor.symbolicTraits
        if originalTrait.contains(.traitBold) {
            var traits = f2.fontDescriptor.symbolicTraits
            traits.insert(.traitBold)
            if let fd = f2.fontDescriptor.withSymbolicTraits(traits) {
                return UIFont.init(descriptor: fd, size: 0)
            }
        }
        return f2
    }
}
