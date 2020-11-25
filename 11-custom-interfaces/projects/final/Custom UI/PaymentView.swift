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
