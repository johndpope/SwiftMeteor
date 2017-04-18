//
//  RVCoreInfo2.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 3/10/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import UIKit

class RVCoreInfo2 {
    var loginCredentials: [String: AnyObject]? = nil
    var watchGroupImagePlaceholder: UIImage { get { return UIImage(named: "JNW.png")! } }
    var currentAppState: RVBaseAppState4 = RVBaseAppState4(appState: .loggedOut) {
        didSet {
           // print("........... In \(self.instanceType).currentAppState oldValue = \(oldValue.appState), new value = \(currentAppState.appState)")
            _priorAppState = oldValue
        }
    }
    private var _priorAppState: RVBaseAppState4 = RVBaseAppState4(appState: .defaultState)
    var priorAppState: RVBaseAppState4  {
        get { return _priorAppState }
    }
    var instanceType: String { get { return String(describing: type(of: self)) } }
    static let shared: RVCoreInfo2 = {
        return RVBaseCoreInfo8.sharedInstance
    }()

    //var domain: RVDomain? { get { return core.domain } }
    var domain: RVDomain? = nil
    var domainId: String? {
        get {
            if let domain = self.domain { return domain.localId}
            return nil
        }
    }
    var differentTopState: Bool {
        get {
            print("In \(self.instanceType).differentTopState: Prior: \(priorAppState.appState), current: \(currentAppState.appState)")
            return !(priorAppState == currentAppState)
        }
    }
    var domainName: RVDomainName { get {return RVDomainName.Rendevu }}
    var rootGroup: RVGroup? = nil

    private var _loggedInUserProfile: RVUserProfile? = nil
    var loggedInUserProfile: RVUserProfile? {
        get {
            return _loggedInUserProfile
            //return core.userProfile
        }
        set {
            self._loggedInUserProfile = newValue
        }
    }
    var loggedInUserProfileId: String? {
        get {
            if let profile = self.loggedInUserProfile { return profile.localId}
            return nil
        }
    }
    var navigationBarColor: UIColor { get {return UIColor(colorLiteralRed: 64/256, green: 128/256, blue: 255/256, alpha: 1.0)}}

    var loggedInSuccess: Bool = false
    var username: String? = nil
    var appState: RVBaseAppState2 = RVLoggedOutState2()
    var loggedIn: Bool {
        get {
            if domain == nil { return false }
            if loggedInUserProfile == nil { return false }
            if rootGroup == nil { return false }
            return loggedInSuccess
        }
    }
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(RVCoreInfo2.connected), name: NSNotification.Name(rawValue: RVNotification.connected.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RVCoreInfo2.userLoggedIn(notification:)), name: NSNotification.Name(rawValue: RVNotification.userDidLogin.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RVCoreInfo2.userLoggedOut(notification:)), name: NSNotification.Name(rawValue: RVNotification.userDidLogout.rawValue), object: nil)
    }
    func logoutModels() {
        self.loggedInUserProfile = nil
        self.rootGroup = nil
        self.loggedInSuccess = false
    }
    @objc func connected(notification: NSNotification) {
        //print("In \(self.instanceType).connected")
        self.getDomain2 { (error) in
            if let error = error { error.printError() }
            else {print("In \(self.instanceType).connected, have domain: \(self.domain!.localId ?? " no domain.localId") with domainName: \(self.domain!.domainName.rawValue)") }
        }
    }
    @objc func userLoggedIn(notification: NSNotification) {
        print("In \(self.instanceType).userLoggedIn notification observer")
        //self.getRootGroup { (error) in if let error = error { error.printError() } }
        if let userInfo = notification.userInfo {
            if let username = userInfo["user"] as? String  {
                self.completeLogin(username: username, callback: { (error ) in
                    if let error = error {
                        error.printError()
                    } else {
                    }
                })
            }
        }
    }
    @objc func userLoggedOut(notification: NSNotification) {
        self.rootGroup = nil
        self.loggedInUserProfile = nil
    }
    func printCoreInfo() {
        var domainString = "No domain"
        if let domain = self.domain {
            domainString = domain.localId   != nil ? "Domain:             , id: \(domain.localId!)" : "Domain:             , ### no id ###"
            domainString = "\(domainString), DomainName: \(domain.domainName.rawValue)"
            domainString = domain.createdAt != nil ? "\(domainString), createdAt: \(domain.createdAt!)" : "\(domainString), ### no createdAt ###"
        }
        domainString = domainString + "\n"
        var userProfileString = "No loggedInUserProfile"
        if let userProfile = self.loggedInUserProfile {
            userProfileString = "LoggedInUserProfile:"
            userProfileString = userProfile.localId   != nil ? "\(userProfileString), id: \(userProfile.localId!)" : "\(userProfileString), ### no id ### "
            userProfileString = userProfile.fullName  != nil ? "\(userProfileString), fullName: \(userProfile.fullName!)" : "\(userProfileString), ### no fullName ### "
            userProfileString = userProfile.createdAt != nil ? "\(userProfileString), createdAt: \(userProfile.createdAt!)" : "\(userProfileString), ### no createdAt ###"
        }
        var username = self.username != nil ? "Username is:          \(self.username!)" : "      ### No Username ### "
        username = username + "\n"
        userProfileString = userProfileString + "\n"
        var rootGroupString = "No Root Group"
        if let rootGroup = self.rootGroup {
            rootGroupString = rootGroup.localId   != nil ? "RootGroup:            id:\(rootGroup.localId ?? "no localId")" : "RootGroup:            ### no id ### "
            rootGroupString = rootGroup.title     != nil ? "\(rootGroupString), \(rootGroup.title!)" : "\(rootGroupString), \(rootGroupString) ### no title ### "
            rootGroupString = rootGroup.createdAt != nil ? "\(rootGroupString), createdAt: \(rootGroup.createdAt!)" : "\(rootGroupString), no createdAt"
         }
        rootGroupString = rootGroupString + "\n"
        print("------- \(self.instanceType) ---------------- CoreInfo:\n\(domainString)\(userProfileString)\(username)\(rootGroupString)AppState:       \(self.appState.state2.rawValue)\n------------------------------------")
    }
    func changeToLoggedInState() {
        
    }
    func completeLogin(username: String, callback: @escaping(_ error: RVError?) -> Void) {
        loggedInSuccess = false
        RVUserProfile.getOrCreateUsersUserProfile(callback: { (profile, error) in
            if let error = error {
                self.loggedInUserProfile = nil
                self.username = nil
                error.append(message: "In RVCoreInfos2.completeLogin, got error getting LoggedInUserProfile")
                DispatchQueue.main.async {
                    callback(error)
                }
                return
            } else if let profile = profile {
                self.loggedInUserProfile = profile
                self.username = username
              //  print("In \(self.instanceType).completeLogin, have profile \(profile.localId!), username: \(username)")
                let _ = RVSwiftDDP.sharedInstance.unsubscribe(collectionName: RVModelType.transaction.rawValue, callback: {
                   // print("In \(self.instanceType).completeLogin # \(#line), logged out \(RVModelType.transaction.rawValue)")
                })
              //  RVStateDispatcher4.shared.changeState(newState: RVBaseAppState4(appState: .transactionList))
                 print("In \(self.instanceType).completeLogin, about to get RootGroup")
                self.getRootGroup(callback: { (error) in
                    if let error = error {
                        self.rootGroup = nil
                        error.append(message: "In \(self.instanceType).completeLogin, got error getting RootGroup")
                        DispatchQueue.main.async {
                            callback(error)
                            //RVStateDispatcher8.shared.changeState(newState: RVTransactionListState8())
                          //  RVAppStateManager.shared.changeState(newState: RVUserLoggedIn(), callback: { })
                        }
                        return
                    } else {
                        DispatchQueue.main.async {
                            RVStateDispatcher8.shared.changeState(newState: RVTransactionListState8())
                            callback(nil)
                        }
                    }
                })
                return
            } else {
                self.loggedInUserProfile = nil
                self.username = nil
                let rvError = RVError(message: "In \(self.instanceType).completeLogin, no error but no userProfile")
                DispatchQueue.main.async {
                    callback(rvError)
                }
            }
        })
    }


    func getDomainAndRoot(callback: @escaping (_ error: RVError?) -> Void) {
        self.getDomain { (domain , error) in
            if let error = error {
                error.append(message: "In \(self.instanceType).getDomainAndRoot")
                callback(error)
                return
            } else if let domain = domain {
                self.domain = domain
                if let domainId = domain.localId {

                    let query = RVQuery()
                    query.addAnd(term: .domainId, value: domainId as AnyObject, comparison: .eq)
                    query.addAnd(term: .special, value: RVSpecial.root.rawValue as AnyObject, comparison: .eq)
                    RVGroup.findOne(query: query, callback: { (group , error) in
                        if let error = error {
                            error.append(message: "In \(self.instanceType).getDomainAndRoot, got error retrieving Root Record")
                            callback(error)
                            return
                        } else if let group = group as? RVGroup {
                            print("In \(self.instanceType).getDomainAndRoot, found RootGroup")
                            self.rootGroup = group
                            callback(nil)
                            return
                        } else {
                            print("In \(self.instanceType).getDomainAndRoot, creating RootGroup")
                            let group = RVGroup()
                            group.domainId = domainId
                            group.special = .root
                            group.title = RVSpecial.root.rawValue
                            group.create(callback: { (group , error ) in
                                if let error = error {
                                    error.append(message: "In \(self.instanceType).getDomainAndRoot, got error creating Root Group")
                                    callback(error)
                                    return
                                } else if let group = group as? RVGroup {
                                    self.rootGroup = group
                                    callback(nil)
                                    return
                                } else {
                                    let error = RVError(message: "In \(self.instanceType).getDomainAndRoot, no error but no result creating group")
                                    callback(error)
                                    return
                                }
                            })
                            return
                        }
                    })
                    return
                } else {
                    let error = RVError(message: "In \(self.instanceType).getDomainAndRoot, no domainId")
                    callback(error)
                    return
                }
            } else {
                error?.append(message: "In \(self.instanceType).getDomainAndRoot")
                callback(error)
            }
        }
    }
    func getRootGroup(callback: @escaping(_ error: RVError?) -> Void) {
       // print("In \(self.instanceType).getRootGroup")
        if let domainId = self.domainId {
            //print("In \(self.instanceType).getRootGroup, have domain: \(self.domain!.localId) \(self.domain!.domainName.rawValue)")
            let query = RVQuery()
            query.addAnd(term: .domainId, value: domainId as AnyObject, comparison: .eq)
            query.addAnd(term: .special, value: RVSpecial.root.rawValue as AnyObject, comparison: .eq)
            RVGroup.findOne(query: query, callback: { (group , error) in
                if let error = error {
                    error.append(message: "In \(self.instanceType).getRootGroup, got error retrieving Root Record")
                    callback(error)
                    return
                } else if let group = group as? RVGroup {
                    print("In \(self.instanceType).getRootGroup, found RootGroup")
                    self.rootGroup = group
                    callback(nil)
                    return
                } else {
                    print("In \(self.instanceType).getRootGroup, creating RootGroup, group was: \(group?.toString() ?? "No group")")
                    let group = RVGroup()
                    group.domainId = domainId
                    group.special = .root
                    group.title = RVSpecial.root.rawValue
                    if let loggedInUser = RVBaseModel.loggedInUser {
                        print("In \(self.instanceType).getRootGroup, loggedInUser is \(String(describing: loggedInUser.email)), and ownerModelType \(String(describing: loggedInUser.objects[RVKeys.modelType.rawValue]))")
                        group.setOwner(owner: loggedInUser)
                    } else {
                        print("In \(self.instanceType).getRootGroup #\(#line), no loggedInUser")
                    }
                    
                    group.create(callback: { (group , error ) in
                        if let error = error {
                            error.append(message: "In \(self.instanceType).getRootGroup, got error creating Root Group")
                            callback(error)
                            return
                        } else if let group = group as? RVGroup {
                            self.rootGroup = group
                            print("In \(self.instanceType).getRootGroup, have rootGroup")
                            callback(nil)
                            return
                        } else {
                            let error = RVError(message: "In \(self.instanceType).getRootGroup, no error but no result creating group")
                            callback(error)
                            return
                        }
                    })
                    return
                }
            })
            return
        } else {
            let error = RVError(message: "In \(self.instanceType).getRoot, no domainId")
            callback(error)
        }
    }
    func getDomain(callback: @escaping(_ domain: RVDomain?, _ error: RVError?) -> Void ) {
        let domain = RVDomain()
        domain.domainName = self.domainName
        domain.title = self.domainName.rawValue
        domain.findOrCreate { (domain , error) in
            if let error = error {
                error.append(message: "In \(self.instanceType).getDomain, got error")
                callback(nil, error)
                return
            } else if let domain = domain {
                callback(domain, nil)
                return
            } else {
                let error = RVError(message: "In \(self.instanceType).getDomain, no error but no domain")
                callback(nil, error)
            }
        }
    }
    func getDomain2(callback: @escaping(_ error: RVError?) -> Void ) {
        let domain = RVDomain()
        domain.domainName = self.domainName
        domain.title = self.domainName.rawValue
        domain.findOrCreate { (domain , error) in
            if let error = error {
                error.append(message: "In \(self.instanceType).getDomain2, got error")
                callback(error)
                return
            } else if let domain = domain {
                self.domain = domain
                callback(nil)
                return
            } else {
                let error = RVError(message: "In \(self.instanceType).getDomain2, no error but no domain")
                callback(error)
            }
        }
    }
   
}
class RVCoreInfo2Logger: Operation {
    enum State { case New, UserProfile, Domain, Group, Finished, Failure, Restart }
    var loadState: State = .New
    var username: String
    var callback: (_ error: RVError?) -> Void
    var networkActive: Bool { get { return true }}
    init(username: String, callback: @escaping (_ error: RVError?) -> Void ) {
        self.username = username
        self.callback = callback
        super.init()
    }
    func cancelIfStarted() -> Bool {
        if self.loadState == .New { return true }
        else { self.cancel() }
        return false
    }
    override func main() {
        if self.isCancelled { return }
        if !networkActive {
            self.loadState = .Restart
            self.cancel()
            self.callback(nil)
            return
        }
        self.loadState = .UserProfile
        RVUserProfile.getOrCreateUsersUserProfile { (profile , error) in
            if self.isCancelled { return }
            if let error = error {
                error.append(message: "In \(self.classForCoder).main got error retrieving userProfile for \(self.username)")
                self.loadState = .Failure
                self.cancel()
                self.callback(error)
                return
            } else if let profile = profile {
                RVCoreInfo2.shared.loggedInUserProfile = profile
                self.loadState = .Domain
                self.getDomain(callback: { (domain , error) in
                    if self.isCancelled { return }
                    if let error = error {
                        self.loadState = .Failure
                        self.cancel()
                        self.callback(error)
                        return
                    } else if let domain = domain {
                        RVCoreInfo2.shared.domain = domain
                        self.loadState = .Group
                        print("In \(self.classForCoder).main, about to get RootGroup")
                        RVGroup.getRootGroup(callback: { (group , error) in
                            if self.isCancelled { return }
                            if let error = error {
                                self.loadState = .Failure
                                error.append(message: "In \(self.classForCoder).main getting Root Group, got error")
                                self.cancel()
                                self.callback(error)
                                return
                            } else if let group = group {
                                self.loadState = .Finished
                                RVCoreInfo2.shared.rootGroup = group
                                self.callback(nil)
                                return
                            } else {
                                self.loadState = .Failure
                                self.cancel()
                                let error = RVError(message: "In \(self.classForCoder).main error getting Root Group")
                                self.callback(error)
                                return
                            }
                        })
                    } else {
                        self.loadState = .Failure
                        print("In \(self.classForCoder).main getting Domain, shouldn't get here")
                    }
                })
            } else {
                let error = RVError(message: "In \(self.classForCoder).main getOrCreateUserProfile, no error but no result")
                self.callback(error)
                return
            }
        }
        
    }
    
    func getDomainAndRoot(callback: @escaping (_ error: RVError?) -> Void) {
        self.getDomain { (domain , error) in
            if let error = error {
                error.append(message: "In \(self.classForCoder).getDomainAndRoot")
                callback(error)
                return
            } else if let _ = domain {
               //self.domain = domain
            } else {
                error?.append(message: "In \(self.classForCoder).getDomainAndRoot")
                callback(error)
            }
        }
    }
    func getDomain(callback: @escaping(_ domain: RVDomain?, _ error: RVError?) -> Void ) {
        let domain = RVDomain()
        domain.domainName = RVCoreInfo2.shared.domainName
        domain.title = RVCoreInfo2.shared.domainName.rawValue
        domain.findOrCreate { (domain , error) in
            if let error = error {
                error.append(message: "In \(self.classForCoder).getDomain, got error")
                callback(nil, error)
                return
            } else if let domain = domain {
                callback(domain, nil)
                return
            } else {
                let error = RVError(message: "In \(self.classForCoder).getDomain, no error but no domain")
                callback(nil, error)
            }
        }
    }
}
