//
//  File.swift
//  
//
//  Created by Alvar Hansen on 27.03.2021.
//

import JavaScriptKit
import Foundation

class App {
    let document = JSObject.global.document
    var game: Game
    let zoomCanvas: TransformingCanvas
    var body: JSValue { document.object!.body }
    var buttonsCallbacks: [JSClosure] = []
    let stylesheet = Stylesheet()
//    let buttons = Buttons()
    var canvas: JSValue
    var debugInfo: JSValue

    init() {
        let canvas = document.createElement("canvas")
        let debugInfo = document.createElement("pre")

        let cosmosCanvas = JSCanvas(canvas: canvas.object!)
        let zoomCanvas = TransformingCanvas(realCanvas: cosmosCanvas)
        zoomCanvas.fill(color: .black)

        self.canvas = canvas
        self.zoomCanvas = zoomCanvas
        self.debugInfo = debugInfo
        self.game = Game(canvas: zoomCanvas)

        _ = body.appendChild(canvas)
        _ = body.appendChild(debugInfo)
        setupUI()

        addViewportMeta()
    }

    func addViewportMeta() {
        var metaElement = document.createElement("meta")
        metaElement.name = "viewport"
        metaElement.content = "width=device-width, initial-scale=1.0"

        let head = document.object!.head
        _ = head.appendChild(metaElement)
    }

    func setupUI() {
    }

    func start() {
        game.start()
    }
}

class Stylesheet {

    init() {
        let document = JSObject.global.document
        let head: JSValue = document.object!.head

        var style = document.createElement("style")
        style.type = .string("text/css")
        style.innerHTML = .string(
            """
            html, body, div {
                margin: 0;
                padding: 0;
                border: 0;
                font-size: 100%;
                font: inherit;
                vertical-align: baseline;
            }
            canvas {
                height: 100%;
                width: 100%;
            }
            #buttonsContainer {
                position: absolute;
            }
            #buttonsContainer button {
                color: white;
                background: none;
                border: 1px solid #FFFFFF60;
            }
            #buttonsContainer button:hover {
                background: #FFFFFF40;
            }
            #debugInfo {
                position: absolute;
                bottom: 0;
                left: 0;
                color: white;
                font-family: monospace;
            }
            """)
        _ = head.appendChild(style)
    }
}
