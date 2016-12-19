//
//  SensorTagTableViewCell.swift
//  SwiftSensorTag
//
//  Created by Anas Imtiaz on 13/11/2015.
//  Copyright © 2015 Anas Imtiaz. All rights reserved.
//

import UIKit

class SensorTagTableViewCell: UITableViewCell {
    
    var sensorNameLabel  = UILabel()
    var sensorValueLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // sensor name
        sensorNameLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        sensorNameLabel.frame = CGRect(x: self.bounds.origin.x+self.layoutMargins.left * 0.5, y: self.bounds.origin.y, width: self.frame.width, height: self.frame.height)
        sensorNameLabel.textAlignment = NSTextAlignment.Left
        sensorNameLabel.text = "Sensor Name Label"
        self.addSubview(sensorNameLabel)

        // sensor value
        
        sensorValueLabel.font = UIFont(name: "HelveticaNeue", size: 14)
              sensorValueLabel.textAlignment = NSTextAlignment.Right
        sensorValueLabel.text = "Value"
        sensorValueLabel.frame = CGRect(x: self.bounds.origin.x-50, y: self.bounds.origin.y, width: self.frame.width, height: self.frame.height)
        self.addSubview(sensorValueLabel)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
