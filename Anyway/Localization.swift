//
//  Localization.swift
//  Anyway
//
//  Created by Aviel Gross on 16/11/2015.
//  Copyright © 2015 Hasadna. All rights reserved.
//

import Foundation

/**
 Builds and gets a localized string for an enum
 type using the enum's name and the raw value.
 
 Format is:
 ENUM_NAME + "_" + RAW_VALUE
 
 e.g.,:
 SUG_YOM_1
 HUMRAT_TEUNA_9
 etc.

 For this to work any string using this
 enum must follow the above format...
 */
enum Localization {
    
    // Road Conditions
    case SUG_DERECH, YEHIDA, SUG_YOM, HUMRAT_TEUNA, SUG_TEUNA,
         ZURAT_DEREH, HAD_MASLUL, RAV_MASLUL, MEHIRUT_MUTERET,
         TKINUT, ROHAV, SIMUN_TIMRUR, TEURA, BAKARA, MEZEG_AVIR,
         PNE_KVISH, SUG_EZEM, MERHAK_EZEM, LO_HAZA, OFEN_HAZIYA,
         MEKOM_HAZIYA, KIVUN_HAZIYA, STATUS_IGUN
    
    // Vehicle Description
    case MATZAV_REHEV, SHIYUH_REHEV_LMS, SUG_REHEV_LMS
    
    // Involved Person Description
    case SUG_MEORAV, MIN, SUG_REHEV_NASA_LMS, EMZAE_BETIHUT,
         HUMRAT_PGIA, SUG_NIFGA_LMS, PEULAT_NIFGA_LMS,
         PAZUA_USHPAZ, MADAD_RAFUI, YAAD_SHIHRUR,
         SHIMUSH_BE_AVIZAREY_BETIHOT, PTIRA_MEUHERET
    
    
    subscript(val: Int) -> String? {
        let localKey = "\(self)_\(val)"
        let result = local(localKey)
        
        // when no localized string found, we get
        // back the code we sent to 'local()'.
        // When this happens - pass an empty string
        // to the caller.
        return result.hasPrefix("\(self)") ? "" : result
    }
    
}



var staticFieldNames = [
    "INNER_PERSON_TITLE": "פרטי אדם מעורב",
    "INNER_VEHICLE_TITLE": "פרטי רכב מעורב",
    "pk_teuna_fikt": "מזהה",
    "SUG_DERECH": "סוג דרך",
    "SHEM_ZOMET": "שם צומת",
    "SEMEL_YISHUV": "ישוב",
    "REHOV1": "רחוב 1",
    "REHOV2": "רחוב 2",
    "BAYIT": "מספר בית",
    "ZOMET_IRONI": "צומת עירוני",
    "KVISH1": "כביש 1",
    "KVISH2": "כביש 2",
    "ZOMET_LO_IRONI": "צומת לא עירוני",
    "YEHIDA": "יחידה",
    "SUG_YOM": "סוג יום",
    "RAMZOR": "רמזור",
    "HUMRAT_TEUNA": "חומרת תאונה",
    "SUG_TEUNA": "סוג תאונה",
    "ZURAT_DEREH": "צורת דרך",
    "HAD_MASLUL": "חד מסלול",
    "RAV_MASLUL": "רב מסלול",
    "MEHIRUT_MUTERET": "מהירות מותרת",
    "TKINUT": "תקינות",
    "ROHAV": "רוחב",
    "SIMUN_TIMRUR": "סימון תמרור",
    "TEURA": "תאורה",
    "BAKARA": "בקרה",
    "MEZEG_AVIR": "מזג אוויר",
    "PNE_KVISH": "פני כביש",
    "SUG_EZEM": "סוג עצם",
    "MERHAK_EZEM": "מרחק עצם",
    "LO_HAZA": "לא חצה",
    "OFEN_HAZIYA": "אופן חציה",
    "MEKOM_HAZIYA": "מקום חציה",
    "KIVUN_HAZIYA": "כיוון חציה",
    "STATUS_IGUN": "עיגון",
    "MAHOZ": "מחוז",
    "NAFA": "נפה",
    "EZOR_TIVI": "אזור טבעי",
    "MAAMAD_MINIZIPALI": "מעמד מוניציפלי",
    "ZURAT_ISHUV": "צורת יישוב",
    
    "SUG_MEORAV": "סוג מעורב",
    "SHNAT_HOZAA": "שנת הוצאת רשיון נהיגה",
    "KVUZA_GIL": "קבוצת גיל",
    "MIN": "מין",
    "SUG_REHEV_NASA_LMS": "סוג רכב בו נסע",
    "EMZAE_BETIHUT": "אמצעי בטיחות",
    "HUMRAT_PGIA": "חומרת פגיעה",
    "SUG_NIFGA_LMS": "סוג נפגע",
    "PEULAT_NIFGA_LMS": "מיקום פצוע",
    "KVUTZAT_OHLUSIYA_LMS": "קבוצת אוכלוסיה",
    "MAHOZ_MEGURIM": "מחוז מגורים",
    "NAFA_MEGURIM": "נפת מגורים",
    "EZOR_TIVI_MEGURIM": "אזור טבעי מגורים",
    "MAAMAD_MINIZIPALI_MEGURIM": "מעמד מוניצפלי מגורים",
    "ZURAT_ISHUV_MEGURIM": "צורת ישוב מגורים",
    
    "PAZUA_USHPAZ": "משך אשפוז",
    "MADAD_RAFUI": "מדד רפואי לחומרת הפציעה - ISS",
    "YAAD_SHIHRUR": "יעד שחרור",
    "SHIMUSH_BE_AVIZAREY_BETIHOT": "שימוש באביזרי בטיחות",
    "PTIRA_MEUHERET": "מועד הפטירה",
    
    "NEFAH": "נפח מנוע",
    "SHNAT_YITZUR": "שנת ייצור",
    "KIVUNE_NESIA": "כיוון נסיעה",
    "MATZAV_REHEV": "מצב רכב",
    "SHIYUH_REHEV_LMS": "שיוך רכב",
    "SUG_REHEV_LMS": "סוג רכב",
    "MEKOMOT_YESHIVA_LMS": "מקומות ישיבה",
    "MISHKAL_KOLEL_LMS": "משקל כולל",
    "ACC_ID": "מספר סידורי",
    "PROVIDER_CODE": "סוג תיק"
]