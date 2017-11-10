import Html
import HttpPipeline
import HttpPipelineHtmlSupport
import Prelude
import XCTest

class HttpPipelineHtmlSupportTests: XCTestCase {
  func testResponse() {
    let view = View<Prelude.Unit> { _ in p(["Hello world!"]) }
    let pipeline: Middleware<StatusLineOpen, ResponseEnded, Never, Never, Prelude.Unit, Data> =
      writeStatus(.ok)
        >-> respond(view)

    let conn = connection(from: URLRequest(url: URL(string: "/")!))
    let response = (conn |> pipeline).perform()

    XCTAssertEqual(200, response.response.status.rawValue)
    XCTAssertEqual(
      "Content-Type: text/html; charset=utf8",
      response.response.headers.map(get(\.description)).joined(separator: "")
    )
    XCTAssertEqual("<p>Hello world!</p>", String(decoding: response.response.body, as: UTF8.self))
  }
}
