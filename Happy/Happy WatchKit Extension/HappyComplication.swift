//
//  HappyComplication.swift
//  Happy WatchKit Extension
//
//  Created by J Rogel PhD on 28/11/2022.
//  Copyright © 2022 Ray Wenderlich. All rights reserved.
//
import ClockKit
import SwiftUI

struct HappyComplication: View {
  var body: some View {
    ZStack {
      Circle()
      Image("eyesAndMouth")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .complicationForeground()
    }
  }
}

struct HappyComplication_Previews: PreviewProvider {
    static var previews: some View {
      Group {
        ForEach(CLKComplicationTemplate.PreviewFaceColor.allColors) {
          CLKComplicationTemplateGraphicExtraLargeCircularView(
            HappyComplication()
          )
          .previewContext(faceColor: $0)
        }
      }
    }
}