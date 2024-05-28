//
//  ContentView.swift
//  BusQRGenerator
//
//  Created by Alumno-008 on 23/05/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var router = Router.shared
    
    var body: some View {
        NavigationStack(path: $router.path) {
            VStack(alignment: .center) {
                Spacer()
                Button(action: {
                    router.path.append(NavigationDestination.login)
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
                    router.path.append(NavigationDestination.register)
                }) {
                    Text("Crear Cuenta")
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
                Spacer()
            }
            .navigationTitle("Bienvenido")
            .navigationBarTitleDisplayMode(/*@START_MENU_TOKEN@*/.inline/*@END_MENU_TOKEN@*/)
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .start:
                    ContentView()
                case .login:
                    LogInView()
                case .register:
                    RegisterView()
                case .forgottenPassword:
                    ForgottenView()
                case .generateQR:
                    GenerateQRView()
                case .editAccount:
                    EditAccountView()
                }
            }
            .padding(.horizontal, 48.0)
        }
    }
}


#Preview {
    ContentView()
}
