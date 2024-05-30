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
                    .frame(width: 300, height: 300)
                    .padding()
                    .clipped()
                    .padding()
                
                Text("Escanéa el QR Code")
                Button(action: {
                    deleteQR()
                }) {
                    Text("Borrar QR")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.top)
                Spacer()
            } else {
                Spacer()
                Text("No QR disponible.")
                Button(action: {
                    generateQR()
                }) {
                    Text("Genera QR")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.vertical)
                .padding(.vertical)
                Spacer()
            }
        }
        .padding(.horizontal, 48.0)
        .navigationTitle("Generar QR")
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
                title: Text("Cerrar Sesión"),
                message: Text("¿Estás seguro que deseas salir?"),
                primaryButton: .default(Text("No")),
                secondaryButton: .default(Text("Sí")) {
                    do {
                        try Auth.auth().signOut()
                        router.path = NavigationPath()
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            )
        }
        .onAppear {
            checkActiveQR()
        }
    }
    
    func checkActiveQR() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            errorMessage = "Usuario no autenticado."
            return
        }
        
        let ref = Database.database().reference().child("clave")
        ref.queryOrdered(byChild: "status").queryEqual(toValue: "ocupado").observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                       let keyData = snapshot.value as? [String: Any],
                       let userId = keyData["user_id"] as? String,
                       userId == currentUserID {
                        let key = snapshot.key
                        generateQRCode(from: key)
                        return
                    }
                }
            }
        }
    }
    
    func generateQR() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            errorMessage = "Usuario no autenticado."
            return
        }
        
        let ref = Database.database().reference().child("clave")
        
        ref.queryOrdered(byChild: "status").queryEqual(toValue: "libre").observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                errorMessage = "No QR disponible de momento."
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
    func
    generateQRCode(from string: String) {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        let data = Data(string.utf8)
        
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 512, y: 512)
            let scaledImage = outputImage.transformed(by: transform)
            
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                qrCode = UIImage(cgImage: cgImage)
            }
        }
    }
    
    func deleteQR() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            errorMessage = "Usuario no autenticado."
            return
        }
        
        let ref = Database.database().reference().child("clave")
        ref.queryOrdered(byChild: "user_id").queryEqual(toValue: currentUserID).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                errorMessage = "No se encontró ningún QR asociado a tu usuario."
                return
            }
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let keyData = snapshot.value as? [String: Any],
                   let status = keyData["status"] as? String {
                    
                    if status == "ocupado" {
                        let key = snapshot.key
                        ref.child(key).child("status").setValue("libre")
                        ref.child(key).child("user_id").setValue("")
                        qrCode = nil
                        return
                    } else if status == "QR utilizado" {
                        qrCode = nil
                        return
                    }
                }
            }
            errorMessage = "No se encontró ningún QR en estado 'ocupado' o 'QR utilizado' asociado a tu usuario."
        }
    }
}

#Preview {
    GenerateQRView()
}
