tableextension 94001 "BWK  Etax VAT Entry" extends "VAT Entry"
{
    fields
    {
        //Customize Siravich 031023 ASB2310-0034
        field(94000; "BWK Generate E-TAX"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Generate E-TAX';

        }
        field(94001; "BWK Document Type"; Enum "BWK E-Tax Document Type")
        {
            DataClassification = ToBeClassified;
            Caption = 'Document Type';

        }
        field(94002; "BWK End date of Month"; Date)
        {
            DataClassification = ToBeClassified;
            Caption = 'End date of Month';

        }
        //Customize Siravich 031023 ASB2310-0034
    }

    var
        myInt: Integer;
}