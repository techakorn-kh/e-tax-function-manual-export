tableextension 94005 "BWK Sales Header" extends "Sales Header"
{
    fields
    {
        modify("Applies-to Doc. No.")
        {
            trigger OnAfterValidate()
            begin
                if Rec."Document Type" = Rec."Document Type"::Invoice then begin
                    if Rec."Applies-to Doc. No." <> '' then begin
                        "BWK Is Debit Note" := true;
                        "BWK Applies-to ID" := Rec."Applies-to Doc. No.";
                    end else begin
                        "BWK Is Debit Note" := false;
                        "BWK Applies-to ID" := '';
                    end;
                end;
            end;
        }
        modify("Applies-to ID")
        {
            trigger OnAfterValidate()
            begin
                if Rec."Document Type" = Rec."Document Type"::Invoice then begin
                    if Rec."Applies-to ID" <> '' then begin
                        "BWK Is Debit Note" := true;
                        "BWK Applies-to ID" := Rec."Applies-to ID";
                    end else begin
                        "BWK Is Debit Note" := false;
                        "BWK Applies-to ID" := '';
                    end;
                end;
            end;
        }
        field(94001; "BWK Etax Building No."; Text[70])
        {
            DataClassification = ToBeClassified;
            Caption = 'บ้านเลขที่';

        }
        field(94002; "BWK Etax Building Name"; Text[70])
        {
            DataClassification = ToBeClassified;
            Caption = 'ชื่ออาคาร';
        }
        field(94003; "BWK Etax Address1"; Text[70])
        {
            DataClassification = ToBeClassified;
            Caption = 'ซอย';
        }
        field(94004; "BWK Etax Address2"; Text[70])
        {
            DataClassification = ToBeClassified;
            Caption = 'หมู่บ้าน';
        }
        field(94005; "BWK Etax Address3"; Text[70])
        {
            DataClassification = ToBeClassified;
            Caption = 'หมู่ที่';
        }
        field(94006; "BWK Etax Street"; Text[70])
        {
            DataClassification = ToBeClassified;
            Caption = 'ถนน';
        }
        field(94007; "BWK Etax City Sub"; Text[70])
        {
            DataClassification = ToBeClassified;
            Caption = 'ตำบล';

        }
        field(94008; "BWK Etax City"; Text[70])
        {
            DataClassification = ToBeClassified;
            Caption = 'อำเภอ';
        }
        field(94009; "BWK Etax Sub Country"; Text[70])
        {
            DataClassification = ToBeClassified;
            Caption = 'จังหวัด';
        }
        field(94010; "BWK Etax E-Mail"; Text[150])
        {
            DataClassification = ToBeClassified;
            Caption = 'E-Mail';
        }
        field(94011; "BWK Etax Country ID"; Text[70])
        {
            DataClassification = ToBeClassified;
            Caption = 'รหัสประเทศ';
        }
        field(94012; "BWK Etax Address4"; Text[70])
        {
            DataClassification = ToBeClassified;

        }
        field(94013; "BWK Etax Address5"; Text[70])
        {
            DataClassification = ToBeClassified;

        }
        field(94014; "BWK Etax Country Name"; Text[70])
        {
            DataClassification = ToBeClassified;
            Caption = 'ชื่อประเทศ';
        }
        field(94015; "BWK Etax Taxpayer Type"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = " ",TXID,NIDN,CCPT,OTHR;
            Caption = 'Taxpayer Type';
        }
        field(94016; "BWK Etax Taxpayer Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Taxpayer Name';
        }
        field(94017; "BWK Etax Branch Code"; code[5])
        {
            DataClassification = ToBeClassified;
            Caption = 'Branch Code';
        }
        field(94018; "BWK DN Purpost Code"; Code[10])
        {
            Caption = 'DN Purpost Code';
            DataClassification = ToBeClassified;
            TableRelation = "BWK ETax Purpose Code"."BWK Purpose Code" where("BWK Purpose Type" = filter('DN'));
            // OptionMembers = " ","DBNG01","DBNG02","DBNG99","DBNS01","DBNS02","DBNS99";
            // OptionCaption = ' ,DBNG01,DBNG02,DBNG99,DBNS01,DBNS02,DBNS99';

            trigger OnValidate()
            var
                ETaxPurposeCode: Record "BWK ETax Purpose Code";
            begin
                if Rec."BWK DN Purpost Code" <> '' then begin
                    ETaxPurposeCode.Get(1, Rec."BWK DN Purpost Code");
                    "BWK DN Purpost Name" := ETaxPurposeCode."BWK Purpose Name";
                end else begin
                    "BWK DN Purpost Name" := '';
                end;
                //     if "BWK DN Purpost Code" = "BWK DN Purpost Code"::" " then begin
                //         "BWK DN Purpost Name" := '';
                //         "BWK Is Debit Note" := false;
                //     end else begin
                //         case "BWK DN Purpost Code" of
                //             "BWK DN Purpost Code"::DBNG01:
                //                 begin
                //                     "BWK DN Purpost Name" := 'มีการเพิ่มราคาค่าสินค้า (สินค้าเกินกว่าจำนวนที่ตกลงกัน)';
                //                     "BWK Is Debit Note" := true;
                //                 end;
                //             "BWK DN Purpost Code"::DBNG02:
                //                 begin
                //                     "BWK DN Purpost Name" := 'คำนวณราคาสินค้า ผิดพลาดต่ำกว่าที่เป็นจริง';
                //                     "BWK Is Debit Note" := true;
                //                 end;
                //             "BWK DN Purpost Code"::DBNG99:
                //                 begin
                //                     "BWK DN Purpost Name" := 'เหตุอื่น (ระบุสาเหตุ)';
                //                     "BWK Is Debit Note" := true;
                //                 end;
                //             "BWK DN Purpost Code"::DBNS01:
                //                 begin
                //                     "BWK DN Purpost Name" := 'การเพิ่มราคาค่าบริการ (บริการเกินกว่าข้อกำหนดที่ตกลงกัน)';
                //                     "BWK Is Debit Note" := true;
                //                 end;
                //             "BWK DN Purpost Code"::DBNS02:
                //                 begin
                //                     "BWK DN Purpost Name" := 'คำนวณราคาค่าบริการ ผิดพลาดต่ำกว่าที่เป็นจริง';
                //                     "BWK Is Debit Note" := true;
                //                 end;
                //             "BWK DN Purpost Code"::DBNS99:
                //                 begin
                //                     "BWK DN Purpost Name" := 'เหตุอื่น (ระบุสาเหตุ)';
                //                     "BWK Is Debit Note" := true;
                //                 end;
                //         end;
                //     end;
            end;
        }
        field(94019; "BWK DN Purpost Name"; Text[100])
        {
            Caption = 'DN Purpost Name';
            DataClassification = ToBeClassified;
        }

        field(94020; "BWK CN Purpost Code"; Code[10])
        {
            Caption = 'CN Purpost Code';
            DataClassification = ToBeClassified;
            TableRelation = "BWK ETax Purpose Code"."BWK Purpose Code" where("BWK Purpose Type" = filter('CN'));
            // OptionMembers = " ","CDNG01","CDNG02","CDNG03","CDNG04","CDNG05","CDNG99","CDNS01","CDNS02","CDNS03","CDNS04","CDNS99";
            // OptionCaption = ' ,CDNG01,CDNG02,CDNG03,CDNG04,CDNG05,CDNG99,CDNS01,CDNS02,CDNS03,CDNS04,CDNS99';

            trigger OnValidate()
            var
                ETaxPurposeCode: Record "BWK ETax Purpose Code";
            begin
                if Rec."BWK CN Purpost Code" <> '' then begin
                    ETaxPurposeCode.Get(0, Rec."BWK CN Purpost Code");
                    "BWK CN Purpost Name" := ETaxPurposeCode."BWK Purpose Name";
                end else begin
                    "BWK CN Purpost Name" := '';
                end;

                // if "BWK CN Purpost Code" = Rec."BWK CN Purpost Code"::" " then begin
                //     "BWK CN Purpost Name" := '';
                // end else begin
                //     case "BWK CN Purpost Code" of
                //         "BWK CN Purpost Code"::CDNG01:
                //             begin
                //                 "BWK CN Purpost Name" := 'ลดราคาสินค้าที่ขาย (สินค้าผิดข้อกาหนดที่ตกลงกัน)';
                //             end;
                //         "BWK CN Purpost Code"::CDNG02:
                //             begin
                //                 "BWK CN Purpost Name" := 'สินค้าชำรุดเสียหาย';
                //             end;
                //         "BWK CN Purpost Code"::CDNG03:
                //             begin
                //                 "BWK CN Purpost Name" := 'สินค้าขาดจานวนตามที่ตกลงซื้อขาย';
                //             end;
                //         "BWK CN Purpost Code"::CDNG04:
                //             begin
                //                 "BWK CN Purpost Name" := 'คำนวณราคาสินค้าผิดพลาดสูงกว่าที่เป็นจริง';
                //             end;
                //         "BWK CN Purpost Code"::CDNG05:
                //             begin
                //                 "BWK CN Purpost Name" := 'รับคืนสินค้า (ไม่ตรงตามคำพรรณนา)';
                //             end;
                //         "BWK CN Purpost Code"::CDNG99:
                //             begin
                //                 "BWK CN Purpost Name" := 'เหตุอื่น (ระบุสาเหตุ)';
                //             end;
                //         "BWK CN Purpost Code"::CDNS01:
                //             begin
                //                 "BWK CN Purpost Name" := 'ลดราคาค่าบริการ (บริการผิดข้อกำหนดที่ตกลงกัน)';
                //             end;
                //         "BWK CN Purpost Code"::CDNS02:
                //             begin
                //                 "BWK CN Purpost Name" := 'ค่าบริการขาดจำนวน';
                //             end;
                //         "BWK CN Purpost Code"::CDNS03:
                //             begin
                //                 "BWK CN Purpost Name" := 'คำนวณราคาค่าบริการผิดพลาดสูงกว่าที่เป็นจริง';
                //             end;
                //         "BWK CN Purpost Code"::CDNS04:
                //             begin
                //                 "BWK CN Purpost Name" := 'บอกเลิกสัญญาบริการ';
                //             end;
                //         "BWK CN Purpost Code"::CDNS99:
                //             begin
                //                 "BWK CN Purpost Name" := 'เหตุอื่น (ระบุสาเหตุ)';
                //             end;
                //     end;
                // end;
            end;
        }
        field(94021; "BWK CN Purpost Name"; Text[100])
        {
            Caption = 'CN Purpost Name';
            DataClassification = ToBeClassified;
        }
        field(94022; "BWK Is Debit Note"; Boolean)
        {
            Caption = 'Is Debit Note';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(94023; "BWK Applies-to ID"; Code[50])
        {
            Caption = 'BWK Applies-to ID';
            DataClassification = ToBeClassified;
            Editable = false;
        }


        modify("Sell-to Customer No.")
        {
            trigger OnAfterValidate()
            var
                lrCustomer:
                    record Customer;

            begin
                if ("Document Type" = "Document Type"::Invoice) or ("Document Type" = "Document Type"::"Credit Memo") then ///
                begin
                    lrCustomer.Reset();
                    lrCustomer.SetFilter("No.", '%1', "Sell-to Customer No.");
                    if lrCustomer.FindFirst() then ///
                    begin
                        "BWK Etax Building No." := lrCustomer."BWK Etax Building No.";
                        "BWK Etax Building Name" := lrCustomer."BWK Etax Building Name";
                        "BWK Etax Address1" := lrCustomer."BWK Etax Address1";
                        "BWK Etax Address2" := lrCustomer."BWK Etax Address2";
                        "BWK Etax Address3" := lrCustomer."BWK Etax Address3";
                        "BWK Etax Street" := lrCustomer."BWK Etax Street";
                        "BWK Etax City Sub" := lrCustomer."BWK Etax City Sub";
                        "BWK Etax City" := lrCustomer."BWK Etax City";
                        "BWK Etax Sub Country" := lrCustomer."BWK Etax Sub Country";
                        "BWK Etax E-Mail" := lrCustomer."BWK Etax E-Mail";
                        "BWK Etax Country ID" := lrCustomer."BWK Etax Country ID";
                        "BWK Etax Address4" := lrCustomer."BWK Etax Address4";
                        "BWK Etax Address5" := lrCustomer."BWK Etax Address5";
                        "BWK Etax Country Name" := lrCustomer."BWK Etax Country Name";
                        "BWK Etax Taxpayer Type" := lrCustomer."BWK Etax Taxpayer Type";
                        "BWK Etax Taxpayer Name" := lrCustomer."BWK Etax Taxpayer Name";
                        "Sell-to Post Code" := lrCustomer."Post Code";
                        "VAT Registration No." := lrCustomer."VAT Registration No.";
                        "BWK Etax Branch Code" := lrCustomer."BWK Etax Branch Code";
                    end;
                end;
            end;
        }
    }

    var
        myInt: Integer;
}