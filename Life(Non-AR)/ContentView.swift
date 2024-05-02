import SwiftUI
import SceneKit
import AVFoundation

enum GameState: Int {
    case initial = 0
    case blueCube = 1
    case purpleCube = 2
    case quitGame = 3
}

struct SceneViewContainer: UIViewRepresentable {
    var color: UIColor?
    var rotationAngle: CGFloat
    var swivelCubeAction: (CGFloat) -> Void

    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()

        // Load the "room.usdc" scene
        if let scene = SCNScene(named: "untitled.usdc") {
            sceneView.scene = scene
        }

        // Enable default lighting
        sceneView.autoenablesDefaultLighting = true

        // Set the camera to an isometric view
        let camera = SCNCamera()
        camera.zNear = 0.1
        camera.zFar = 100
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(5, 5, 5)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        sceneView.pointOfView = cameraNode

        // Apply rotation angle
        let rotation = SCNAction.rotateTo(x: 0, y: rotationAngle, z: 0, duration: 0) // Set duration to 0
        sceneView.scene?.rootNode.runAction(rotation)

        // Set the color of the diorama if provided
        if let color = color {
            setColor(of: sceneView.scene?.rootNode, to: color)
        }

        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update the view if needed
    }

    private func setColor(of node: SCNNode?, to color: UIColor) {
        guard let node = node else { return }
        for child in node.childNodes {
            if let geometry = child.geometry {
                geometry.materials.first?.diffuse.contents = color
            }
            setColor(of: child, to: color)
        }
    }
}

private struct GameScreen: View {
    @Binding var gameState: GameState
    @State private var buttonTextIndexInitial = 0
    @State private var buttonTextIndexBlueCube = 0
    @State private var buttonTextIndexPurpleCube = 0
    @State private var buttonTextsInitial = ["Start?", "Keep tapping", "Maybe tap faster?", "Harder?", "Now you missed it right?"] // Array of texts for initial state
    @State private var buttonTextsBlueCube = ["Stop trying", "This time work for living", "Or try other things?", "Run away from the rabbit hole"] // Array of texts for blueCube state
    @State private var buttonTextsPurpleCube = ["Well it's done", "Finished!", "You want to try something else?", "Did we hid something in the game?", "Try it again?", "Maybe your choice will make the game different!"] // Array of texts for purpleCube state
    @State private var transitionComplete = false
    @AppStorage("lastViewPage") var pageIndex: Int = 0

    var body: some View {
        let sceneScaleFactor: CGFloat = 2

        return ZStack{
            switch gameState {
            case .initial:
                VStack {
                    Text("Chances").font(.title)
                    Spacer()
                    SceneViewContainer(color: nil, rotationAngle: 0, swivelCubeAction: { _ in })
                        .scaledToFit()
                        .scaleEffect(sceneScaleFactor)
                        .edgesIgnoringSafeArea(.all)
                    Spacer()
                    Button(action: {
                        // Cycle through texts in buttonTextsInitial array
                        self.buttonTextIndexInitial = (self.buttonTextIndexInitial + 1) % self.buttonTextsInitial.count

                        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                            self.gameState = .blueCube
                        }
                    }) {
                        Text(buttonTextsInitial[buttonTextIndexInitial]) // Use buttonTextIndexInitial to get current text
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(Color.white)
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 20)
                }
            case .blueCube:
                VStack {
                    Spacer()
                    SceneViewContainer(color: .yellow, rotationAngle: 0, swivelCubeAction: { _ in })
                        .scaledToFit()
                        .scaleEffect(sceneScaleFactor)
                        .edgesIgnoringSafeArea(.all)
                    Spacer()
                    Button(action: {
                        // Cycle through texts in buttonTextsBlueCube array
                        self.buttonTextIndexBlueCube = (self.buttonTextIndexBlueCube + 1) % self.buttonTextsBlueCube.count

                        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                            self.gameState = .purpleCube
                        }
                    }) {
                        Text(buttonTextsBlueCube[buttonTextIndexBlueCube]) // Use buttonTextIndexBlueCube to get current text
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(Color.white)
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 20)
                }

            case .purpleCube:
                VStack {
                    Spacer()
                    SceneViewContainer(color: .yellow, rotationAngle: 0, swivelCubeAction: { _ in })
                        .scaledToFit()
                        .scaleEffect(sceneScaleFactor)
                        .edgesIgnoringSafeArea(.all)
                    Spacer()
                    Button(action: {
                        // Cycle through texts in buttonTextsPurpleCube array
                        self.buttonTextIndexPurpleCube = (self.buttonTextIndexPurpleCube + 1) % self.buttonTextsPurpleCube.count

                        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                            pageIndex = GameState.quitGame.rawValue
                            
                            self.gameState = .quitGame
                        }
                    }) {
                        Text(buttonTextsPurpleCube[buttonTextIndexPurpleCube]) // Use buttonTextIndexPurpleCube to get current text
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(Color.white)
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 20)
                }

            case .quitGame:
                QuitGameOverlay()
                    .edgesIgnoringSafeArea(.all)
                    .scaledToFit()
            }
            
            // Restart button
            VStack {
                Spacer()
                Button(action: {
                    // Reset game to initial state
                    self.gameState = .initial
                }) {
                    Text("Restart Game")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                }
                Spacer()
            }
        }
    }
}

private struct QuitGameOverlay: View {
    var body: some View {
        Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
        VStack {
            Spacer()
            Button(action: {
                exit(0)
            }) {
                Text("No Retry, One Life, One Chance. Make it work.")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
            }
            Spacer()
        }
    }
}

struct ContentView: View {
    @State private var gameState: GameState
    @State private var isMuted = false
    @AppStorage("lastViewPage") var pageIndex: Int = 0
    
    private var audioPlayer: AVAudioPlayer?

    init() {
        let storedState = UserDefaults.standard.integer(forKey: "lastViewPage") ?? GameState.initial.rawValue
        self._gameState = State(initialValue: GameState(rawValue: storedState) ?? .initial)

        // Load background music
        if let path = Bundle.main.path(forResource: "Walking-Home-chosic", ofType: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.numberOfLoops = -1 // Loop indefinitely
                audioPlayer?.play()
            } catch {
                // Handle error
                print("Error loading background music: \(error)")
            }
        }
    }

    var body: some View {
        VStack {
            GameScreen(gameState: $gameState)
                .onDisappear {
                    // Stop music when the view disappears
                    audioPlayer?.stop()
                }
            
            // Mute Button
            Button(action: {
                isMuted.toggle()
                if isMuted {
                    audioPlayer?.pause()
                } else {
                    audioPlayer?.play()
                }
            }) {
                Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.fill")
                    .foregroundColor(isMuted ? .red : .green)
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
