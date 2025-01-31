table 94001 "BWK E-Tax Line"
{
    Caption = 'BWK E-Tax Line';
    Permissions = tabledata 254 = rm;

    fields
    {
        field(1; "BWK E-Tax Document Type"; Enum "BWK E-Tax Document Type")
        {
            Editable = false;
            DataClassification = SystemMetadata;
            Caption = 'Document Type';
        }
        field(2; "BWK End date of Month"; Date)
        {
            Caption = 'End date of Month';
            DataClassification = CustomerContent;
        }

        field(3; "BWK Source Table"; Enum "BWK E-Tax Source Table")
        {
            Caption = 'Source Table';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(4; "BWK Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(5; "BWK Tax Invoice No."; Code[20])
        {
            Caption = 'Tax Invoice No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(6; "BWK Posting Date"; Date)
        {
            Editable = false;
            Caption = 'Posting Date';
            DataClassification = SystemMetadata;
        }

        field(7; "BWK Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer."no.";
            DataClassification = CustomerContent;
        }

        field(8; "BWK Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(9; "BWK Customer Address"; Text[500])
        {
            Caption = 'Customer Address';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(10; "BWK Head Office"; Boolean)
        {
            Caption = 'Head Office';
            DataClassification = SystemMetadata;
        }

        field(11; "BWK Branch Code"; Code[5])
        {
            Caption = 'Branch Code';
            DataClassification = SystemMetadata;
        }

        field(12; "BWK VAT Registration No."; Text[20])
        {
            Caption = 'VAT Registration No.';
            DataClassification = SystemMetadata;
        }

        field(14; "BWK Amount"; Decimal)
        {
            Caption = 'Amount';
            DataClassification = SystemMetadata;

        }
        field(15; "BWK VAT Amount"; Decimal)
        {
            Caption = 'VAT Amount';
            DataClassification = SystemMetadata;
        }

        field(16; "BWK Amount Incl. VAT"; Decimal)
        {
            Caption = 'Amount Incl. VAT';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(17; "BWK VAT Business Posting Group"; Code[20])
        {
            TableRelation = "VAT Business Posting Group";
            Caption = 'VAT Business Posting Group';
            DataClassification = SystemMetadata;
        }

        field(18; "BWK Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;

        }

        field(19; "BWK VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
        }

        field(20; "BWK Etax Select Export File"; Boolean)
        {
            Caption = 'Select Export File';
            DataClassification = SystemMetadata;
        }

        field(21; "BWK Etax Export Text File"; Boolean)
        {
            Caption = 'Export Text File';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(22; "BWK Etax Export PDF File"; Boolean)
        {
            Caption = 'Export PDF File';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(23; "BWK Etax User Export Text file"; code[50])
        {
            Caption = 'User Export Text file';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(24; "BWK Etax User Export PDF file"; code[50])
        {
            Caption = 'User Export PDF file';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(25; "BWK Etax DateTime Export Text file"; DateTime)
        {
            Caption = 'DateTime Export Text file';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(26; "BWK Etax DateTime Export PDF file"; DateTime)
        {
            Caption = 'DateTime Export PDF file';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(27; "BWK Etax Text file name"; Text[500])
        {
            Caption = 'Path Text file name';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(28; "BWK Etax PDF file name"; Text[500])
        {
            Caption = 'Path PDF file name';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "BWK E-Tax Document Type", "BWK End date of Month", "BWK Source Table", "BWK Document No.", "BWK Line No.")
        {
        }

    }


    trigger OnDelete()
    var
        Vatentry: Record "VAT Entry";
    begin
        // Rec.TestField("BWK Etax Send File", false);
        // Vatentry.Reset();
        // Vatentry.SetRange("Document No.", Rec."BWK Document No.");
        // Vatentry.SetRange("BWK Generate E-TAX", true);
        // if Vatentry.FindSet() then begin
        //     repeat
        //         Vatentry."BWK Document Type" := Vatentry."BWK Document Type"::" ";
        //         Vatentry."BWK End date of Month" := 0D;
        //         Vatentry."BWK Generate E-TAX" := false;
        //         Vatentry.Modify();
        //     until Vatentry.Next() = 0;
        // end;
    end;
}