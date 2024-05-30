//
//  RegisterView.swift
//  BusQRGenerator
//
//  Created by Alumno-015 on 24/05/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct RegisterView: View {
    @StateObject var router = Router.shared
    @State private var name: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var semester: String = ""
    @State private var career: String = ""
    @State private var errorMessage: String = ""
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            TextField("Nombre", text: $name)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5)
            
            TextField("Apellido", text: $lastName)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5)
            
            TextField("Correo electrónico", text: $email)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5)
            
            SecureField("Contraseña", text: $password)
                .textContentType(.password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5)
            
            SecureField("Confirmar contraseña", text: $confirmPassword)
                .textContentType(.password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5)
            
            TextField("Carrera", text: $career)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5)
            
            TextField("Semestre", text: $semester)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5)
            Spacer()
            Button(action: {
                if fieldsAreValid() {
                    register()
                }
            }) {
                Text("Registrarse")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Text(errorMessage)
                .foregroundColor(.red)
                .padding()
            Spacer()
        }
        .navigationTitle("Crear Cuenta")
        .padding(.horizontal, 32.0)
    }
    
    func fieldsAreValid() -> Bool {
        guard !name.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty, !semester.isEmpty, !career.isEmpty else {
            errorMessage = "Por favor completa todos los campos."
            return false
        }
        
        guard password == confirmPassword else {
            errorMessage = "Las contraseñas no coinciden."
            return false
        }
        
        return true
    }
    
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                saveUserData()
                router.path.removeLast()
            }
        }
    }
    
    func saveUserData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "Error: No se pudo obtener el ID de usuario."
            return
        }
        
        let userRef = Database.database().reference().child("usuario").child(userId)
        let userData: [String: Any] = [
            "apellido": lastName,
            "carrera": career,
            "email": email,
            "nombre": name,
            "semestre": semester
        ]
        
        userRef.setValue(userData) { error, _ in
            if let error = error {
                errorMessage = "Error al guardar los datos del usuario: \(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    RegisterView()
}
