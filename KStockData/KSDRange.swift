//
//  KSDRange.swift
//  KStockData
//
//  Created by khr on 6/17/15.
//  Copyright (c) 2015 khr. All rights reserved.
//

import Foundation

class KSDRange : NSObject {
  let min:Float
  let max:Float

  init(_ min:Float, _ max: Float) {
    self.min = min
    self.max = max
  }

  class func make(min: Float, max: Float) -> KSDRange {
    return KSDRange(min, max)
  }
}