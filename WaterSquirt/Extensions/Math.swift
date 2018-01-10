
extension BinaryInteger {
  var degreesToRadians: Float { return Float(Int(self)) * .pi / 180 }
}

extension FloatingPoint {
  var degreesToRadians: Self { return self * .pi / 180 }
  var radiansToDegrees: Self { return self * 180 / .pi }
}

extension Int {
  var degreesToRadians: Float { return Float(Int(self)) * .pi / 180 }
}

func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T {
  return min(max(value, lower), upper)
}
