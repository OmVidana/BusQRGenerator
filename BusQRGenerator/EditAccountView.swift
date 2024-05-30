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
    @State private var nombre: String = ""
    @State private var apellido: String = ""
    @State private var carrera: String = ""
    @State private var semestre: String = ""
    @State private var errorMessage = ""
    @State private var successMessage = ""
    
    var body: some View {
        VStack {
            Spacer()
            Form {
                Section(header: Text("Password")) {
                    SecureField("Contraseña Actual", text: $password)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                    SecureField("Nueva Contraseña", text: $newPassword)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                    SecureField("Confirmar Nueva Contraseña", text: $confirmNewPassword)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                }
                .listRowBackground(Color.white)
                
                Section(header: Text("Información de Cuenta")) {
                    TextField("Nombre", text: $nombre)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                    TextField("Apellido", text: $apellido)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                    TextField("Carrera", text: $carrera)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                    TextField("Semestre", text: $semestre)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                }
                .listRowBackground(Color.white)
            }
            .background(Color.white)
            .cornerRadius(10)
            .scrollContentBackground(.hidden)
            Spacer()
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
        .background(Color.white.ignoresSafeArea())
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
            nombre = data["nombre"] as? String ?? ""
            apellido = data["apellido"] as? String ?? ""
            carrera = data["carrera"] as? String ?? ""
            semestre = data["semestre"] as? String ?? ""
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
        
        let credential = EmailAuthProvider.credential(withEmail: currentUser.email!, password: password)
        currentUser.reauthenticate(with: credential) { result, error in
            if let error = error {
                errorMessage = "Error de autenticación: \(error.localizedDescription)"
                return
            }
            
            currentUser.updatePassword(to: newPassword) { error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                } else {
                    guard let currentUserID = Auth.auth().currentUser?.uid else {
                        errorMessage = "Usuario no autenticado."
                        return
                    }
                    
                    let ref = Database.database().reference().child("usuario").child(currentUserID)
                    let updatedData: [String: Any] = [
                        "apellido": apellido,
                        "carrera": carrera,
                        "nombre": nombre,
                        "semestre": semestre
                    ]
                    
                    ref.setValue(updatedData) { error, _ in
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
}

#Preview {
    EditAccountView()
}
