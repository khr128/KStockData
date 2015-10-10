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
  let YAHOO_CHART_URL = "http://ichart.finance.yahoo.com/table.csv?"
  let SECONDS_IN_YEAR = 365*24*3600

  func sendRequest(url: String,
    completionHandler: ((NSData?, NSURLResponse?, NSError?) -> Void))
  {
    let webServiceURL = NSURL(string: url)
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithURL(webServiceURL!, completionHandler: completionHandler)

    task.resume()
  }

  func stockDataFor(
    symbol: String,
    commands: String,
    completionHandler:(data: NSData?, response: NSURLResponse?, error: NSError?) -> (Void))
  {
    let url = "\(YAHOO_FINANCE_COMMAND_URL)s=\(symbol)&f=\(commands)"
    sendRequest(url, completionHandler: completionHandler)
  }

  func chartDataFor(
    symbol: String,
    years: Float,
    completionHandler:(data: NSData?, response: NSURLResponse?, error: NSError?) -> (Void))
  {
    let today = NSDate()
    let yearAgo = NSDate(timeIntervalSinceNow: NSTimeInterval(-Float(SECONDS_IN_YEAR)*years))
    let dayFormatter = NSDateFormatter()
    dayFormatter.dateFormat = "dd"
    let monthFormatter = NSDateFormatter()
    monthFormatter.dateFormat = "MM"
    let yearFormatter = NSDateFormatter()
    yearFormatter.dateFormat = "yyyy"

    let monthNow = Int(monthFormatter.stringFromDate(today))!-1
    let dayNow = dayFormatter.stringFromDate(today)
    let yearNow = yearFormatter.stringFromDate(today)

    let monthYearsAgo = Int(monthFormatter.stringFromDate(yearAgo))!-1
    let dayYearsAgo = dayFormatter.stringFromDate(yearAgo)
    let yearYearsAgo = yearFormatter.stringFromDate(yearAgo)

    //"ichart.finance.yahoo.com/table.csv?s=AAPL&d=4&e=2&f=2011&g=d&a=0&b=1&c=2008&ignore.csv"
    let url = "\(YAHOO_CHART_URL)" +
      "s=\(symbol)" +
      "&d=\(monthNow)" +
      "&e=\(dayNow)" +
      "&f=\(yearNow)" +
      "&g=d" +
      "&a=\(monthYearsAgo)" +
      "&b=\(dayYearsAgo)" +
      "&c=\(yearYearsAgo)" +
    "&ignore.csv"

    sendRequest(url, completionHandler: completionHandler)
  }

  class func isStockMarketOpen() -> (Bool) {
    let now = NSDate()
    let cal = NSCalendar.currentCalendar()
    cal.timeZone = NSTimeZone(abbreviation: "EST")!
    let dateComp = cal.components(
      [NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Weekday],
      fromDate: now)

    return (dateComp.weekday > 1 && dateComp.weekday < 7) &&
    (dateComp.hour > 9 || (dateComp.hour == 9 && dateComp.minute > 45))
  }
}
