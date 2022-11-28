import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    func complicationDescriptors() async -> [CLKComplicationDescriptor] {
        return [
            .init(
                identifier: "com.jrogel.TideWatch",
                displayName: "Tide Conditions",
                supportedFamilies: [
                    .graphicCircular, .graphicBezel
                ]
            )
        ]
    }

    func currentTimelineEntry(for complication: CLKComplication) async -> CLKComplicationTimelineEntry? {
        guard let factory = ComplicationTemplates.generate(for: complication),
              let tide = Tide.getCurrent()
        else {
            return nil
        }

        let template = factory.template(for: tide)

        return .init(date: tide.date, complicationTemplate: template)
    }

    func localizableSampleTemplate(for complication: CLKComplication) async -> CLKComplicationTemplate? {
        return ComplicationTemplates.generate(for: complication)?.templateForSample()
    }
}
