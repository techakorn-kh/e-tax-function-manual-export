tableextension 94003 "BWK Customer" extends Customer
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
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                if "BWK Etax Taxpayer Type" = "BWK Etax Taxpayer Type"::TXID then
                    rec."BWK Etax Taxpayer Name" := 'เลขประจำตัวประชาชน (สำหรับนิติบุคคล)'
                else
                    if "BWK Etax Taxpayer Type" = "BWK Etax Taxpayer Type"::NIDN then
                        rec."BWK Etax Taxpayer Name" := 'เลขประจำตัวประชาชน (สำหรับบุคคลธรรมดา)'
                    else
                        if "BWK Etax Taxpayer Type" = "BWK Etax Taxpayer Type"::CCPT then
                            rec."BWK Etax Taxpayer Name" := 'เลขหนังสือเดินทาง (Passport)'
                        else
                            if "BWK Etax Taxpayer Type" = "BWK Etax Taxpayer Type"::OTHR then
                                rec."BWK Etax Taxpayer Name" := 'อื่นๆ'
                            else
                                rec."BWK Etax Taxpayer Name" := '';
            end;
        }
        field(94016; "BWK Etax Taxpayer Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            Caption = 'Taxpayer Name';
            Editable = false;
        }
        field(94017; "BWK Etax Branch Code"; code[5])
        {
            DataClassification = ToBeClassified;
            Caption = 'Branch Code';
        }

    }
    //Insert 20231124 by NM >>>
    trigger OnAfterModify()
    var
        Country: Record "Country/Region";
    begin
        // Rec."BWK Etax Sub Country" := Rec.City;
        // Rec."BWK Etax E-Mail" := Rec."E-Mail";
        // Rec."BWK Etax Country ID" := Rec."Country/Region Code";
        // if Country.Get(Rec."Country/Region Code") then begin
        //     Rec."BWK Etax Country Name" := Country.Name;
        // end;

        if Rec."BWK Head Office" then begin
            Rec."BWK Etax Branch Code" := '00000';
        end else begin
            Rec."BWK Etax Branch Code" := "BWK Branch Code";
        end;

        // if StrLen(Rec."AVF_Customer Branch No.") > 5 then begin
        //     Rec."BWK Etax Branch Code" := '00000';
        // end else begin
        //     Rec."BWK Etax Branch Code" := Rec."AVF_Customer Branch No.";
        // end;
    end;
    //End insert 20231124 by NM <<<

    var
        myInt: Integer;
}