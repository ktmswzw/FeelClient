// The MIT License (MIT)
//
// Copyright (c) 2015 Rudolf Adamkovič
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Accelerate

// MARK: Parametrization

struct vImage_BlurParametrization {
    
    let blurRadius: CGFloat
    
    var kernelSize: UInt32 {
        
        // For more information see:
        // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
        
        let standardDeviationMinimum: CGFloat = 2
        let standardDeviation = max(blurRadius, standardDeviationMinimum)
        
        precondition(vImage_BlurParametrization.numberOfSuccessiveBoxBlurs == 3)
        
        let kernelSize = floor(standardDeviation * 3 * CGFloat(sqrt(2 * M_PI)) / 4 + 0.5)
        let kernelSizeForThreeSuccessiveBoxBlurs = kernelSize % 2 == 1 ? kernelSize : kernelSize + 1
        
        let integralKernelSize = UInt32(kernelSizeForThreeSuccessiveBoxBlurs)
        
        return integralKernelSize
        
    }
    
    static let numberOfSuccessiveBoxBlurs = 3
    
}

// MARK: Image format

let vImage_BlurBitsPerComponent: UInt32 = 8
let vImage_BlurBitsPerPixel = vImage_BlurBitsPerComponent * 4

func vImageBlurGetImageFormat() -> vImage_CGImageFormat {
    
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue | CGBitmapInfo.ByteOrder32Little.rawValue)
    
    return vImage_CGImageFormat(
        bitsPerComponent: vImage_BlurBitsPerComponent,
        bitsPerPixel: vImage_BlurBitsPerPixel,
        colorSpace: nil,
        bitmapInfo: bitmapInfo,
        version: 0,
        decode: nil,
        renderingIntent: .RenderingIntentDefault
    )
    
}

// MARK: Getting input image

func vImageBlurCreateImageBuffer(image: CGImage) -> vImage_Buffer {
    
    let flags = vImage_Flags(kvImagePrintDiagnosticsToConsole)
    var buffer = vImage_Buffer()
    var format = vImageBlurGetImageFormat()
    
    vImageBuffer_InitWithCGImage(&buffer, &format, nil, image, flags)
    
    return buffer
    
}

// MARK: Creating utility buffers

func vImageBlurCreateShadowBuffer(inout imageBuffer: vImage_Buffer, _ parametrization: vImage_BlurParametrization) -> vImage_Buffer {
    
    let flags = vImage_Flags(kvImageNoFlags)
    var buffer = vImage_Buffer()
    
    vImageBuffer_Init(&buffer, imageBuffer.height, imageBuffer.width, vImage_BlurBitsPerPixel, flags)
    
    return buffer
    
}

func vImageBlurCreateTemporaryBuffer(inout imageBuffer: vImage_Buffer, _ parametrization: vImage_BlurParametrization) -> UnsafeMutablePointer<Void> {
    
    let kernelSize = parametrization.kernelSize
    let flags = vImage_Flags(kvImageGetTempBufferSize) | vImage_Flags(kvImageEdgeExtend)
    let size = vImageBoxConvolve_ARGB8888(&imageBuffer, &imageBuffer, nil, 0, 0, kernelSize, kernelSize, nil, flags)
    
    return malloc(size)
    
}

// MARK: Applying blur effect

func vImageBlur(inout imageBuffer: vImage_Buffer, inout _ shadowBuffer: vImage_Buffer, _ temporaryBuffer: UnsafeMutablePointer<Void>, _ parametrization: vImage_BlurParametrization) {
    
    let kernelSize = parametrization.kernelSize
    let flags = vImage_Flags(kvImageEdgeExtend)
    
    for _ in 1 ... vImage_BlurParametrization.numberOfSuccessiveBoxBlurs {
        
        vImageBoxConvolve_ARGB8888(&imageBuffer, &shadowBuffer, temporaryBuffer, 0, 0, kernelSize, kernelSize, nil, flags)
        swap(&imageBuffer, &shadowBuffer)
        
    }
    
}

// MARK: Adjusting saturation

func vImageSaturate(inout imageBuffer: vImage_Buffer, inout _ shadowBuffer: vImage_Buffer, _ saturation: CGFloat) {
    
    // For more information see:
    // http://www.w3.org/TR/filter-effects/#grayscaleEquivalent
    
    let divisor: Int32 = 256
    
    let saturationMatrix: [CGFloat] = [
        0.0722 + 0.9278 * saturation,  0.0722 - 0.0722 * saturation,  0.0722 - 0.0722 * saturation, 0,
        0.7152 - 0.7152 * saturation,  0.7152 + 0.2848 * saturation,  0.7152 - 0.7152 * saturation, 0,
        0.2126 - 0.2126 * saturation,  0.2126 - 0.2126 * saturation,  0.2126 + 0.7873 * saturation, 0,
        0,                             0,                             0, 1
    ]
    
    let integralSaturationMatrix = saturationMatrix.map { matrixElement in
        Int16(round(matrixElement * CGFloat(divisor)))
    }
    
    vImageMatrixMultiply_ARGB8888(&imageBuffer, &shadowBuffer, integralSaturationMatrix, divisor, nil, nil, vImage_Flags(kvImageNoFlags))
    swap(&imageBuffer, &shadowBuffer)
    
}

// MARK: Getting output image

func vImageBlurCreateImage(inout imageBuffer: vImage_Buffer) -> CGImage {
    
    var format = vImageBlurGetImageFormat()
    let flags = vImage_Flags(kvImageNoFlags)
    let image = vImageCreateCGImageFromBuffer(&imageBuffer, &format, nil, nil, flags, nil)
    
    return image.takeRetainedValue()
    
}
