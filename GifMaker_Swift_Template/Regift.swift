//
//  Regift.swift
//  GifMaker_ObjC
//
//  Created by Gabrielle Miller-Messner on 3/2/16.
//  Copyright © 2016 Gabrielle Miller-Messner. All rights reserved.
//

import Foundation
import UIKit
import ImageIO
import MobileCoreServices
import AVFoundation

public typealias TimePoint = CMTime

/// Errors thrown by Regift
@objc public enum RegiftError: Int, ErrorType {
    case DestinationNotFound
    case AddFrameToDestination
    case DestinationFinalize
}

/// Easily convert a video to a GIF.
///
/// Usage:
///
///      let regift = Regift(sourceFileURL: movieFileURL, frameCount: 24, delayTime: 0.5, loopCount: 7)
///      print(regift.gifURL)
///


@objc public class Regift: NSObject {
    
    // Constants
    static let FileName = "regift.gif"
    static let TimeInterval: Int32 = 600
    static let Tolerance = 0.01
    
    private let sourceFileURL: NSURL
    private let frameCount: Int
    private let delayTime: Float
    private let loopCount: Int
    
    /// Create a GIF from a movie stored at the given URL.
    ///
    /// :param: frameCount The number of frames to include in the gif; each frame has the same duration and is spaced evenly over the video.
    /// :param: delayTime The amount of time each frame exists for in the GIF.
    /// :param: loopCount The number of times the GIF will repeat. This defaults to 0, which means that the GIF will repeat infinitely.
    public init(sourceFileURL: NSURL, frameCount: Int, delayTime: Float, loopCount: Int = 0) {
        self.sourceFileURL = sourceFileURL
        self.frameCount = frameCount
        self.delayTime = delayTime
        self.loopCount = loopCount
    }
    
    /// Get the URL of the GIF created with the attributes provided in the initializer.
    public func createGif() -> NSURL? {
        let fileProperties = [kCGImagePropertyGIFDictionary as String:
            [
                kCGImagePropertyGIFLoopCount as String: loopCount
            ]]
        
        let frameProperties = [kCGImagePropertyGIFDictionary as String:
            [
                kCGImagePropertyGIFDelayTime as String: delayTime
            ]]
        
        let asset = AVURLAsset(URL: sourceFileURL, options: nil)
        
        // The total length of the movie, in seconds.
        let movieLength = Float(asset.duration.value) / Float(asset.duration.timescale)
        
        // How far along the video track we want to move, in seconds.
        let increment = Float(movieLength) / Float(frameCount)
        
        // Add each of the frames to the buffer
        var timePoints: [TimePoint] = []
        
        for frameNumber in 0 ..< frameCount {
            let seconds: Float64 = Float64(increment) * Float64(frameNumber)
            let time = CMTimeMakeWithSeconds(seconds, Regift.TimeInterval)
            
            timePoints.append(time)
        }
        
        do {
            return try createGIFForTimePoints(timePoints, fileProperties: fileProperties, frameProperties: frameProperties, frameCount: frameCount)
            
        } catch {
            return nil
        }
    }
    
    /// Create a GIF using the given time points in a movie file stored at the URL provided.
    ///
    /// :param: timePoints An array of `TimePoint`s (which are typealiased `CMTime`s) to use as the frames in the GIF.
    /// :param: URL The URL of the video file to convert
    /// :param: fileProperties The desired attributes of the resulting GIF.
    /// :param: frameProperties The desired attributes of each frame in the resulting GIF.
    public func createGIFForTimePoints(timePoints: [TimePoint], fileProperties: [String: AnyObject], frameProperties: [String: AnyObject], frameCount: Int) throws -> NSURL {
        let temporaryFile = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(Regift.FileName)
        let fileURL = NSURL(fileURLWithPath: temporaryFile)
        
        guard let destination = CGImageDestinationCreateWithURL(fileURL, kUTTypeGIF, frameCount, nil) else {
            print("An error occurred.")
            throw RegiftError.DestinationNotFound
        }
        
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionaryRef)
        
        let asset = AVURLAsset(URL: sourceFileURL)
        let generator = AVAssetImageGenerator(asset: asset)
        
        generator.appliesPreferredTrackTransform = true
        
        let tolerance = CMTimeMakeWithSeconds(Regift.Tolerance, Regift.TimeInterval)
        generator.requestedTimeToleranceBefore = tolerance
        generator.requestedTimeToleranceAfter = tolerance
        
        for time in timePoints {
            do {
                let imageRef = try generator.copyCGImageAtTime(time, actualTime: nil)
                
                
                
                CGImageDestinationAddImage(destination, imageRef, frameProperties as CFDictionaryRef)
            } catch let error as NSError {
                print("An error occurred: \(error)")
                throw RegiftError.AddFrameToDestination
            }
        }
        
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionaryRef)
        
        // Finalize the gif
        if !CGImageDestinationFinalize(destination) {
            throw RegiftError.DestinationFinalize
        }
        
        return fileURL
    }

    /// Get the URL of the GIF created with the attributes provided in the initializer.
    public func createGifWithCaption(caption: NSString, font: UIFont) -> NSURL? {
        let fileProperties = [kCGImagePropertyGIFDictionary as String:
            [
                kCGImagePropertyGIFLoopCount as String: loopCount
            ]]
        
        let frameProperties = [kCGImagePropertyGIFDictionary as String:
            [
                kCGImagePropertyGIFDelayTime as String: delayTime
            ]]
        
        let asset = AVURLAsset(URL: sourceFileURL, options: nil)
        
        // The total length of the movie, in seconds.
        let movieLength = Float(asset.duration.value) / Float(asset.duration.timescale)
        
        // How far along the video track we want to move, in seconds.
        let increment = Float(movieLength) / Float(frameCount)
        
        // Add each of the frames to the buffer
        var timePoints: [TimePoint] = []
        
        for frameNumber in 0 ..< frameCount {
            let seconds: Float64 = Float64(increment) * Float64(frameNumber)
            let time = CMTimeMakeWithSeconds(seconds, Regift.TimeInterval)
            
            timePoints.append(time)
        }
        
        do {
            return try createGIFForTimePointsAndCaption(timePoints, fileProperties: fileProperties, frameProperties: frameProperties, frameCount: frameCount, caption: caption, font:font)
            
        } catch {
            return nil
        }
    }
    
    /// Create a GIF using the given time points in a movie file stored at the URL provided.
    ///
    /// :param: timePoints An array of `TimePoint`s (which are typealiased `CMTime`s) to use as the frames in the GIF.
    /// :param: URL The URL of the video file to convert
    /// :param: fileProperties The desired attributes of the resulting GIF.
    /// :param: frameProperties The desired attributes of each frame in the resulting GIF.
    public func createGIFForTimePointsAndCaption(timePoints: [TimePoint], fileProperties: [String: AnyObject], frameProperties: [String: AnyObject], frameCount: Int, caption: NSString, font: UIFont) throws -> NSURL {
        let temporaryFile = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(Regift.FileName)
        let fileURL = NSURL(fileURLWithPath: temporaryFile)
        
        guard let destination = CGImageDestinationCreateWithURL(fileURL, kUTTypeGIF, frameCount, nil) else {
            print("An error occurred.")
            throw RegiftError.DestinationNotFound
        }
        
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionaryRef)
        
        let asset = AVURLAsset(URL: sourceFileURL)
        let generator = AVAssetImageGenerator(asset: asset)
        
        generator.appliesPreferredTrackTransform = true
        
        let tolerance = CMTimeMakeWithSeconds(Regift.Tolerance, Regift.TimeInterval)
        generator.requestedTimeToleranceBefore = tolerance
        generator.requestedTimeToleranceAfter = tolerance
        
        for time in timePoints {
            do {
                let imageRef = try generator.copyCGImageAtTime(time, actualTime: nil)
                let imageRefWithCaption = addCaption(imageRef,text:caption, font:font)
                CGImageDestinationAddImage(destination, imageRefWithCaption, frameProperties as CFDictionaryRef)
            } catch let error as NSError {
                print("An error occurred: \(error)")
                throw RegiftError.AddFrameToDestination
            }
        }
        
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionaryRef)
        
        // Finalize the gif
        if !CGImageDestinationFinalize(destination) {
            throw RegiftError.DestinationFinalize
        }
        
        return fileURL
    }
}
