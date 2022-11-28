import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
  func complicationDescriptors() async -> [CLKComplicationDescriptor] {
    return [
      .init(
        identifier: "com.raywenderlich.Happy",
        displayName: "Happy",
        supportedFamilies: [
          .graphicExtraLarge
        ]
      )
    ]
  }

  func currentTimelineEntry(for complication: CLKComplication) async -> CLKComplicationTimelineEntry? {
    guard let full = UIImage(named: "Full"),
          let background = UIImage(named: "Background"),
          let eyesAndMouth = UIImage(named: "eyesAndMouth")
    else {
      fatalError("Images are missing from the asset catalogue")
    }

    let template = CLKComplicationTemplateGraphicExtraLargeCircularImage(
      imageProvider: CLKFullColorImageProvider(fullColorImage: full,
                                               tintedImageProvider: .init(
                                                onePieceImage: full,
                                                twoPieceImageBackground: background,
                                                twoPieceImageForeground: eyesAndMouth
                                               )
                                              )
    )
    return .init(date: Date.now, complicationTemplate: template)
  }

  func localizableSampleTemplate(for complication: CLKComplication) async -> CLKComplicationTemplate? {
    guard let full = UIImage(named: "Full") else {
      fatalError("Full.png is missing from asset catalog.")
    }

    return CLKComplicationTemplateGraphicExtraLargeCircularImage(
      imageProvider: CLKFullColorImageProvider(fullColorImage: full)
    )
  }
}
