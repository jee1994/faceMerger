//
//  CameraView.swift
//  faceMerger
//
//  Created by Jeewoon Han on 2021/01/06.
//

import SwiftUI
import AVFoundation

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}

struct CameraView: View {
    
    @StateObject var camera = CameraModel()
    
    var body: some View {
        ZStack {
            CameraPreview(camera: camera)
                .ignoresSafeArea(.all, edges: .all)
            
            VStack {
                Spacer()
                
                if camera.isTaken {
                    
                } else {
                    HStack {
                        Button(action: { camera.takePic() }, label: {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 55, height: 55, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 65, height: 65
                                           , alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            }.padding()
                        })
                    }
                }
            }.onAppear(perform: {
                camera.checkAuthorization()
            })
            
            
        }
    }
}

class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    
    @Published var isTaken = false
    @Published var session = AVCaptureSession()
    @Published var alert = false
    @Published var pictureDatas = Data([])
    
    @Published var output = AVCapturePhotoOutput()
    @Published var photoSettings = AVCapturePhotoBracketSettings()
    
    @Published var preview = AVCaptureVideoPreviewLayer()
    
    func checkAuthorization() {
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUp()
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] success in
                if success {
                    self?.setUp()
                }
            }
        case .denied:
            self.alert.toggle()
            return
        default:
            return
        }
    }
    
    func setUp() {
        do {
            
            let exposureValues: [Float] = [0, 0, 0, 0]
            let makeAutoExposureSettings = AVCaptureAutoExposureBracketedStillImageSettings.autoExposureSettings(exposureTargetBias:)
            let exposureSettings = exposureValues.map(makeAutoExposureSettings)
            
            photoSettings =
                AVCapturePhotoBracketSettings(rawPixelFormatType: 0,
                processedFormat: [AVVideoCodecKey : AVVideoCodecType.hevc],
                bracketedSettings: exposureSettings)
            
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo
            //self.session.avca
            
            

            
            if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                let input = try AVCaptureDeviceInput(device: device)
                
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                }
            }
            
            if self.session.canAddOutput(self.output) {
                self.session.addOutput(self.output)
                print("max count \(self.output.maxBracketedCapturePhotoCount)")
            }
            
            self.session.commitConfiguration()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func takePic() {
        
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            self.output.capturePhoto(with: self.photoSettings, delegate: self)
            self.session.stopRunning()
            DispatchQueue.main.async {
                withAnimation{ //self.isTaken.toggle()
                    
                }
            }
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if error != nil {
            return
        }
        
        guard pictureDatas.count == 5 else {
            if let imageData = photo.fileDataRepresentation() {
                pictureDatas.append(imageData)
            }
            print(pictureDatas.count)
            return
        }
        
        
    }
}

struct CameraPreview: UIViewRepresentable {
    
    @ObservedObject var camera: CameraModel
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        
        camera.preview.videoGravity = .resizeAspectFill
        
        view.layer.addSublayer(camera.preview)
        
        camera.session.startRunning()
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
}
