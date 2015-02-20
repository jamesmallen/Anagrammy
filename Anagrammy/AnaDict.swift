//
//  AnaDict.swift
//  Anagrammy
//
//  Created by James Allen on 2/2/15.
//  Copyright (c) 2015 James Allen. All rights reserved.
//

import Foundation


let dictionaryLoadingNotificationKey = "net.jamesmallen.Anagrammy.dictionaryLoading"
let dictionaryLoadedNotificationKey = "net.jamesmallen.Anagrammy.dictionaryLoaded"


let concurrentDictQueue = dispatch_queue_create("net.jamesmallen.Anagrammy.dictionaryQueue", DISPATCH_QUEUE_CONCURRENT)



// http://stackoverflow.com/questions/24581517/read-a-file-url-line-by-line-in-swift
class StreamReader : SequenceType {
    let encoding: UInt
    let chunkSize: Int
    
    
    var fileHandle: NSFileHandle!
    let buffer: NSMutableData!
    let delimData: NSData!
    var atEof: Bool = false
    
    init?(path: String, delimiter: String="\n", encoding: UInt=NSUTF8StringEncoding, chunkSize: Int=4096) {
        self.chunkSize = chunkSize
        self.encoding = encoding
        
        if let fileHandle = NSFileHandle(forReadingAtPath: path) {
            self.fileHandle = fileHandle
        } else {
            return nil
        }
        
        if let delimData = delimiter.dataUsingEncoding(encoding) {
            self.delimData = delimData
        } else {
            return nil
        }
        
        if let buffer = NSMutableData(capacity: chunkSize) {
            self.buffer = buffer
        } else {
            return nil
        }
    }
    
    deinit {
        self.close()
    }
    
    func nextLine() -> String? {
        if atEof {
            return nil
        }
        
        var range = buffer.rangeOfData(delimData, options: nil, range: NSMakeRange(0, buffer.length))
        
        while range.location == NSNotFound {
            var tmpData = fileHandle.readDataOfLength(chunkSize)
            if tmpData.length == 0 {
                // EOF or read error
                atEof = true
                if buffer.length > 0 {
                    let line = NSString(data: buffer, encoding: encoding)
                    buffer.length = 0
                    return line
                } else {
                    // no more lines
                    return nil
                }
            }
            buffer.appendData(tmpData)
            range = buffer.rangeOfData(delimData, options: nil, range: NSMakeRange(0, buffer.length))
        }
        
        let line = NSString(data: buffer.subdataWithRange(NSMakeRange(0, range.location)), encoding: encoding)
        buffer.replaceBytesInRange(NSMakeRange(0, range.location + range.length), withBytes: nil, length: 0)
        
        return line
    }
    
    func rewind() -> Void {
        fileHandle.seekToFileOffset(0)
        buffer.length = 0
        atEof = false
    }
    
    func close() -> Void {
        if fileHandle != nil {
            fileHandle.closeFile()
            fileHandle = nil
        }
    }
    
    func generate() -> GeneratorOf<String> {
        return GeneratorOf<String> {
            return self.nextLine()
        }
    }
    
    
}

struct WordHistogram {
    var histogram: [Character: Int]
    
    init(word: String) {
        histogram = [Character: Int]()
        for uni in word.lowercaseString.unicodeScalars {
            if NSCharacterSet.letterCharacterSet().longCharacterIsMember(uni.value) {
                ++self[Character(uni)]
            }
        }
    }
    
    subscript(index: Character) -> Int {
        get {
            if let ret = histogram[index] {
                return ret
            } else {
                return 0
            }
        }
        set(newValue) {
            histogram[index] = newValue
        }
    }
    
    var count: Int {
        get {
            var ret = 0
            for (key, value) in histogram {
                ret += value
            }
            return ret
        }
    }
    
}

extension String {
    var length: Int {
        return Array(self).count
    }
    
    var lengthOfLettersOnly: Int {
        var count = 0
        for uni in self.unicodeScalars {
            if NSCharacterSet.letterCharacterSet().longCharacterIsMember(uni.value) {
                ++count
            }
        }
        return count
    }
    
    func substringToIndex(to: Int) -> String {
        return self.substringToIndex(advance(self.startIndex, to))
    }
    
    func removeString(sub: String) -> String {
        var histogram = WordHistogram(word: sub)
        
        var ret = ""
        for c in self {
            if histogram[c] == 0 {
                ret += String(c)
            } else {
                --histogram[c]
            }
        }
        
        return ret
    }
}


class AnaNode2 {
    var letter: Character?
}




class AnaNode {
    var letter: Character?
    var depth: Int
    var words: [String]?
    var children: [Character: AnaNode]
    //var root: AnaNode
    let MIN_WORD_SIZE = 1
    
    
    
    class func getHistogram(word: String) -> [Character: Int] {
        var ret = [Character: Int]()
        // word.lowercaseString.unicodeScalars.st
        for uni in word.lowercaseString.unicodeScalars {
            if NSCharacterSet.letterCharacterSet().longCharacterIsMember(uni.value) {
                let currentLetter = Character(uni)
                if ret[currentLetter] == nil {
                    ret[currentLetter] = 1
                } else {
                    ++ret[currentLetter]!
                }
            }
        }
        return ret
    }
    
    init(letter: Character? = nil, depth: Int = 0, words: [String]? = nil, root: AnaNode? = nil) {
        self.letter = letter
        self.depth = depth
        self.words = words
        self.children = [Character: AnaNode]()
        
    }
    
    func add(word: String) {
        var node: AnaNode = self
        var currentDepth = node.depth
        
        for uni in word.lowercaseString.unicodeScalars {
            if NSCharacterSet.letterCharacterSet().longCharacterIsMember(uni.value) {
                let currentLetter = Character(uni)
                var child: AnaNode! = node.children[currentLetter]
                ++currentDepth
                if child == nil {
                    child = AnaNode(letter: currentLetter, depth: currentDepth)
                    node.children[currentLetter] = child
                }
                node = child
            }
        }
        
        if node.words == nil {
            node.words = [word]
        } else {
            node.words!.append(word)
        }
    }
    
    // http://stackoverflow.com/questions/55210/algorithm-to-generate-anagrams
    func anagram(word: String) -> [String] {
        
        //return _anagram(AnaNode.getHistogram(word), path: [String](), root: self, minLength: word.lengthOfLettersOnly)
        return _anagram2(WordHistogram(word: word), minLength: 2)
    }
    
    
    //func
    
    func _anagram2(var histogram: WordHistogram, minLength: Int, onlyComplete: Bool = true) -> [String] {
        var ret = [String]()
        
        if self.words != nil && self.depth >= min(minLength, MIN_WORD_SIZE) {
            // TODO: look to see if there is at least one "path" to use all the letters
            for word in self.words! {
                if onlyComplete {
                    if hasACompleteAnagramChild(histogram) {
                        ret.append(word)
                    }
                } else {
                    ret.append(word)
                }
            }
            // ret.extend(self.words!)
        }
        
        for (letter, node) in self.children {
            if histogram[letter] > 0 {
                --histogram[letter]
                
                for word in node._anagram2(histogram, minLength: minLength) {
//                    if onlyComplete {
//                          if hasACompleteAnagramChild(histogram) {
                    ret.append(word)
 //                       }
 //                   } else {
 //                       ret.append(word)
 //                   }
                }
                
                // ret.extend(node._anagram2(histogram, minLength: minLength))
                ++histogram[letter]
            }
        }
        
        return ret
    }
    
    func hasACompleteAnagramChild(var histogram: WordHistogram) -> Bool {
        if self.words != nil && histogram.count == 0 {
            return true
        } else {
            for (letter, node) in self.children {
                if histogram[letter] > 0 {
                    --histogram[letter]
                    if node.hasACompleteAnagramChild(histogram) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    
    
    
    func _anagram(var histogram: [Character: Int], var path: [String], root: AnaNode, minLength: Int) -> [String] {
        var ret = [String]()
        if self.words != nil && self.depth >= min(minLength, MIN_WORD_SIZE) {
            
            let prefix = "".join(path)
            
            for word in self.words! {
                let newWord = prefix + word + " "
                if newWord.lengthOfLettersOnly >= minLength {
                    ret.append(newWord)
                } else {
                    path.append(newWord)
                    ret.extend(root._anagram(histogram, path: path, root: root, minLength: minLength))
                    path.removeLast()
                }
            }
            
        }
        for (letter, node) in self.children {
            
            var count: Int? = histogram[letter]
            if count == nil || count == 0 {
                continue
            } else {
                histogram[letter] = count! - 1
                ret.extend(node._anagram(histogram, path: path, root: root, minLength: minLength))
                histogram[letter] = count!
            }
            
        }
        
        return ret
    }
    
}

class AnaDict {
    var anaTrie = AnaNode()
    
    init(wordsFile: String) {
        loadWords(wordsFile)
    }
    
    func addWord(word: String) {
        anaTrie.add(word)
    }
    
    func loadWords(wordsFile: String) {
        dispatch_async(dispatch_get_main_queue()) {
            NSNotificationCenter.defaultCenter().postNotificationName(dictionaryLoadingNotificationKey, object: self)
        }
        println("Attempting to load \(wordsFile)...")
        var wordCount = 0
        if let aStreamReader = StreamReader(path: wordsFile) {
            for line in aStreamReader {
                addWord(line)
                ++wordCount
                if wordCount % 1000 == 0 {
                    println("Word \(wordCount): \(line)")
                }
            }
        } else {
            println("failed")
        }
        dispatch_async(dispatch_get_main_queue()) {
            NSNotificationCenter.defaultCenter().postNotificationName(dictionaryLoadedNotificationKey, object: self)
        }
    }
    
    
    func getAnagrams(word: String) -> [String] {
        return anaTrie.anagram(word)
    }
}
