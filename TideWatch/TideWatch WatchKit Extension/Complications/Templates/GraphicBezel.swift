//
//  GraphicBezel.swift
//  TideWatch WatchKit App
//
//  Created by J Rogel PhD on 28/11/2022.
//

import ClockKit

struct GraphicBezel: ComplicationTemplateFactory {
    func template(for waterLevel: Tide) -> CLKComplicationTemplate {
        let circularTemplate = CLKComplicationTemplateGraphicCircularImage(
            imageProvider: fullColorImageProvider(for: waterLevel)
        )

        return CLKComplicationTemplateGraphicBezelCircularText(
            circularTemplate: circularTemplate,
            textProvider: textProvider(for: waterLevel, unitStyle: .long)
        )
    }
}
