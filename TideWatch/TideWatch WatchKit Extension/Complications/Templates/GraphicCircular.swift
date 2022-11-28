//
//  GraphicCircular.swift
//  TideWatch WatchKit App
//
//  Created by J Rogel PhD on 28/11/2022.
//

import ClockKit

struct GraphicCircular: ComplicationTemplateFactory {
    func template(for waterLevel: Tide) -> CLKComplicationTemplate {
        return CLKComplicationTemplateGraphicCircularStackImage(
            line1ImageProvider: fullColorImageProvider(for: waterLevel),
            line2TextProvider: textProvider(for: waterLevel))
    }
}
