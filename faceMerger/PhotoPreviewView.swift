//
//  PhotoPreviewView.swift
//  faceMerger
//
//  Created by  Jeewwon Han on 1/14/21.
//

import SwiftUI

struct PhotoPreviewView: View {
    var body: some View {
        
        VStack {
            TopTitleView()
            Spacer()
        }
    }
}

struct PhotoPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoPreviewView()
    }
}


struct TopTitleView: View {
    var body: some View {
        ZStack {
            Color.green.ignoresSafeArea()
            HStack {
                Button("back button", action: {
                    print("go back")
                })
                Spacer()
                Text("Choose Image").fontWeight(.bold)
                Spacer()
                Button("retake", action: {
                    print("retake")
                }).padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10
                ))
                
            }
            Spacer()
        }.frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    }
}
