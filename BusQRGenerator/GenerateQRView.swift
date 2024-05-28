//
//  GenerateQRView.swift
//  BusQRGenerator
//
//  Created by Alumno-015 on 24/05/24.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth
import CodeScanner
import CoreImage.CIFilterBuiltins

struct GenerateQRView: View {
    @StateObject var router = Router.shared
    @State private var qrCode: UIImage?
    @State private var errorMessage = ""
    @State private var showLogoutConfirmation = false
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            if let qrCode = qrCode {
                Image(uiImage: qrCode)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 2048, height: 2048)
                    .padding()
                    .clipped()
                    .padding()
                
                Text("Scan this QR Code")
            } else {
                Spacer()
                Text("No QR code available.")
                Spacer()
            }
            
            Button(action: {
                generateQR()
            }) {
                Text("Generate QR")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.vertical)
            Spacer()
        }
        .padding(.horizontal, 48.0)
        .navigationTitle("Generate QR")
        .navigationBarBackButtonHidden()
        .navigationBarItems(
            leading: Button(action: {
                showLogoutConfirmation = true
            }) {
                Image(systemName: "arrow.uturn.backward.circle")
            },
            trailing: Button(action: {
                router.path.append(NavigationDestination.editAccount)
            }) {
                Image(systemName: "person.crop.circle")
            }
        )
        .alert(isPresented: $showLogoutConfirmation) {
            Alert(
                title: Text("Logout"),
                message: Text("Are you sure you want to log out?"),
                primaryButton: .default(Text("Yes")) {
                    do {
                        try Auth.auth().signOut()
                        // router.path = [NavigationDestination.start]
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    func generateQR() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated."
            return
        }
        
        let ref = Database.database().reference().child("clave")
        ref.queryOrdered(byChild: "status").queryEqual(toValue: "libre").observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                errorMessage = "No free keys available."
                return
            }
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   var keyData = snapshot.value as? [String: Any],
                   let key = keyData["key"] as? String {
                    keyData["status"] = "ocupado"
                    keyData["user_id"] = currentUserID
                    ref.child(key).setValue(keyData)
                    
                    generateQRCode(from: key)
                    errorMessage = ""
                    return
                }
            }
        }
    }
    
    func generateQRCode(from string: String) {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        let data = Data(string.utf8)
        
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                qrCode = UIImage(cgImage: cgImage)
            }
        }
    }
}
#Preview {
    GenerateQRView()
}
