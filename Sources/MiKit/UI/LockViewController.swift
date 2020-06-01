// LockViewController.swift
// This file is part of MiKee.
//
// Copyright © 2019 Maxime Epain. All rights reserved.
//
// MiKee is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// MiKee is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with MiKee. If not, see <https://www.gnu.org/licenses/>.

import UIKit
import Resources
import KeePassKit
import LocalAuthentication
import FontAwesome_swift

open class LockViewController: UIViewController {

    public var database: Database? {
        didSet {
            databaseLabel?.text = database?.name
            keyField?.text = database?.key?.name

            emptyStateView?.isHidden = database != nil
            databaseView?.isHidden = database == nil
        }
    }

    @IBOutlet weak var iconView: UIImageView?
    @IBOutlet weak var formView: UIView?
    @IBOutlet weak var emptyStateView: UIView!

    @IBOutlet weak var selectDatabaseLabel: UILabel!

    @IBOutlet weak var databaseView: UIView!
    @IBOutlet weak var databaseTitleLabel: UILabel!
    @IBOutlet public weak var databaseLabel: UILabel?
    @IBOutlet public weak var keyField: UITextField?

    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var passwordTitleLabel: UILabel!
    @IBOutlet public weak var passwordField: UITextField?

    @IBOutlet weak var unlockButton: UIButton!

    @IBOutlet public weak var formBottomConstraint: NSLayoutConstraint?

    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Asset.background.color
        formView?.backgroundColor = Asset.background.color

        iconView?.image = Asset.miKee.image

        selectDatabaseLabel.textColor = Asset.grey.color
        selectDatabaseLabel.text = L10n.selectAPasswordDatabase

        databaseView.backgroundColor = Asset.background.color
        databaseTitleLabel.textColor = Asset.grey.color
        databaseTitleLabel.text = L10n.databaseName

        keyField?.textColor = Asset.purple.color
        keyField?.placeholder = L10n.selectKeyFile

        passwordTitleLabel.textColor = Asset.grey.color
        passwordTitleLabel.text = L10n.masterPassword

        passwordField?.textColor = Asset.purple.color
        passwordField?.tintColor = Asset.purple.color

        passwordView.backgroundColor = Asset.background.color
        emptyStateView.backgroundColor = Asset.background.color

        unlockButton.backgroundColor = Asset.purple.color
        unlockButton.setTitle(L10n.unlock, for: .normal)
        unlockButton.setTitleColor(.white, for: .normal)

        database = Settings.LastDatabase

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground(notification:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)

        guard let database = database else { return }

        if database.lockIfNeeded() {
            unlock()

        } else if database.hasPassword {
            formView?.alpha = 0
            open(database: database)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        passwordField?.text = nil

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    open func open(tree: KPKTree, animated: Bool = true, completion: (() -> Void)? = nil) {
        fatalError("not implemented")
    }

    private func open(database: Database, animated: Bool = true, completion: (() -> Void)? = nil) {

        startLoading()

        database.open { result in

            switch result {
            case .success(let tree):
                self.stopLoading()
                Settings.LastDatabaseName = database.name
                self.open(tree: tree, animated: animated, completion: self.presentForm)

            case .failure(let error):
                self.presentForm()
                error.show()
                database.password = nil
                try? database.archive()
            }

            completion?()
        }
    }

    @IBAction func editPassword(_ sender: Any) {
        passwordField?.becomeFirstResponder()
    }

    @IBAction func unlock(_ sender: Any) {
        guard let password = passwordField?.text else { return }

        guard let database = database else {
            if password == "demo", let demo = Demo() {
                startLoading()
                open(database: demo)
            }
            return
        }

        database.password = password

        open(database: database) {
            self.passwordField?.resignFirstResponder()
        }
    }

    // MARK: - Navigation

    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? UISplitViewController else { return }
        destination.transitioningDelegate = self
    }

    // MARK: - Keyboard

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        let height = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height

        formBottomConstraint?.constant = height
        UIView.animate(withDuration: 0.3, animations: view.layoutIfNeeded)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        formBottomConstraint?.constant = 0
        UIView.animate(withDuration: 0.3, animations: view.layoutIfNeeded)
    }

    @objc func willEnterForeground(notification: NSNotification) {
        guard database?.lockIfNeeded() ?? true else { return }
        presentedViewController?.dismiss(animated: false, completion: unlock)
    }

    // MARK: - Ask User Credentials

    private func unlock() {
        guard let database = database else { return }

        if Settings.Biometrics, database.hasPassword {
            askBiometrics()
        } else {
            askPassword()
        }
    }

    private func askPassword() {
        let delay = isAppExtension ? 0.1 : 0

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.passwordField?.becomeFirstResponder()
        }
    }

    private func askBiometrics() {
        guard let database = database else { return }
        formView?.alpha = 0

        passwordField?.resignFirstResponder()

        let context = LAContext()
        context.localizedCancelTitle = L10n.cancel
        context.localizedFallbackTitle = L10n.enterMasterPassword

        context.authenticate(localizedReason: L10n.unlockMiKee) { result in

            switch result {
            case .success(let success):
                guard success else { return }
                self.startLoading()
                self.open(database: database)

            case .failure:
                self.formView?.alpha = 1
                self.askPassword()
            }
        }
    }

    func startLoading() {
        self.passwordField?.resignFirstResponder()

        UIView.animate(withDuration: 0.2) {
            self.formView?.alpha = 0
        }

        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0.0
        animation.toValue = -Double.pi * 2 //Minus can be Direction
        animation.duration = 1
        animation.repeatCount = .infinity
        iconView?.layer.add(animation, forKey: nil)
    }

    func stopLoading() {
        iconView?.layer.removeAllAnimations()
        iconView?.transform = CGAffineTransform.identity
    }

    func presentForm() {
        stopLoading()
        UIView.animate(withDuration: 0.2) {
            self.formView?.alpha = 1
        }
    }

}

extension LockViewController: UITextFieldDelegate {

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        unlock(textField)
        return true
    }

}

extension LockViewController: UIViewControllerTransitioningDelegate {

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentationAnimator()
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissalAnimator()
    }

    class Animator: NSObject, UIViewControllerAnimatedTransitioning {

        var transitionDuration: Double = 0.3

        func frames(using transitionContext: UIViewControllerContextTransitioning) -> (from: CGRect, to: CGRect) {
            guard let to = transitionContext.viewController(forKey: .to), let from = transitionContext.viewController(forKey: .from) else {
                return (from: CGRect.zero, to: CGRect.zero)
            }
            return (from: transitionContext.initialFrame(for: from), to: transitionContext.finalFrame(for: to))
        }

        // This is used for percent driven interactive transitions, as well as for
        // container controllers that have companion animations that might need to
        // synchronize with the main animation.
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return transitionDuration
        }

        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let to = transitionContext.viewController(forKey: .to), let from = transitionContext.viewController(forKey: .from) else {
                return
            }

            transitionContext.containerView.addSubview(to.view)

            let frames = self.frames(using: transitionContext)

            to.view.frame = frames.to
            UIView.animate(withDuration: transitionDuration, delay: 0, options: [.curveEaseOut], animations: {
                to.view.frame = transitionContext.finalFrame(for: to)
                from.view.frame = frames.from
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        }
    }

    class PresentationAnimator: Animator {

        override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let to = transitionContext.viewController(forKey: .to) else { return }

            to.view.alpha = 0
            transitionContext.containerView.addSubview(to.view)

            to.view.frame = transitionContext.finalFrame(for: to)
            UIView.animate(withDuration: transitionDuration, delay: 0, options: [.curveEaseOut], animations: {
                to.view.alpha = 1
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        }
    }

    class DismissalAnimator: Animator {

        override func frames(using transitionContext: UIViewControllerContextTransitioning) -> (from: CGRect, to: CGRect) {
            var frames = super.frames(using: transitionContext)
            frames.from.origin.y = frames.from.maxY
            frames.to.origin.y = frames.to.minY - frames.to.height
            return frames
        }
    }
}

extension LAContext {

    public static var biometry: LABiometryType {

        let context = LAContext()

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }

        return context.biometryType
    }

    public func authenticate(localizedReason reason: String, completionHandler: @escaping ResultClosure<Bool>) {

        var error: NSError?

        guard canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {

            let result = Result { () -> Bool in
                if let error = error { throw error }
                return false
            }

            return DispatchQueue.main.async { completionHandler(result) }
        }

        let delay = isAppExtension ? 0.5 : 0

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {

            self.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                let result = Result { () -> Bool in
                    if let error = error { throw error }
                    return success
                }
                DispatchQueue.main.async { completionHandler(result) }
            }
        }
    }
}
