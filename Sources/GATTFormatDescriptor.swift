//
//  GATTFormatDescriptor.swift
//  Bluetooth
//
//  Created by Carlos Duclos on 6/14/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

// MARK: - Characteristic Presentation Format
/// GATT Characteristic Presentation Format Descriptor
///
/// The Characteristic Presentation Format descriptor defines the format of the Characteristic Value.
///
/// One or more Characteristic Presentation Format descriptors may be present.
/// If multiple of these descriptors are present, then a Aggregate Formate descriptor is present.
/// This descriptor is read only and does not require authentication or authorization to read.
/// This descriptor is composed of five parts: format, exponent, unit, name space and description.
/// The Format field determines how a single value contained in the Characteristic Value is formatted.
/// The Exponent field is used with interger data types to determine how the Characteristic Value is furhter formatted.
/// The actual value = Characteristic Value * 10^Exponent.
///
/// Examples:
/// When encoding an IPv4 address, the uint32 Format type is used.
/// When encoding an IPv6 address, the uint128 Format type is used.
/// When encoding a Bluetooth address (BD_ADDR), the uint48 Format type is used.
/// For a Characteristic Value of 23 and an Exponent of 2, the actual value is 2300
/// For a Characteristi Value of 3892 and an Exponent of -3, the actual value is 3.892
public struct GATTFormatDescriptor: GATTDescriptor {
    
    public static let uuid: BluetoothUUID = .characteristicFormat
    
    public static let length = 7
    
    public let format: CharacteristicFormatType
    
    public let exponent: Int8
    
    public let unit: UInt16
    
    public let namespace: UInt8
    
    public let description: UInt16
    
    public init(format: CharacteristicFormatType, exponent: Int8, unit: UInt16, namespace: UInt8, description: UInt16) {
        
        self.format = format
        self.exponent = exponent
        self.unit = unit
        self.namespace = namespace
        self.description = description
    }
    
    public init?(byteValue: Data) {
        
        guard byteValue.count == type(of: self).length
            else { return nil }
        
        guard let format = CharacteristicFormatType.init(rawValue: byteValue[0])
            else { return nil }
        
        self.init(format: format,
                  exponent: Int8(bitPattern: byteValue[1]),
                  unit: UInt16(littleEndian: UInt16(bytes: (byteValue[2], byteValue[3]))),
                  namespace: byteValue[4],
                  description: UInt16(littleEndian: UInt16(bytes: (byteValue[5], byteValue[6]))))
    }
    
    public var byteValue: Data {
        
        let unitBytes = unit.littleEndian.bytes
        let descriptionBytes = description.littleEndian.bytes
        
        return Data([format.rawValue,
                     UInt8(bitPattern: exponent),
                     unitBytes.0,
                     unitBytes.1,
                     namespace,
                     descriptionBytes.0,
                     descriptionBytes.1
            ])
    }
    
    public var descriptor: GATT.Descriptor {
        
        return GATT.Descriptor(uuid: type(of: self).uuid,
                               value: byteValue,
                               permissions: [.read])
    }
}
