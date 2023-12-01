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
        let clientId = clientId ?? "" // 애플리케이션 클라이언트 아이디값
        let clientSecret = clientSecret ?? "" // 애플리케이션 클라이언트 시크릿값
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

            print(apiURL)
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

    //plist에서 선언한 clientId 받기
    private var clientId: String?{
        get{
            let keyfilename = "ApiKeys"
            let api_id = "client_Id"
            
            //생성한 .plist 파일 경로 불러오기
            guard let filePath = Bundle.main.path(forResource: keyfilename, ofType: "plist") else {
                fatalError("Couldn't find file '\(keyfilename).plist'")
            }
            
            // .plist 파일 내용을 딕셔너리로 받아오기
            let plist = NSDictionary(contentsOfFile: filePath)
            
            // 딕셔너리에서 키 찾기
            guard let value = plist?.object(forKey: api_id) as? String else {
                fatalError("Couldn't find key '\(api_id)'")
            }
            
            return value
        }
    }
    
    //plist에서 선언한 clientId 받기
    private var clientSecret: String?{
        get{
            let keyfilename = "ApiKeys"
            let api_secret = "client_Secret"
            
            //생성한 .plist 파일 경로 불러오기
            guard let filePath = Bundle.main.path(forResource: keyfilename, ofType: "plist") else {
                fatalError("Couldn't find file '\(keyfilename).plist'")
            }
            
            // .plist 파일 내용을 딕셔너리로 받아오기
            let plist = NSDictionary(contentsOfFile: filePath)
            
            // 딕셔너리에서 키 찾기
            guard let value = plist?.object(forKey: api_secret) as? String else {
                fatalError("Couldn't find key '\(api_secret)'")
            }
            
            return value
        }
    }
}

