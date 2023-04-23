//
//  NightOutTests.swift
//  NightOutTests
//
//  Created by Kyle Zeller on 1/11/23.
//

/* Testing Structure
 
 given -> when -> then
 */

import XCTest
@testable import NightOut

final class ClassPostViewModelTesting: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPostArrayCanSet()  {
        //given: there is an array of posts
        let post1: ClassPost = ClassPost(postBody: "", postAuthor: "", forClass: "", votes: 0, id: "")
        var array: [ClassPost] = [post1]
        
        //when there is a viewmodel
        var posts: ClassPostsViewModel = ClassPostsViewModel()
         
        //then: we can set the vm post propperty to the array
        posts.postsArray = array
        
        XCTAssertEqual(posts.postsArray.count, array.count)
        //add a new post, check again
        
        let post2: ClassPost = ClassPost(postBody: "1", postAuthor: "1", forClass: "1", votes: 1, id: "1")
        array.append(post2)
        posts.postsArray = array
        XCTAssertEqual(posts.postsArray.count, array.count)
        
        //remove an element
        array.removeLast()
        posts.postsArray = array
        XCTAssertEqual(posts.postsArray.count, array.count)
      
    }
    
    func testPostArrayCanBeAccessed(){
    //given: there is a viewmodel
        var posts:ClassPostsViewModel = ClassPostsViewModel()
        
        //when: there are posts in the array
        let post1: ClassPost = ClassPost(postBody: "", postAuthor: "", forClass: "", votes: 0, id: "")
        posts.postsArray.append(post1)
        
        //Then: we can access the postsArray
        var array :[ClassPost] = []
        XCTAssertEqual(array.count,0)
        
        //set array equal to postsArray
        array = posts.postsArray
        XCTAssertEqual(array.count,posts.postsArray.count)
        
        //add another element
        let post2: ClassPost = ClassPost(postBody: "1", postAuthor: "1", forClass: "1", votes: 1, id: "1")
        posts.postsArray.append(post2)
        
        var arr2 = posts.postsArray
        XCTAssertEqual(arr2.count,posts.postsArray.count)
        
        //remove all
        
        posts.postsArray.removeAll()
        array = posts.postsArray
        
        XCTAssertEqual(array.count,posts.postsArray.count)
        
        
    }
    
    
}
