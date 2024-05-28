//
//  ForgottenView.swift
//  BusQRGenerator
//
//  Created by Alumno-015 on 24/05/24.
//

import SwiftUI
import FirebaseAuth

struct ForgottenView: View {
    @StateObject var router = Router.shared
    @State private var email = ""
    @State private var newPassword = ""
    @State private var confirmNewPassword = ""
    @State private var errorMessage = ""
    
    var body: some View {
        VStack {
            Text("Escribe tu Correo y una nueva Contraseña.")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Nueva Contraseña", text: $newPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.password)
            
            SecureField("Confirmar Nueva Contraseña", text: $confirmNewPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textContentType(.password)
            
            Button(action: {
                resetPassword()
            }) {
                Text("Restablecer Contraseña")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.vertical)
            
            Text(errorMessage)
                .foregroundColor(.red)
                .padding(.vertical)
        }
        .navigationTitle("Restablecer Contraseña")
        .padding(.horizontal, 48.0)
    }
    
    func resetPassword() {
        guard !email.isEmpty, !newPassword.isEmpty, !confirmNewPassword.isEmpty else {
            errorMessage = "Por favor completa todos los campos."
            return
        }
        guard newPassword == confirmNewPassword else {
            errorMessage = "Las contraseñas no coinciden."
            return
        }
        
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: email, password: newPassword)
        
        user?.reauthenticate(with: credential) { result, error in
            if let error = error {
                errorMessage = "Error al reautenticar al usuario: \(error.localizedDescription)"
                return
            }
            user?.updatePassword(to: newPassword) { error in
                if let error = error {
                    errorMessage = "Error al restablecer la contraseña: \(error.localizedDescription)"
                } else {
                    errorMessage = "Contraseña restablecida con éxito."
                    router.path.removeLast()
                }
            }
        }
    }
}

#Preview {
    ForgottenView()
}
