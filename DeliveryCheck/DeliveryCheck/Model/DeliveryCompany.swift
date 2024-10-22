//
//  Untitled.swift
//  DeliveryCheck
//
//  Created by 현수빈 on 10/22/24.
//

enum DeliveryCompany: String, CaseIterable {
    case dhl = "de.dhl"
    case sagawa = "jp.sagawa"
    case kuronekoYamato = "jp.yamato"
    case japanPost = "jp.yuubin"
    case chunilps = "kr.chunilps"
    case cjlogistics = "kr.cjlogistics"
    case cuPost = "kr.cupost"
    case gsPostbox = "kr.cvsnet"
    case cway = "kr.cway"
    case daesin = "kr.daesin"
    case epost = "kr.epost"
    case haniSarang = "kr.hanips"
    case hanjin = "kr.hanjin"
    case hdexp = "kr.hdexp"
    case homepick = "kr.homepick"
    case honamLogis = "kr.honamlogis"
    case ilyanglogis = "kr.ilyanglogis"
    case kdexp = "kr.kdexp"
    case kunyoung = "kr.kunyoung"
    case logen = "kr.logen"
    case lotte = "kr.lotte"
    case slx = "kr.slx"
    case swgexp = "kr.swgexp"
    case tnt = "nl.tnt"
    case ems = "un.upu.ems"
    case fedex = "us.fedex"
    case ups = "us.ups"
    case usps = "us.usps"
    
    var name: String {
        switch self {
        case .dhl: return "DHL"
        case .sagawa: return "Sagawa"
        case .kuronekoYamato: return "Kuroneko Yamato"
        case .japanPost: return "Japan Post"
        case .chunilps: return "천일택배"
        case .cjlogistics: return "CJ대한통운"
        case .cuPost: return "CU 편의점택배"
        case .gsPostbox: return "GS Postbox 택배"
        case .cway: return "CWAY (Woori Express)"
        case .daesin: return "대신택배"
        case .epost: return "우체국 택배"
        case .haniSarang: return "한의사랑택배"
        case .hanjin: return "한진택배"
        case .hdexp: return "합동택배"
        case .homepick: return "홈픽"
        case .honamLogis: return "한서호남택배"
        case .ilyanglogis: return "일양로지스"
        case .kdexp: return "경동택배"
        case .kunyoung: return "건영택배"
        case .logen: return "로젠택배"
        case .lotte: return "롯데택배"
        case .slx: return "SLX"
        case .swgexp: return "성원글로벌카고"
        case .tnt: return "TNT"
        case .ems: return "EMS"
        case .fedex: return "Fedex"
        case .ups: return "UPS"
        case .usps: return "USPS"
        }
    }
    
    var tel: String? {
        switch self {
        case .dhl: return "+8215880001"
        case .sagawa: return "+810120189595"
        case .kuronekoYamato: return "+810120189595"
        case .japanPost: return "+810570046111"
        case .chunilps: return "+8218776606"
        case .cjlogistics: return "+8215881255"
        case .cuPost: return "+8215771287"
        case .gsPostbox: return "+8215771287"
        case .cway: return "+8215884899"
        case .daesin: return "+82314620100"
        case .epost: return "+8215881300"
        case .haniSarang: return "+8216001055"
        case .hanjin: return "+8215880011"
        case .hdexp: return "+8218993392"
        case .homepick: return "+8218000987"
        case .honamLogis: return "+8218770572"
        case .ilyanglogis: return "+8215880002"
        case .kdexp: return "+8218995368"
        case .kunyoung: return "+82533543001"
        case .logen: return "+8215889988"
        case .lotte: return "+8215882121"
        case .slx: return "+82316375400"
        case .swgexp: return "+82327469984"
        case .tnt: return nil
        case .ems: return nil
        case .fedex: return nil
        case .ups: return nil
        case .usps: return nil
        }
    }
}
