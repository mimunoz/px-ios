import Foundation

class Cause {
    open var code: String!
    open var causeDescription: String!

    open class func fromJSON(_ json: NSDictionary) -> Cause {
        let cause: Cause = Cause()

        if let code = JSONHandler.attemptParseToString(json["code"]) {
            cause.code = code
        }

        if let description = JSONHandler.attemptParseToString(json["description"]) {
            cause.causeDescription = description
        }

        return cause
    }
}
