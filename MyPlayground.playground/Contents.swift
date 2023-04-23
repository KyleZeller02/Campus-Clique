
import Foundation
func A(first: Int, second: Int) -> Int {
    if first == 0 {
        return second + 1
    } else if first == 1 {
        return second + 2
    }
    else if second == 2{
        return 2*second + 3
    }
    else if first == 3{
        var temp:Double =  pow(2.0, Double(second)+3.0) - 3
        return Int(temp)
    }
    else if second == 0{
        return A(first: first-1,second: A(first: first,second: second - 1))
    }
    else{
        return A(first: first - 1, second: A(first: first, second: second - 1))
    }
    
}

//
//print("A(1,0) : \(A(first: 1, second: 0)) should be 2")
//print("A(0,1) : \(A(first: 0, second: 1)) should be 2")
//
//print("A(1,1) :  \(A(first: 1, second: 1)) should be 3")
//print("A(0,A(1,0) : \(A(first: 0, second: A(first: 1, second: 0))) : should be 3")
//print("A(0, 2) : \(A(first: 0, second: 2)) should be 3")
//
//print("A(1,2) : \(A(first: 1, second: 2)) should be 4")
//print("A(0,A(1,1)) : \(A(first: 0, second: A(first: 1, second: 1))) should be 4")
//print("A(0,3) : \(A(first: 0, second: 3)) should be 4")
//
//


print("\(A(first: 4, second: 1))")

