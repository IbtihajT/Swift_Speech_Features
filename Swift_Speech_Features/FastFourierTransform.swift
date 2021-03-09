//
//  FFT.swift
//  Swift_Speech_Features
//
//  Created by Ibtihaj Tahir on 11/02/2021.
//

import Foundation
import Accelerate

enum FFTMode {
    case fft
    case rfft
}

// TODO: Implement Inverses
class FastFourierTransform {
    
    private var real = [Double]()
    private var imaginary = [Double]()
    private var fftMode: FFTMode
    private var nfft: Int
    private var magnitudes: [Double] {
        computeMagnitudes()
    }
    private var powerSpectrum: [Double] {
        _ = computeMagnitudes()
        return computePowerSpectrums()
    }
    
    // Constructor
    init(inputSignal: [Double], nfft: Int, fftMode: FFTMode) {
        self.fftMode = fftMode
        self.nfft = nfft
        computeFFT(inputSignal: inputSignal)
    }
    
    // Get FFT
    func getFFT() -> ([Double], [Double]) {
        
        switch fftMode {
        case .fft:
            return (real, imaginary)
        case .rfft:
            return (
                Array(real[0...(real.count / 2)]),
                Array(imaginary[0...(imaginary.count / 2)])
            )
        }
    }
    
    // Get magnitude
    func getMagnitudes() -> [Double] {
        return magnitudes
    }
    
    // Get PowerSpectrums
    func getPowerSpectrums() -> [Double] {
        return powerSpectrum
    }
    
    // Private compute methods
    private func computeFFT(inputSignal: [Double]) {
        
        // Initialize Real and Imag
        real = inputSignal
        imaginary = [Double](repeating: 0, count: nfft)
        
        
        // Compute FFT
        real.withUnsafeMutableBufferPointer { realBuffer in
            imaginary.withUnsafeMutableBufferPointer { imaginaryBuffer in
                
                var splitComplex = DSPDoubleSplitComplex(
                    realp: realBuffer.baseAddress!,
                    imagp: imaginaryBuffer.baseAddress!
                )
                
                let length = vDSP_Length(floor(log2(Float(nfft))))
                let radix = FFTRadix(kFFTRadix2)
                let weights = vDSP_create_fftsetupD(length, radix)
                withUnsafeMutablePointer(to: &splitComplex) { splitComplex in
                    vDSP_fft_zipD(weights!, splitComplex, 1, length, FFTDirection(FFT_FORWARD))
                }
                
                vDSP_destroy_fftsetupD(weights)
            }
        }
        
    }
    
    private func computeMagnitudes() -> [Double] {
        var localMagnitudes: [Double] = []
        switch fftMode {
        case .fft:
            let sum = vDSP.add(vDSP.square(real), vDSP.square(imaginary))
            localMagnitudes = vForce.sqrt(sum)
        case .rfft:
            let rfftReal = Array(real[0...(real.count / 2)])
            let rfftImag = Array(imaginary[0...(imaginary.count / 2)])
            let sum = vDSP.add(vDSP.square(rfftReal), vDSP.square(rfftImag))
            localMagnitudes = vForce.sqrt(sum)
        }
        
        return localMagnitudes
    }
    private func computePowerSpectrums() -> [Double] {
        var localPowerSpectrums: [Double] = []
        localPowerSpectrums = vDSP.multiply(Double(1.0)/Double(nfft), vDSP.square(magnitudes))
        return localPowerSpectrums
    }
    
}
