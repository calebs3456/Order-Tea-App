//
//  ChangeAllFactorsView.swift
//  courseworkIOSApp
//
//  Created by Caleb Saunderson on 19/01/2024.
//


import SwiftUI
//Factor template
struct TotalFactor: Identifiable, Equatable {
    let id = UUID()
    var text: String
    var data: String
    var isChecked: Bool = true
}

struct ChangeAllFactorsView: View {
    @State public var taskView: TotalTaskView
    //List of factors
    @State private var factors: [TotalFactor] = [TotalFactor(text: "End Date", data:"EndDate" ),TotalFactor(text: "Progress", data:"Progress"),TotalFactor(text: "Start Date", data:"StartDate"),TotalFactor(text: "Access Level", data:"AccessLevel"),TotalFactor(text: "Assigned Priority", data:"AssignedPriority")]
    @State private var factorsText: [String] = []

    
    var body: some View {
        NavigationView{
            List {
                
                //Orderable list of factors
                ForEach($factors) { $factor in
                    
                    //Horizontal stack
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
                        factorsText.append(factor.text)
                    }
                    
                }
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
    ChangeAllFactorsView(taskView: TotalTaskView.init(groupView: GroupView.init()))
}
