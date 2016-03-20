//
//  SqListUtils.swift
//  FeelingClient
//
//  Created by vincent on 14/2/16.
//  Copyright © 2016 xecoder. All rights reserved.
//

import Foundation
import SQLite

class SQLUtils{
    
    let db = try! Connection("path/to/db.sqlite3")

    func CreateUsersTable(sql: String) {
        try! db.execute(sql)
    }
    
    
}
