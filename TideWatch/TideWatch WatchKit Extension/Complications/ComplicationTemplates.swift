//
//  ComplicationTemplates.swift
//  TideWatch WatchKit App
//
//  Created by J Rogel PhD on 28/11/2022.
//

import ClockKit

enum ComplicationTemplates {
    static func generate(
        for complication: CLKComplication
    ) -> ComplicationTemplateFactory? {
        switch complication.family {
            case .graphicCircular: return GraphicCircular()
            case .graphicBezel: return GraphicBezel()

            default:
                return nil
        }
    }
}
