//
//  RVMemberToMemberChatState.swift
//  SwiftMeteor
//
//  Created by Neil Weintraut on 2/18/17.
//  Copyright © 2017 Neil Weintraut. All rights reserved.
//

import Foundation
class RVMemberToMemberChatState: RVBaseAppState {

    //var chatBuddy: RVUserProfile? = nil
    override func configure() {
        super.configure()
        self.state = .MemberToMemberChat
        self.showSearchBar = false
        self.showTopView = true
        self.installRefreshControl = false
        self.installSearchController = false
        
        
        navigationBarTitle = "Private Chat"
        topInTopAreaHeight = 100.0
        controllerOuterSegmentedViewHeight = 0.0
        bottomInTopAreaHeight = 0.0
        scopes = [[String: RVKeys]]()
     //   scopes = [["Handle": RVKeys.handle], ["Title": RVKeys.title]  , ["Comment": RVKeys.comment]]
     //   segmentViewFields = [.WatchGroupInfo, .WatchGroupMembers, .WatchGroupMessages]

        
        let mainDatasource = RVMessageDatasource()
        self.mainDatasource = mainDatasource
        mainDatasource.datasourceType =  .main
        datasources.append(mainDatasource)
        
        let filterDatasource = RVMessageDatasource(maxArraySize: 300, filterMode: true)
        filterDatasource.datasourceType = .filter
        datasources.append(filterDatasource)
        //        for datasource in datasources { manager.addSection(section: datasource) }
        let mainQuery: queryFunction = {(params) in
            //     print("In \(self.instanceType).mainQuery")
            let query = mainDatasource.basicQuery()
            if let baseModel = RVCoreInfo.sharedInstance.appState.stack.last {
                query.addAnd(term: .parentId, value: baseModel.localId as AnyObject, comparison: .eq)
            }
            query.addAnd(term: .createdAt, value: RVEJSON.convertToEJSONDate(Date()) as AnyObject, comparison: .lte)
            return query
        }
        queryFunctions[.main] = mainQuery
        let filterQuery: queryFunction = {(params) in
            
            let query = filterDatasource.basicQuery()
            query.removeAllSortTerms()
            if let top = self.stack.last {
                query.addAnd(term: .parentId, value: top.localId as AnyObject, comparison: .eq)
            }
            if let text = params[RVMainViewControllerState.textLabel] as? String {
                query.fixedTerm = RVQueryItem(term: .fullName, value: text.lowercased() as AnyObject, comparison: .regex)
                query.addSort(field: .title, order: .ascending)
            } else {
                print("IN \(self.instanceType).configure, filterQueryFunction, setting fixedTerm to .title, no text")
                query.fixedTerm = RVQueryItem(term: .fullName, value: "a" as AnyObject, comparison: .regex)
                query.addSort(field: .title, order: .ascending)
            }
            return query
        }
        queryFunctions[.filter] = filterQuery
    }
    func subscribe(callback: @escaping ()-> Void) {
        if let datasource = self.mainDatasource {
        
            let query = datasource.basicQuery()
            if let baseModel = RVCoreInfo.sharedInstance.appState.stack.last {
                query.addAnd(term: .parentId, value: baseModel.localId as AnyObject, comparison: .eq)
            }
            query.addSort(field: .createdAt, order: .ascending)
            query.addAnd(term: .createdAt, value: RVEJSON.convertToEJSONDate(query.decadeAgo) as AnyObject, comparison: .gt)
            let (filters, projections) = query.query()
            let _ = RVCoreInfo.sharedInstance.messageCollection
            self.subscriptionId = RVSwiftDDP.sharedInstance.subscribe(method: .messagesWQuery, params: [filters as AnyObject, projections as AnyObject]) {
                callback()
            }
        }
    }
    deinit {
        if let id = self.subscriptionId {
            RVSwiftDDP.sharedInstance.unsubscribe(subscriptionId: id, callback: { })
        }
    }
}
