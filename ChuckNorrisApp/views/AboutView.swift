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
        SystemHelper.getAppName()
    }
    
    var version: String {
        SystemHelper.getFormattedAppVersion()
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
                    .accessibilityIdentifier("about_app_name")
                
                Text(NSLocalizedString("about_description", comment: "Description of the app on the About screen"))
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text(version)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .accessibilityIdentifier("about_app_version")
                
                Spacer()
            }
            .padding()
            .navigationBarItems(trailing: Button(NSLocalizedString("about_close_button", comment: "Close button title")) {
                presentationMode.wrappedValue.dismiss()
            }
            .accessibilityIdentifier("about_close_button"))
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
