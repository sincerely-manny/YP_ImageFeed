import Foundation

enum NetworkError: Error {
  case httpStatusCode(Int)
  case urlRequestError(Error)
  case urlSessionError
}

extension URLSession {
  func data(
    for request: URLRequest,
    completion: @escaping (Result<Data, Error>) -> Void
  ) -> URLSessionTask {
    let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
      DispatchQueue.main.async {
        completion(result)
      }
    }

    let task = dataTask(
      with: request,
      completionHandler: { data, response, error in
        if let data = data, let response = response,
          let statusCode = (response as? HTTPURLResponse)?.statusCode
        {
          if 200..<300 ~= statusCode {
            fulfillCompletionOnTheMainThread(.success(data))
          } else {
            print(
              "❌ Error: server responded with status code \(statusCode), response message: \(String(describing: String(data: data, encoding: .utf8)))"
            )
            fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
          }
        } else if let error = error {
          fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
        } else {
          fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
        }
      })

    return task
  }

  func objectTask<T: Decodable>(
    for request: URLRequest,
    completion: @escaping (Result<T, Error>) -> Void
  ) -> URLSessionTask {
    let task = data(for: request) { result in
      switch result {
      case .success(let data):
        do {
          let decoder = JSONDecoder()
          decoder.keyDecodingStrategy = .convertFromSnakeCase
          let object = try decoder.decode(T.self, from: data)
          completion(.success(object))
        } catch {
          print("❌ Error decoding object: \(error)")
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
    return task
  }
}
