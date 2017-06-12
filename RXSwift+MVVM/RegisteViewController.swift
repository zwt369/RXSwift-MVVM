//
//  RegisteViewController.swift
//  RXSwift+MVVM
//
//  Created by Tony Zhang on 17/6/11.
//  Copyright © 2017年 Tony Zhang. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class RegisteViewController: UIViewController {

    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var nameNoteLab: UILabel!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var passwordNoteLab: UILabel!
    
    
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    @IBOutlet weak var repeatNoteLabe: UILabel!
    
    @IBOutlet weak var registeButton: UIButton!
    
     let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewModel = RegisteViewModel()
        // 输入绑定(用户名)
        nameTextField.rx.text.orEmpty.bind(to: viewModel.name).addDisposableTo(disposeBag)
       // 绑定输出(用户名)
        viewModel.nameUseable.bind(to: nameNoteLab.rx.validationResult).addDisposableTo(disposeBag)
        viewModel.nameUseable.bind(to: passwordTextField.rx.inputEnabled).addDisposableTo(disposeBag)
        

        
        passwordTextField.rx.text.orEmpty.bind(to: viewModel.password).addDisposableTo(disposeBag)
        viewModel.passwordUseable.bind(to: passwordNoteLab.rx.validationResult).addDisposableTo(disposeBag)
        viewModel.passwordUseable.bind(to: repeatPasswordTextField.rx.inputEnabled).addDisposableTo(disposeBag)
        
        repeatPasswordTextField.rx.text.orEmpty.bind(to: viewModel.repeatPassword).addDisposableTo(disposeBag)
        viewModel.repeatPasswordUseable.bind(to: repeatNoteLabe.rx.validationResult).addDisposableTo(disposeBag)
        
        registeButton.rx.tap.bind(to: viewModel.registerTaps).addDisposableTo(disposeBag)
        viewModel.registerButtonEnabled.subscribe (onNext: { [unowned self]valid in
            self.registeButton.isEnabled = valid
            self.registeButton.alpha = valid ? 1.0 : 0.5
        }).addDisposableTo(disposeBag)

        viewModel.registerResult.subscribe(onNext:{[unowned self] result in
            switch result {
              case let .passed(message):
                self.showAlert(message: message)
            default:
                break
            }
        } ).addDisposableTo(disposeBag)
    }

    
    func showAlert(message: String) {
        let action = UIAlertAction(title: "确定", style: .default, handler: nil)
        let alertViewController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertViewController.addAction(action)
        present(alertViewController, animated: true, completion: nil)
    }

}
