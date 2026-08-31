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

    override public func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 17.0, *) {
            if let windowScene = view.window?.windowScene {
                windowScene.registerForTraitChanges(
                    [UITraitPreferredContentSizeCategory.self],
                ) { [weak self] (_: any UITraitEnvironment, _: UITraitCollection) in
                    self?.applyCurrentTextSize()
                }
            } else {
                registerForTraitChanges(
                    [UITraitPreferredContentSizeCategory.self],
                ) { [weak self] (_: any UITraitEnvironment, _: UITraitCollection) in
                    self?.applyCurrentTextSize()
                }
            }
        }
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #unavailable(iOS 17.0) {
            applyCurrentTextSize()
        }
    }

    // MARK: Private

    /// Reapplies the current text size, guarding against trait change recursion.
    private func applyCurrentTextSize() {
        guard !isApplyingTextSize else { return }

        isApplyingTextSize = true
        applyTextSize(textSize)
        isApplyingTextSize = false
    }
}
