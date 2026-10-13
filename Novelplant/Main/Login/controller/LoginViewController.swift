//
//  LoginViewController.swift
//  novelplant
//
//  Created by hehe on 2026/10/9.
//

import UIKit
import AuthenticationServices

class LoginViewController: BaseViewController {

    /// 是否已勾选用户协议（审核合规：未勾选不允许发起登录）
    private var isAgreed = false

    override func viewDidLoad() {
        super.viewDidLoad()
        hiddenNavigationBar = true
        initView()
        initFrame()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // layer.borderColor 不跟随深浅模式自动更新，需手动刷新（UI-Style-Guide §2）
        agreeCheckBox.layer.borderColor = UIColor.separatorColor.cgColor
    }

    func initView() {
        view.addSubview(closeButton)
        view.addSubview(logoContainerView)
        logoContainerView.addSubview(logoImageView)
        view.addSubview(sloganLabel)
        view.addSubview(appleButton)
        view.addSubview(agreementStackView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleAgreed))
        agreementStackView.addGestureRecognizer(tap)
    }

    func initFrame() {
        closeButton.snp.makeConstraints { make in
            make.size.equalTo(44)
            make.left.equalTo(4)
            make.top.equalToSuperview().offset(safeAreaTopSpace)
        }

        logoContainerView.snp.makeConstraints { make in
            make.size.equalTo(80)
            make.centerX.equalToSuperview()
            make.top.equalTo(closeButton.snp.bottom).offset(64)
        }
        logoImageView.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.center.equalToSuperview()
        }

        sloganLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoContainerView.snp.bottom).offset(16)
        }

        appleButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.bottom.equalTo(agreementStackView.snp.top).offset(-12)
        }

        agreementStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(safeAreaBottomSpace + 24))
        }
        agreeCheckBox.snp.makeConstraints { make in
            make.size.equalTo(20)
        }
    }

    // MARK: - 事件

    @objc private func closeTapped() {
        if presentingViewController != nil {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    @objc private func toggleAgreed() {
        isAgreed.toggle()
        agreeCheckBox.isSelected = isAgreed
        agreeCheckBox.backgroundColor = isAgreed ? .themeColor : .clear
    }

    @objc private func appleLoginTapped() {
        guard isAgreed else {
            XHToastManager.makeToast(NSLocalizedString("Please agree to the User Agreement and Privacy Policy first", comment: ""))
            return
        }
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    /// 协议/隐私页 H5 待接入，先占位提示
    @objc private func agreementLinkTapped() {
        XHToastManager.makeToast(NSLocalizedString("Coming soon", comment: ""))
    }

    // MARK: - 登录请求

    private func requestAppleLogin(userId: String,
                                   displayName: String,
                                   givenName: String,
                                   familyName: String,
                                   email: String,
                                   userToken: String) {
        XHToastManager.makeToastActivity()
        NetWorkRequest(LoginManager.appleLogin(userId: userId,
                                               displayName: displayName,
                                               givenName: givenName,
                                               familyName: familyName,
                                               email: email,
                                               userToken: userToken)) { result in
            XHToastManager.hideToastActivity()
            guard let json = result as? [String: Any] else { return }
            let loginModel = json.kj.model(LoginModel.self)
            guard !loginModel.token.isEmpty else {
                XHToastManager.makeToast(NSLocalizedString("Login failed", comment: ""))
                return
            }
            let user = User()
            user.id = "\(loginModel.user?.uid ?? 0)"
            user.token = loginModel.token
            User.saveUserInfo(model: user)
            XHToastManager.makeToast(NSLocalizedString("Login successful", comment: ""))
            self.closeTapped()
        } failed: { _, _ in
            // 失败文案网络层已统一 toast（UI-Style-Guide §6.6），此处只收 loading
            XHToastManager.hideToastActivity()
        }
    }
    
    
    private lazy var closeButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.tintColor = .textSecondaryColor
        btn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var logoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .cellBgColor
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()

    private lazy var logoImageView: UIImageView = {
        let img = UIImageView()
        // 优先 Assets 同名切图，缺失回落 SF Symbols（与 tabbar 图标同款回落链）
        img.image = UIImage(named: "logo") ?? UIImage(systemName: "books.vertical.fill")
        img.tintColor = .themeColor
        img.contentMode = .scaleAspectFit
        return img
    }()

    private lazy var sloganLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Sign in to sync your books", comment: "")
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .textSecondaryColor
        return label
    }()

    private lazy var appleButton: UIButton = {
        // 不用系统 ASAuthorizationAppleIDButton：其点按由系统直接拉起授权，无法在发起前拦截协议勾选校验；
        // 按 Apple HIG 用 apple.logo + 官方文案自绘等价样式
        // 不走 adjustImageTitlePosition：configuration 迁移不覆盖 titleColor/font，此按钮需精确还原官方样式
        let btn = UIButton(type: .custom)
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "apple.logo")
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.attributedTitle = AttributedString(
            NSLocalizedString("Sign in with Apple", comment: ""),
            attributes: AttributeContainer([.font: UIFont.systemFont(ofSize: 16, weight: .semibold)])
        )
        config.baseForegroundColor = .appleBtnTitleColor
        btn.configuration = config
        btn.backgroundColor = .appleBtnBgColor
        btn.layer.cornerRadius = 22
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(appleLoginTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var agreementStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [agreeCheckBox, agreePrefixLabel, termsButton, policyButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        stack.isUserInteractionEnabled = true
        return stack
    }()

    private lazy var agreeCheckBox: UIButton = {
        let btn = UIButton(type: .custom)
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.separatorColor.cgColor
        btn.setImage(UIImage(systemName: "checkmark",
                             withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)), for: .selected)
        btn.tintColor = .onThemeColor
        btn.addTarget(self, action: #selector(toggleAgreed), for: .touchUpInside)
        return btn
    }()

    private lazy var agreePrefixLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("I have read and agreed to", comment: "")
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .textTertiaryColor
        return label
    }()

    private lazy var termsButton: UIButton = {
        let btn = UIButton(title: NSLocalizedString("《User Agreement》", comment: ""),
                           titleColor: .themeColor,
                           titleFont: 12)
        // 撑大点击热区（UI-Style-Guide §4.2）
        btn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        btn.addTarget(self, action: #selector(agreementLinkTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var policyButton: UIButton = {
        let btn = UIButton(title: NSLocalizedString("《Privacy Policy》", comment: ""),
                           titleColor: .themeColor,
                           titleFont: 12)
        btn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        btn.addTarget(self, action: #selector(agreementLinkTapped), for: .touchUpInside)
        return btn
    }()
}

// MARK: - ASAuthorizationControllerDelegate
extension LoginViewController: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        // 参数对齐老项目 LoginViewController.m：display_name 拼「姓+名」，空值传空串
        let familyName = credential.fullName?.familyName ?? ""
        let givenName = credential.fullName?.givenName ?? ""
        let email = credential.email ?? ""
        let identityToken = credential.identityToken.flatMap { String(data: $0, encoding: .utf8) } ?? ""
        requestAppleLogin(userId: credential.user,
                          displayName: familyName + givenName,
                          givenName: givenName,
                          familyName: familyName,
                          email: email,
                          userToken: identityToken)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 用户主动取消静默处理，其余情况提示
        guard (error as? ASAuthorizationError)?.code == .canceled else {
            XHToastManager.makeToast(NSLocalizedString("Authorization failed", comment: ""))
            return
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window ?? keyWindow ?? ASPresentationAnchor()
    }
}

