import Foundation

enum Constants {
  static let accessScope = "public+read_user+write_likes"
  static let accessKey = "RcPt1aWD-PeEXsBsSf3XAtEjx__Mbd-hyn1T7eXKDI8"
  static let secretKey = "sKiDGKbD9_-0Ze-nVSlPbe7cbhGT_40PgI77SNSK-Xw"
  static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
  static let defaultBaseURL = URL(string: "https://unsplash.com/")
  static let apiBaseURL = URL(string: "https://api.unsplash.com/")
  /*
  Uncomment the line below to use the local server (to avoid rate limits)
  start the server with:
  ```sh
  cd ./MockServer
  npm install
  npm start
  ```
  */
  //static let apiBaseURL = URL(string: "http://localhost:3000/")
}

struct AuthConfiguration {
  let accessKey: String
  let secretKey: String
  let redirectURI: String
  let accessScope: String
  let defaultBaseURL: URL
  let apiBaseURL: URL

  static let standard =
    {
      guard let defaultBaseURL = Constants.defaultBaseURL,
        let apiBaseURL = Constants.apiBaseURL
      else {
        fatalError("Invalid URL")
      }
      return AuthConfiguration(
        accessKey: Constants.accessKey,
        secretKey: Constants.secretKey,
        redirectURI: Constants.redirectURI,
        accessScope: Constants.accessScope,
        defaultBaseURL: defaultBaseURL,
        apiBaseURL: apiBaseURL
      )
    }()

  init(
    accessKey: String,
    secretKey: String,
    redirectURI: String,
    accessScope: String,
    defaultBaseURL: URL,
    apiBaseURL: URL
  ) {
    self.accessKey = accessKey
    self.secretKey = secretKey
    self.redirectURI = redirectURI
    self.accessScope = accessScope
    self.defaultBaseURL = defaultBaseURL
    self.apiBaseURL = apiBaseURL
  }
}
