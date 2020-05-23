//
//  ContentView.swift
//  stepcountertest
//
//  Created by Ceren on 10.04.2020.
//  Copyright © 2020 ceren. All rights reserved.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    
    private var healthkitStore = HKHealthStore()
    @State private var stepValue_Today = 0
    
    var body: some View {
        
        VStack{
            Text("Adım Sayınız")
                .font(.system(size: 20))
                .foregroundColor(.purple)
                .padding()
            
            HStack{
                
                Text("\(self.stepValue_Today)")
                    .fontWeight(.regular)
                    .font(.system(size: 30))
                    .foregroundColor(.purple)
                
            }
            /*HStack Sonu**/
            
            
        }.onAppear(perform: getHealthKitPermission)
        /*VStack Sonu**/
    }
    
    ///HealthKit İzni
    func getHealthKitPermission() {
        // delay(0.1) {
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        
        let stepsCount = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
        
        self.healthkitStore.requestAuthorization(toShare: [], read: [stepsCount]) { (success, error) in
            if success {
                print("Permission accept.")
                self.getStepCountToday()
                
            }
            else {
                if error != nil {
                    print(error ?? "")
                }
                print("Permission denied.")
            }
        }
    }
    
    ///Bugünki adım sayısını getir methodu
    func getStepCountToday(){
        self.getStepsCount(forSpecificDate: Date()) { (steps) in
            if steps == 0.0 {
                self.stepValue_Today = Int(steps)
                print("steps :: \(steps)")
                
            }
            else {
                DispatchQueue.main.async {
                    self.stepValue_Today = Int(steps)
                    print("steps :: \(steps)")
                }
            }
        }
    }
    
    
    func getStepsCount(forSpecificDate:Date, completion: @escaping (Double) -> Void) {
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let (start, end) = self.getWholeDate(date: forSpecificDate)
        
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()))
        }
        
        self.healthkitStore.execute(query)
    }
    
    ///Tarih işlemlerini yapar.
    func getWholeDate(date : Date) -> (startDate:Date, endDate: Date) {
        var startDate = date
        var length = TimeInterval()
        _ = Calendar.current.dateInterval(of: .day, start: &startDate, interval: &length, for: startDate)
        let endDate:Date = startDate.addingTimeInterval(length)
        return (startDate,endDate)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
