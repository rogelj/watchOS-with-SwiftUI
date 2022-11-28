import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    func complicationDescriptors() async -> [CLKComplicationDescriptor] {
        return [
            .init(
                identifier: "com.raywenderlich.TideWatch",
                displayName: "Tide Conditions",
                supportedFamilies: [
                    .graphicCircular
                ]
            )
        ]
    }

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

    func localizableSampleTemplate(for complication: CLKComplication) async -> CLKComplicationTemplate? {
        guard complication.family == .graphicCircular,
        let image = UIImage(named: "tide_rising") else {
            return nil
        }

        let tide = Tide(entity: Tide.entity(), insertInto: nil)
        tide.date = Date()
        tide.height = 24
        tide.type = .high

        return CLKComplicationTemplateGraphicCircularStackImage(
            line1ImageProvider: .init(fullColorImage: image),
            line2TextProvider: .init(format: tide.heightString())
        )
    }
}
