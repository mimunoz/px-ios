import Foundation

// will only execute the print action if running in debug
func printDebug(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        let output = items.map { "\($0)" }.joined(separator: separator)
        Swift.print(output, terminator: terminator)
    #endif
}

// this function should be used when the user experience has been broken and this log needs to be reported as a warning in order to be fixed in a further version
func printError(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        let output = items.map { "\($0)" }.joined(separator: separator)
        Swift.debugPrint(output, terminator: terminator)
    #endif
}
