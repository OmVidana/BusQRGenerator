//
//  LogInView.swift
//  BusQRGenerator
//
//  Created by Alumno-015 on 24/05/24.
//

import SwiftUI
import FirebaseAuth

struct LogInView: View {
    @StateObject var router = Router.shared
    @State private var email = ""
    @State private var password = ""
    @State private var errorMsg = ""
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            VStack(alignment: .center){
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Contraseña", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.vertical)
            VStack(alignment: .center){
                Button(action: {
                    login()
                }) {
                    Text("Iniciar Sesión")
                        .font(.title)
                        .fontWeight(.regular)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                }
                Button(action: {
                    router.path.append(NavigationDestination.forgottenPassword)
                }) {
                    Text("Olvidé mi contraseña")
                        .font(.title)
                        .fontWeight(.regular)
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                }
            }
            .padding(.vertical)
            Text(errorMsg)
                .font(.body)
                .fontWeight(.regular)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
        .navigationTitle("Iniciar Sesión")
        .padding(.horizontal, 32.0)
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMsg = error.localizedDescription
            } else {
                router.path.append(NavigationDestination.generateQR)
                errorMsg = ""
            }
        }
    }
}

#Preview {
    LogInView()
}
