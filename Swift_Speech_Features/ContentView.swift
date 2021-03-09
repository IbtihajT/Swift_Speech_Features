//
//  ContentView.swift
//  Swift_Speech_Features
//
//  Created by Ibtihaj Tahir on 22/01/2021.
//

import SwiftUI
import Accelerate

// Int16 Sin Wav to test
var int16Sin: [Int16] =
    [
        0, 3271, 6509, 9683, 12760, 15709, 18501, 21109, 23505, 25667, 27572, 29202, 30540, 31572, 32290, 32684, 32753, 32493, 31910, 31007, 29794, 28284, 26492, 24434, 22132, 19610, 16891, 14003, 10976, 7839, 4624, 1362, -1912, -5168, -8373, -11494, -14500, -17361, -20048, -22536, -24798, -26812, -28558, -30020, -31181, -32030, -32560, -32764, -32641, -32192, -31421, -30336, -28948, -27270, -25321, -23118, -20684, -18044, -15223, -12250, -9155, -5968, -2722, 550, 3818, 7048, 10208, 13265, 16190, 18953, 21527, 23886, 26006, 27866, 29447, 30735, 31715, 32379, 32719, 32732, 32418, 31780, 30824, 29561, 28002, 26164, 24063, 21723, 19165, 16416, 13503, 10455, 7303, 4077, 811, -2462, -5712, -8904, -12008, -14992, -17825, -20481, -22932, -25154, -27125, -28824, -30236, -31346, -32142, -32617, -32766, -32588, -32084, -31260, -30123, -28685, -26961, -24967, -22724, -20254, -17581, -14733, -11738, -8625, -5426, -2173, 1101, 4365, 7585, 10730, 13767, 16667, 19400, 21939, 24259, 26337, 28152, 29685, 30922, 31849, 32459, 32744, 32702, 32333, 31641, 30633, 29319, 27712, 25828, 23686, 21307, 18716, 15937, 12999, 9932, 6765, 3530, 260, -3011, -6253, -9433, -12519, -15479, -18285, -20908, -23323, -25504, -27430, -29082, -30444, -31502, -32244, -32665, -32759, -32526, -31968, -31090, -29902, -28415, -26644, -24607, -22324, -19818, -17114, -14239, -11222, -8092, -4882, -1623, 1652, 4911, 8120, 11249, 14265, 17139, 19841, 22345, 24626, 26661, 28430, 29914, 31099, 31974, 32529, 32760, 32663, 32239, 31494, 30433, 29069, 27414, 25485, 23302, 20886, 18261, 15454, 12492, 9405, 6225, 2982, -290, -3559, -6793, -9960, -13026, -15963, -18740, -21330, -23706, -25846, -27728, -29332, -30644, -31649, -32338, -32704, -32743, -32455, -31842, -30912, -29673, -28137, -26320, -24240, -21918, -19377, -16642, -13741, -10702, -7557, -4336, -1072, 2202, 5455, 8653, 11765, 14759, 17606, 20277, 22745, 24986, 26978, 28699, 30135, 31269, 32090, 32591, 32766, 32614, 32136, 31337, 30225, 28811, 27109, 25136, 22911, 20458, 17801, 14966, 11981, 8876, 5683, 2433, -840, -4106, -7331, -10483, -13530, -16442, -19189, -21745, -24083, -26181, -28017, -29574, -30834, -31787, -32422, -32733, -32717, -32374, -31708, -30725, -29435, -27850, -25988, -23866, -21505, -18929, -16165, -13239, -10180, -7020, -3790, -521, 2751, 5997, 9183, 12277, 15249, 18068, 20707, 23139, 25339, 27287, 28961, 30347, 31429, 32197, 32643, 32764, 32556, 32024, 31172, 30008, 28544, 26795, 24779, 22514, 20025, 17336, 14473, 11466, 8345, 5140, 1883, -1391, -4652, -7867, -11003, -14030, -16916, -19633, -22154, -24453, -26509, -28299, -29807, -31016, -31916, -32497, -32753, -32682, -32285, -31565, -30529, -29188, -27556, -25649, -23485, -21086, -18477, -15683, -12733, -9655, -6481, -3242, 29, 3300, 6538, 9711, 12786, 15734, 18525, 21131, 23525, 25685, 27588, 29215, 30550, 31580, 32295, 32686, 32752, 32490, 31903, 30997, 29782, 28270, 26474, 24415, 22111, 19586, 16866, 13977, 10949, 7811, 4595, 1333, -1941, -5197, -8401, -11521, -14526, -17385, -20071, -22557, -24817, -26829, -28573, -30031, -31190, -32036, -32563, -32764, -32638, -32186, -31412, -30325, -28934, -27254, -25302, -23097, -20662, -18020, -15197, -12223, -9127, -5940, -2693, 580, 3847, 7077, 10235, 13292, 16215, 18977, 21549, 23906, 26023, 27881, 29460, 30745, 31723, 32383, 32720, 32730, 32414, 31773, 30815, 29548, 27987, 26146, 24044, 21701, 19142, 16391, 13477, 10428, 7275, 4049, 782, -2491, -5740, -8932, -12035, -15017, -17850, -20504, -22953, -25173, -27141, -28838, -30247, -31354, -32147, -32620, -32766, -32585, -32078, -31251, -30112, -28671, -26945, -24949, -22703, -20231, -17557, -14707, -11710, -8597, -5397, -2144, 1130, 4394, 7614, 10757, 13794, 16692, 19423, 21961, 24279, 26354, 28167, 29697, 30931, 31856, 32463, 32745, 32700, 32328, 31634, 30623, 29306, 27697, 25810, 23666, 21285, 18692, 15912, 12973, 9904, 6736, 3501, 231, -3040, -6282, -9461, -12546, -15505, -18309, -20931, -23343, -25522, -27446, -29096, -30455, -31510, -32250, -32667, -32758, -32522, -31961, -31081, -29890, -28401, -26627, -24588, -22303, -19795, -17089, -14213, -11194, -8064, -4853, -1594, 1681, 4939, 8148, 11276, 14291, 17164, 19864, 22367, 24645, 26678, 28444, 29926, 31109, 31981, 32533, 32760, 32660, 32234, 31486, 30423, 29056, 27398, 25467, 23282, 20863, 18237, 15428, 12465, 9377, 6196, 2953, -319, -3588, -6822, -9987, -13053, -15988, -18764, -21352, -23726, -25864, -27743, -29345, -30654, -31656, -32342, -32705, -32742, -32451, -31836, -30902, -29660, -28122, -26302, -24220, -21896, -19353, -16617, -13714, -10675, -7529, -4307, -1043, 2231, 5483, 8681, 11792, 14785, 17630, 20300, 22766, 25005, 26994, 28714, 30146, 31277, 32096, 32594, 32766, 32611, 32130, 31329, 30214, 28797, 27092, 25117, 22891, 20436, 17777, 14940, 11954, 8848, 5654, 2404, -870, -4135, -7360, -10511, -13556, -16467, -19213, -21767, -24103, -26199, -28032, -29586, -30844, -31794, -32426, -32734, -32716, -32370, -31701, -30715, -29422, -27835, -25970, -23846, -21483, -18906, -16139, -13212, -10152, -6991, -3761, -492, 2780, 6026, 9211, 12304, 15275, 18092, 20729, 23159, 25358, 27303, 28975, 30358, 31437, 32202, 32646, 32763, 32553, 32018, 31163, 29996, 28530, 26778, 24760, 22493, 20002, 17311, 14447, 11439, 8317, 5111, 1854, -1420, -4681, -7895, -11031, -14056, -16941, -19656, -22175, -24473, -26526, -28314, -29819, -31026, -31923, -32501, -32754, -32680, -32280, -31557, -30518, -29175, -27540, -25631, -23465, -21064, -18453, -15658, -12706, -9627, -6452, -3213, 58, 3329, 6566, 9738, 12813, 15760, 18549, 21153, 23546, 25703, 27603, 29228, 30561, 31588, 32300, 32688, 32751, 32486, 31896, 30988, 29770, 28255, 26457, 24395, 22089, 19563, 16841, 13951, 10921, 7782, 4566, 1304, -1970, -5226, -8429, -11548, -14552, -17410, -20094, -22578, -24836, -26845, -28587, -30043, -31198, -32042, -32566, -32765, -32636, -32181, -31404, -30314, -28920, -27238, -25284, -23077, -20639, -17995, -15172, -12196, -9099, -5911, -2664, 609, 3876, 7105, 10263, 13318, 16241, 19001, 21571, 23925, 26041, 27896, 29473, 30755, 31730, 32388, 32722, 32729, 32409, 31766, 30805, 29536, 27972, 26128, 24024, 21679, 19118, 16366, 13450, 10400, 7246, 4020, 753, -2520, -5769, -8960, -12062, -15043, -17874, -20527, -22974, -25192, -27157, -28852, -30258, -31362, -32153, -32622, -32766, -32582, -32072, -31242, -30100, -28657, -26928, -24930, -22682, -20208, -17532, -14681, -11683, -8569, -5368, -2115, 1159, 4423, 7642, 10785, 13820, 16717, 19447, 21982, 24298, 26372, 28181, 29710, 30941, 31863, 32467, 32746, 32698, 32324, 31626, 30612, 29293, 27681, 25792, 23646, 21263, 18668, 15886, 12946, 9876, 6708, 3472, 202, -3069, -6310, -9489, -12573, -15531, -18333, -20953, -23363, -25540, -27462, -29109, -30466, -31518, -32255, -32669, -32758, -32519, -31955, -31072, -29878, -28386, -26610, -24569, -22281, -19772, -17064, -14186, -11167, -8036, -4824, -1564, 1710, 4968, 8177, 11304, 14317, 17188, 19888, 22388, 24665, 26695, 28458, 29938, 31118, 31987, 32536, 32761, 32658, 32229, 31477, 30412, 29042, 27382, 25449, 23261, 20841, 18213, 15402, 12438, 9350, 6168, 2924, -348, -3617, -6850, -10015, -13080, -16014, -18788, -21374, -23746, -25882, -27759, -29358, -30664, -31664, -32347, -32707, -32741, -32447, -31829, -30893, -29648, -28107, -26285, -24201, -21874, -19330, -16592, -13688, -10647, -7500, -4279, -1014, 2260, 5512, 8709, 11819, 14811, 17655, 20323, 22787, 25024, 27011, 28728, 30157, 31286, 32102, 32597, 32766, 32609, 32125
    ]

// Double Sin Wave
var doubleSin = [Double](repeating: 0.0, count: int16Sin.count)

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
        
        //            .onAppear {
        //
        //                var count = 0
        //                let swiftSpeechFeatures = SwiftSpeechFeatures()
        //
        //                Timer.scheduledTimer(withTimeInterval: 0.02133, repeats: true) { (_) in
        //
        //                    // PCSMs
        //                    let nearEndPCM: [Int16] = getRandomNumbersInt16(1024)
        //                    //                    var nearEndPCMDouble = [Double](repeating: 0.0, count: 1024)
        //                    //                    vDSP.convertElements(of: nearEndPCM, to: &nearEndPCMDouble)
        //
        //                    let mfccArgumentModel = MFCCArgumentModel(
        //                        signal: nearEndPCM,
        //                        sampleRate: 48000,
        //                        windowLength: 0.02133,
        //                        windowStep: 0.02133,
        //                        cepstralCoefficientsCount: 12,
        //                        filterCount: 32,
        //                        nfft: 1024,
        //                        lowFrequency: 0,
        //                        highFrequency: 24000,
        //                        preEmphasisCoefficient: 0.97,
        //                        cepstralLifter: 22,
        //                        appendEnergy: true
        //                    )
        //
        //                    _ = swiftSpeechFeatures.mfcc(mfccArgumentModel: mfccArgumentModel)
        //
        //                    //                    let preemphises = preemphasis(nearEndPCMDouble, 0.97)
        //                    //                    var preEmpFloat = [Float](repeating: 0.0, count: 1024)
        //                    //                    vDSP.convertElements(of: preemphises, to: &preEmpFloat)
        //                    //                    var(real, imag) = myFFTSurge.rfft(preemphises)
        //                    //                    let magnitude = myFFTSurge.calculateMagnitude(&real, &imag)
        //                    //                    var powSpec = myFFTSurge.calculatePowSpec(magnitude)
        //                    //                    var nearEndFeatures = [Float](repeating: 0.0, count: 13)
        //
        //                    //                    var computedFeat  = mfcc(signal: nearEndPCM, samplerate: 48000, winlen: 0.02133, winstep: 0.02133, numcep: 13, nfilt: 32, nfft: 1024, lowfreq: 0, highfreq: 24000, preemph: 0.97, ceplifter: 22, appendEnergy: true, winFunc: [1])
        //
        //
        //
        //                    //                    let farEndPCM: [[Int16]] =
        //                    //                        [
        //                    //                            getRandomNumbersInt16(1024),
        //                    //                            getRandomNumbersInt16(1024),
        //                    //                            getRandomNumbersInt16(1024),
        //                    //                            getRandomNumbersInt16(1024),
        //                    //                            getRandomNumbersInt16(1024),
        //                    //                            getRandomNumbersInt16(1024),
        //                    //                            getRandomNumbersInt16(1024),
        //                    //                            getRandomNumbersInt16(1024),
        //                    //                            getRandomNumbersInt16(1024),
        //                    //                            getRandomNumbersInt16(1024)
        //                    //
        //                    //                        ]
        //                    //
        //                    //                    // Extracted Features
        //                    //                    var nearEndFeatures = [Float](repeating: 0.0, count: 13)
        //                    //                    var farEndFeatures = [[Float]]()
        //                    //
        //                    //                    // Self Powspec For Near End
        //                    //                    var nearEndPCMDouble = [Double](repeating: 0.0, count: 1024)
        //                    //                    vDSP.convertElements(of: nearEndPCM, to: &nearEndPCMDouble)
        //                    //                    let preemphises = preemphasis(nearEndPCMDouble, 0.97)
        //                    //                    var preEmpFloat = [Float](repeating: 0.0, count: 1024)
        //                    //                    vDSP.convertElements(of: preemphises, to: &preEmpFloat)
        //                    //                    var(real, imag) = myFFTSurge.rfft(preemphises)
        //                    //                    let magnitude = myFFTSurge.calculateMagnitude(&real, &imag)
        //                    //                    var powSpec = myFFTSurge.calculatePowSpec(magnitude)
        //                    //
        //                    //                    // Calculate NearEnd Features
        //                    //                    csf_mfcc(&nearEndPCM, UInt32(nearEndPCM.count), 48000, 0.02133, 0.02133, 13, 26, 1024, 0, 24000, 0.97, 22, 1, &winFunc, &num_frames, &nearEndFeatures, &preEmpFloat, &powSpec)
        //                    //
        //                    //                    // Calculate FarEnd Features
        //                    //                    for i in 0..<10 {
        //                    //
        //                    //                        var singleOutput = [Float](repeating: 0.0, count: 13)
        //                    //                        var singleFarPCM = farEndPCM[i]
        //                    //
        //                    //                        var farEndPCMDouble = [Double](repeating: 0.0, count: 1024)
        //                    //                        vDSP.convertElements(of: singleFarPCM, to: &farEndPCMDouble)
        //                    //                        let preemphises = preemphasis(farEndPCMDouble, 0.97)
        //                    //                        var preEmpFloat = [Float](repeating: 0.0, count: 1024)
        //                    //                        vDSP.convertElements(of: preemphises, to: &preEmpFloat)
        //                    //                        var(real, imag) = myFFTSurge.rfft(preemphises)
        //                    //                        let magnitude = myFFTSurge.calculateMagnitude(&real, &imag)
        //                    //                        var powSpec = myFFTSurge.calculatePowSpec(magnitude)
        //                    //
        //                    //                        csf_mfcc(&singleFarPCM, UInt32(singleFarPCM.count), 48000, 0.02133, 0.02133, 13, 26, 1024, 0, 24000, 0.97, 22, 1, &winFunc, &num_frames, &singleOutput, &preEmpFloat, &powSpec)
        //                    //
        //                    //                        farEndFeatures.append(singleOutput)
        //                    //                    }
        //                    //
        //                    //                    // FarEnd features to single Array
        //                    //                    var singleDimFarEndFeat: [Float] = []
        //                    //                    for data in farEndFeatures {
        //                    //                        singleDimFarEndFeat.append(contentsOf: data)
        //                    //                    }
        //                    //
        //                    //                    // Call Detection and Cancelation
        //                    //                    for i in 0..<10 {
        //                    //                        let singleFarPCM: [Int16] = farEndPCM[i]
        //                    //
        //                    //                        _ = myMFCC.calculate(farendOutput: singleDimFarEndFeat, farendFrames: 10, nearendOutput: nearEndFeatures, nearendFrames: 0, nearEndPCM: nearEndPCM, farEndPCM: singleFarPCM)
        //                    //                    }
        //
        //                    count += 1
        //                    print(count)
        //                }
        //
        //            }
        
                    .onAppear {
        //                vDSP.convertElements(of: int16Sin, to: &doubleSin)
        
                        let mfccArgumentModel = MFCCArgumentModel(
                            signal: int16Sin,
                            sampleRate: 48000,
                            windowLength: 0.02133,
                            windowStep: 0.02133,
                            cepstralCoefficientsCount: 12,
                            filterCount: 32,
                            nfft: 1024,
                            lowFrequency: 0,
                            highFrequency: 24000,
                            preEmphasisCoefficient: 0.97,
                            cepstralLifter: 22,
                            appendEnergy: true
                        )
                        let swiftSpeechFeatures = SwiftSpeechFeatures()
        
        
                        print(swiftSpeechFeatures.mfcc(mfccArgumentModel: mfccArgumentModel))
        
        //                print(mfcc(signal: int16Sin, samplerate: 48000, winlen: 0.02133, winstep: 0.02133, numcep: 13, nfilt: 32, nfft: 1024, lowfreq: 0, highfreq: 24000, preemph: 0.97, ceplifter: 22, appendEnergy: true, winFunc: [0,0]))
        
        
                    }
                    }
}
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
    
    func getRandomNumbersFloat32(_ n: Int) -> [Float32] {
        return vDSP.ramp(withInitialValue: .random(in: 1.0...100.0), increment: .random(in: 1...20), count: n)
        //    return (0..<n).map {_ in .random(in: 1.0...100.0)}
    }
    func getRandomNumbersInt16(_ n: Int) -> [Int16] {
        var floatRandom = vDSP.ramp(withInitialValue: .random(in: 1.0...100.0), increment: .random(in: 1...20), count: n)
        var intRandom = [Int16](repeating: 0, count: n)
        vDSP.convertElements(of: floatRandom, to: &intRandom, rounding: .towardNearestInteger)
        return intRandom
        
        //    return (0..<n).map {_ in .random(in: 1...100)}
    }



