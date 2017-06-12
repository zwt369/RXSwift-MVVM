//
//  RegisteViewModel.swift
//  RXSwift+MVVM
//
//  Created by Tony Zhang on 17/6/11.
//  Copyright © 2017年 Tony Zhang. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class RegisteViewModel {

     // MARK: - 用户名处理
    //input:
    let name = Variable<String>("")	//初始值为""
    // output:
    let nameUseable: Observable<Result>
    
     // MARK: - 密码
    //input:
    let password = Variable<String>("")	//初始值为""
    let repeatPassword = Variable<String>("")	//初始值为""
    // output:
    let passwordUseable: Observable<Result>
    let repeatPasswordUseable: Observable<Result>
    
    // MARK: - 按钮
    //input:
    let registerTaps = PublishSubject<Void>()
    // output:
    let registerButtonEnabled: Observable<Bool>
    let registerResult: Observable<Result>
    
    init() {
        let manager = ValidationManager.instance
        nameUseable = name.asObservable().flatMapLatest{ name  in
            return manager.validateUsername(name).observeOn(MainScheduler.instance).catchErrorJustReturn(.failed(message:"username检测出错")).shareReplay(1)
        }
        
        passwordUseable = password.asObservable().map{ password in
            return manager.validatePassword(password)
        }.shareReplay(1)
        
        
        repeatPasswordUseable = Observable.combineLatest(password.asObservable(),repeatPassword.asObservable()){
            return manager.validateRepeatedPassword($0, repeatedPasswordword: $1)
        }.shareReplay(1)
        
        registerButtonEnabled = Observable.combineLatest(nameUseable, passwordUseable, repeatPasswordUseable){(name,password,repeatPassword) in
            name.isValid && password.isValid && repeatPassword.isValid
        }.distinctUntilChanged().shareReplay(1)
        
        let nameAndPassword = Observable.combineLatest(name.asObservable(),password.asObservable()){
            ($0,$1)
        }
        
        registerResult = registerTaps.asObservable().withLatestFrom(nameAndPassword).flatMapLatest{(name,password) in
            return manager.registerSucess(name:name,password: password).observeOn(MainScheduler.instance).catchErrorJustReturn(.failed(message: "注册出错"))
            }.shareReplay(1)
        
    }
    

}


 // MARK: - 业务逻辑处理
class ValidationManager{

    static let instance = ValidationManager()
    
    private init() {}
    
    //这里面我们返回一个Observable对象，因为我们这个请求过程需要被监听。用户名逻辑
    func validateUsername(_ username: String) -> Observable<Result> {
        if username.characters.count == 0 {//当字符等于0的时候什么都不做
            return .just(.empty(message: "用户名不少于5个字符"))
        }
        if username.characters.count < 5 {//当字符小于5的时候返回failed
            return .just(.failed(message: "用户名长度不少于5个字符"))
        }
        return .just(.passed(message: "用户名可用"))
    }
    
     //密码逻辑
    func validatePassword(_ password: String) -> Result {
        if password.characters.count == 0 {
            return .empty(message: "密码长度不少于6个字符")
        }
        if password.characters.count < 6 {
            return .failed(message: "密码长度不少于6个字符")
        }
        return .passed(message: "密码可用")
    }
    
      //重复密码逻辑
    func validateRepeatedPassword(_ password: String, repeatedPasswordword: String) -> Result {
        switch repeatedPasswordword.characters.count {
        case 0:
            return .empty(message: "密码长度不少于6个字符")
        case password.characters.count:
            if password == repeatedPasswordword {
                return .passed(message: "密码可用")
            }else{
                return .failed(message: "两次密码不一致")
            }
        default:
            if repeatedPasswordword.characters.count>password.characters.count {
                return .failed(message: "两次密码不一致")
            }else{
                return .failed(message: "密码长度不少于6个字符")
            }
        }
    }
    
     // MARK: - 点击事件
    func registerSucess(name:String,password:String) -> Observable<Result> {
        print("点击了按钮")
        return Observable.just(.passed(message:"注册成功"))
    }

    
   
    
}
