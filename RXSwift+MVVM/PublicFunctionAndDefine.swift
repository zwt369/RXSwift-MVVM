//
//  PublicFunctionAndDefine.swift
//  RXSwift+MVVM
//
//  Created by Tony Zhang on 17/6/11.
//  Copyright © 2017年 Tony Zhang. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

  /** 结果 */
enum Result {
    case passed(message:String)
    case empty(message:String)
    case failed(message:String)
}

extension Result {
    /** 提示语颜色 */
    var textColor: UIColor {
        switch self {
        case .passed:
            return UIColor.green
        default:
            return UIColor.orange
        }
    }
    /** 是否满足业务逻辑 */
    var isValid: Bool {
        switch self {
        case .passed:
            return true
        default:
            return false
        }
    }
    /** 提示语文本 */
    var message: String {
        switch self {
        case let .passed (data):
            return data
        case let .empty(data):
            return data
        case let .failed (data):
            return data
        }
    }
    /** 提示语是否隐藏 */
    var hidden: Bool {
        switch self {
        case .passed:
            return true
        default:
            return false
        }
    }
}


extension Reactive where Base:UILabel{
    /** 监听结果 */
    var validationResult : UIBindingObserver<Base,Result>{
        return UIBindingObserver(UIElement: base, binding: { (label, result) in
            label.textColor = result.textColor
            label.text = result.message
            label.isHidden = result.hidden
        })
    }
}

extension Reactive where Base: UITextField {
     /** 是否满足输入逻辑 */
    var inputEnabled: UIBindingObserver<Base, Result> {
        return UIBindingObserver(UIElement: base) { textFiled, result in
            textFiled.isEnabled = result.isValid
        }
    }
}

extension Reactive where Base:UIButton{
    /** 是否满足注册逻辑 */
    var clickEnabled : UIBindingObserver<Base,Result>{
        return UIBindingObserver(UIElement: base, binding: { (button, result) in
            button.isEnabled = result.isValid
        })
    }
}

