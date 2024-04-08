//
//  GameScene.swift
//  Maze
//
//  Created by Mac Students on 19.03.2024.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: SKSpriteNode!
    var gameOverLabel: SKLabelNode!
    var livesLabel: SKLabelNode!
    var coinsLabel: SKLabelNode!
    
    var lives = 5
    var coins = 0
    var gameEnded = false
    
    var playAgainButton: SKLabelNode!
    
    let playerCategory: UInt32 = 0x1 << 0
    let enemyCategory: UInt32 = 0x1 << 1
    let coinCategory: UInt32 = 0x1 << 2
    
    override func didMove(to view: SKView) {
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode(color: UIColor.black, size: CGSize(width: frame.width, height: frame.height))
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = self.size
        background.zPosition = -1
        addChild(background)
        
        setupPlayer()
        
        setupGameOverLabel()
        
        setupLivesLabel()
        
        setupCoinsLabel()
        
        startEnemySpawning()
        
        startCoinSpawning()
    }
    
    func setupLivesLabel() {
        livesLabel = SKLabelNode(text: "\(lives) lives left")
        livesLabel.position = CGPoint(x: 200, y: 600)
        livesLabel.fontColor = SKColor.white
        livesLabel.fontSize = 40
        livesLabel.isHidden = false
        self.addChild(livesLabel)
    }
    
    func setupGameOverLabel() {
        gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.position = CGPoint(x: 0, y: 0)
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.fontSize = 90
        gameOverLabel.isHidden = true
        self.addChild(gameOverLabel)
        
        playAgainButton = SKLabelNode(text: "Play Again")
        playAgainButton.position = CGPoint(x: 0, y: -100)
        playAgainButton.fontColor = SKColor.white
        playAgainButton.fontSize = 70
        playAgainButton.isHidden = true
        self.addChild(playAgainButton)
    }
    
    func setupCoinsLabel() {
        coinsLabel = SKLabelNode(text: "Coins: \(coins)")
        coinsLabel.position = CGPoint(x: -200, y: 600)
        coinsLabel.fontColor = SKColor.yellow
        coinsLabel.fontSize = 40
        coinsLabel.isHidden = false
        self.addChild(coinsLabel)
    }
    
    func setupPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 0, y: -self.size.height / 3)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.isDynamic = false
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = enemyCategory
        player.physicsBody?.affectedByGravity = false
        self.addChild(player)
    }
    
    func startEnemySpawning() {
        let spawnAction = SKAction.run {
            if self.gameEnded == false {
                self.spawnEnemy()
            }
            
        }
        let delayAction = SKAction.wait(forDuration: 1)
        let sequenceAction = SKAction.sequence([spawnAction, delayAction])
        let repeatAction = SKAction.repeatForever(sequenceAction)
        self.run(repeatAction)
        
    }
    
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        let randomX = CGFloat.random(in: -self.size.width/2 ..< self.size.width/2)
        enemy.position = CGPoint(x: randomX, y: self.size.height + enemy.size.height / 2)
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width / 2)
        enemy.physicsBody?.categoryBitMask = enemyCategory
        enemy.physicsBody?.contactTestBitMask = playerCategory
        enemy.physicsBody?.affectedByGravity = false
        self.addChild(enemy)
        
        let moveAction = SKAction.moveTo(y: -self.size.height / 3 - 200, duration: 1.5)
        let removeAction = SKAction.removeFromParent()
        let sequenceAction = SKAction.sequence([moveAction, removeAction])
        enemy.run(sequenceAction)
        
    }
    
    func startCoinSpawning() {
        let spawnAction = SKAction.run {
            if self.gameEnded == false {
                self.spawnCoins()
            }
            
        }
        let delayAction = SKAction.wait(forDuration: 1.4)
        let sequenceAction = SKAction.sequence([spawnAction, delayAction])
        let repeatAction = SKAction.repeatForever(sequenceAction)
        self.run(repeatAction)
        
    }
    
    func spawnCoins() {
        let coin = SKSpriteNode(imageNamed: "coins")
        let randomX = CGFloat.random(in: -self.size.width/2 ..< self.size.width/2)
        coin.position = CGPoint(x: randomX, y: self.size.height + coin.size.height / 2)
        coin.physicsBody = SKPhysicsBody(rectangleOf: coin.size)
        coin.physicsBody?.categoryBitMask = coinCategory
        coin.physicsBody?.contactTestBitMask = playerCategory
        coin.physicsBody?.affectedByGravity = false
        self.addChild(coin)
        
        let moveAction = SKAction.moveTo(y: -self.size.height / 3 - 200, duration: 1.6)
        let removeAction = SKAction.removeFromParent()
        let sequenceAction = SKAction.sequence([moveAction, removeAction])
        coin.run(sequenceAction)
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == playerCategory && contact.bodyB.categoryBitMask == enemyCategory) || (contact.bodyA.categoryBitMask == enemyCategory && contact.bodyB.categoryBitMask == playerCategory) {
            lives = lives - 1
            livesLabel.removeFromParent()
            livesLabel = SKLabelNode(text: "\(lives) lives left")
            livesLabel.position = CGPoint(x: 200, y: 600)
            livesLabel.fontColor = SKColor.white
            livesLabel.fontSize = 40
            self.addChild(livesLabel)
            if lives <= 0 {
                endGame()
                gameEnded = true
                livesLabel.isHidden = true
                
            }
        }
        else if (contact.bodyA.categoryBitMask == playerCategory && contact.bodyB.categoryBitMask == coinCategory) || (contact.bodyA.categoryBitMask == coinCategory && contact.bodyB.categoryBitMask == playerCategory) {
            if (contact.bodyA.categoryBitMask == coinCategory) {
                contact.bodyA.node?.isHidden = true
            }
            if (contact.bodyB.categoryBitMask == coinCategory) {
                contact.bodyB.node?.isHidden = true
            }
            coins = coins + 1
            coinsLabel.removeFromParent()
            coinsLabel = SKLabelNode(text: "Coins: \(coins)")
            coinsLabel.position = CGPoint(x: -200, y: 600)
            coinsLabel.fontColor = SKColor.yellow
            coinsLabel.fontSize = 40
            self.addChild(coinsLabel)
        }
    }
    
    func resetGame() {
        gameEnded = false
        gameOverLabel.isHidden = true
        playAgainButton.isHidden = true
        livesLabel.isHidden = false
        lives = 5
        livesLabel.removeFromParent()
        livesLabel = SKLabelNode(text: "\(lives) lives left")
        livesLabel.position = CGPoint(x: 200, y: 600)
        livesLabel.fontColor = SKColor.white
        livesLabel.fontSize = 40
        self.addChild(livesLabel)
        
        coins = 0
        coinsLabel.removeFromParent()
        coinsLabel = SKLabelNode(text: "Coins: \(coins)")
        coinsLabel.position = CGPoint(x: -200, y: 600)
        coinsLabel.fontColor = SKColor.yellow
        coinsLabel.fontSize = 40
        self.addChild(coinsLabel)
        player.position = CGPoint(x: 0, y: -self.size.height / 3)
    }
    
    func endGame() {
        gameEnded = true
        gameOverLabel.isHidden = false
        playAgainButton.isHidden = false
    }
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
                
        // Move player horizontally to follow touch location
        if gameEnded == false {
            player.position.x = touchLocation.x
            
        }
        if (playAgainButton.contains(touchLocation)) {
            resetGame()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
