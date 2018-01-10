//import CoreMotion
//
//class MotionManager {
////  private let NOTIFICATION_NAME = Notification.Name("MotionNotifications")
////
////  private let operationQueue: OperationQueue = OperationQueue()
//  private let motionManager = CMMotionManager()
////
////
//  init() {
//
////    // Post notification
////    NotificationCenter.default.post(name: NOTIFICATION_NAME, object: nil)
////
////    // Stop listening notification
////    NotificationCenter.default.removeObserver(self, name: NOTIFICATION_NAME, object: nil)
////
//
//    motionManager.startDeviceMotionUpdates(
//      to: operationQueue, withHandler: {
//        (deviceMotion, error) -> Void in
//
//        if(error == nil) {
//          self.handleDeviceMotionUpdate(deviceMotion!)
//        } else {
//          //handle the error
//        }
//    })
//  }
////
////  private func handleDeviceMotionUpdate(_ deviceMotion: CMDeviceMotion) {
////
////  }
////
////  public func registerUpdateHandler(completion: @escaping (result: String) -> Void) {
////    NotificationCenter.default.addObserver(<#T##observer: Any##Any#>, selector: <#T##Selector#>, name: <#T##NSNotification.Name?#>, object: <#T##Any?#>)  //, selector: #selector(completion), name: NOTIFICATION_NAME, object: nil)
////  }
//
//}

