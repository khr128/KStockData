//
//  StockDataRetriever.swift
//  KStockData
//
//  Created by khr on 6/20/15.
//  Copyright (c) 2015 khr. All rights reserved.
//

import UIKit

class StockDataRetriever: NSObject {
  let YAHOO_FINANCE_COMMAND_URL = "http://finance.yahoo.com/d/quotes.csv?"
  let yahooCommandFormat = "%ss=%@&f=%@"
  let YAHOO_CHART_URL = "http://ichart.finance.yahoo.com/table.csv?"
  let SECONDS_IN_YEAR = 365*24*3600
  //"ichart.finance.yahoo.com/table.csv?s=AAPL&d=4&e=2&f=2011&g=d&a=0&b=1&c=2008&ignore.csv"
  let yahooChartFormat = "%ss=%@&d=%d&e=%@&f=%@&g=d&a=%d&b=%@&c=%@&ignore.csv"

  func sendRequest(url: String,
    completionHandler: (data: NSData!, response: NSURLResponse!, error: NSError!) -> (Void)
    )
  {
    let webServiceURL = NSURL(string: url)
    let session = NSURLSession.sharedSession()
    session.dataTaskWithURL(webServiceURL!, completionHandler: completionHandler)
  }


  func chartDataFor(
    symbol: String,
    years: Float,
    completionHandler:(data: NSData!, response: NSURLResponse!, error: NSError!) -> (Void))
  {
    let today = NSDate()
    let yearAgo = NSDate(timeIntervalSinceNow: -SECONDS_IN_YEAR*years)
    let dayFormatter = NSDateFormatter()
    dayFormatter.dateFormat = "dd"
    let monthFormatter = NSDateFormatter()
    monthFormatter.dateFormat = "MM"
    let yearFormatter = NSDateFormatter()
    yearFormatter.dateFormat = "yyyy"

    let url = "%ss=\(YAHOO_CHART_URL)" + "&d=%d&e=%@&f=%@&g=d&a=%d&b=%@&c=%@&ignore.csv"

  }

  func isStockMarketOpen() -> (Bool) {
    let now = NSDate()
    let cal = NSCalendar.currentCalendar()
    cal.timeZone = NSTimeZone(abbreviation: "EST")!
    let dateComp = cal.components(
      NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitWeekday,
      fromDate: now)

    return (dateComp.weekday > 1 && dateComp.weekday < 7) &&
    (dateComp.hour > 9 || (dateComp.hour == 9 && dateComp.minute > 45))
  }
}
