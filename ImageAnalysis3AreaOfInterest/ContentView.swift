//
//  ContentView.swift
//  ImageAnalysis3AreaOfInterest
//
//  Created by Quanpeng Yang on 3/16/26.
//

import SwiftUI
import Vision

struct ContentView: View {
    @State private var observations: SaliencyImageObservation?

    var body: some View {
        VStack {
            // Button to trigger object/saliency detection
            Button("Detect") {
                Task {
                    await detectObjects()
                }
            }
            .buttonStyle(.borderedProminent)

            // Canvas to draw image and bounding boxes
            Canvas { context, size in
                // Load image
                guard let image = UIImage(named: "tower") else { return }

                // Calculate size to fit Canvas
                let width = size.width
                let height = image.size.height * width / image.size.width
                let imageFrame = CGRect(origin: .zero, size: CGSize(width: width, height: height))

                // Draw the image
                context.draw(Image(uiImage: image), in: imageFrame)

                // Draw bounding boxes for salient objects
                if let salientObjects = observations?.salientObjects {
                    for object in salientObjects {
                        let rect = object.boundingBox
                        // Convert bounding box to image coordinates
                        let boxFrame = rect.toImageCoordinates(imageFrame.size, origin: .upperLeft)
                        context.stroke(
                            Rectangle().path(in: boxFrame),
                            with: .color(.green),
                            lineWidth: 5
                        )
                    }
                }
            }
            Spacer()
        }
        .padding()
    }

    // Async function to detect saliency
    func detectObjects() async {
        guard let uiImage = UIImage(named: "tower"),
              let cgImage = uiImage.cgImage else {
            print("Image not found or cannot convert to CGImage")
            return
        }

        do {
            let request = GenerateAttentionBasedSaliencyImageRequest()
            observations = try await request.perform(on: cgImage)
            print("Detected objects:", observations?.salientObjects.count ?? 0)
        } catch {
            print("Vision error:", error)
        }
    }
}
