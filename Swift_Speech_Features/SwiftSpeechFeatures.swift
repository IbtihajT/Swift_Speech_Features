//
//  SwiftSpeechFeatures.swift
//  Swift_Speech_Features
//
//  Created by Ibtihaj Tahir on 11/02/2021.
//

import Foundation
import Accelerate

// MFCC Arguments Model
struct MFCCArgumentModel {
    
    var signal: [Int16]
    var sampleRate: Int
    var windowLength: Float
    var windowStep: Float
    var cepstralCoefficientsCount: Int
    var filterCount: Int
    var nfft: Int
    var lowFrequency: Float
    var highFrequency: Float
    var preEmphasisCoefficient: Float
    var cepstralLifter: Int
    var appendEnergy: Bool
}

// Lambda Struct
struct Lambda {
    static func create(count: Int) -> [Int16] {
        return [Int16](repeating: 1, count: count)
    }
}

// Swift Speech Features Main Class
final class SwiftSpeechFeatures {
    
    private let smallestFloat = 2.220446049250313e-16
    
    func mfcc(mfccArgumentModel: MFCCArgumentModel) -> [Double] {
        
        // Get Features and Energy
        var (features, energy) = calculateFeatureBanks(mfccArgumentModel: mfccArgumentModel)
        
        // Logged Features
        //        features = vForce.log(features)
        var loggedFeatures = [Double](repeating: 0, count: features.count)
        var featureCount = Int32(features.count)
        vvlog(&loggedFeatures, &features, &featureCount)
        
        // TODO: Implement Length Invarient DCT using BLAS
        // Calculate DCT Scaled Orthonormal of twice the DCT
        guard let dct = vDSP.DCT(count: 1 * Int(pow(2, 5.0)), transformType: .II) else { return [] }
        var dctTransformed = dct.transform(loggedFeatures.toFloat())
        dctTransformed = vDSP.multiply(2.0, dctTransformed)
        var orthoNormalizedDCT = vDSP.multiply(sqrt(1.0/(2.0 * Float(dctTransformed.count))), dctTransformed[1...])
        orthoNormalizedDCT.insert(dctTransformed[0] * sqrt(1.0/(4.0 * Float(dctTransformed.count))), at: 0)
        let slicedCepstrals = Array(orthoNormalizedDCT[0..<mfccArgumentModel.cepstralCoefficientsCount])
        
        // Computer Lifter
        var enhancedFeatures = lifter(feat: slicedCepstrals.toDouble(), ceplifter: mfccArgumentModel.cepstralLifter)
        
        // Append Energy Check
        enhancedFeatures[0] = mfccArgumentModel.appendEnergy ? log(energy) : enhancedFeatures[0]
        
        // Return Calculated MFCC Features
        return enhancedFeatures
        
        
    }
    
    // Get Feature Banks
    func calculateFeatureBanks(mfccArgumentModel: MFCCArgumentModel) -> ([Double], Double) {
        
        // Calculate Preemphasis
        let preEmphasis = preemphasis(
            signal: mfccArgumentModel.signal,
            coeff: mfccArgumentModel.preEmphasisCoefficient
        )
        
        // Calculate Frames
        _ = frameSig(
            signal: preEmphasis,
            winLength: mfccArgumentModel.windowLength,
            winStep: mfccArgumentModel.windowStep,
            sampleRate: mfccArgumentModel.sampleRate
        )
        
        // Calculate PowSpec
        let fastFourierTransform = FastFourierTransform(inputSignal: preEmphasis, nfft: mfccArgumentModel.nfft, fftMode: .rfft)
        let powerSpectrum = fastFourierTransform.getPowerSpectrums()
        
        // Calculate Energy
        var energy = vDSP.sum(powerSpectrum)
        if energy == 0 {
            energy = smallestFloat
        }
        
        // Get Filter Banks
        let filterBanks = getFilterBanks(
            nfilt: mfccArgumentModel.filterCount,
            nfft: mfccArgumentModel.nfft,
            sampleRate: mfccArgumentModel.sampleRate,
            lowFreq: mfccArgumentModel.lowFrequency,
            highFreq: mfccArgumentModel.highFrequency
        )
        
        // TODO: Consider Using BLAS (np.dot(powerSpectrum, filterBank.T))
        var features = filterBanks.map { filter in
            vDSP.dot(powerSpectrum, filter)
        }
        
        // Filter out zeros
        features = features.map { $0 == 0 ? smallestFloat : $0 }
        
        // Return Calculated Features and Energy
        return (features, energy)
    }
    
    func frameSig(signal: [Double], winLength: Float, winStep: Float, sampleRate: Int) -> [Double] {
        
        //    var signalCopy = signal
        
        // Num Frames
        var numFrames: Int = 1
        
        // Get Signal Count
        let signalLength = signal.count
        
        // Get Frame Length and frame Step
        let frameLength = vDSP.multiply(winLength, [Float(sampleRate)])[0].round(to: 0)
        let frameStep = vDSP.multiply(winStep, [Float(sampleRate)])[0].round(to: 0)
        
        // nFrames Calculate
        if (Float(signalLength) <= frameLength) {
            numFrames = 1
        } else {
            numFrames = 1 + Int(vForce.ceil(vDSP.divide(vDSP.subtract(multiplication: ([Float(1.0)], [Float(signalLength)]), [frameLength]), frameStep))[0])
        }
        
        // Pad Length
        let padLen = Int(vDSP.add(frameLength, vDSP.multiply(subtraction: ([Float(numFrames)], [Float(1.0)]), frameStep))[0])
        
        // Zeros Array
        let zeros = [Double](repeating: 0.0, count: padLen - signalLength)
        
        // Pad the Signal
        let padSignal = signal + zeros
        
        // TODO: Fix Indices Problem
        
        // Calculate Indices
        //    let indices1 = [[Double]](repeating: vDSP.ramp(withInitialValue: 0.0, increment: 1.0, count: Int(frameLength)), count: Int(numFrames))
        
        //numFrames = 2
        //    var initialValue: Double = 0.0
        //    let stepVector: [Double] = [Double](repeating: Double(frameStep), count: Int(numFrames))
        //    let ramps = vDSP.ramp(withInitialValue: &initialValue, multiplyingBy: stepVector, increment: 1.0)
        //    let onesMatrix = [[Double]](repeating: [Double](repeating: 1, count: Int(frameLength)), count: Int(numFrames))
        //    let indices2 = zip(onesMatrix, ramps).map { first, second in
        //        vDSP.multiply(second, first)
        //
        //    }
        //    // Handled for only our case.
        //    let indices = vDSP.add(indices1[0], indices2[0])
        //    var intIndices = [Int32](repeating: 0, count: indices.count)
        //    vDSP.convertElements(of: indices, to: &intIndices, rounding: .towardNearestInteger)
        
        // Caculate Frames
        //    let frames = intIndices.map { num in
        //        padSignal[Int(num)]
        //    }
        
        
        return Array(padSignal[0..<1024])
    }
    
    func getFilterBanks(nfilt: Int, nfft: Int, sampleRate: Int, lowFreq: Float, highFreq: Float) -> [[Double]] {
        
        // Compute points evenly spaced in mels
        let lowMel = hz2mel(hz: Double(lowFreq))
        let highMel = hz2mel(hz: Double(highFreq))
        let melpoints = vDSP.ramp(in: lowMel...highMel, count: nfilt + 2)
        
        // our points are in Hz, but we use fft bins, so we have to convert
        //  from Hz to fft bin number
        var bin = vForce.floor(vDSP.multiply(Double(nfft+1), vDSP.divide(mel2hz(mel: melpoints), Double(sampleRate))))
        var fbank = [[Double]](repeating: [Double](repeating: 0.0, count: Int(vForce.floor([Double(nfft) / 2 + 1])[0])), count: nfilt)
        
        let binPointer = UnsafeMutablePointer<Double>.allocate(capacity: bin.count)
        binPointer.initialize(from: &bin, count: bin.count)
        let binBufferPointer = UnsafeMutableBufferPointer(start: binPointer, count: bin.count)
        let fbankPointer = UnsafeMutablePointer<[Double]>.allocate(capacity: fbank.count)
        fbankPointer.initialize(from: &fbank, count: fbank.count)
        let fbankBufferPointer = UnsafeMutableBufferPointer(start: fbankPointer, count: fbank.count)
        
        for j in 0..<nfilt {
            for i in Int(binBufferPointer[j])..<Int(binBufferPointer[j + 1]) {
                fbankBufferPointer[j][i] = (Double(i) - binBufferPointer[j]) / (binBufferPointer[j + 1] - binBufferPointer[j])
            }
            for i in Int(binBufferPointer[j + 1])..<Int(binBufferPointer[j + 2]) {
                fbankBufferPointer[j][i] = (binBufferPointer[j + 2] - Double(i)) / (binBufferPointer[j + 2] - binBufferPointer[j + 1])
            }
        }
        
        defer {
            binPointer.deinitialize(count: bin.count)
            binPointer.deallocate()
            fbankPointer.deinitialize(count: fbank.count)
            fbankPointer.deallocate()
        }
        
        //    binPointer.deallocate()
        //    fbankPointer.deallocate()
        
        // TODO: Find Alternative way to eliminate loop
        //    for j in 0..<nfilt {
        //
        //        for i in Int(bin[j])..<Int(bin[j+1]) {
        //            fbank[j][i] = (Double(i) - bin[j]) / (bin[j+1]-bin[j])
        //        }
        //
        //        for i in Int(bin[j+1])..<Int(bin[j+2]) {
        //            fbank[j][i] = (bin[j+2]-Double(i)) / (bin[j+2]-bin[j+1])
        //        }
        //    }
        return Array(fbankBufferPointer)
    }
    
    func lifter(feat: [Double], ceplifter: Int = 22) -> [Double] {
        
        if (ceplifter > 0) {
            let ncoeff = feat.count
            let n: [Double] = vDSP.ramp(withInitialValue: 0.0, increment: 1.0, count: ncoeff)
            let lift = vDSP.add(1.0, vDSP.multiply((Double(ceplifter) / 2.0), vForce.sin(vDSP.multiply(Double.pi, vDSP.divide(n, Double(ceplifter))))))
            return vDSP.multiply(lift, feat)
        }
        return feat
    }
    
    func preemphasis(signal: [Int16], coeff: Float) -> [Double] {
        
        var signalInt16toDouble = [Double](repeating: 0.0, count: signal.count)
        vDSP.convertElements(of: signal, to: &signalInt16toDouble)
        
        var calculatedPreemphasis: [Double] = []
        calculatedPreemphasis.append(signalInt16toDouble[0])
        calculatedPreemphasis.append(contentsOf: vDSP.subtract(signalInt16toDouble[1...], vDSP.multiply(Double(coeff), signalInt16toDouble[0..<signalInt16toDouble.count - 1])))
        return calculatedPreemphasis
    }
    
    func hz2mel(hz: Double) -> Double {
        return 2595 * vForce.log10(vDSP.add(1, vDSP.divide([hz], 700.0)))[0]
    }
    
    func mel2hz(mel: Double) -> Double {
        return vDSP.multiply(700, vDSP.subtract(vForce.pow(bases: [10], exponents: vDSP.divide([mel], 2595.0)), [1]))[0]
    }
    
    func mel2hz(mel: [Double]) -> [Double] {
        // TODO: Repeating Vector Problem
        let bases = [Double](repeating: 10, count: mel.count)
        let ones = [Double](repeating: 1.0, count: mel.count)
        return vDSP.multiply(700.0, vDSP.subtract(vForce.pow(bases: bases, exponents: vDSP.divide(mel, 2595.0)), ones))
    }
    
    
}

extension Array where Element == (Double) {
    func toFloat() -> [Float] {
        var holder = [Float](repeating: 0.0, count: self.count)
        vDSP.convertElements(of: self, to: &holder)
        return holder
    }
}

extension Array where Element == Float {
    func toDouble() -> [Double] {
        var holder = [Double](repeating: 0.0, count: self.count)
        vDSP.convertElements(of: self, to: &holder)
        return holder
    }
}

extension Double {
    func round(to places: Int) -> Double {
        let divisor = vForce.pow(bases: [10.0], exponents: [Double(places)])[0]
        return (vDSP.multiply(self, [divisor])[0]).rounded()
    }
    var clean: Double {
        return floor(self)
    }
}

extension Float {
    func round(to places: Int) -> Float {
        let divisor = vForce.pow(bases: [10.0], exponents: [Float(places)])[0]
        return (vDSP.multiply(self, [divisor])[0]).rounded()
    }
    var clean: Float {
        return floor(self)
    }
}
