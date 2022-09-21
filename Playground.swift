import UIKit
import PlaygroundSupport

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: 1)
                    return
                }
            }
        }
        return nil
    }
}

extension CGContext {
    func addCircle(at point: CGPoint, diameter: CGFloat) {
        let radius = diameter / 2.0
        let rectangle = CGRect(x: point.x - radius, y: point.y - radius, width: diameter, height: diameter)
        
        self.addEllipse(in: rectangle)
    }
}

/// Returns the point at the given angle in radian in the circle with the given radius and center
/// in an upper left origin coordinate system
private func circlePoint(radius: CGFloat, center: CGPoint, radian: CGFloat) -> CGPoint {
    let x = cos(radian) * radius + center.x
    let y = -(sin(radian) * radius) + center.y
    
    return CGPoint(x: x, y: y)
}

/// Returns the coordinates of the seats in an hemicycle corresponding to the French National assembly
/// in the inside to outside and left to right order
/// in an upper left origin coordinate system
private func hemicyclePoints(width: CGFloat) -> [CGPoint] {
    let height = width / 2.0
    let rowCount = 10
    let rowCircles = 58
    let rowRadian = 1.5 * CGFloat.pi / 180.0
    let rowSpacing = 8.57 / 343.0 * width
    let circlesDiameter = 4.7 / 343.0 * width
    let circlesCount = rowCount * rowCircles
    let skippedPoints: Set = [0, 10, 570]
    let center = CGPoint(x: width / 2.0, y: height)
    
    var points: [CGPoint] = []
    points.reserveCapacity(circlesCount - skippedPoints.count)
    
    let radianStart = CGFloat.pi - rowRadian
    let radianEnd = 0.0 + rowRadian
    let radianStep = (radianStart - radianEnd) / CGFloat(rowCircles - 1)
    
    let radiusStart = CGFloat(rowCount + 1) * rowSpacing - circlesDiameter / 2.0
    let radiusStep = rowSpacing
    
    var radian: CGFloat = radianStart
    var i = 0
    for _ in 0..<rowCircles {
        var radius: CGFloat = radiusStart
        for _ in 0..<rowCount {
            if !skippedPoints.contains(i) {
                let point = circlePoint(radius: radius, center: center, radian: radian)
                points.append(point)
            }
            i += 1
            radius += radiusStep
        }
        radian -= radianStep
    }
    return points
}

func hemicycleImage() -> UIImage {
    let parties: [(Int, String)] = [
        (17, "#D93A33"),
        (16, "#F5695E"),
        (28, "#C4516B"),
        (331, "#ECBD50"),
        (30, "#DE6C35"),
        (24, "#41B1D6"),
        (115, "#334EA1"),
        (9, "#313184"),
    ]
    let width: CGFloat = 700
    let height: CGFloat = width / 2.0
    
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))

    return renderer.image { rendererContext in
        let context = rendererContext.cgContext
        let points = hemicyclePoints(width: width)

        var i = points.makeIterator()
        for party in parties {
            context.setFillColor(UIColor(hex: party.1)!.cgColor)
            for _ in 0..<party.0 {
                guard let point = i.next() else {
                    context.drawPath(using: .fill)
                    return
                }
                context.addCircle(at: point, diameter: 4.7 / 343.0 * width)
            }
            context.drawPath(using: .fill)
        }
        context.setFillColor(UIColor(hex: "#D6D6CE")!.cgColor)
        while let point = i.next() {
            context.addCircle(at: point, diameter: 4.7 / 343.0 * width)
        }
        context.drawPath(using: .fill)
    }
}

PlaygroundPage.current.liveView = UIImageView(image: hemicycleImage())
