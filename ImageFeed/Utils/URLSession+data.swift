import Foundation

enum NetworkError: Error {
  case httpStatusCode(Int)
  case urlRequestError(Error)
  case urlSessionError
  case taskCancelled
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
          print(
            "❌ Error decoding object: \(error), data: \(String(data: data, encoding: .utf8) ?? "")")
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
    return task
  }

  func query<T: Decodable>(
    for request: URLRequest,
    id: String? = nil,
    completion: @escaping (Result<T, Error>) -> Void
  ) -> URLSessionTask {
    let taskId = id ?? request.url?.absoluteString ?? UUID().uuidString

    if let existingTask = URLSessionQueryTaskManager.shared.getTask(taskId) {
      URLSessionQueryTaskManager.shared.addCompletionHandler(
        taskId: taskId,
        handlerType: T.self,
        completion: completion)

      return existingTask
    } else {
      let task = objectTask(for: request) { (result: Result<T, Error>) in
        URLSessionQueryTaskManager.shared.completeTask(taskId: taskId, result: result, type: T.self)
      }
      URLSessionQueryTaskManager.shared.registerTask(taskId: taskId, task: task)
      URLSessionQueryTaskManager.shared.addCompletionHandler(
        taskId: taskId,
        handlerType: T.self,
        completion: completion)

      task.resume()
      return task
    }
  }
}

private class URLSessionQueryTaskManager {
  static let shared = URLSessionQueryTaskManager()
  private var tasks: [String: TaskInfo] = [:]
  private let queue = DispatchQueue(
    label: "com.imagefeed.querytaskmanager", attributes: .concurrent)

  private init() {}

  private class TaskInfo {
    let task: URLSessionTask
    var completionHandlers: [String: [(Any) -> Void]]
    var results: [String: Any]
    var isCompleted: Bool

    init(task: URLSessionTask) {
      self.task = task
      self.completionHandlers = [:]
      self.results = [:]
      self.isCompleted = false
    }
  }

  func registerTask(taskId: String, task: URLSessionTask) {
    queue.async(flags: .barrier) { [weak self] in
      guard let self = self else { return }
      self.tasks[taskId] = TaskInfo(task: task)
    }
  }

  func getTask(_ taskId: String) -> URLSessionTask? {
    var result: URLSessionTask?
    queue.sync {
      if let taskInfo = tasks[taskId], !taskInfo.isCompleted {
        result = taskInfo.task
      }
    }
    return result
  }

  func addCompletionHandler<T: Decodable>(
    taskId: String,
    handlerType: T.Type,
    completion: @escaping (Result<T, Error>) -> Void
  ) {
    let typeKey = String(describing: handlerType)

    queue.async(flags: .barrier) { [weak self] in
      guard let self = self, let taskInfo = self.tasks[taskId] else { return }
      if taskInfo.isCompleted, let result = taskInfo.results[typeKey] as? Result<T, Error> {
        DispatchQueue.main.async {
          completion(result)
        }
        return
      }

      if taskInfo.completionHandlers[typeKey] == nil {
        taskInfo.completionHandlers[typeKey] = []
      }

      let wrapper: (Any) -> Void = { anyResult in
        if let typedResult = anyResult as? Result<T, Error> {
          completion(typedResult)
        }
      }

      taskInfo.completionHandlers[typeKey]?.append(wrapper)
    }
  }

  func completeTask<T: Decodable>(taskId: String, result: Result<T, Error>, type: T.Type) {
    let typeKey = String(describing: type)

    queue.async(flags: .barrier) { [weak self] in
      guard let self = self, let taskInfo = self.tasks[taskId] else { return }

      taskInfo.results[typeKey] = result
      taskInfo.isCompleted = true

      let handlers = taskInfo.completionHandlers[typeKey] ?? []

      DispatchQueue.main.async {
        for handler in handlers {
          handler(result)
        }
      }

      taskInfo.completionHandlers[typeKey]?.removeAll()
    }
  }

  func cancelTask(_ taskId: String) {
    queue.async(flags: .barrier) { [weak self] in
      guard let self = self, let taskInfo = self.tasks[taskId] else { return }

      taskInfo.task.cancel()
      let error = NetworkError.taskCancelled
      for (typeKey, handlers) in taskInfo.completionHandlers {
        let errorResult = Result<Any, Error>.failure(error)
        taskInfo.results[typeKey] = errorResult

        DispatchQueue.main.async {
          for handler in handlers {
            handler(errorResult)
          }
        }
      }

      taskInfo.completionHandlers.removeAll()
      taskInfo.isCompleted = true

      DispatchQueue.global().asyncAfter(deadline: .now() + 5) { [weak self] in
        self?.queue.async(flags: .barrier) {
          self?.tasks.removeValue(forKey: taskId)
        }
      }
    }
  }

  func clearAllTasks() {
    queue.async(flags: .barrier) { [weak self] in
      self?.tasks.removeAll()
    }
  }

  func invalidateQuery(id: String) {
    queue.async(flags: .barrier) { [weak self] in
      self?.tasks.removeValue(forKey: id)
    }
  }
}
