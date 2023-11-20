import '../proxy_broad_phase.dart';

/// An element of proxies.
class SAPElement{
  /// An element of proxies.
  /// 
  /// [proxy] the parent proxy
  /// [max] does this element have a max value
  SAPElement(this.proxy, this.max);

  /// The parent proxy
  Proxy proxy;
	/// The pair element.
  SAPElement? pair;
  /// The minimum element on other axis.
  SAPElement? min1;
  /// The maximum element on other axis.
  SAPElement? max1;
  /// The minimum element on other axis.
  SAPElement? min2;
  /// The maximum element on other axis.
  SAPElement? max2;
  /// Whether the element has maximum value or not.
  bool max;
  /// The value of the element.
  double value = 0;
}