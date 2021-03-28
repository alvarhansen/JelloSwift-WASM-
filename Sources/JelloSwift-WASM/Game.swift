import Foundation
import JelloSwift
import JavaScriptKit

class Game {
    var world = World()
    private var timer: JSValue?
    var canvas: TransformingCanvas
    let iterationInterval: Double = 10

    private lazy var tickFn: JSClosure! = JSClosure { [weak self] _ in
        self?.iterate()
        return .undefined
    }

    deinit {
        tickFn.release()
    }

    init(
        canvas: TransformingCanvas
    ) {
        self.canvas = canvas

        canvas.zoom = 32
    }

    func start() {
        canvas.fill(color: .black)
        timer = JSObject.global.setInterval!(tickFn, iterationInterval)

        let size = Size(width: 1024, height: 768)
        let vec = (Vector2(x: size.width, y: 500) / 2).inWorldCoords

        for i in 2..<6 {
            let v = vec + Vector2(x: CGFloat(i + 10), y: 2 + CGFloat(i) * 3.2)

            let ball = createBouncyBall(
                v,
                radius: 1 + Double(i) * 0.2,
                mass: 0.1 + Double(i) * 0.2
            )
            ball.freeRotate = false
        }

        let pinnedBox = createBox(
            Vector2(x: size.width / 2, y: size.height / 2).inWorldCoords,
            size: .unit * 2.3,
            pinned: true
        )
//        // Increase the velocity damping of the pinned box so it won't jiggle around nonstop
        pinnedBox.velDamping = 0.99

        let box1 = createBox(
            Vector2(x: size.width * 1.0, y: 300).inWorldCoords,
            size: .unit * 3.1,
            angle: 0.5,
            mass: 1
        )
//        box1.velDamping = 0.99
        box1.freeRotate = false


        // Create the ground box
        let box = ClosedShape.create { box in
            box.addVertex(x: -10, y:   1)
            box.addVertex(x:  0,  y: 0.6) // A little inward slope
            box.addVertex(x:  10, y:   1)
            box.addVertex(x:  10, y:  -1)
            box.addVertex(x: -10, y:  -1)
        }

        let platform = Body(
            world: world,
            shape: box,
            pointMasses: [Double.infinity],
            position: Vector2(x: size.width, y: 150).inWorldCoords
        )
        platform.isStatic = true
        platform.objectTag = UInt(0x7D999999)

//        world.relaxWorld(timestep: 1.0 / 600, iterations: 120 * 3)

    }

    func stop() {
        _ = JSObject.global.clearInterval!(timer)
        timer = nil
    }

    func iterate() {
//        print("iter", world.worldSize, world.worldLimits)

        canvas.updateSize()

        for _ in 0..<5 {
            world.update(0.1/iterationInterval)
        }

        canvas.clear()
        canvas.fill(color: .white)

        for (idx, body) in world.bodies.enumerated() {
            let shapes: [Point] = (body.vertices + [body.vertices.first!])
                .map {
                    Point(x: $0.x, y: $0.y)
                }

            let colors = [Color.blue, .gray, .green, .red, .init(value: "#F0F"), .init(value: "#F60")]
            canvas.setStroke(color: colors[idx % colors.count])
            canvas.drawPath(points: shapes)
            shapes.enumerated().forEach { (idx, point) in
                canvas.drawCircle(origin: point, radius: 0.1)
            }
            canvas.setStroke(color: .black)
        }
    }

    @discardableResult
    func createBox(_ pos: Vector2, size: Vector2, pinned: Bool = false,
                   kinematic: Bool = false, isStatic: Bool = false,
                   angle: JFloat = 0, mass: JFloat = 0.5) -> Body {

        // Create the closed shape for the box's physics body
        let shape = ClosedShape
            .rectangle(ofSides: size)
            .transformedBy(rotatingBy: angle)

        var comps = [BodyComponentCreator]()

        // Add a spring body component - spring bodies have string physics that attract the inner points, it's one of the
        // forces that holds a body together
        comps.append(SpringComponentCreator(shapeMatchingOn: true, edgeSpringK: 600, edgeSpringDamp: 20, shapeSpringK: 100, shapeSpringDamp: 60))

        if !pinned {
            // Add a gravity component that will pull the body down
            comps.append(GravityComponentCreator())
        }

        let body = Body(world: world, shape: shape, pointMasses: [isStatic ? JFloat.infinity : mass], position: pos, kinematic: kinematic, components: comps)
        body.isPined = pinned

        // In order to have the box behave correctly, we need to add some internal springs to the body
        let springComp = body.component(ofType: SpringComponent.self)

        // The two first arguments are the indexes of the point masses to link, the next two are the spring constants,
        // and the last one is the distance the spring will try to mantain the two point masses at.
        // Specifying the distance as -1 sets it as the current distance between the specified point masses
        springComp?.addInternalSpring(body, pointA: 0, pointB: 2, springK: 100, damping: 10)
        springComp?.addInternalSpring(body, pointA: 1, pointB: 3, springK: 100, damping: 10)

        return body
    }

    /// Creates a bouncy ball at the specified world coordinates
    @discardableResult
    func createBouncyBall(_ pos: Vector2, pinned: Bool = false, kinematic: Bool = false, radius: JFloat = 1, mass: JFloat = 0.5, def: Int = 12) -> Body {
        // Create the closed shape for the ball's physics body
        let shape = ClosedShape
            .circle(ofRadius: radius, pointCount: def)
            .transformedBy(scalingBy: Vector2(x: 0.3, y: 0.3))

        var comps = [BodyComponentCreator]()

        // Add a spring body component - spring bodies have string physics that attract the inner points, it's one of the
        // forces that holds a body together
        comps.append(SpringComponentCreator(shapeMatchingOn: true, edgeSpringK: 600, edgeSpringDamp: 20, shapeSpringK: 10, shapeSpringDamp: 20))

        // Add a pressure component - pressure applies an outwards-going force that basically
        // tries to expand the body as if filled with air, like a balloon
        comps.append(PressureComponentCreator(gasAmmount: 90))

        // Add a gravity component taht will pull the body down
        comps.append(GravityComponentCreator())

        let body = Body(world: world, shape: shape, pointMasses: [mass], position: pos, kinematic: kinematic, components: comps)

        body.isPined = pinned

        return body
    }
}

extension Vector2 {

    /// Helper post-fix alias for global function `toWorldCoords(self)`
    var inWorldCoords: Vector2 {
        return JelloSwift.toWorldCoords(self)
    }

    /// Helper post-fix alias for global function `toScreenCoords(self)`
    var inScreenCoords: Vector2 {
        return JelloSwift.toScreenCoords(self)
    }

    init(x: CGFloat, y: CGFloat) {
        self.init(x: x.native, y: y.native)
    }
}
