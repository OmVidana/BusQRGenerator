//
//  EditAccountView.swift
//  BusQRGenerator
//
//  Created by Alumno-015 on 24/05/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct EditAccountView: View {
    @StateObject var router = Router.shared
    @State private var password: String = ""
    @State private var newPassword: String = ""
    @State private var confirmNewPassword: String = ""
    @State private var userData: [String: Any] = [:]
    @State private var errorMessage = ""
    @State private var successMessage = ""
    
    var body: some View {
        VStack {
            Spacer()
            Form {
                Spacer()
                Section(header: Text("Password")) {
                    SecureField("Contraseña Actual", text: $password)
                    SecureField("Nueva Contraseña", text: $newPassword)
                    SecureField("Confirmar Nueva Contraseña", text: $confirmNewPassword)
                }
                
                Section(header: Text("Información de Cuenta")) {
                    TextField("Nombre", text: Binding(
                        get: { userData["nombre"] as? String ?? "" },
                        set: { userData["nombre"] = $0 }
                    ))
                    TextField("Apellido", text: Binding(
                        get: { userData["apellido"] as? String ?? "" },
                        set: { userData["apellido"] = $0 }
                    ))
                    TextField("Carrera", text: Binding(
                        get: { userData["carrera"] as? String ?? "" },
                        set: { userData["carrera"] = $0 }
                    ))
                    TextField("Semestre", text: Binding(
                        get: { userData["semestre"] as? String ?? "" },
                        set: { userData["semestre"] = $0 }
                    ))
                }
                Spacer()
            }
            .scrollContentBackground(.hidden)
            Button(action: {
                updateAccount()
            }) {
                Text("Actualizar Cuenta")
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.vertical)
            Spacer()
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            if !successMessage.isEmpty {
                Text(successMessage)
                    .foregroundColor(.green)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .padding(.horizontal, 32.0)
        .onAppear(perform: loadUserData)
        .navigationTitle("Editar Cuenta")
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: Button(action: {
            router.path.removeLast()
        }) {
            Image(systemName: "arrow.uturn.backward.circle")
        })
    }
    
    func loadUserData() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            errorMessage = "Usuario no autenticado."
            return
        }
        
        let ref = Database.database().reference().child("usuario").child(currentUserID)
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let data = snapshot.value as? [String: Any] else {
                errorMessage = "Error al cargar la información de Usuario."
                return
            }
            userData = data
        }
    }
    
    func updateAccount() {
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "Usuario no autenticado."
            return
        }
        
        errorMessage = ""
        successMessage = ""
        
        if password.isEmpty || newPassword.isEmpty || confirmNewPassword.isEmpty {
            errorMessage = "Todos los campos son obligatorios."
            return
        }
        
        if newPassword != confirmNewPassword {
            errorMessage = "Contraseña nueva no es la misma."
            return
        }
        
        currentUser.updatePassword(to: newPassword) { error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                guard let currentUserID = Auth.auth().currentUser?.uid else {
                    errorMessage = "Usuario no autenticado."
                    return
                }
                
                let ref = Database.database().reference().child("usuario").child(currentUserID)
                ref.setValue(userData) { error, _ in
                    if let error = error {
                        errorMessage = error.localizedDescription
                    } else {
                        successMessage = "Cuenta Actualizada exitósamente."
                        router.path.removeLast()
                    }
                }
            }
        }
    }
}

#Preview {
    EditAccountView()
}
