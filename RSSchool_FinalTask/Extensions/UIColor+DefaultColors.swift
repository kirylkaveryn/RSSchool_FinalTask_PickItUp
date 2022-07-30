//
//  UIColor+DefaultColors.swift
//  RSSchool_T12_FinanceManager
//
//  Created by Kirill on 22.09.21.
//

import UIKit

extension UIColor {
    static let rsGreenMain = UIColor(named:"GreenMain") ?? UIColor.green
    static let rsRedMain = UIColor(named:"RedMain") ?? UIColor.red
    static let rsSystemBackground = UIColor(named:"SystemBackground") ?? UIColor.white
    static let rsSecondaryBackground = UIColor(named:"SecondaryBackground") ?? UIColor.white
    static let rsLineSeparatorColor = UIColor(named:"LineSeparatorColor") ?? UIColor.lightGray
    static let rsMapButtonBackground = UIColor(named:"MapButtonBackground") ?? UIColor.lightGray

    static let rsBlack = UIColor(red: 0.027, green: 0.063, blue: 0.075, alpha: 1)
    
    static let rsDumpMetalColor = UIColor(named:"DumpMetal") ?? UIColor.lightGray
    static let rsDumpPlasticColor = UIColor(named:"DumpPlastic") ?? UIColor.lightGray
    static let rsDumpPaperColor = UIColor(named:"DumpPaper") ?? UIColor.lightGray
    static let rsDumpMixedColor = UIColor(named:"DumpMixed") ?? UIColor.lightGray
    static let rsDumpClearColor = UIColor(named:"DumpClear") ?? UIColor.lightGray


}
