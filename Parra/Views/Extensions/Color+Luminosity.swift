//
//  Color+Luminosity.swift
//  Parra
//
//  Created by Mick MacCallum on 1/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI

// TODO: Fix black input leading to white output

// Fantastic explanation of how it works
// http://www.niwa.nu/2013/05/math-behind-colorspace-conversions-rgb-hsl/
fileprivate extension CGFloat {
    /// clamp the supplied value between a min and max
    /// - Parameter min: The min value
    /// - Parameter max: The max value
    func clamp(min: CGFloat, max: CGFloat) -> CGFloat {
        if self < min {
            return min
        } else if self > max {
            return max
        } else {
            return self
        }
    }

    /// If colour value is less than 1, add 1 to it. If temp colour value is greater than 1, substract 1 from it
    func convertToColourChannel() -> CGFloat {
        let min: CGFloat = 0
        let max: CGFloat = 1
        let modifier: CGFloat = 1
        if self < min {
            return self + modifier
        } else if self > max {
            return self - max
        } else {
            return self
        }
    }

    /// Formula to convert the calculated colour from colour multipliers
    /// - Parameter temp1: Temp variable one (calculated from luminosity)
    /// - Parameter temp2: Temp variable two (calcualted from temp1 and luminosity)
    func convertToRGB(temp1: CGFloat, temp2: CGFloat) -> CGFloat {
        if 6 * self < 1 {
            return temp2 + (temp1 - temp2) * 6 * self
        } else if 2 * self < 1 {
            return temp1
        } else if 3 * self < 2 {
            return temp2 + (temp1 - temp2) * (0.666 - self) * 6
        } else {
            return temp2
        }
    }
}

extension Color {
    // Check if the color is light or dark, as defined by the injected lightness threshold.
    func isLight(threshold: Float = 0.5) -> Bool {
        let originalCGColor = UIColor(self).cgColor

        // Now we need to convert it to the RGB colorspace. UIColor.white / UIColor.black are greyscale and not RGB.
        // If you don't do this then you will crash when accessing components index 2 below when evaluating greyscale colors.
        let RGBCGColor = originalCGColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)
        guard let components = RGBCGColor?.components else {
            return true
        }

        guard components.count >= 3 else {
            return true
        }

        let brightness = Float(((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000)

        return (brightness > threshold)
    }

    /// Return a UIColor with adjusted luminosity, returns self if unable to convert
    /// - Parameter newLuminosity: New luminosity, between 0 and 1 (percentage)
    func withLuminosity(_ newLuminosity: CGFloat) -> Color {
        // 1 - Convert the RGB values to the range 0-1
        let coreColour = CIColor(color: UIColor(self))
        var red = coreColour.red
        var green = coreColour.green
        var blue = coreColour.blue
        let opacity = coreColour.alpha

        // 1a - Clamp these colours between 0 and 1 (combat sRGB colour space)
        red = red.clamp(min: 0, max: 1)
        green = green.clamp(min: 0, max: 1)
        blue = blue.clamp(min: 0, max: 1)

        // 2 - Find the minimum and maximum values of R, G and B.
        guard let minRGB = [red, green, blue].min(), let maxRGB = [red, green, blue].max() else {
            return self
        }

        // 3 - Now calculate the Luminace value by adding the max and min values and divide by 2.
        var luminosity = (minRGB + maxRGB) / 2

        if luminosity == 0 && newLuminosity <= 0.5 {
            // The color is black. There's nothing we can do
            return self
        }

        // 4 - The next step is to find the Saturation.
        // 4a - if min and max RGB are the same, we have 0 saturation
        // 5 - Now we know that there is Saturation we need to do check the level of the Luminance in order to select the correct formula.
        //     If Luminance is smaller then 0.5, then Saturation = (max-min)/(max+min)
        //     If Luminance is bigger then 0.5. then Saturation = ( max-min)/(2.0-max-min)
        let saturation: CGFloat = if luminosity == 0.0 {
            0
        } else if luminosity <= 0.5 {
            (maxRGB - minRGB) / (maxRGB + minRGB)
        } else if luminosity > 0.5 {
            (maxRGB - minRGB) / (2.0 - maxRGB - minRGB)
        } else {
            // 0 if we are equal RGBs
            0
        }

        // 6 - The Hue formula is depending on what RGB color channel is the max value. The three different formulas are:
        var hue: CGFloat = if red == maxRGB {
            // 6a - If Red is max, then Hue = (G-B)/(max-min)
            (green - blue) / (maxRGB - minRGB)
        } else if green == maxRGB {
            // 6b - If Green is max, then Hue = 2.0 + (B-R)/(max-min)
            2.0 + ((blue - red) / (maxRGB - minRGB))
        } else if blue == maxRGB {
            // 6c - If Blue is max, then Hue = 4.0 + (R-G)/(max-min)
            4.0 + ((red - green) / (maxRGB - minRGB))
        } else {
            0.0
        }

        // 7 - The Hue value you get needs to be multiplied by 60 to convert it to degrees on the color circle
        //     If Hue becomes negative you need to add 360 to, because a circle has 360 degrees.
        if hue < 0 {
            hue += 360
        } else {
            hue = hue * 60
        }

        // we want to convert the luminosity. So we will.
        luminosity = newLuminosity

        // Now we need to convert back to RGB

        // 1 - If there is no Saturation it means that it’s a shade of grey. So in that case we just need to convert the Luminance and set R,G and B to that level.
        if saturation == 0 {
            return Color(
                red: 1.0 * luminosity,
                green: 1.0 * luminosity,
                blue: 1.0 * luminosity,
                opacity: opacity
            )
        }

        // 2 - If Luminance is smaller then 0.5 (50%) then temporary_1 = Luminance x (1.0+Saturation)
        //     If Luminance is equal or larger then 0.5 (50%) then temporary_1 = Luminance + Saturation – Luminance x Saturation
        var temporaryVariableOne: CGFloat = 0
        if luminosity < 0.5 {
            temporaryVariableOne = luminosity * (1 + saturation)
        } else {
            temporaryVariableOne = luminosity + saturation - luminosity * saturation
        }

        // 3 - Final calculated temporary variable
        let temporaryVariableTwo = 2 * luminosity - temporaryVariableOne

        // 4 - The next step is to convert the 360 degrees in a circle to 1 by dividing the angle by 360
        let convertedHue = hue / 360

        // 5 - Now we need a temporary variable for each colour channel
        let tempRed = (convertedHue + 0.333).convertToColourChannel()
        let tempGreen = convertedHue.convertToColourChannel()
        let tempBlue = (convertedHue - 0.333).convertToColourChannel()

        // 6 we must run up to 3 tests to select the correct formula for each colour channel, converting to RGB
        let newRed = tempRed.convertToRGB(temp1: temporaryVariableOne, temp2: temporaryVariableTwo)
        let newGreen = tempGreen.convertToRGB(temp1: temporaryVariableOne, temp2: temporaryVariableTwo)
        let newBlue = tempBlue.convertToRGB(temp1: temporaryVariableOne, temp2: temporaryVariableTwo)

        guard newRed.isFinite, newGreen.isFinite, newBlue.isFinite else {
            return self
        }

        return Color(
            red: newRed,
            green: newGreen,
            blue: newBlue,
            opacity: opacity
        )
    }
}
