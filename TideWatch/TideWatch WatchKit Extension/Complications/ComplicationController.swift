import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
  func currentTimelineEntry(for complication: CLKComplication) async -> CLKComplicationTimelineEntry? {
    guard complication.family == .circularSmall else {
      return nil
    }

    let template = CLKComplicationTemplateGraphicCircularStackText(
      line1TextProvider: .init(format: "Surf's"),
      line2TextProvider: .init(format: "Up!")
      )

    return .init(date: Date(), complicationTemplate: template)
  }

  func complicationDescriptors() async -> [CLKComplicationDescriptor] {
    return [
      .init(identifier: "com.raywenderlich.TideWatch", displayName: "Tide Conditions", supportedFamilies: [.graphicCircular]
           )
    ]
  }
}
