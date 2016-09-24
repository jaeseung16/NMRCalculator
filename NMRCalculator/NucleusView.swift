//
//  NucleusView.swift
//  NMRCalculator
//
//  Created by Jae-Seung Lee on 6/15/16.
//  Copyright © 2016 Jae-Seung Lee. All rights reserved.
//

import UIKit

@IBDesignable class NucleusView: UIView {
    
    @IBOutlet var NucleusUIView: UIView!
    
    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var abundance: UILabel!
    @IBOutlet weak var spin: UILabel!
    @IBOutlet weak var gamma: UILabel!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.commonInit()
    
/*        let rotate = CGAffineTransformMakeRotation(CGFloat(M_PI/2))
        self.transform = rotate */

    }
    
    convenience init(frame: CGRect, nucleus: Nucleus){
        self.init(frame: frame)
        
        var fontsize = CGFloat(12.0)
        
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            fontsize = 18.0
        }
        
        var character_attribute: [String: AnyObject] = [NSBaselineOffsetAttributeName : fontsize as AnyObject, NSFontAttributeName: UIFont.systemFont(ofSize: fontsize, weight: UIFontWeightBold)]

        let textforweight = NSMutableAttributedString(string: nucleus.atomicWeight!)
        textforweight.setAttributes(character_attribute, range: NSMakeRange(0, nucleus.atomicWeight!.lengthOfBytes(using: String.Encoding.utf8)) )
        
        character_attribute[NSBaselineOffsetAttributeName] = 0 as AnyObject?
        character_attribute[NSFontAttributeName] = UIFont.systemFont(ofSize: 2.0 * fontsize, weight: UIFontWeightBold)

        let textforname = NSMutableAttributedString(string: nucleus.symbolNucleus!)
        textforname.setAttributes(character_attribute, range: NSMakeRange(0, nucleus.symbolNucleus!.lengthOfBytes(using: String.Encoding.utf8)) )
        textforweight.append(textforname)
        
        symbol.attributedText = textforweight
        
        character_attribute[NSFontAttributeName] = UIFont.systemFont(ofSize: fontsize, weight: UIFontWeightRegular)
        
        let abundance_text = "Natural Abundance: \(nucleus.naturalabundance!) %"
       
        abundance.attributedText = NSAttributedString(string: abundance_text, attributes: character_attribute)

        let spin_text = "Nuclear Spin: \(nucleus.nuclearspin!)"
        spin.attributedText = NSAttributedString(string: spin_text, attributes: character_attribute)
        
        let gamma_text = "Gyromagnetic Ratio: \(Double(nucleus.gyromagneticratio!)!.format(".3")) MHz/T"
        gamma.attributedText = NSAttributedString(string: gamma_text, attributes: character_attribute)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    fileprivate func commonInit() {
        Bundle.main.loadNibNamed("NucleusView", owner: self, options: nil)
        guard let content = NucleusUIView else { return }
        content.frame = self.bounds
        content.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(content)
    }

}
