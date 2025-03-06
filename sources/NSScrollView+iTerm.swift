//
//  NSScrollView+iTerm.swift
//  iTerm2SharedARC
//
//  Created by George Nachman on 11/21/21.
//

import Foundation

extension NSScrollView {
    @objc static func scrollViewWithTableViewForToolbelt(container: NSView & NSTableViewDelegate & NSTableViewDataSource,
                                                         insets: NSEdgeInsets) -> NSScrollView {
        return scrollViewWithTableViewForToolbelt(container: container, insets: insets, rowHeight: 0)
    }

    @objc static func scrollViewWithTableViewForToolbelt(container: NSView & NSTableViewDelegate & NSTableViewDataSource,
                                                         insets: NSEdgeInsets,
                                                         rowHeight: CGFloat) -> NSScrollView {
        let frame = container.bounds.insetByEdgeInsets(insets)
        let scrollView = NSScrollView(frame: frame)
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        if #available(macOS 10.16, *) {
            scrollView.borderType = .lineBorder
            scrollView.scrollerStyle = .overlay
        } else {
            scrollView.borderType = .bezelBorder
        }
        scrollView.autoresizingMask = [.width, .height]
        scrollView.drawsBackground = false

        _ = NSTableView.toolbeltTableView(inScrollview: scrollView,
                                          fixedRowHeight: rowHeight,
                                          owner: container)
        return scrollView
    }
}
extension NSScrollView {
    var distanceToTop: CGFloat {
        get {
            guard let documentView else {
                return 0
            }
            return documentView.bounds.height - contentView.bounds.maxY
        }
    }
    func performWithoutScrolling(_ closure: () -> Void) {
        let contentView = self.contentView
        guard let documentView = self.documentView else {
            closure()
            return
        }

        // Compute the current visible region's position relative to the top of the documentView
        let oldDocumentHeight = documentView.frame.height
        let oldTopVisibleY = oldDocumentHeight - contentView.bounds.maxY

        // Perform modifications
        closure()

        // Compute how much the document height changed
        let newDocumentHeight = documentView.frame.height

        // Adjust the bounds to keep the same content visible
        var newBounds = contentView.bounds
        newBounds.origin.y = max(0, (newDocumentHeight - oldTopVisibleY - newBounds.height))

        // Apply the change and update scrollbars
        NSLog("performWithoutScrolling will set clipview's bounds to \(newBounds)")
        contentView.bounds = newBounds
        self.reflectScrolledClipView(contentView)
    }
}
