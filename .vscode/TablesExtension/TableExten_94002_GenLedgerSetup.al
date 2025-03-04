tableextension 94002 "BWK Genaral Ledger Setup" extends "General Ledger Setup"
{
    fields
    {
        // Path Setup
        field(94001; "BWK Export text file"; Text[500])
        {
            DataClassification = CustomerContent;
            Caption = 'BWK Export text file to path';
            Description = 'Etax';
        }

        field(94002; "BWK Export pdf file"; Text[500])
        {
            DataClassification = CustomerContent;
            Caption = 'BWK Export pdf file to path';
            Description = 'Etax';
        }

        field(94003; "BWK Download pdf sign file"; Text[500])
        {
            DataClassification = CustomerContent;
            Caption = 'BWK Download pdf sign file to path';
            Description = 'Etax';
        }

        field(94004; "BWK Download xml file"; Text[500])
        {
            DataClassification = CustomerContent;
            Caption = 'BWK Download xml file to path';
            Description = 'Etax';
        }

        field(94005; "BWK URL text file"; Text[500])
        {
            DataClassification = CustomerContent;
            Caption = 'BWK URL text file to path';
            Description = 'Etax';
        }

        field(94006; "BWK URL pdf file"; Text[500])
        {
            DataClassification = CustomerContent;
            Caption = 'BWK URL pdf file to path';
            Description = 'Etax';
        }

        field(94007; "BWK URL pdf sign file"; Text[500])
        {
            DataClassification = CustomerContent;
            Caption = 'BWK URL pdf sign file to path';
            Description = 'Etax';
        }

        field(94008; "BWK URL xml file"; Text[500])
        {
            DataClassification = CustomerContent;
            Caption = 'BWK URL xml file to path';
            Description = 'Etax';
        }

        // API Setup
        field(94009; "BWK WE-TAX Service URL"; Text[150])
        {
            DataClassification = CustomerContent;
            Caption = 'BWK WE-TAX Service URL';
            Description = 'Etax';
        }

        field(94010; "BWK WE-TAX Access Token"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'BWK WE-TAX Access Token';
            Description = 'Etax';
        }

        field(94011; "BWK POC Service URL"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'BWK POC Service URL';
            Description = 'Etax';
        }

        field(94012; "BWK POC Authorization"; Text[300])
        {
            DataClassification = CustomerContent;
            Caption = 'BWK POC Authorization';
            Description = 'Etax';
        }

        field(94013; "BWK POC Seller Tax ID"; Text[20])
        {
            DataClassification = CustomerContent;
            Caption = 'BWK POC Seller Tax ID';
            Description = 'Etax';
        }

        field(94014; "BWK POC Seller Branch ID"; Text[10])
        {
            DataClassification = CustomerContent;
            Caption = 'BWK POC Seller Branch ID';
            Description = 'Etax';
        }

        field(94015; "BWK POC API Key"; Text[300])
        {
            DataClassification = CustomerContent;
            Caption = 'BWK POC API Key';
            Description = 'Etax';
        }

        field(94016; "BWK POC User Code"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'BWK POC User Code';
            Description = 'Etax';
        }

        field(94017; "BWK POC Access Key"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'BWK POC Access Key';
            Description = 'Etax';
        }

        field(94018; "BWK POC Service Code"; Text[10])
        {
            DataClassification = CustomerContent;
            Caption = 'BWK POC Service Code';
            Description = 'Etax';
        }

        // No. Series Setup
        field(94019; "BWK DN No. Series"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'BWK DN No. Series';
            TableRelation = "No. Series";
        }

        // Form ID Setup
        field(94020; "BWK Etax Sales Invoice Form ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'BWK Etax Sales Invoice Form ID';
            Description = 'Etax';
        }

        field(94021; "BWK Etax Sales DN Form ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'BWK Etax Sales DN Form ID';
            Description = 'Etax';
        }

        field(94022; "BWK Etax Sales Cr Memo Form ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'BWK Etax Sales Cr Memo Form ID';
            Description = 'Etax';
        }

        field(94023; "BWK Etax Sales Receipt Form ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'BWK Etax Sales Receipt Form ID';
            Description = 'Etax';
        }

        field(94024; "BWK Etax Rcp Deposit Form ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'BWK Etax Receipt Deposit Form ID';
            Description = 'Etax';
        }

        field(94025; "BWK Etax Rcp Tax KeyIn Form ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'BWK Etax Receipt Tax KeyIn Form ID';
            Description = 'Etax';
        }
    }

    var
        myInt: Integer;
}