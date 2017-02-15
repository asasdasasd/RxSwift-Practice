//
//  PseudoRandomGenerator.swift
//  Practice
//
//  Created by shen on 2017/2/15.
//  Copyright © 2017年 asasdasasd. All rights reserved.
//

class PseudoRandomGenerator {
    var m_w: UInt32
    var m_z: UInt32
    
    init(_ m_w: UInt32, _ m_z: UInt32) {
        self.m_w = m_w      /* must not be zero, nor 0x464fffff */
        self.m_z = m_z      /* must not be zero, nor 0x9068ffff */
    }
    
    func get_random() -> Int {
        m_z = 36969 &* (m_z & 65535) &+ (m_z >> 16)
        m_w = 18000 &* (m_w & 65535) &+ (m_w >> 16)
        let val = ((m_z << 16) &+ m_w)
        return Int(val % (1 << 30))
        
    }
    
    
}




















