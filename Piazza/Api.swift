import Foundation

struct Api {
#if DEBUG
  static let rootURL = URL(string: "http://localhost:3000/")!
#else
  static let rootURL =
    URL(string: "https://piazza-web.onrender.com/")!
#endif
  
  struct Path {
    static let profile =
      Api.rootURL.appendingPathComponent("profile")
    static let login =
      Api.rootURL.appendingPathComponent("login")
    static let myAds =
      Api.rootURL.appendingPathComponent("my_listings")
    static let savedAds =
      Api.rootURL.appendingPathComponent("saved_listings")
    static let messages =
      Api.rootURL.appendingPathComponent("conversations")
  }
}
