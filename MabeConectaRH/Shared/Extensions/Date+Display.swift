import Foundation

extension Date {
    var mabeShortDate: String {
        formatted(.dateTime.day().month(.abbreviated).year())
    }
}
