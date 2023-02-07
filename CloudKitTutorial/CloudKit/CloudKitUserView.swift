//
//  CloudKitUserView.swift
//  CloudKitTutorial
//
//  Created by Matheus Homrich on 07/02/23.
//

import SwiftUI
import CloudKit

class CloudKitUserViewModel: ObservableObject {
 
    @Published var permisstionStatus: Bool = false
    @Published var isSignedIn: Bool = false
    @Published var error: String = ""
    @Published var userName: String = ""
    
    init() {
        getiCloudStatus()
        requestPermission()
        fetchiCloudUserRecordID()
    }
    
    private func getiCloudStatus() {
        CKContainer.default().accountStatus { [weak self] returnedStatus, returnedError in
            DispatchQueue.main.async {
                switch returnedStatus {
                case .available:
                    self?.isSignedIn = true
                case .noAccount:
                    self?.error = CloudKitError.iCloudAccountNotFound.rawValue
                case .couldNotDetermine:
                    self?.error = CloudKitError.iCloudAccountNotDetermined.rawValue
                case .restricted:
                    self?.error = CloudKitError.iCloudAccountRestricted.rawValue
                default:
                    self?.error = CloudKitError.iCloudAccountUnknown.rawValue
                }
            }
        }
    }
    
    func requestPermission() {
        CKContainer.default().requestApplicationPermission([.userDiscoverability]) { status, error in
//            DispatchQueue.main.sync {
//                if returnedStatus == .granted {
//                    self?.permisstionStatus = true
//                    print("permission granted")
//                } else {
//                    print("permission not granted")
//                }
//            }
            guard status == .granted, error == nil else {
                // error handling voodoo
                return
            }
            
        }
    }
    
    func fetchiCloudUserRecordID() {
        CKContainer.default().fetchUserRecordID { [weak self] returnedId, returnedError in
            if let id = returnedId {
                self?.discoveriCloudUser(id: id)
            }
        }
    }
    
    func discoveriCloudUser(id: CKRecord.ID) {
        CKContainer.default().discoverUserIdentity(withUserRecordID: id) { [weak self] returnedId, returnedError in
            DispatchQueue.main.async {
                if let name = returnedId?.nameComponents?.givenName {
                    self?.userName = name
                }
            }
        }
    }
    
    enum CloudKitError: String, LocalizedError {
        case iCloudAccountNotFound
        case iCloudAccountNotDetermined
        case iCloudAccountRestricted
        case iCloudAccountUnknown
    }
}

struct CloudKitUserView: View {
    
    @StateObject private var viewModel = CloudKitUserViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        Text("Is signed in: \(viewModel.isSignedIn.description.uppercased())")
        Text(viewModel.error)
        Text("Permission: \(viewModel.permisstionStatus.description.uppercased())")
        Text("Name: \(viewModel.userName)")
    }
}

struct CloudKitUserView_Previews: PreviewProvider {
    static var previews: some View {
        CloudKitUserView()
    }
}
