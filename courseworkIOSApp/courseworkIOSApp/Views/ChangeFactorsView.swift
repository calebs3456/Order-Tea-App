//
//  ChangeFactorsView.swift
//  courseworkIOSApp
//
//  Created by Caleb Saunderson on 15/01/2024.
//

import SwiftUI
//Template of a factor
struct Factor: Identifiable, Equatable {
    let id = UUID()
    var text: String
    var data: String
    var isChecked: Bool = true
}

struct ChangeFactorsView: View {
    @State public var taskView: TaskView
    @State private var factors: [Factor] = [Factor(text: "End Date", data:"EndDate" ),Factor(text: "Progress", data:"Progress"),Factor(text: "Start Date", data:"StartDate"),Factor(text: "Access Level", data:"AccessLevel"),Factor(text: "Assigned Priority", data:"AssignedPriority")]
    @State private var factorsText: [String] = []

    
    var body: some View {
        NavigationView{
            List {
                //Orderable list of factors
                ForEach($factors) { $factor in
                    HStack {
                        //Toggle factors
                        Toggle(isOn: $factor.isChecked){
                            Text(factor.text)
                        }
                    }
                    
                }
                .onMove(perform: move)
            }
            .navigationBarTitle("Factors")
            .navigationBarItems(trailing: EditButton())
            
        }
        Button {
            do{
                factorsText = []
                for factor in factors{
                    if factor.isChecked==true{
                        factorsText.append(factor.data)
                    }
                    
                }
                //Send api request to change factors
            
                changeFactors(factors:factorsText){ fetchedResponse, fetchedError in
                    if let fetchedResponse = fetchedResponse {
                        if fetchedResponse=="Title"{
                            Alert(title: Text("Choose a unique title"))
                        }
                        if fetchedResponse=="Success"{
                            taskView.reloadData()
                            print("Success")
                        }
                        if fetchedResponse=="Fail"{
                            Alert(title: Text("Failed to change factors!"))
                            print("Fail")
                        }
                        //taskView.reloadData()
                            
                        
                    }
                    if let fetchedError = fetchedError{
                        print(fetchedError)
                    }
                }
            }
            catch{
                Alert(title: Text("Fill out all fields"))
            }
        }label: {
            Text("Submit")
        }
        
    }
    //Function to move factor from one position in list to another
    func move(from source: IndexSet, to destination: Int) {
            factors.move(fromOffsets: source, toOffset: destination)
            
        }
}

#Preview {
    ChangeFactorsView(taskView: TaskView.init(groupView: GroupView.init()))
}
