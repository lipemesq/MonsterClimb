//
//  SwiftUIView.swift
//  nano4
//
//  Created by Felipe Mesquita on 09/03/20.
//  Copyright © 2020 Felipe Mesquita. All rights reserved.
//

import SwiftUI

struct SwiftUIView: View {
    
    // controla o estado, se foi comprado ou não
    @State var purchased : Bool = false
    
    var body: some View {
        Text("Hello, World!")
            
            // A cor do texto. O mesmo que a cor da sombra
            /// A `corSombra` devolve a cor do texto de acordo com o estado, ou seja, se foi comprado ou não
            .foregroundColor( corSombra() )
            
            // Quando der um tap, muda o estado para "comprado"
            // e reconstrói toda a view, com a cor de "corSombra"
            .onTapGesture {
                self.purchased = true
            }
    }
    
    func corSombra() -> Color {
        
        // Se foi comprado, devolve a cor verde
        if purchased {
            return Color.green
        }
            
        // se não, devolve preto
        else {
            return Color.black
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
