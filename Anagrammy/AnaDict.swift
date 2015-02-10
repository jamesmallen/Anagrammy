//
//  AnaDict.swift
//  Anagrammy
//
//  Created by James Allen on 2/2/15.
//  Copyright (c) 2015 James Allen. All rights reserved.
//

import Foundation


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
}


class AnaNode {
    var letter: Character?
    var depth: Int
    var words: [String]?
    var children: [Character: AnaNode]
    
    let MIN_WORD_SIZE = 3
    
    
    
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
    
    init(letter: Character? = nil, depth: Int = 0, words: [String]? = nil) {
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
        
        return _anagram(AnaNode.getHistogram(word), path: [String](), root: self, minLength: word.lengthOfLettersOnly)
    }
    
    func _anagram(var histogram: [Character: Int], var path: [String], root: AnaNode, minLength: Int) -> [String] {
        var ret = [String]()
        if self.words != nil && self.depth >= min(minLength, MIN_WORD_SIZE) {
            var word = "".join(path)
            if word.lengthOfLettersOnly >= minLength {
                ret.append(word)
            }
            path.append(" ")
            ret.extend(root._anagram(histogram, path: path, root: root, minLength: minLength))
            path.removeLast()
        }
        for (letter, node) in self.children {
            
            var count: Int? = histogram[letter]
            if count == nil || count == 0 {
                continue
            } else {
                histogram[letter] = count! - 1
                path.append(String(letter))
                ret.extend(node._anagram(histogram, path: path, root: root, minLength: minLength))
                path.removeLast()
                histogram[letter] = count!
            }
            
        }
        
        return ret
    }
    
}

class AnaDict {
    var words = [String: Bool]()
    var anaMap = [String: [String]]()
    
    var anaTrie = AnaNode()
    
    init(wordsFile: String) {
        loadWords(wordsFile)
    }
    
    func addWord(word: String) {
        /*
        let key = AnaDict.keyForWord(word)
        if anaMap[key] != nil {
        anaMap[key]?.append(word)
        } else {
        anaMap[key] = [word]
        }
        */
        anaTrie.add(word)
        words[word] = true
    }
    
    
    class func keyForWord(word: String) -> String {
        var retArr = [String]()
        for uni in word.lowercaseString.unicodeScalars {
            if NSCharacterSet.letterCharacterSet().longCharacterIsMember(uni.value) {
                retArr.append(String(uni))
            }
        }
        
        return "".join(sorted(retArr))
        
    }
    
    
    func loadWords(wordsFile: String) {
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
    }
    
    func wordExists(word: String) -> Bool {
        if let w = self.words[word] {
            return true
        } else {
            return false
        }
    }
    
    class func subpermutations(word: String) -> [String] {
        var ret = [String]()
        if countElements(word) == 1 {
            // base case
            return [word]
        }
        for i in 0..<countElements(word) {
            let idx = advance(word.startIndex, i)
            let kernel = String(word[idx])
            var rest = word.substringToIndex(idx) + word.substringFromIndex(advance(idx, 1))
            let subs = subpermutations(rest)
            for partial in subs {
                ret.append(kernel + partial)
            }
        }
        return ret
    }
    
    func anaPermutations(word: String) -> [String] {
        var ret = [String]()
        if countElements(word) == 1 {
            // base case
            return [word]
        }
        for i in 0..<countElements(word) {
            let idx = advance(word.startIndex, i)
            let kernel = String(word[idx])
            var rest = word.substringToIndex(idx) + word.substringFromIndex(advance(idx, 1))
            let subs = AnaDict.subpermutations(rest)
            for partial in subs {
                let candidate = kernel + partial
                if wordExists(candidate) && find(ret, candidate) == nil {
                    ret.append(candidate)
                }
            }
        }
        return ret
    }
    
    
    func getAnagrams(word: String) -> [String] {
        // return anaPermutations(word)
        /*
        if let ret = anaMap[AnaDict.keyForWord(word)] {
            return ret
        } else {
            return []
        }
*/
        return anaTrie.anagram(word)
    }
}
