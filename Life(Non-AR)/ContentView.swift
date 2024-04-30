
import SwiftUI
import SceneKit

enum GameState {
    case initial
    case blueCube
    case purpleCube
    case quitGame
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

        // Add a pan gesture recognizer to swivel the camera
//        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
//        sceneView.addGestureRecognizer(panGesture)

        // Set up the coordinator for gesture handling
        objc_setAssociatedObject(sceneView, &AssociatedKeys.coordinator, context.coordinator, .OBJC_ASSOCIATION_RETAIN)

        // Set the color of the diorama if provided
        if let color = color {
            setColor(of: sceneView.scene?.rootNode, to: color)
        }

        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update the view if needed
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(swivelCubeAction: swivelCubeAction)
    }

    class Coordinator: NSObject {
        var swivelCubeAction: (CGFloat) -> Void

        init(swivelCubeAction: @escaping (CGFloat) -> Void) {
            self.swivelCubeAction = swivelCubeAction
        }

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            let translation = gesture.translation(in: gesture.view).x
            if let view = gesture.view as? SCNView,
               let sceneView = view.scene?.rootNode {
                sceneView.eulerAngles.y += Float(translation) * 0.01
            }
            gesture.setTranslation(.zero, in: gesture.view)
        }
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

    var body: some View {
        let sceneScaleFactor: CGFloat = 2

        return ZStack{
            
            //background color
//            Color(.red)
//                .ignoresSafeArea()
            
            switch gameState {
            case .initial:
                VStack {
                    Text("Chances").font(.title)
                    Spacer()
                    SceneViewContainer(color: nil, rotationAngle: 0, swivelCubeAction: { _ in })
                        .scaledToFit()
                        .scaleEffect(sceneScaleFactor)
                        .edgesIgnoringSafeArea(.all)
//                        .foregroundStyle(.red) //background color
                    Spacer()
                    Button(action: {
                        self.gameState = .blueCube
                    }) {
                        Text("Continue")
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
                        self.gameState = .purpleCube
                    }) {
                        Text("Work")
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
                        self.gameState = .quitGame
                    }) {
                        Text("End Life")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(Color.white)
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 20)
                }

                

//            case .blueCube:
//                SceneViewContainer(color: .blue, rotationAngle: 0, swivelCubeAction: { _ in })
//                    .edgesIgnoringSafeArea(.all)
//                    .scaledToFit()
            
//            case .purpleCube:
//                SceneViewContainer(color: .purple, rotationAngle: 0, swivelCubeAction: { _ in })
//                    .edgesIgnoringSafeArea(.all)
//                    .scaledToFit()
                
            case .quitGame:
                QuitGameOverlay()
                    .edgesIgnoringSafeArea(.all)
                    .scaledToFit()
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
                Text("No Retry, One Life, One Chance.")
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
    @State private var gameState: GameState = .initial

    var body: some View {
        GameScreen(gameState: $gameState)
    }
}

private struct AssociatedKeys {
    static var coordinator = "coordinator"
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

