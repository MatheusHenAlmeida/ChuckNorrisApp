//
//  AboutView.swift
//  ChuckNorrisApp
//
//  Created by Gemini on 12/02/26.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "Chuck Norris App"
    }
    
    var version: String {
        let dictionary = Bundle.main.infoDictionary
        let version = dictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = dictionary?["CFBundleVersion"] as? String ?? "1"
        let format = NSLocalizedString("about_version_format", comment: "Format for app version and build")
        return String(format: format, version, build)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("app_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 4))
                    .shadow(radius: 10)
                
                Text(appName)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(NSLocalizedString("about_description", comment: "Description of the app on the About screen"))
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text(version)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationBarItems(trailing: Button(NSLocalizedString("about_close_button", comment: "Close button title")) {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
