//
//  APIStore.swift
//  Papago
//
//  Created by 김지훈 on 2023/11/15.
//

import Foundation

class TranslateData: ObservableObject{
    @Published var translatedText: String?
    
    func translateText(_ expression:String,_ source:String,_ target:String) {
        let clientId = "bWuBu02GTBUtbAYWfmsF" // 애플리케이션 클라이언트 아이디값
        let clientSecret = "BK6Ity8Isx" // 애플리케이션 클라이언트 시크릿값

//        let text = "만나서 반갑습니다."
        let apiURL = URL(string: "https://openapi.naver.com/v1/papago/n2mt")!

        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.addValue(clientId, forHTTPHeaderField: "X-Naver-Client-Id")
        request.addValue(clientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")

        let postParams = "source=" + source + "&target=" + target + "&text=" + expression
        request.httpBody = postParams.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let result = result, let translatedText = result["message"] as? [String: Any], let output = translatedText["result"] as? [String: Any], let translated = output["translatedText"] as? String {
                        
                        print("번역 결과: \(translated)")
                        
                        // 결과를 뷰 모델의 속성에 할당하고 발행 <<이게 핵심
                        DispatchQueue.main.async {
                            self.translatedText = translated
                        }

                    }
                } catch {
                    print(error.localizedDescription)
                }
            } else {
                print("에러 발생")
            }
        }
        task.resume()
    }

}
