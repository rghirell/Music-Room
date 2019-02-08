//
//  SparkSetup.swift
//  TestingFirestoreAuth
//
//  Created by Alex Nagy on 28/11/2018.
//  Copyright © 2018 Alex Nagy. All rights reserved.
//

import Firebase
import FirebaseStorage

extension FacebookManager {
    static let Firestore_Users_Collection = firebaseManager.firestoreDatabase.collection(SparkKeys.CollectionPath.users)
    static let Storage_Profile_Images = Storage.storage().reference().child(SparkKeys.StorageFolder.profileImages)
}
