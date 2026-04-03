//
//  SnapshotTestingConfig.swift
//  PathlyTestss
//
//  Created by Sharon Omoyeni Babatunde on 03/04/2026.
//

import SnapshotTesting
import SwiftUI
import XCTest

public enum SnapshotTestingConfig {
    /// Whether or not to record all new references.
    static var isRecording: Bool = false
    public static var isRecordingInline: Bool = false
}

/// Enum defining the content size strategy.
/// The size of the snapshot can be based either on device screen dimensions, or on the content's intrinsic size.
public enum ContentSizeMode {
    /// Snapshot width is the same as the view's instrinsic width; Snapshot height is the same as the screen height.
    case intrinsicWidth
    /// Snapshot width is the same as the screen width; Snapshot height is the same as view's instrinsic height.
    case intrinsicHeight
    /// Snaphot size is the same as view's intrinsic content size.
    case intrinsicSize
    /// Snapshot size is the same as the screen dimensions.
    case screenDimensions
}

/// Asserts that a given value matches a reference on disk.
///
/// - Parameters:
///   - view: View to be snapshot tested.
///   - name: An optional description of the snapshot.
///   - record: Whether or not to record a new reference.
///   - timeout: The amount of time a snapshot must be generated in.
///   - contentSizeMode: Enum defining the content size strategy.
///     The size of the snapshot can be based either on device screen dimensions, or on the content's intrinsic size.
///   - precision: The percentage of pixels that must match.
///   - perceptualPrecision: The percentage a pixel must match the source pixel to be considered a match.
///     [98-99% mimics the precision of the human eye.](http://zschuessler.github.io/DeltaE/learn/#toc-defining-delta-e)
///   - delay: The amount of time to wait before taking the snapshot.
///   - file: The file in which failure occurred.
///     Defaults to the file name of the test case in which this function was called.
///   - testName: The name of the test in which failure occurred.
///     Defaults to the function name of the test case in which this function was called.
///   - line: The line number on which failure occurred. Defaults to the line number on which this function was called.
public func assertSnapshot<Content: View>(
    view: Content,
    name: String? = nil,
    record recording: Bool = false,
    timeout: TimeInterval = 10,
    contentSizeMode: ContentSizeMode = .intrinsicHeight,
    precision: Float = 1,
    perceptualPrecision: Float = 0.98,
    delay: TimeInterval = 0,
    file: StaticString = #file,
    testName: String = #function,
    line: UInt = #line
) {
    let isRecording = SnapshotTestingConfig.isRecording || recording
    let snapshot = {
        let hostingController = makeHostingController(view: view, contentSizeMode: contentSizeMode)
        let snapshotSize = calculateSnapshotSize(view: hostingController.view, contentSizeMode: contentSizeMode)
        let failureMessage = verifySnapshot(
            of: hostingController,
            as: .wait(for: delay, on: .image(
                precision: precision,
                perceptualPrecision: perceptualPrecision,
                size: snapshotSize
            )),
            named: name,
            record: isRecording,
            timeout: timeout,
            file: file,
            testName: testName,
            line: line
        )
        guard let failureMessage else { return }
        XCTFail(failureMessage, file: file, line: line)
    }

    if isRecording {
        withSnapshotTesting(record: .all, operation: snapshot)
    } else {
        snapshot()
    }
}

// MARK: - Private

private let iphone14ProDeviceWidth: CGFloat = 402
private let iphone14ProDeviceHeight: CGFloat = 874

private func makeHostingController<Content: View>(
    view: Content,
    contentSizeMode: ContentSizeMode
) -> UIHostingController<some View> {
    let reframedView = makeReframedView(view: view, contentSizeMode: contentSizeMode)
    return UIHostingController(rootView: reframedView.ignoresSafeArea())
}

private func makeReframedView<Content: View>(
    view: Content,
    contentSizeMode: ContentSizeMode
) -> AnyView {
    switch contentSizeMode {
    case .intrinsicWidth:
        AnyView(view.frame(height: iphone14ProDeviceHeight))
    case .intrinsicHeight:
        AnyView(view.frame(width: iphone14ProDeviceWidth))
    case .intrinsicSize:
        AnyView(view)
    case .screenDimensions:
        AnyView(view.frame(width: iphone14ProDeviceWidth, height: iphone14ProDeviceHeight))
    }
}

private func calculateSnapshotSize(
    view: UIView,
    contentSizeMode: ContentSizeMode
) -> CGSize {
    let intrinsicContentWidth = view.intrinsicContentSize.width
    let intrinsicContentHeight = view.intrinsicContentSize.height
    switch contentSizeMode {
    case .intrinsicWidth:
        return CGSize(
            width: intrinsicContentWidth,
            height: iphone14ProDeviceHeight
        )
    case .intrinsicHeight:
        return CGSize(
            width: iphone14ProDeviceWidth,
            height: intrinsicContentHeight
        )
    case .intrinsicSize:
        return CGSize(
            width: intrinsicContentWidth,
            height: intrinsicContentHeight
        )
    case .screenDimensions:
        return CGSize(
            width: iphone14ProDeviceWidth,
            height: iphone14ProDeviceHeight
        )
    }
}
