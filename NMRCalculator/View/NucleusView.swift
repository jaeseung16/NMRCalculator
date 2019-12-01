//
//  NucleusView.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 6/15/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import UIKit

@IBDesignable class NucleusView: UIView {
    // Properties
    @IBOutlet var NucleusUIView: UIView!
    
    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var abundance: UILabel!
    @IBOutlet weak var spin: UILabel!
    @IBOutlet weak var gamma: UILabel!
    
    // MARK:- Methods
    override init(frame: CGRect){
        super.init(frame: frame)
        self.commonInit()
    }
    
    convenience init(frame: CGRect, nucleus: NMRNucleus){
        self.init(frame: frame)
        
        let fontsize = setFontSize()
   
        symbol.attributedText = buildTextForSymbol(nucleus: nucleus, fontsize: fontsize)
        
        let attributesForOtherText = buildAttributesForOtherText(fontsize: fontsize)
        
        let abundance_text = "Natural Abundance: \(nucleus.naturalAbundance) %"
        abundance.attributedText = NSAttributedString(string: abundance_text, attributes: attributesForOtherText)

        let spin_text = "Nuclear Spin: \(nucleus.nuclearSpin)"
        spin.attributedText = NSAttributedString(string: spin_text, attributes: attributesForOtherText)
        
        let gamma_text = "Gyromagnetic Ratio: \(Double(nucleus.gyromagneticRatio)!.format(".3")) MHz/T"
        gamma.attributedText = NSAttributedString(string: gamma_text, attributes: attributesForOtherText)
    }
    
    func setFontSize() -> CGFloat {
        let fontsize = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad ? 18.0 : 12.0
        return CGFloat(fontsize)
    }
    
    func buildTextForSymbol(nucleus: NMRNucleus, fontsize: CGFloat) -> NSAttributedString {
        let characterAttributeForWeight = [NSAttributedString.Key.baselineOffset : fontsize as AnyObject,
                                  NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontsize, weight: UIFont.Weight.bold)]
        let textForWeight = NSMutableAttributedString(string: nucleus.atomicWeight)
        textForWeight.setAttributes(characterAttributeForWeight, range: NSMakeRange(0, nucleus.atomicWeight.lengthOfBytes(using: String.Encoding.utf8)) )
        
        let characterAttributeForName = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 2.0 * fontsize, weight: UIFont.Weight.bold)]
        let textForName = NSMutableAttributedString(string: nucleus.symbolNucleus)
        textForName.setAttributes(characterAttributeForName, range: NSMakeRange(0, nucleus.symbolNucleus.lengthOfBytes(using: String.Encoding.utf8)) )
        
        textForWeight.append(textForName)
        return textForWeight
    }
    
    func buildAttributesForOtherText(fontsize: CGFloat) -> [NSAttributedString.Key: AnyObject] {
        let characterAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontsize, weight: UIFont.Weight.regular)]
        return characterAttribute
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func commonInit() {
        Bundle.main.loadNibNamed("NucleusView", owner: self, options: nil)
        guard let content = NucleusUIView else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
    }
}
