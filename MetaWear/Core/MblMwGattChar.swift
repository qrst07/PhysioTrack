/**
 * MblMwGattChar.swift
 * MetaWear-Swift
 *
 * Created by Stephen Schiffli on 12/14/17.
 * Copyright 2017 MbientLab Inc. All rights reserved.
 *
 * IMPORTANT: Your use of this Software is limited to those specific rights
 * granted under the terms of a software license agreement between the user who
 * downloaded the software, his/her employer (which must be your employer) and
 * MbientLab Inc, (the "License").  You may not use this Software unless you
 * agree to abide by the terms of the License which can be found at
 * www.mbientlab.com/terms.  The License limits your use, and you acknowledge,
 * that the Software may be modified, copied, and distributed when used in
 * conjunction with an MbientLab Inc, product.  Other than for the foregoing
 * purpose, you may not use, reproduce, copy, prepare derivative works of,
 * modify, distribute, perform, display or sell this Software and/or its
 * documentation for any purpose.
 *
 * YOU FURTHER ACKNOWLEDGE AND AGREE THAT THE SOFTWARE AND DOCUMENTATION ARE
 * PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY, TITLE,
 * NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL
 * MBIENTLAB OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER CONTRACT, NEGLIGENCE,
 * STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR OTHER LEGAL EQUITABLE
 * THEORY ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES INCLUDING BUT NOT LIMITED
 * TO ANY INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE OR CONSEQUENTIAL DAMAGES, LOST
 * PROFITS OR LOST DATA, COST OF PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY,
 * SERVICES, OR ANY CLAIMS BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY
 * DEFENSE THEREOF), OR OTHER SIMILAR COSTS.
 *
 * Should you have any questions regarding your right to use this Software,
 * contact MbientLab via email: hello@mbientlab.com
 */

import CoreBluetooth
import MetaWearCpp


/// Helpers for dealing with the C++ version of GATT Service/Characteristic
extension MblMwGattChar: Hashable {
    var serviceUUID: CBUUID { CBUUID(high64: service_uuid_high, low64: service_uuid_low) }
    var characteristicUUID: CBUUID { CBUUID(high64: uuid_high, low64: uuid_low) }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(service_uuid_high)
        hasher.combine(service_uuid_low)
        hasher.combine(uuid_high)
        hasher.combine(uuid_low)
    }
    public static func ==(lhs: MblMwGattChar, rhs: MblMwGattChar) -> Bool {
        return lhs.service_uuid_high == rhs.service_uuid_high &&
            lhs.service_uuid_low == rhs.service_uuid_low &&
            lhs.uuid_high == rhs.uuid_high &&
            lhs.uuid_low == rhs.uuid_low
    }
}

extension CBUUID {

    convenience init(high64: UInt64, low64: UInt64) {
        let uuid_high_swap = high64.byteSwapped
        let uuid_low_swap  = low64.byteSwapped
        var data = withUnsafePointer(to: uuid_high_swap) { p in
            Data(buffer: UnsafeBufferPointer(start: p, count: 1))
        }
        withUnsafePointer(to: uuid_low_swap) { p in
            data.append(UnsafeBufferPointer(start: p, count: 1))
        }
        self.init(data: data)
    }
}
