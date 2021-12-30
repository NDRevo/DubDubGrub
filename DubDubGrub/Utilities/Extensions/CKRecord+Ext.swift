//
//  CKRecord+Ext.swift
//  DubDubGrub
//
//  Created by Noé Duran on 12/29/21.
//

import CloudKit

extension CKRecord {
    func convertToDDGLocation() -> DDGLocation { DDGLocation(record: self) }
    func convertToDDGProfile() -> DDGProfile { DDGProfile(record: self) }
}
