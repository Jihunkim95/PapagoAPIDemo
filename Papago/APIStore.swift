//
//  APIStore.swift
//  Papago
//
//  Created by 김지훈 on 2023/11/15.
//

import Foundation

class TranslateData: ObservableObject {
    @Published var translatedText: String?

    // API 엔드포인트 URL
    private let apiURL = URL(string: "https://openapi.naver.com/v1/papago/n2mt")!
    // API 키 및 시크릿을 저장한 Plist 파일 이름
    private let keyFileName = "ApiKeys"
    private let clientIdKey = "client_Id"
    private let clientSecretKey = "client_Secret"

    // 텍스트 번역 메서드
    func translateText(_ expression: String, _ source: String, _ target: String) {
        // API 키와 시크릿을 가져오기
        guard let clientId = getKey(from: clientIdKey), let clientSecret = getKey(from: clientSecretKey) else {
            fatalError("Failed to get API keys.")
        }

        // API 요청 생성
        var request = createRequest(clientId: clientId, clientSecret: clientSecret, source: source, target: target, expression: expression)

        // 네트워크 요청
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                // 네트워크 에러 처리
                self.handleRequestError(error)
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                // 성공적인 응답 처리
                self.handleTranslationResponse(data)
            } else {
                print("에러 발생")
            }
        }
        task.resume()
    }

    // API 요청 생성
    private func createRequest(clientId: String, clientSecret: String, source: String, target: String, expression: String) -> URLRequest {
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.addValue(clientId, forHTTPHeaderField: "X-Naver-Client-Id")
        request.addValue(clientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")

        let postParams = "source=" + source + "&target=" + target + "&text=" + expression
        request.httpBody = postParams.data(using: .utf8)

        return request
    }

    // 네트워크 요청 시 발생한 에러 처리
    private func handleRequestError(_ error: Error) {
        print(error.localizedDescription)
    }

    // 번역 결과 응답 처리
    private func handleTranslationResponse(_ data: Data?) {
        guard let data = data else {
            print("No data")
            return
        }

        do {
            // JSON 데이터 파싱
            let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            if let result = result, let translatedText = result["message"] as? [String: Any], let output = translatedText["result"] as? [String: Any], let translated = output["translatedText"] as? String {
                // 번역 결과를 뷰 모델의 속성에 할당하고 발행
                print("번역 결과: \(translated)")

                DispatchQueue.main.async {
                    self.translatedText = translated
                }
            }
        } catch {
            // JSON 파싱 에러 처리
            print(error.localizedDescription)
        }
    }

    // Plist에서 API 키 가져오기
    private func getKey(from key: String) -> String? {
        guard let filePath = Bundle.main.path(forResource: keyFileName, ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath),
              let value = plist.object(forKey: key) as? String else {
            return nil
        }

        return value
    }
}
