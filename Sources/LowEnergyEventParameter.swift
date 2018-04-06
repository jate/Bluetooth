//
//  LowEnergyEventParameter.swift
//  Bluetooth
//
//  Created by Alsey Coleman Miller on 3/2/16.
//  Copyright © 2016 PureSwift. All rights reserved.
//

public extension LowEnergyEvent {
    
    /// LE Connection Complete Event
    /// 
    /// The LE Connection Complete event indicates to both of the Hosts forming the connection 
    /// that a new connection has been created. Upon the creation of the connection a 
    /// `Connection_Handle` shall be assigned by the Controller, and passed to the Host in this event. 
    /// If the connection establishment fails this event shall be provided to the Host that had issued 
    /// the LE Create Connection command.
    ///
    /// This event indicates to the Host which issued a LE Create Connection command 
    /// and received a Command Status event if the connection establishment failed or was successful.
    ///
    /// The `masterClockAccuracy` parameter is only valid for a slave. 
    /// On a master, this parameter shall be set to 0x00.
    public struct ConnectionCompleteParameter: HCIEventParameter {
        
        public static let event = LowEnergyEvent.connectionComplete // 0x01
        public static let length = 18
        
        /// Connection supervision timeout.
        ///
        /// Range: 0x000A to 0x0C80
        /// Time = N * 10 msec
        /// Time Range: 100 msec to 32 seconds
        public typealias SupervisionTimeout = LowEnergySupervisionTimeout
        
        public typealias Status = HCIStatus
        
        /// `0x00` if Connection successfully completed.
        /// `HCIError` value otherwise.
        public let status: Status
        
        /// Connection Handle
        ///
        /// Connection Handle to be used to identify a connection between two Bluetooth devices.
        /// The handle is used as an identifier for transmitting and receiving data.
        ///
        /// Range: 0x0000-0x0EFF (0x0F00 - 0x0FFF Reserved for future use)
        ///
        /// Size: 2 Octets (12 bits meaningful)
        public let handle: UInt16 // Connection_Handle
        
        /// Connection role (master or slave).
        public let role: Role // Role
        
        /// Peer Bluetooth address type.
        public let peerAddressType: LowEnergyAddressType // Peer_Address_Type
        
        /// Public Device Address or Random Device Address of the peer device.
        public let peerAddress: Address
        
        /// Connection interval used on this connection.
        ///
        /// Range: 0x0006 to 0x0C80
        /// Time = N * 1.25 msec
        /// Time Range: 7.5 msec to 4000 msec.
        public let interval: ConnectionInterval
        
        /// Connection latency for this connection.
        ///
        /// Range: 0x0006 to 0x0C80
        /// Time = N * 1.25 msec
        /// Time Range: 7.5 msec to 4000 msec.
        public let latency: ConnectionInterval
        
        /// Connection supervision timeout.
        ///
        /// Range: 0x000A to 0x0C80
        /// Time = N * 10 msec
        /// Time Range: 100 msec to 32 seconds
        public let supervisionTimeout: SupervisionTimeout
        
        /// The `masterClockAccuracy` parameter is only valid for a slave.
        ///
        /// On a master, this parameter shall be set to 0x00.
        public let masterClockAccuracy: MasterClockAccuracy // Master_Clock_Accuracy
        
        public init?(byteValue: [UInt8]) {
            
            guard byteValue.count == ConnectionCompleteParameter.length
                else { return nil }
            
            let statusByte = byteValue[0]
            
            let handle = UInt16(littleEndian: UInt16(bytes: (byteValue[1], byteValue[2])))
            
            let roleByte = byteValue[3]
            
            let peerAddressTypeByte = byteValue[4]
            
            let peerAddress = Address(littleEndian:
                Address(bytes: (byteValue[5],
                                byteValue[6],
                                byteValue[7],
                                byteValue[8],
                                byteValue[9],
                                byteValue[10])))
            
            let intervalRawValue = UInt16(littleEndian: UInt16(bytes: (byteValue[11], byteValue[12])))
            
            let latencyRawValue = UInt16(littleEndian: UInt16(bytes: (byteValue[13], byteValue[14])))
            
            let supervisionTimeoutRaw = UInt16(littleEndian: UInt16(bytes: (byteValue[15], byteValue[16])))
            
            let masterClockAccuracyByte = byteValue[17]
            
            // Parse enums and values ranges
            guard let status = Status(rawValue: statusByte),
                let role = Role(rawValue: roleByte),
                let peerAddressType = LowEnergyAddressType(rawValue: peerAddressTypeByte),
                let supervisionTimeout = SupervisionTimeout(rawValue: supervisionTimeoutRaw),
                let masterClockAccuracy = MasterClockAccuracy(rawValue: masterClockAccuracyByte)
                else { return nil }
            
            self.status = status
            self.handle = handle
            self.role = role
            self.peerAddressType = peerAddressType
            self.peerAddress = peerAddress
            self.interval = ConnectionInterval(rawValue: intervalRawValue)
            self.latency = ConnectionInterval(rawValue: latencyRawValue)
            self.supervisionTimeout = supervisionTimeout
            self.masterClockAccuracy = masterClockAccuracy
        }
        
        /// Connection role
        public enum Role: UInt8 {
            
            /// Connection is master.
            case master
            
            /// Connection is slave
            case slave
        }
        
        /// Connection interval / latency used on this connection.
        ///
        /// Range: 0x0006 to 0x0C80
        /// Time = N * 1.25 msec
        /// Time Range: 7.5 msec to 4000 msec.
        public struct ConnectionInterval: RawRepresentable, Equatable, Hashable, Comparable {
            
            /// 7.5 msec
            public static let min = ConnectionInterval(0x0006)
            
            /// 4000 msec
            public static let max = ConnectionInterval(0x0C80)
            
            public let rawValue: UInt16
            
            public init(rawValue: UInt16) {
                
                self.rawValue = rawValue
            }
            
            /// Time = N * 1.25 msec
            public var miliseconds: Double {
                
                return Double(rawValue) * 1.25
            }
            
            // Private, unsafe
            private init(_ rawValue: UInt16) {
                self.rawValue = rawValue
            }
            
            // Equatable
            public static func == (lhs: ConnectionInterval, rhs: ConnectionInterval) -> Bool {
                
                return lhs.rawValue == rhs.rawValue
            }
            
            // Comparable
            public static func < (lhs: ConnectionInterval, rhs: ConnectionInterval) -> Bool {
                
                return lhs.rawValue < rhs.rawValue
            }
            
            // Hashable
            public var hashValue: Int {
                
                return Int(rawValue)
            }
        }
        
        /// Master Clock Accuracy
        public enum MasterClockAccuracy: UInt8 {
            
            case ppm500     = 0x00
            case ppm250     = 0x01
            case ppm150     = 0x02
            case ppm100     = 0x03
            case ppm75      = 0x04
            case ppm50      = 0x05
            case ppm30      = 0x06
            case ppm20      = 0x07
            
            public var ppm: UInt {
                
                switch self {
                case .ppm500: return 500
                case .ppm250: return 250
                case .ppm150: return 150
                case .ppm100: return 100
                case .ppm75: return 75
                case .ppm50: return 50
                case .ppm30: return 30
                case .ppm20: return 20
                }
            }
        }
    }
    
    /// LE Advertising Report Event
    /// 
    /// The LE Advertising Report event indicates that a Bluetooth device 
    /// or multiple Bluetooth devices have responded to an active scan 
    /// or received some information during a passive scan. 
    /// The Controller may queue these advertising reports and send 
    /// information from multiple devices in one LE Advertising Report event.
    public struct AdvertisingReportEventParameter: HCIEventParameter {
        
        public static let event = LowEnergyEvent.advertisingReport
        public static let length = 1 + Report.length // must have at least one report
        
        public let reports: [Report]
        
        public init?(byteValue: [UInt8]) {
            
            guard byteValue.count >= AdvertisingReportEventParameter.length
                else { return nil }
            
            // Number of responses in event.
            let reportCount = Int(byteValue[0]) // Num_Reports
            
            // 0x01 - 0x19
            guard reportCount > 0,
                reportCount <= 19
                else { return nil }
            
            var reports = [Report]()
            reports.reserveCapacity(reportCount)
            
            var offset = 1
            for _ in 0 ..< reportCount {
                
                let reportBytes = [UInt8](byteValue.suffix(from: offset))
                
                guard let report = Report(byteValue: reportBytes)
                    else { return nil }
                
                offset += Report.length + report.data.count
                reports.append(report)
            }
            
            self.reports = reports
        }
        
        public struct Report {
            
            public static let length = 1 + 1 + 6 + 1 + /* 0 - 31 */ 0 + 1
            
            public let event: Event
            
            public let addressType: LowEnergyAddressType // Address_Type
            
            public let address: Address // Address
            
            /// Advertising or scan response data
            public let data: [UInt8] // Data
            
            /// RSSI
            ///
            /// Size: 1 Octet (signed integer) 
            /// Range: -127 ≤ N ≤ +20
            /// Units: dBm
            public let rssi: RSSI // RSSI
            
            public init?(byteValue: [UInt8]) {
                
                guard byteValue.count >= Report.length
                    else { return nil }
                
                // parse enums
                guard let event = Event(rawValue: byteValue[0]),
                    let addressType = LowEnergyAddressType(rawValue: byteValue[1])
                    else { return nil }
                
                let address = Address(littleEndian:
                    Address(bytes: (byteValue[2],
                                    byteValue[3],
                                    byteValue[4],
                                    byteValue[5],
                                    byteValue[6],
                                    byteValue[7])))
                
                let length = Int(byteValue[8])
                
                self.event = event
                self.addressType = addressType
                self.address = address
                
                let data = [UInt8](byteValue[9 ..< (9 + length)])
                assert(data.count == length)
                self.data = data
                
                // not enough bytes
                guard byteValue.count == (Report.length + length)
                    else { return nil }
                
                // last byte
                let rssiByte = Int8(bitPattern: byteValue[9 + length])
                
                guard let rssi = RSSI(rawValue: rssiByte)
                    else { return nil }
                
                self.rssi = rssi
            }
            
            public enum Event: UInt8 { // Event_Type
                
                /// Connectable undirected advertising event
                case undirected         = 0x00 // ADV_IND
                
                /// Connectable directed advertising event
                case directed           = 0x01 // ADV_DIRECT_IND
                
                /// Scannable undirected advertising event
                case scannable          = 0x02 // ADV_SCAN_IND
                
                /// Non-connectable undirected advertising event
                case nonConnectable     = 0x03 // ADV_NONCONN_IND
                
                /// Scan Response
                case scanResponse       = 0x04 // SCAN_RSP
            }
            
            /// RSSI
            ///
            /// Size: 1 Octet (signed integer)
            /// Range: -127 ≤ N ≤ +20
            /// Units: dBm
            public struct RSSI: RawRepresentable, Equatable, Comparable, Hashable {
                
                /// Units: dBm
                public let rawValue: Int8
                
                public init?(rawValue: Int8) {
                    
                    guard -127 <= rawValue,
                        rawValue <= +20
                        else { return nil }
                    
                    self.rawValue = rawValue
                }
                
                // Equatable
                public static func == (lhs: RSSI, rhs: RSSI) -> Bool {
                    
                    return lhs.rawValue == rhs.rawValue
                }
                
                // Comparable
                public static func < (lhs: RSSI, rhs: RSSI) -> Bool {
                    
                    return lhs.rawValue < rhs.rawValue
                }
                
                // Hashable
                public var hashValue: Int {
                    
                    return Int(rawValue)
                }
            }
        }
    }
    
    public struct ReadRemoteUsedFeaturesCompleteParameter: HCIEventParameter {
    
        public static let event = LowEnergyEvent.readRemoteUsedFeaturesComplete // 0x04
        
        public static let length: Int = 11
        
        public typealias Status = HCIStatus
        
        /// `0x00` if Connection successfully completed.
        /// `HCIError` value otherwise.
        public let status: Status
        
        /// Connection Handle
        ///
        /// Range: 0x0000-0x0EFF (all other values reserved for future use)
        public let handle: UInt16 // Connection_Handle
        
        /// LE features of the remote controller.
        public let features: LowEnergyFeatureSet
        
        public init?(byteValue: [UInt8]) {
            
            guard byteValue.count == ReadRemoteUsedFeaturesCompleteParameter.length
                else { return nil }
            
            let statusByte = byteValue[0]
            
            let handle = UInt16(littleEndian: UInt16(bytes: (byteValue[1], byteValue[2])))
            
            let featuresRawValue = UInt64(littleEndian: UInt64(bytes: (byteValue[3],
                                                                       byteValue[4],
                                                                       byteValue[5],
                                                                       byteValue[6],
                                                                       byteValue[7],
                                                                       byteValue[8],
                                                                       byteValue[9],
                                                                       byteValue[10])))
            
            guard let status = Status(rawValue: statusByte)
                else { return nil }
            
            self.status = status
            self.handle = handle
            self.features = LowEnergyFeatureSet(rawValue: featuresRawValue)
        }
    }
    
    /// LE Encryption Change Event
    ///
    /// The Encryption Change event is used to indicate that the change of the encryption mode has been completed.
    ///
    /// This event will occur on both devices to notify the Hosts when Encryption has changed for all connections between the two devices.
    /// Note: This event shall not be generated if encryption is paused or resumed; during a role switch, for example.
    public struct EncryptionChangeParameter: HCIEventParameter {
        public static let event = LowEnergyEvent.encryptionChange // 0x08
        
        public static let length: Int = 4
        
        public let status: HCIStatus
        
        /// The Connection_Handle will be a Connection_Handle for an ACL connection and is used to identify the remote device.
        public let handle: UInt16 // Connection_Handle
        
        /// The Encryption_Enabled event parameter specifies the new Encryption_Enabled parameter
        /// for the Connection_Handle specified by the Connection_Handle event parameter.
        ///
        /// The meaning of the Encryption_Enabled parameter depends on whether the Host has indicated support for Secure Connections in the Secure_Connections_Host_Support parameter.
        /// When Secure_Connections_Host_Support is ‘disabled’ or the Connection_Handle refers to an LE link, the Controller
        /// shall only use Encryption_Enabled values 0x00 (OFF) and 0x01 (ON). When Secure_Connections_Host_Support is ‘enabled’ and
        /// the Connection_Handle refers to a BR/EDR link, the Controller shall set Encryption_Enabled to 0x00 when encryption is off,
        /// to 0x01 when encryption is on and using E0 and to 0x02 when encryption is on and using AES-CCM.
        public let encryptionEnabled: EncryptionEnabled
        
        public init?(byteValue: [UInt8]) {
            guard byteValue.count == EncryptionChangeParameter.length
                else { return nil }
            
            let statusByte = byteValue[0]
            
            let handle = UInt16(littleEndian: UInt16(bytes: (byteValue[1], byteValue[2])))
            
            let encryptionEnabledByte = byteValue[3]
            
            guard let status = HCIStatus(rawValue: statusByte)
                else { return nil }
            
            guard let encryptionEnabled = EncryptionEnabled(rawValue: encryptionEnabledByte)
                else { return nil }
            
            self.status = status
            self.handle = handle
            self.encryptionEnabled = encryptionEnabled
        }
        
        public enum EncryptionEnabled: UInt8 { // Encryption_Enabled
            
            /// Link Level Encryption is OFF.
            case off         = 0x00
            
            /// Link Level Encryption is ON with E0 for BR/EDR.
            /// Link Level Encryption is ON with AES-CCM for LE.
            case e0          = 0x01
            
            /// Link Level Encryption is ON with AES-CCM for BR/EDR.
            case aes         = 0x02
        }
    }
    
    /// LE Encryption Key Refresh Complete Event
    ///
    /// The Encryption Key Refresh Complete event is used to indicate to the Host that the encryption key was
    /// refreshed on the given Connection_Handle any time encryption is paused and then resumed.
    /// The BR/EDR Controller shall send this event when the encryption key has been refreshed
    /// due to encryption being started or resumed.
    ///
    /// If the Encryption Key Refresh Complete event was generated due to an encryption pause
    /// and resume operation embedded within a change connection link key procedure, t
    /// he Encryption Key Refresh Complete event shall be sent prior to the Change Connection Link Key Complete event.
    ///
    /// If the Encryption Key Refresh Complete event was generated due to an encryption pause and
    /// resume operation embedded within a role switch procedure,
    /// the Encryption Key Refresh Complete event shall be sent prior to the Role Change event.
    public struct EncryptionKeyRefreshCompleteParameter: HCIEventParameter {
        
        public static let event = LowEnergyEvent.encryptionKeyRefreshComplete // 0x30
        
        public static let length: Int = 3
        
        public let status: HCIStatus
        
        public let handle: UInt16 // Connection_Handle
        
        public init?(byteValue: [UInt8]) {
            guard byteValue.count == EncryptionKeyRefreshCompleteParameter.length
                else { return nil }
            
            let statusByte = byteValue[0]
            
            let handle = UInt16(littleEndian: UInt16(bytes: (byteValue[1], byteValue[2])))
            
            guard let status = HCIStatus(rawValue: statusByte)
                else { return nil }
            
            self.status = status
            self.handle = handle
        }
    }
}
