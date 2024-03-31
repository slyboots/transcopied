//
//  ShareViewController.swift
//  transporter
//
//  Created by Dakota Lorance on 3/19/24.
//

import SwiftUI
import UIKit

struct ImageView: View {
    @State var image: Image

    var body: some View {
        VStack {
            Spacer()
            Text("👋 Hello, from share extension").font(.largeTitle)
            self.image.resizable().aspectRatio(contentMode: .fit)
            Spacer()
        }
    }
}

@objc(PrincipalClassName)
class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // self.extensionContext can be used to retrieve images, videos and urls from share extension input
        let extensionAttachments = (self.extensionContext!.inputItems.first as! NSExtensionItem).attachments
        for provider in extensionAttachments! {
            switch provider.registeredTypeIdentifiers.first {
                case "public.plain-text":
                    provider.loadItem(forTypeIdentifier: "public.plain-text") { data, _ in
                        print(data as? String as Any)
                    }
                default:
                    provider.loadItem(forTypeIdentifier: "public.content") { data, _ in
                        print(data as? Data as Any)
                    }
            }
            // loadItem can be used to extract different types of data from NSProvider object in attachements
            provider.loadItem(forTypeIdentifier: "public.text") { data, _ in
                // Load Image data from image URL
                if let url = data as? URL {
                    if let imageData = try? Data(contentsOf: url) {
                        // Load Image as UIImage from image data
                        let uiimg = UIImage(data: imageData)!
                        // Convert to SwiftUI Image
                        let image = Image(uiImage: uiimg)
                        // [START] The following piece of code can be used to render swifUI views from UIKit
                        DispatchQueue.main.async {
                            let u = UIHostingController(
                                rootView: ImageView(image: image)
                            )
                            u.view.frame = (self.view.bounds)
                            self.view.addSubview(u.view)
                            self.addChild(u)
                        }
                        // [END]
                    }
                }
            }
        }
    }
}

// import Social
// import UIKit
//
// class ShareViewController: SLComposeServiceViewController {
//    override func isContentValid() -> Bool {
//        // Do validation of contentText and/or NSExtensionContext attachments here
//        true
//    }
//
//    override func didSelectPost() {
//        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
//
//        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
//        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
//    }
//
//    override func configurationItems() -> [Any]! {
//        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
//        []
//    }
// }
