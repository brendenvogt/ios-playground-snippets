import UIKit

// Random response time callback, load items in order
// problem. Imagine you have 20 "Item" objects, each requiring separate network calls. They need to be loaded in order after they have loaded. (Items are finished loading when they have called their callback Action.
// Build a solution that implements a func loadData(fromStarting start: Int, toEnd end : Int)  which represents the loading of a block of items from start to end. Each call to loadData must be in ascending order to be correct.
// e.g. 3 items with callbacks from 2 and then 0 would load 0. Only until callback from 1 is received will we load 1 through 2

typealias CallbackAction = () -> Void
class Item {
    var index : Int
    let callback : CallbackAction
    var timer : Timer? = nil
    
    init(index: Int, callback: @escaping CallbackAction) {
        self.index = index
        self.callback = callback
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval.random(in: ClosedRange.init(uncheckedBounds: (1,5))), target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
    }
    @objc func timerAction(){
        self.callback()
    }
}

func getHighest(fromNeeded lower: Int) -> Int {
    var current = lower
    for i in current..<numberOfItems {
        if finishedItems.contains(i) {
            current = i
        } else {
            return current
        }
    }
    return current
}

func loadItems(withLower lower: Int, andUpper upper: Int) {
    let toAdd = items[lower...upper]
    loadedItems.append(contentsOf: toAdd)
    print("loaded \(lower) \(upper) for a total of \(loadedItems.count)")
}

var items : [Item] = []
var loadedItems : [Item] = []
var finishedItems = Set<Int>()
let numberOfItems = 20
var neededItem = 0

for callbackItem in 0..<numberOfItems {
    items.append(Item(index: callbackItem, callback: {
        print("\(callbackItem) finished")
        finishedItems.insert(callbackItem)
        
        if (callbackItem == neededItem) {
            let highest = getHighest(fromNeeded: neededItem)
            loadItems(withLower: neededItem, andUpper: highest)
            neededItem = highest+1
        }
    }))
}

