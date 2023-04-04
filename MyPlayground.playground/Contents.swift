import Foundation

func insertionSort(array: [Int]) -> Int {
    var comparisonCount = 0
    var sortedArray = array
    
    for i in 1..<sortedArray.count {
        let currentElement = sortedArray[i]
        var j = i - 1
        
        while j >= 0 && sortedArray[j] > currentElement {
            sortedArray[j+1] = sortedArray[j]
            j -= 1
            comparisonCount += 1
        }
        
        sortedArray[j+1] = currentElement
    }
    
    return comparisonCount
}

func heapSort(array: inout [Int]) -> Int {
    var swapCount = 0
    
    // Build max heap
    for i in stride(from: (array.count / 2) - 1, through: 0, by: -1) {
        heapify(array: &array, heapSize: array.count, index: i, swapCount: &swapCount)
    }
    
    // Heap sort
    for i in stride(from: array.count - 1, to: 0, by: -1) {
        array.swapAt(0, i)
        swapCount += 1
        heapify(array: &array, heapSize: i, index: 0, swapCount: &swapCount)
    }
    
    return swapCount
}

func heapify(array: inout [Int], heapSize: Int, index: Int, swapCount: inout Int) {
    var largest = index
    let left = 2 * index + 1
    let right = 2 * index + 2
    
    if left < heapSize && array[left] > array[largest] {
        largest = left
    }
    
    if right < heapSize && array[right] > array[largest] {
        largest = right
    }
    
    if largest != index {
        array.swapAt(index, largest)
        swapCount += 1
        heapify(array: &array, heapSize: heapSize, index: largest, swapCount: &swapCount)
    }
}

func quickSort(array: inout [Int], start:Int, stop:Int, colorCount: inout Int){

    if start < stop{
        var pivot = array[stop]
        var redIndex = start
        var curIndex = stop
        var blueIndex = stop

        while curIndex >= redIndex {
            colorCount += 1
            if array[curIndex] < pivot{
                array.swapAt(redIndex, curIndex)
                //array.swapAt(redIndex, curIndex)
                redIndex += 1
            }
            else if array[curIndex] > pivot{
                array.swapAt(curIndex, blueIndex)
                //array.swapAt(curIndex, blueIndex)
                blueIndex -= 1
                curIndex -= 1
            }
            else{
                curIndex -= 1
            }
        }
        quickSort(array: &array, start: start, stop: redIndex - 1, colorCount: &colorCount)
        quickSort(array: &array, start: blueIndex + 1, stop: stop, colorCount: &colorCount)
    }
}








var Increasing20Array:[Int] = []
for i in 0..<20{
    Increasing20Array.append(i)
}

var Increasing2000Array:[Int] = []
for i in 0..<2000{
    Increasing2000Array.append(i)
}

var Decreasing20Array:[Int] = Increasing20Array.reversed()
var Decreasing2000Array:[Int] = Increasing2000Array.reversed()
Decreasing2000Array.sort()

var Random20Array = [877]


for i in 1...19 {
    let xi = (Random20Array[i-1] + 877) % 2027
    Random20Array.append(xi)
}

var RandomArray2000 = [877]
for i in 1...1999 {
    let xi = (RandomArray2000[i-1] + 877) % 2027
    RandomArray2000.append(xi)
}





//insertionSort(array: Increasing20Array)//0
//insertionSort(array: Increasing2000Array)//0
//insertionSort(array: Random20Array)//90
//insertionSort(array: RandomArray2000)// 999208
//insertionSort(array: Decreasing20Array) //190

//insertionSort(array: Decreasing2000Array)//1999000


//heapSort(array: &Increasing20Array)//80
//  heapSort(array: &Increasing2000Array)//21300
// heapSort(array: &Decreasing20Array)//62
//heapSort(array: &Decreasing2000Array)//18708
//heapSort(array: &Random20Array)//76
//heapSort(array: &RandomArray2000)//20234

var count = 0
//quickSort(array: &Increasing20Array, start: 0, stop: Increasing20Array.count - 1, colorCount: &count)//108

//count = 0
//quickSort(array: &Increasing2000Array, start: 0, stop: Increasing2000Array.count-1, colorCount: &count)//99896

//count = 0
//
//quickSort(array: &Decreasing20Array, start:0 , stop: Decreasing20Array.count - 1, colorCount: &count)//209

//count = 0
//

quickSort(array: &Decreasing2000Array, start: 0, stop: Decreasing2000Array.count - 1, colorCount: &count)//23801
//
////count = 0
//quickSort(array: &Random20Array, start: 0, stop: Random20Array.count - 1, colorCount: &count)//83
//
//count = 0
//quickSort(array: &RandomArray2000, start: 0, stop: RandomArray2000.count - 1, colorCount: &count)//25724



