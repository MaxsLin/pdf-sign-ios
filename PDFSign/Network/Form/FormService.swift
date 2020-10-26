//
//  FormService.swift
//  PDFSign
//
//  Created by kawu on 8/10/20.
//  Copyright © 2020 weshine. All rights reserved.
//

import Foundation
import UIKit

struct FormRequest {
    enum RequestType {
        case getAllForm, checkFile

        func validateResponse(_ dict: [String: Any]) -> Response<Any> {
            switch self {
            case .getAllForm:
                guard
                    let success = dict["result"] as? Bool,
                    let message = dict["message"] as? [[String: Any]]
                else {
                    return Response<Any>(success: false)
                }
                let forms: [FormInfo] = message.map({ FormInfo(dict: $0) })
                return Response<Any>(success: success, model: forms)
            case .checkFile:
                guard let fileurl = dict[""] else {
                    return Response<Any>(success: false)
                }
                return Response<Any>(success: true, model: nil)
            }
        }
    }

    var type: RequestType

    init(type: RequestType) {
        self.type = type
    }

    func validateResponse(data: Data) -> Response<Any> {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            guard let parsedJson = json as? [String: Any] else { return Response<Any>(success: false) }

            return type.validateResponse(parsedJson)
        } catch let error {
            return Response<Any>(success: false, error: error)
        }
    }
}

class FormService: NetworkService {

    var onResponse: ((Response<FormServiceResult>) -> Void)?
    var request: FormRequest?

    func getAllForm(custId: String) {
        guard !custId.isEmpty else { return }

        request = FormRequest(type: .getAllForm)

        let identity = Encryption.encrypt(sourceText: "\(UserService.deviceID)|\(custId)")
        let session = URLSession.shared
        let urlString = "http://60.248.154.118:8050/EpaperWS/wsFormService.asmx"
        let action = "getAllFormByCustID"
        let soapMessageAsText = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><getAllFormByCustID xmlns ='http://tempuri.org/'><identity>\(identity)</identity><custId>\(custId)</custId></getAllFormByCustID></soap:Body></soap:Envelope>"

        var request = URLRequest(url: URL(string: urlString)!)
        request.addValue("60.248.154.118:8050", forHTTPHeaderField: "HOST")
        request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("http://tempuri.org/" + action, forHTTPHeaderField: "SOAPAction")
        request.addValue("\(soapMessageAsText.count)", forHTTPHeaderField: "Content-Length")
        request.httpMethod = "POST"
        request.httpBody = soapMessageAsText.data(using: String.Encoding.utf8)

        let task = session.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in

            if let error = error {
                print("getAllFormByCustID failure: \(error)")
                self?.onResponse?(Response<FormServiceResult>(success: false))
            } else if let data = data {
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()
            }
        })
        task.resume()
    }

    func getFormArea(custId: String, formId: String) {

        result = GetAreaByFormIDResult()

        let identity = Encryption.encrypt(sourceText: "\(UserService.deviceID)|\(custId)")
        let session = URLSession.shared
        let urlString = "http://60.248.154.118:8050/EpaperWS/wsFormService.asmx"
        let action = "getAreaByFormID"
        let soapMessageAsText = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><getAreaByFormID xmlns ='http://tempuri.org/'><identity>\(identity)</identity><custId>\(custId)</custId><formID>\(formId)</formID></getAreaByFormID></soap:Body></soap:Envelope>"

        var request = URLRequest(url: URL(string: urlString)!)
        request.addValue("60.248.154.118:8050", forHTTPHeaderField: "HOST")
        request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("http://tempuri.org/" + action, forHTTPHeaderField: "SOAPAction")
        request.addValue("\(soapMessageAsText.count)", forHTTPHeaderField: "Content-Length")
        request.httpMethod = "POST"
        request.httpBody = soapMessageAsText.data(using: String.Encoding.utf8)

        let task = session.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in

            if let error = error {
                print("getAreaByFormID failure: \(error)")
                self?.onResponse?(Response<FormServiceResult>(success: false))
            } else if let data = data {
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()
            }
        })
        task.resume()
    }

    // MARK: - UPLOAD

    func checkArchiveFile(custId: String, filename: String) {

        result = CheckFileResult()

        // Meta
        let scode = "14d3e741-60fa-45a0-af28-cfd18e766385"
        let size = "0"
        let archiveType = "0"

        let session = URLSession.shared
        let urlString = "http://60.248.154.118:8050/WcfService/upload.svc"
        let action = "CheckArchiveFile"
        let soapMessageAsText = "<v:Envelope xmlns:i='http://www.w3.org/2001/XMLSchema-instance' xmlns:d='http://www.w3.org/2001/XMLSchema' xmlns:c='http://schemas.xmlsoap.org/soap/encoding/' xmlns:v='http://schemas.xmlsoap.org/soap/envelope/'><v:Header /><v:Body><CheckArchiveFile xmlns='http://tempuri.org/' id='o0' c:root='1'><custid i:type='d:string'>\(custId)</custid><archivetype i:type='d:string'>\(archiveType)</archivetype><filename i:type='d:string'>\(filename)</filename><filesize i:type='d:string'>\(size)</filesize><scode i:type='d:string'>\(scode)</scode></CheckArchiveFile></v:Body></v:Envelope>"

        var request = URLRequest(url: URL(string: urlString)!)
        request.addValue("60.248.154.118:8050", forHTTPHeaderField: "HOST")

        request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("http://tempuri.org/Iupload/" + action, forHTTPHeaderField: "SOAPAction")
        request.addValue("\(soapMessageAsText.count)", forHTTPHeaderField: "Content-Length")
        request.httpMethod = "POST"
        request.httpBody = soapMessageAsText.data(using: String.Encoding.utf8)

        let task = session.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            if let error = error {
                print("checkArchiveFile in upload failure: \(error)")
                self?.onResponse?(Response(success: false))
            } else if let data = data {
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()
            }
        })
        task.resume()
    }

    // MARK: - DOWNLOAD

    func checkFile(custId: String, filename: String) {

        result = CheckFileResult()

        // Meta
        let scode = "14d3e741-60fa-45a0-af28-cfd18e766385"
        let nowdata = "0"

        let session = URLSession.shared
        let urlString = "http://60.248.154.118:8050/WcfService/Service1.svc"
        let action = "CheckFile"
        let soapMessageAsText = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:d='http://www.w3.org/2001/XMLSchema' xmlns:c='http://schemas.xmlsoap.org/soap/encoding/' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><CheckFile xmlns ='http://tempuri.org/' id='o0' c:root='1'><custid>\(custId)</custid><filename>\(filename)</filename><nowdata>\(nowdata)</nowdata><scode>\(scode)</scode></CheckFile></soap:Body></soap:Envelope>"

        var request = URLRequest(url: URL(string: urlString)!)
        request.addValue("60.248.154.118:8050", forHTTPHeaderField: "HOST")

        request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("http://tempuri.org/IService1/" + action, forHTTPHeaderField: "SOAPAction")
        request.addValue("\(soapMessageAsText.count)", forHTTPHeaderField: "Content-Length")
        request.httpMethod = "POST"
        request.httpBody = soapMessageAsText.data(using: String.Encoding.utf8)

        let task = session.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            if let error = error {
                print("checkFile failure: \(error)")
                self?.onResponse?(Response(success: false))
            } else if let data = data {
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()
            }
        })
        task.resume()
    }

    func getData(custId: String, filepath: String, guid: String, offset: Int = 0) {

        result = GetDataResult()

        let session = URLSession.shared
        let urlString = "http://60.248.154.118:8050/WcfService/Service1.svc"
        let action = "GetDatas"
        let soapMessageAsText = "<v:Envelope xmlns:i='http://www.w3.org/2001/XMLSchema-instance' xmlns:d='http://www.w3.org/2001/XMLSchema' xmlns:c='http://schemas.xmlsoap.org/soap/encoding/' xmlns:v='http://schemas.xmlsoap.org/soap/envelope/'><v:Header /><v:Body><GetDatas xmlns='http://tempuri.org/' id='o0' c:root='1'><custid i:type='d:string'>\(custId)</custid><FileName i:type='d:string'>\(filepath)</FileName><OffSet i:type='d:string'>\(offset)</OffSet><scode i:type='d:string'>\(guid)</scode></GetDatas></v:Body></v:Envelope>"

        var request = URLRequest(url: URL(string: urlString)!)
        request.addValue("60.248.154.118:8050", forHTTPHeaderField: "HOST")

        request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("http://tempuri.org/IService1/" + action, forHTTPHeaderField: "SOAPAction")
        request.addValue("\(soapMessageAsText.count)", forHTTPHeaderField: "Content-Length")
        request.httpMethod = "POST"
        request.httpBody = soapMessageAsText.data(using: String.Encoding.utf8)

        let task = session.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            if let error = error {
                print("getDatas failure: \(error)")
                self?.onResponse?(Response(success: false))
            } else if let data = data {
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()
            }
        })
        task.resume()
    }

    func checkArchiveFile(custId: String, typeId: String, filename: String) {

        // Meta
        let scode = "14d3e741-60fa-45a0-af28-cfd18e766385"
        let nowdata = "0"
        let archiveType = "0"

        let session = URLSession.shared
        let urlString = "http://60.248.154.118:8050/WcfService/Service1.svc"
        let action = "CheckArchiveFile"
        let soapMessageAsText = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:d='http://www.w3.org/2001/XMLSchema' xmlns:c='http://schemas.xmlsoap.org/soap/encoding/' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><CheckArchiveFile xmlns ='http://tempuri.org/' id='o0' c:root='1'><custid>\(custId)</custid><archivetype>\(archiveType)</archivetype><typeid>\(typeId)</typeid><filename>\(filename)</filename><nowdata>\(nowdata)</nowdata><scode>\(scode)</scode></CheckArchiveFile></soap:Body></soap:Envelope>"

        var request = URLRequest(url: URL(string: urlString)!)
        request.addValue("60.248.154.118:8050", forHTTPHeaderField: "HOST")

        request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("http://tempuri.org/IService1/" + action, forHTTPHeaderField: "SOAPAction")
        request.addValue("\(soapMessageAsText.count)", forHTTPHeaderField: "Content-Length")
        request.httpMethod = "POST"
        request.httpBody = soapMessageAsText.data(using: String.Encoding.utf8)

        let task = session.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            if let error = error {
                print("checkArchiveFile failure: \(error)")
                self?.onResponse?(Response(success: false))
            } else if let data = data {
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()
            }
        })
        task.resume()
    }

    func getArchiveData(custId: String, filepath: String, guid: String, totalCount: Int) {

        let offset = "0"
        let path = "upload_files/ePaperArchive/23747873/dcffe0b2b8a827fc_20200512234825.zip"

        let session = URLSession.shared
        let urlString = "http://60.248.154.118:8050/WcfService/Service1.svc"
        let action = "GetArchiveDatas"
        let soapMessageAsText = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:d='http://www.w3.org/2001/XMLSchema' xmlns:c='http://schemas.xmlsoap.org/soap/encoding/' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><GetArchiveDatas xmlns ='http://tempuri.org/'><custid>\(custId)</custid><filename>\(path)</filename><OffSet>\(offset)</OffSet><scode>\(guid)</scode></GetArchiveDatas></soap:Body></soap:Envelope>"

        var request = URLRequest(url: URL(string: urlString)!)
        request.addValue("60.248.154.118:8050", forHTTPHeaderField: "HOST")
        request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("http://tempuri.org/IService1/" + action, forHTTPHeaderField: "SOAPAction")
        request.addValue("\(soapMessageAsText.count)", forHTTPHeaderField: "Content-Length")
        request.httpMethod = "POST"
        request.httpBody = soapMessageAsText.data(using: String.Encoding.utf8)

        let task = session.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            if let error = error {
                print("getArchiveData failure: \(error)")
                self?.onResponse?(Response(success: false))
            } else if let data = data {
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()
            }
        })
        task.resume()
    }

    var result: FormServiceResult?
    var resultPair: (element: String, value: String)?
}

extension FormService: XMLParserDelegate {

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        resultPair = (element: elementName, value: "")
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        resultPair?.value.append(string)
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard let pair = resultPair else { return }

        result?.set(element: pair.element, value: pair.value)
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        onResponse?(Response<FormServiceResult>(success: true, model: result))
    }
}
