//
//  PlaceholderTextView.swift
//  ToDoList
//
//  Created by Siarhei Lukyanau on 19.08.25.
//

import UIKit

class PlaceholderTextView: UITextView {
    private var placeholderLabel: UILabel!

    var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
        }
    }

    var placeholderColor: UIColor = .lightGray {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }

    var placeholderFont: UIFont = UIFont.systemFont(ofSize: 16) {
        didSet {
            placeholderLabel.font = placeholderFont
        }
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupPlaceholder()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        setupPlaceholder()
    }

    private func setupPlaceholder() {
        placeholderLabel = UILabel()
        placeholderLabel.numberOfLines = 0
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.font = placeholderFont
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            placeholderLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5)
        ])
        let isHidden = !(text?.isEmpty ?? true)
        placeholderLabel.isHidden = isHidden
    }
}

extension PlaceholderTextView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let isHidden = !(text?.isEmpty ?? true)
        placeholderLabel.isHidden = isHidden
    }
}
