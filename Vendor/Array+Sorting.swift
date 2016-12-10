// Swift 2.0 extension for sorted array operations

extension Array where Element: Comparable {
    func findValueInSortedArray(_ value: Element) -> (Int, Bool) {
        var min = self.startIndex
        var max = self.endIndex
        
        while min < max {
            let mid = (max - min) / 2 + min
            let midValue = self[mid]
            
            if midValue < value {
                min = mid + 1
            }
            else if midValue > value {
                max = mid
            }
            else {
                return (mid, true)
            }
        }
        return (min, false)
    }
    
    mutating func insertInSortedArray(_ newElement: Element) {
        let (index, _) = findValueInSortedArray(newElement)
        insert(newElement, at: index)
    }
    
    func getIndexInSortedArray(_ value: Element) -> Int? {
        let (index, exists) = findValueInSortedArray(value)
        return exists ? index : nil
    }
}
