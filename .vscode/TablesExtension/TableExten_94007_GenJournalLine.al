tableextension 94007 "BWK Gen. Journal Line" extends "Gen. Journal Line"
{
    fields
    {
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
        field(94017; "BWK Etax Post Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'รหัสไปรษณีย์';
        }
        field(94018; "BWK Etax Branch Code"; code[5])
        {
            DataClassification = ToBeClassified;
            Caption = 'Branch Code';
        }
        modify("Account No.")
        {
            trigger OnAfterValidate()
            var
                lrCustomer: record Customer;

            begin
                if "Account Type" = "Account Type"::Customer then ///
                begin
                    lrCustomer.Reset();
                    lrCustomer.SetFilter("No.", '%1', "Account No.");
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
                        "BWK Etax Post Code" := lrCustomer."Post Code";
                        "VAT Registration No." := lrCustomer."VAT Registration No.";

                    end;
                end;
            end;
        }
        modify("BWK Deposit Of Card")
        {
            trigger OnAfterValidate()
            var
                lrCustomer: record Customer;
            begin
                if "BWK Deposit Type Card" = "BWK Deposit Type Card"::Customer then begin
                    lrCustomer.Reset();
                    lrCustomer.SetFilter("No.", '%1', "BWK Deposit Of Card");
                    if lrCustomer.FindFirst() then begin
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
                        "BWK Etax Post Code" := lrCustomer."Post Code";
                        "VAT Registration No." := lrCustomer."VAT Registration No.";
                    end;
                end;
            end;
        }
    }

    var
        myInt: Integer;
}