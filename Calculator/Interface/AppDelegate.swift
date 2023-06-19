//
//  AppDelegate.swift
//  Calculator
//
//  Created by Cyprien Heusse on 09/09/2021.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var mainWindowController: WindowController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let today = Date()
        
        let defaults = UserDefaults.standard
        ExchangeRates.rates = loadRates()
        ExchangeRates.date = defaults.object(forKey: "RatesDate") as? Date ?? Date.distantPast
        ExchangeRates.error = defaults.integer(forKey: "RatesError")
        
        if !Calendar.current.isDate(today, inSameDayAs:ExchangeRates.date) || ExchangeRates.rates.count == 0 {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let url = URL(string: "https://www.imf.org/external/np/fin/data/rms_mth.aspx?SelectDate="+formatter.string(from: today)+"&reportType=CVSDR&tsvflag=Y")
            
            let task = URLSession.shared.dataTask(with: url!) { data, response, error in
                if error != nil {
                    ExchangeRates.error = Constants.API_ERROR
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    ExchangeRates.error = Constants.API_ERROR
                    return
                }
                
                let readText = String(decoding: data!, as: UTF8.self)
                let lines = readText.components(separatedBy: "\r\n") as [String]
                let currencies = getCSVData("currencies.csv")
                
                for i in 0..<lines.count {
                    
                    let line = lines[i].components(separatedBy: "\t") as [String]
                    var rate = ExchangeRate()
                    
                    if let c = currencies.first(where: { $0[0] == line[0] }) {
                        rate.fullName = c[0]
                        rate.iso = c[1]
                        rate.symbol = c[2]
                    } else {
                        continue
                    }
                    
                    for r in line.reversed() {
                        if r != "NA" {
                            rate.value = Double(r) ?? 0
                            break
                        }
                    }
                    
                    if let index = ExchangeRates.rates.firstIndex(where: { $0.fullName == rate.fullName }) {
                        if rate.value != 0 {
                            ExchangeRates.rates[index] = rate
                        }
                    } else {
                        ExchangeRates.rates.append(rate)
                    }
                }
                
                if ExchangeRates.rates.count == 0 {
                    ExchangeRates.error = Constants.API_ERROR
                }
                
                ExchangeRates.date = today
                
                let defaults = UserDefaults.standard
                saveRates(ExchangeRates.rates)
                defaults.set(ExchangeRates.date, forKey: "RatesDate")
                defaults.set(ExchangeRates.error, forKey: "RatesError")
            }
            task.resume()
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminate(_ sender: NSApplication)-> NSApplication.TerminateReply {
        return .terminateNow
    }

}

func getCSVData(_ filename: String) -> [[String]] {
    var lines: [String]
    var content: [[String]] = []
    let path = Bundle.main.path(forResource: "currencies", ofType: "csv")!
    do {
        let contents = try String(contentsOfFile: path)
        lines = contents.components(separatedBy: "\r\n")
        for line in lines {
            content.append(line.components(separatedBy: ";"))
        }
    } catch {
        return []
    }
    return content
}

func saveRates(_ rates: [ExchangeRate]) {
    let data = rates.map { try? JSONEncoder().encode($0) }
    UserDefaults.standard.set(data, forKey: "Rates")
}

func loadRates() -> [ExchangeRate] {
    guard let encodedData = UserDefaults.standard.array(forKey: "Rates") as? [Data] else {
        return []
    }

    return encodedData.map { try! JSONDecoder().decode(ExchangeRate.self, from: $0) }
}
