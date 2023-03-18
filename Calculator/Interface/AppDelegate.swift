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
        if Calendar.current.isDate(today, inSameDayAs:ExchangeRates.date) {
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
                
                let defaults = UserDefaults.standard
                defaults.set(ExchangeRates.rates, forKey: "Rates")
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
