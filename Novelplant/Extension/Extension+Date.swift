//
//  Extension+Date.swift
//  Moyi
//
//  Created by hehe on 2023/3/9.
//

import Foundation

extension Date {
    
    // 获取当前 秒级 时间戳 - 10位
    var timeStamp : String {
        let timeInterval: TimeInterval = timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return "\(timeStamp)"
    }
    
    var milliStamp: String {
        let timeInterval: TimeInterval = timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return "\(millisecond)"
    }
    
    //时间戳转时间
    static func timeStampToString(timeStamp: String, dateFormat: String) -> String {
        
        let string = NSString(string: timeStamp)
        
        let timeSta:TimeInterval = string.doubleValue
        let dfmatter = DateFormatter()
        //"yyyy年MM月dd日"
        dfmatter.dateFormat=dateFormat
        
        let date = NSDate(timeIntervalSince1970: timeSta)
        
        return dfmatter.string(from: date as Date)
    }
    
    //与当前时间对比
    static func compareCurrntTime(timeStamp: String) -> String {
        
        //计算出时间戳距离现在时间的一个秒数(..s)
        
        let interval: TimeInterval = TimeInterval.init(timeStamp)!
        
        let date = Date(timeIntervalSince1970: interval)
        
        var timeInterval = date.timeIntervalSinceNow
        
        //得到的是一个负值 (加' - ' 得正以便后面计算)
        
        timeInterval = -timeInterval
        
        //根据时间差 做所对应的文字描述 (作为返回文字描述)
        
        var result: String
        
        //一分钟以内
        
        if interval < 60 {
            result = "刚刚"
            
            return result
            
        } else if Int(timeInterval/60) < 60 {
            
            //一小时以内
            
            result=String.init(format:"%@分钟前",String(Int(timeInterval/60)))
            
            return result
            
        } else if Int((timeInterval/60)/60) < 24 {
            //一天以内
            
            result = String.init(format:"%@小时前",String(Int((timeInterval/60)/60)))
            
            return result
            
        } else if Int((timeInterval/60)/60)/24 < 30 {
            //一天以内
            
            result = String.init(format:"%@天前",String(Int((timeInterval/60)/60)/24))
            
            return result
            
        } else {
            
            //超过30天的
            
            let dateformatter = DateFormatter()
            
            //自定义日期格式
            
            dateformatter.dateFormat = "MM月dd日"
            
            result = dateformatter.string(from: date as Date)
            
            return result
            
        }
        
    }
    /**
     *  是否为今天
     */
    var isToday: Bool{
        let calendar = Calendar.current
        let unit: Set<Calendar.Component> = [.day,.month,.year]
        let nowComps = calendar.dateComponents(unit, from: Date())
        let selfCmps = calendar.dateComponents(unit, from: self)
        
        return (selfCmps.year == nowComps.year) &&
        (selfCmps.month == nowComps.month) &&
        (selfCmps.day == nowComps.day)
        
    }
     
    /**
     *  是否为昨天
     */
    var isYesterday: Bool {
        let calendar = Calendar.current
        let unit: Set<Calendar.Component> = [.day,.month,.year]
        let nowComps = calendar.dateComponents(unit, from: Date())
        let selfCmps = calendar.dateComponents(unit, from: self)
        if selfCmps.day == nil || nowComps.day == nil {
            return false
        }
        let count = nowComps.day! - selfCmps.day!
        return (selfCmps.year == nowComps.year) &&
            (selfCmps.month == nowComps.month) &&
            (count == 1)
    }
     
    ///只有年月日的字符串
    var dataWithYMD: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let selfStr = fmt.string(from: self)
//        let result = fmt.date(from: selfStr)!
        return selfStr
    }
    
    ///获取当前年月日的时间戳
    var timeIntervalWithYMDDate: TimeInterval {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let selfStr = fmt.string(from: self)
        let result = fmt.date(from: selfStr)!
        return result.timeIntervalSinceReferenceDate + 24 * 60 * 60
    }
    /**
     *  是否为今年
     */
    var isThisYear: Bool {
        let calendar = Calendar.current
        let nowCmps = calendar.dateComponents([.year], from: Date())
        let selfCmps = calendar.dateComponents([.year], from: self)
        let result = nowCmps.year == selfCmps.year
        return result
    }
    /**
     *  获得与当前时间的差距
     */
    var deltaWithNow: DateComponents{
        let calendar = Calendar.current
        let cmps = calendar.dateComponents([.hour,.minute,.second], from: self, to: Date())
        return cmps
    }
}
