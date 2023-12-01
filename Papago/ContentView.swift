//
//  ContentView.swift
//  Papago
//
//  Created by 김지훈 on 2023/11/14.
//

import SwiftUI

struct ContentView: View {
    //파파고 API연동
    @StateObject private var translateData = TranslateData()
    @State private var inputText:String = ""

    @State private var source:String = ""
    @State private var target:String = ""
    

    //다크 라이트
    @Environment(\.colorScheme) var colorScheme

    @State var language: [String:String] = [
        "한국어": "ko",
        "영어": "en",
        "중국어 간체": "zh-CN",
        "중국어 번체": "zh-TW",
        "스페인어": "es",
        "프랑스어": "fr",
        "베트남어": "vi",
        "태국어": "th",
        "인도네시아어": "id"
    ]
    
    @State var selectedColor: String = ""
    var body: some View {
        VStack(spacing: 10) {
            HStack{
                Image(systemName: "menucard")
                    .resizable()
                    .frame(width: 30,height: 30)
                    .padding()
                
                Spacer()
                Text("papago")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Image(systemName: "book")
                    .resizable()
                    .frame(width: 30,height: 30)
                    .padding()
            }
            
            HStack{
                Spacer()
                Picker("", selection: $source) {
                    ForEach(Array(language.keys), id: \.self) { key in
                        Text(key)

                  }
                }
                //이거 왜 안되냐,,,
                .pickerStyle(MenuPickerStyle())
                .foregroundStyle(.black)
                .background(.white)
                .cornerRadius(15)
                .padding()
                
            
                Spacer()
                
                Button(action: {
                    let temp:String = source
                    
                    source = target
                    target = temp
                    print(language.keys)
                    
                    let sourceData:String = language[source] ?? "ko"
                    let targetData:String = language[target] ?? "en"
                     
                    translateData.translateText(inputText,sourceData,targetData)
                    inputText = translateData.translatedText ?? ""
                }) {
                    if colorScheme == .dark{
                        Image(systemName:"fibrechannel")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 1)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    }else{
                        Image(systemName:"fibrechannel") //이미지 파일의 이름
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(.black)
                            .overlay(
                                RoundedRectangle(cornerRadius: 1)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                    }
                    
                    
                }
                Spacer()
                Picker("", selection: $target) {
                    ForEach(Array(language.keys), id: \.self) { key in
                        Text(key)

                  }
                }
                //이거 왜 안되냐,,,
                .pickerStyle(MenuPickerStyle())
                .foregroundStyle(.black)
                .background(.white)
                .cornerRadius(15)
                .padding()
                Spacer()
            }
            .padding(.horizontal)
            Divider()
                .frame(height: 5) // Divider의 높이 설정
                .foregroundColor(.blue) // 선 색상 설정
                .opacity(20)
            Spacer()

            
            TextField("번역할 내용을 입력하세요.", text: $inputText).multilineTextAlignment(.center).font(.title)
                .frame(maxHeight:200)
                            .onSubmit{
                                
                                let sourceData:String = language[source] ?? "ko"
                                let targetData:String = language[target] ?? "en"
                                
                                translateData.translateText(inputText,sourceData,targetData)
                                
                            }
            
            Text("\(translateData.translatedText ?? "")")
            Spacer()
            
        }
        
//        NavigationView {
//            Form {
//                TextField("Enter text", text: $source)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding()
//                    .animation(.easeInOut) // 애니메이션 추가
//            }
//            .navigationTitle("My App")
//        }
    }

    
}

#Preview {
    ContentView()
}
