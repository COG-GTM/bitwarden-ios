import UIKit

/// The root view controller for the apps.
///
/// This view controller is the entry point into each application, and all screens for each app
/// are presented within this view controller.
///
public class RootViewController: UIViewController {
    /// The app's theme.
    public var appTheme: AppTheme = .default

    /// The app's text size.
    public var textSize: TextSize = .default {
        didSet {
            applyCurrentTextSize()
        }
    }

    // MARK: Properties

    /// Whether the text size is currently being applied.
    private var isApplyingTextSize = false

    /// The registration for preferred content size category trait changes.
    private var traitChangeRegistration: AnyObject?

    /// The window scene associated with the preferred content size category trait change registration.
    private weak var traitChangeRegistrationScene: UIWindowScene?

    /// The child view controller currently being displayed within this root view controller.
    ///
    /// Setting this value will remove the previously displayed view controller and immediately replace it with
    /// the new value. This replacement is not animated.
    ///
    public var childViewController: UIViewController? {
        didSet {
            dismiss(animated: false)

            if let fromViewController = oldValue {
                fromViewController.willMove(toParent: nil)
                fromViewController.view.removeFromSuperview()
                fromViewController.removeFromParent()
            }

            if let toViewController = childViewController {
                addChild(toViewController)
                view.addConstrained(subview: toViewController.view)
                toViewController.didMove(toParent: self)
                applyCurrentTextSize()
            }
        }
    }

    // MARK: View Lifecycle

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if #available(iOS 17.0, *) {
            registerForTraitChangesIfNeeded()
        }
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #unavailable(iOS 17.0) {
            applyCurrentTextSize()
        }
    }

    // MARK: Private

    /// Registers for preferred content size category trait changes once the view is attached to a window.
    @available(iOS 17.0, *)
    private func registerForTraitChangesIfNeeded() {
        if let windowScene = view.window?.windowScene {
            guard traitChangeRegistrationScene !== windowScene else { return }

            if let traitChangeRegistration = traitChangeRegistration as? any UITraitChangeRegistration {
                if let traitChangeRegistrationScene {
                    traitChangeRegistrationScene.unregisterForTraitChanges(traitChangeRegistration)
                } else {
                    unregisterForTraitChanges(traitChangeRegistration)
                }
            }

            traitChangeRegistration = windowScene.registerForTraitChanges(
                [UITraitPreferredContentSizeCategory.self],
            ) { [weak self] (_: any UITraitEnvironment, _: UITraitCollection) in
                self?.applyCurrentTextSize()
            }
            traitChangeRegistrationScene = windowScene
        } else {
            guard traitChangeRegistration == nil else { return }

            traitChangeRegistration = registerForTraitChanges(
                [UITraitPreferredContentSizeCategory.self],
            ) { [weak self] (_: any UITraitEnvironment, _: UITraitCollection) in
                self?.applyCurrentTextSize()
            }
        }
    }

    /// Reapplies the current text size, guarding against trait change recursion.
    private func applyCurrentTextSize() {
        applyCurrentTextSize(
            systemContentSizeCategory: view.window?.windowScene?.traitCollection.preferredContentSizeCategory,
        )
    }

    func applyCurrentTextSize(systemContentSizeCategory: UIContentSizeCategory?) {
        guard !isApplyingTextSize else { return }

        isApplyingTextSize = true
        applyTextSize(textSize, systemContentSizeCategory: systemContentSizeCategory)
        isApplyingTextSize = false
    }
}
