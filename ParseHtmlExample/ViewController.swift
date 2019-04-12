//
//  ViewController.swift
//  ParseHtmlExample
//
//  Created by Stanly Shiyanovskiy on 4/12/19.
//  Copyright © 2019 Stanly Shiyanovskiy. All rights reserved.
//

import UIKit
import SwiftSoup

public class ViewController: UIViewController {
    
    // UI
    private var labelTextView: UITextView!

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let html = """
        <html>
        <body>
        <b>
        <i>
        <u>
        <a href="https://www.apple.com">
        <p style="color: blue; font-size:72px;">This is<br> blue!</p>
        </a>
        </u>
        </i>
        </b>
        </body>
        </html>
        """
        
        let data = Data(html.utf8)
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            createLabel(with: attributedString)
        }
        
        checkLinked(html: html)
    }
    
    private func createLabel(with attributedQuote: NSAttributedString) {
        labelTextView = UITextView()
        labelTextView.delegate = self
        labelTextView.isEditable = false
        labelTextView.attributedText = attributedQuote
        labelTextView.sizeToFit()

        self.view.addSubview(labelTextView)
        labelTextView.center = view.center
    }
    
    private func checkLinked(html: String) {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let link: Element = try doc.select("a").first()!
            
            //let text: String = try doc.body()!.text()
            let linkHref: String = try link.attr("href")
            let linkText: String = try link.text()
            updateLink(for: linkText, link: linkHref)
        } catch Exception.Error(_, let message) {
            print(message)
        } catch {
            print("error")
        }
    }
    
    private func updateLink(for text: String, link: String) {
        guard let attributedString = labelTextView.attributedText as? NSMutableAttributedString else { return }
        attributedString.setAsLink(textToFind: text, linkURL: link)
        labelTextView.attributedText = attributedString
    }
}

extension ViewController: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:])
        return false
    }
}

extension NSMutableAttributedString {
    
    public func setAsLink(textToFind:String, linkURL:String) {
        
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(.link, value: linkURL, range: foundRange)
        }
    }
}
