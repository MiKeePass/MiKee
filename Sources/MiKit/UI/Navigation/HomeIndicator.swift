// HomeIndicator.swift
//
// Created by Maxime Epain on 22/11/2017.
// Copyright © 2017 Maxime Epain. All rights reserved.
//
// The methods and techniques described herein are considered trade secrets
// and/or confidential. Reproduction or distribution, in whole or in part,
// is forbidden except by express written permission of Maxime Epain.
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

@IBDesignable class HomeIndicator: UIControl {

    @IBInspectable var length: CGFloat = 5

    override func draw(_ rect: CGRect) {

        let radius = length / 2
        let path = UIBezierPath(roundedRect: CGRect(x: rect.minX,
                                                    y: rect.midY - radius,
                                                    width: rect.width,
                                                    height: length),
                                cornerRadius: radius)

        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

}

@IBDesignable class VerticalHomeIndicator: HomeIndicator {

    override func draw(_ rect: CGRect) {

        let radius = length / 2
        let path = UIBezierPath(roundedRect: CGRect(x: rect.midX - radius,
                                                    y: rect.minY,
                                                    width: length,
                                                    height: rect.height),
                                cornerRadius: radius)

        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

}
