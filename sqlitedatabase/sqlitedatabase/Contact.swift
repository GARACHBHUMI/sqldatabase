
import Foundation

class Contact {
    
    var name: String
    var phone: String
    var address: String

    init() {
       
        name = ""
        phone = ""
        address = ""
    }

    init(name: String, phone: String, address: String) {
       
        self.name = name
        self.phone = phone
        self.address = address
    }
}
