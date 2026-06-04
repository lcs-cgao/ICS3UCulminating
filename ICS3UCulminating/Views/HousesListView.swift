//
//  HousesListView.swift
//  ICS3UCulminating
//
//  Created by GaoZiHan on 2026/6/4.
//

import SwiftUI
 
// VIEW
struct HousesListView: View {
    
    // MARK: Stored properties
    // Stored properties must be provided with a value by providing an argument when creating an instance of this structure, or, be initialized with a default value
    
    // Holds the view model, to track current state of
    // data within the app
    @State var viewModel = HouseListViewModel()
    
    // MARK: Computed properties
    // Computed properties calculate or derive a value using stored properties
    
    // The "body" property defines the user interface for this app
    var body: some View {
        NavigationStack {
            List(viewModel.housesList) { currentHouse in
                HouseItemView(providedHouse: currentHouse)
            }
            .navigationTitle("LCS Houses")
        }
    }
}
 
#Preview {
    HousesListView()
}
