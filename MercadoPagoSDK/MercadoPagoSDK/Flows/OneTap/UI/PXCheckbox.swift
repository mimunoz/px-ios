import UIKit

class PXCheckbox: UIView {
    private var selected: Bool!
    private var view: UIView!

    convenience init (selected: Bool) {
        self.init()
        self.selected = selected
        self.backgroundColor = .clear
        self.isOpaque = false
    }

    convenience init(frame: CGRect, selected: Bool) {
        self.init(frame: frame)
        self.selected = selected
    }

    override func draw(_ rect: CGRect) {
//        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else {
            print("could not get graphics context")
            return
        }

        context.setLineWidth(2)

        context.setStrokeColor(selected ? UIColor.lightBlue().cgColor : UIColor.gray.cgColor)

        context.addEllipse(in: CGRect(x: 1, y: 1, width: 18, height: 18))

        context.strokePath()

        if selected {
            context.setFillColor(UIColor.lightBlue().cgColor)

            context.beginPath() // this prevents a straight line being drawn from the current point to the next ellipse

            context.fillEllipse(in: CGRect(x: 5, y: 5, width: 10, height: 10))

            context.strokePath()
        }
    }
}
