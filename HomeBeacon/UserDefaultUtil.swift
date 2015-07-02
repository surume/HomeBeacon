//
//  UserDefaultUtil.swift
//  HomeBeacon
//
//  Created by miyamotoshota on 2015/07/02.
//  Copyright (c) 2015年 sururne. All rights reserved.
//

import Foundation

class UserDefaultUtil {
  class func save(obj:AnyObject, key:String) -> Bool {
    let defaults = NSUserDefaults.standardUserDefaults()
    defaults.setObject(obj, forKey: key)
    return defaults.synchronize()
  }

  class func load(key:String) -> AnyObject? {
    let defaults = NSUserDefaults.standardUserDefaults()
    return defaults.objectForKey(key)
  }
}