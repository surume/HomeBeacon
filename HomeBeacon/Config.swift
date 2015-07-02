//
//  Config.swift
//  HomeBeacon
//
//  Created by miyamotoshota on 2015/07/02.
//  Copyright (c) 2015年 sururne. All rights reserved.
//

import Foundation

class Config {
  class Uuid {
    private class func key() -> String {return "beacon_uuid"}
    
    private class func addDelimiter(str:String) -> String {
      var result = str
      result.insert("-", atIndex: advance(str.startIndex, 8))
      result.insert("-", atIndex: advance(str.startIndex, 13))
      result.insert("-", atIndex: advance(str.startIndex, 18))
      result.insert("-", atIndex: advance(str.startIndex, 23))
      return result
    }
    
    class func defaultKey() -> String {return "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA"}
    
    class func load() -> String {
      var result = (UserDefaultUtil.load(self.key()) ?? defaultKey()) as! String
      result.stringByReplacingOccurrencesOfString("-", withString: "", options: nil, range: nil)
      result = addDelimiter(result).uppercaseString
      if NSUUID(UUIDString: result) == nil {
        result = defaultKey()
      }
      return result
    }
    
    class func save(obj:String) -> Bool {
      obj.stringByReplacingOccurrencesOfString("-", withString: "", options: nil, range: nil)
      if count(obj.utf16) != 32 {
        return false
      }
      if NSUUID(UUIDString: addDelimiter(obj)) == nil {
        return false
      }
      return UserDefaultUtil.save(obj, key: self.key())
    }
  }
  
  class UserUuid {
    private class func key() -> String {return "user_uuid"}
   
    private class func initUUID() -> String {
      let uuid = NSUUID().UUIDString
      UserDefaultUtil.save(uuid, key: self.key())
      return uuid
    }
    
    class func load() -> String {
      var result = (UserDefaultUtil.load(self.key()) ?? initUUID()) as! String
      return result
    }
  }
}