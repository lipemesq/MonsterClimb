//
//  Button.swift
//  nano4
//
//  Created by Felipe Mesquita on 16/03/20.
//  Copyright © 2020 Felipe Mesquita. All rights reserved.
//

import SpriteKit

protocol ButtonDelegate: class {
    func buttonClicked(button: Button)
}

class Button: SKSpriteNode {
    
    enum TouchType {
        case down
        case up
    }
    
    var isPressed = false
    
    weak var buttonDelegate: ButtonDelegate!
    private var type: TouchType = .down
    
    init(texture: SKTexture, type: TouchType) {
        
        let size = texture.size()
        
        super.init(texture: texture ,color: .clear, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        isPressed = true
        
        if type == .down {
            self.buttonDelegate.buttonClicked(button: self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first as UITouch? {
            
            let touchLocation = touch.location(in: parent!)
            
            if !frame.contains(touchLocation) {
                isPressed = false
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard isPressed else { return }
        
        if type == .up {
            self.buttonDelegate.buttonClicked(button: self)
        }
        
        isPressed = false
    }
}
