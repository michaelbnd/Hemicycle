import UIKit
import PlaygroundSupport

let RESOLUTION_MULTIPLIER = 2
let WIDTH = 343 * RESOLUTION_MULTIPLIER
assert(WIDTH.isMultiple(of: 2))
let HEIGHT = WIDTH / 2

let ROW_COUNT = 10
let ROW_SPACING = 8.57 * CGFloat(RESOLUTION_MULTIPLIER)
let ROW_RADIAN_INSET = 1.5 * CGFloat.pi / 180.0
let ROW_CIRCLES = 58

let CIRCLES_DIAMETER = 4.8 * CGFloat(RESOLUTION_MULTIPLIER)
let CIRCLES_RADIUS = CIRCLES_DIAMETER / 2.0

let SKIPPED_CIRCLES: Set = [0, 10, 570]
let PARTIES: [Party] = [
    (17, "#D93A33"),
    (16, "#F5695E"),
    (28, "#C4516B"),
    (331, "#ECBD50"),
    (30, "#DE6C35"),
    (24, "#41B1D6"),
    (115, "#334EA1"),
    (9, "#313184"),
]

typealias Row = [CGPoint]
typealias Party = (Int, String)

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

func pointInCircle(of radius: CGFloat, at radian: CGFloat) -> CGPoint{
    let x = radius * cos(radian) + CGFloat(WIDTH) / 2.0
    let y = -(radius * sin(radian)) + CGFloat(HEIGHT)
    
    return CGPoint(x: x, y: y)
}

func createRow(with radius: CGFloat) -> Row {
    let start = CGFloat.pi - ROW_RADIAN_INSET
    let end = 0.0 + ROW_RADIAN_INSET
    let step = (start - end) / CGFloat(ROW_CIRCLES - 1)
    var row: Row = []
    
    for i in 0..<ROW_CIRCLES {
        let radian = start - CGFloat(i) * step
        let point = pointInCircle(of: radius, at: radian)
        row.append(point)
    }
    return row
}

func createRows() -> [Row] {
    var rows: [Row] = []
    var radius = CGFloat(HEIGHT) - CIRCLES_RADIUS
    
    for _ in 0..<ROW_COUNT {
        rows.append(createRow(with: radius))
        radius -= ROW_SPACING
    }
    return rows.reversed()
}

func drawParty(_ party: Party, rows: [Row], seat: inout Int, in context: CGContext) {
    let color = UIColor(hex: party.1)?.cgColor ?? UIColor(hex: "#999999")!.cgColor
    context.setFillColor(color)
    
    for _ in 0..<party.0 {
        if SKIPPED_CIRCLES.contains(seat) {
            seat += 1
        }
        let row = rows[seat % rows.count]
        let point = row[seat / rows.count]
        
        context.addCircle(at: point, diameter: CIRCLES_DIAMETER)
        seat += 1
    }
    context.drawPath(using: .fill)
}

let renderer = UIGraphicsImageRenderer(size: CGSize(width: WIDTH, height: HEIGHT))

let img = renderer.image { rendererContext in
    let context = rendererContext.cgContext
    let rows = createRows()
    var seat = 0
    
    for party in PARTIES {
        drawParty(party, rows: rows, seat: &seat, in: context)
    }
    let greyCirclesCount = ROW_COUNT * ROW_CIRCLES - seat
    drawParty((greyCirclesCount, "#999999"), rows: rows, seat: &seat, in: context)
}

PlaygroundPage.current.liveView = UIImageView(image: img)
