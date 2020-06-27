/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class PaymentView: UIView {
  
  var onPaymentRequested: ((NSDecimalNumber) -> Void)?
  
  private lazy var label: UILabel = {
    let label = UILabel()
    label.text = "$1000"
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private lazy var slider: UISlider = {
    let slider = UISlider()
    slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
    slider.minimumValue = 100
    slider.maximumValue = 10_000
    slider.translatesAutoresizingMaskIntoConstraints = false
    return slider
  }()
  
  private lazy var requestButton: UIButton = {
    let button = UIButton()
    button.setTitle("Request Payment", for: .normal)
    button.setTitleColor(tintColor, for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(requestPayment), for: .touchUpInside)
    return button
  }()

  private lazy var numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = 2
    formatter.locale = Locale(identifier: "en_US")

    return formatter
  }()
  
  convenience init() {
    self.init(frame: CGRect(origin: .zero, size: CGSize(width: 275, height: 375)))
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .white
    addSubview(label)
    addSubview(slider)
    addSubview(requestButton)
    addConstraints()
    sliderValueChanged(slider)
  }
  
  private func addConstraints() {
    label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 30).isActive = true
    slider.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -30).isActive = true
    slider.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    slider.widthAnchor.constraint(equalTo: widthAnchor, constant: -40).isActive = true
    requestButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    requestButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 40).isActive = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  @objc private func sliderValueChanged(_ sender: UISlider) {
    let value = NSDecimalNumber(value: sender.value)
    label.text = numberFormatter.string(from: value)
  }
  
  @objc private func requestPayment() {
    let payment = NSDecimalNumber(value: self.slider.value)
    UIView.animate(withDuration: 0.3,
                   animations: { [weak self] in
                    guard let self = self else { return }
                    self.slider.alpha = 0.0
                    self.requestButton.alpha = 0.0
                    self.label.text = "Requested Payment of \(self.numberFormatter.string(from: payment) ?? "")"
                   },
                   completion: { done in
                    guard done else { return }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                      self?.onPaymentRequested?(payment)
                    }
                   })

  }
}
