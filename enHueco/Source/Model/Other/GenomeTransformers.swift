//
//  GenomeTransformers.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 8/28/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import Foundation
import Genome

extension Date: NodeConvertible {
    
    public init(node: Node, in context: Context) throws {
        
        guard let value = node.double else {
            throw GenericError.error(message: "Could not map URL. Found \(node)")
        }
        
        self.init(timeIntervalSince1970: value)
    }
    
    public func makeNode(context: Context) throws -> Node {
        return Node(timeIntervalSince1970)
    }
}

extension RawRepresentable {
    
    public init(node: Node, in context: Context) throws {
        
        guard let rawValue = node.any as? RawValue, let mapped = Self(rawValue: rawValue) else {
            throw GenericError.error(message: "Could not map RawRepresentable. Found \(node)")
        }
        
        self = mapped
    }
    
    public func makeNode(context: Context) throws -> Node {
        return Node(String(describing: rawValue))
    }
}

extension URL: NodeConvertible {
    
    public init(node: Node, in context: Context) throws {
        
        guard let value = node.string, let mapped = URL(string: value) else {
            throw GenericError.error(message: "Could not map URL. Found \(node)")
        }
        
        self = mapped
    }
    
    public func makeNode(context: Context) throws -> Node {
        return Node(absoluteString)
    }
}
