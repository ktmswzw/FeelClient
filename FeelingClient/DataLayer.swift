//  DataLayer.swift

import SQLite

class DataLayer {
    static let sharedInstance = DataLayer()
    let DB: Connection!
    
    private let databaseName = "Notes.sqlite3"
    
    private init() {
        var path = databaseName
        
        if let dirs: [String] = NSSearchPathForDirectoriesInDomains(
            NSSearchPathDirectory.DocumentDirectory,
            NSSearchPathDomainMask.UserDomainMask, true) {
                if dirs.count > 0 {
                    let dir = dirs[0]
                    path = "\(dir)/\(databaseName)"
                }
        }
        
        DB = try! Connection(path)
    }
    
    //func createTables() {
    //    AddressDataHelper.createTable()
    //}
}