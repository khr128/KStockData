//
//  FractalDimensionMinMax.swift
//  KStockData
//
//  Created by khr on 6/13/15.
//  Copyright (c) 2015 khr. All rights reserved.
//

import Foundation

class FractalDimensionMinMax: NSObject {
  var min: Float
  var max: Float
  var data: [Float]
  var currentMaxIndex: Int
  var currentMinIndex: Int
  var currentIndexSet: NSMutableIndexSet

  init(array data: [Float], startIndex start: Int, period p: Int) {
    self.data = data
    currentMaxIndex = -1
    currentMinIndex = -1

    currentIndexSet = NSMutableIndexSet(indexesInRange:NSMakeRange(start, p))

    min = 0.0
    max = 0.0
  }

  func calculate() {
    if currentIndexSet.containsIndex(currentMinIndex) {
      let lastIndexInPeriod = currentIndexSet.lastIndex
      let lastValueInPeriod = data[lastIndexInPeriod]
      if min > lastValueInPeriod {
        min = lastValueInPeriod
        currentMinIndex = lastIndexInPeriod
      }
    } else {
      var minV = data[currentIndexSet.firstIndex]
      currentIndexSet.enumerateIndexesUsingBlock {
        (index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
        let v = self.data[index]
        if minV > v {
          minV = v
          self.currentMinIndex = index;
        }
      }
      min = minV
    }

    //Add code for max here
    if currentIndexSet.containsIndex(currentMaxIndex) {
      let lastIndexInPeriod = currentIndexSet.lastIndex
      let lastValueInPeriod = data[lastIndexInPeriod]
      if max < lastValueInPeriod {
        max = lastValueInPeriod
        currentMaxIndex = lastIndexInPeriod
      }
    } else {
      var maxV = data[currentIndexSet.firstIndex]
      currentIndexSet.enumerateIndexesUsingBlock {
        (index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
        let v = self.data[index]
        if maxV < v {
          maxV = v
          self.currentMaxIndex = index
        }
      }
      max = maxV
    }

    currentIndexSet.shiftIndexesStartingAtIndex(currentIndexSet.firstIndex, by: 1)
  }

}
