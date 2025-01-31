pageextension 94001 "BWK General Ledger Setup" extends "General Ledger Setup"
{
    layout
    {
        addlast(content)
        {
            group("E-TAX")
            {
                group(NoSeriesSetup)
                {
                    Caption = 'No. Series Setup';
                    field("BWK DN No. Series"; Rec."BWK DN No. Series")
                    {
                        ApplicationArea = All;
                    }
                }
                group(PathSetup)
                {
                    Caption = 'Path Setup';

                    field("BWK Etax Export Text File"; Rec."BWK Etax Export Text File")
                    {
                        ApplicationArea = All;

                    }
                    field("BWK Etax Export PDF File"; Rec."BWK Etax Export PDF File")
                    {
                        ApplicationArea = All;

                    }
                    field("BWK Etax Path PDF Sign"; Rec."BWK Etax Path PDF Sign")
                    {
                        ApplicationArea = All;

                    }
                    field("BWK ETAX xml Path"; Rec."BWK ETAX xml Path")
                    {
                        ApplicationArea = All;
                    }
                }
                group(APISetup)
                {
                    Caption = 'API Setup';
                    field("BWK Web Endpoint"; Rec."BWK Web Endpoint")
                    {
                        ApplicationArea = All;
                    }
                    field("BWK I-Net Endpoint"; Rec."BWK I-Net Endpoint")
                    {
                        ApplicationArea = All;
                    }
                    field("BWK Seller Tax ID"; Rec."BWK Seller Tax ID")
                    {
                        ApplicationArea = All;
                    }
                    field("BWK Seller Brance ID"; Rec."BWK Seller Brance ID")
                    {
                        ApplicationArea = All;
                    }
                    // field("BWK API Key"; Rec."BWK API Key")
                    // {
                    //     ApplicationArea = All;
                    //     HideValue = true;
                    // }
                    field(varAPIKey; varAPIKey)
                    {
                        Caption = 'BWK API Key';
                        ApplicationArea = All;
                        trigger OnValidate()
                        begin
                            if varAPIKey <> txtHideValue then begin
                                Rec."BWK API Key" := varAPIKey;
                                Rec.Modify();
                                varAPIKey := txtHideValue;
                            end;
                        end;
                    }
                    field("BWK Use Code"; Rec."BWK User Code")
                    {
                        ApplicationArea = All;
                    }
                    // field("BWK Access Key"; Rec."BWK Access Key")
                    // {
                    //     ApplicationArea = All;
                    //     HideValue = true;
                    // }
                    field(varAccessKey; varAccessKey)
                    {
                        Caption = 'BWK Access Key';
                        ApplicationArea = All;
                        trigger OnValidate()
                        begin
                            if varAccessKey <> txtHideValue then begin
                                Rec."BWK Access Key" := varAccessKey;
                                Rec.Modify();
                                varAccessKey := txtHideValue;
                            end;
                        end;
                    }
                    field("BWK Service Code"; Rec."BWK Service Code")
                    {
                        ApplicationArea = All;
                    }
                    // field("BWK Authorization"; Rec."BWK Authorization")
                    // {
                    //     ApplicationArea = All;
                    //     HideValue = true;
                    // }
                    field(varAuthorize; varAuthorize)
                    {
                        Caption = 'BWK Authorization';
                        ApplicationArea = All;
                        trigger OnValidate()
                        begin
                            if varAuthorize <> txtHideValue then begin
                                Rec."BWK Authorization" := varAuthorize;
                                Rec.Modify();
                                varAuthorize := txtHideValue;
                            end;
                        end;
                    }
                }
                group(FormID)
                {
                    Caption = 'Form ID Setup';

                    field("BWK Etax Sales Invoice Form ID"; Rec."BWK Etax Sales Invoice Form ID")
                    {
                        ApplicationArea = All;
                    }
                    // field("BWK Sales Invoice Form ID GP"; Rec."BWK Sales Invoice Form ID GP")
                    // {
                    //     ApplicationArea = All;
                    // }
                    field("BWK Etax Sales Cr Memo Form ID"; Rec."BWK Etax Sales Cr Memo Form ID")
                    {
                        ApplicationArea = All;
                    }
                    field("BWK Etax Sales DN Form ID"; Rec."BWK Etax Sales DN Form ID")
                    {
                        ApplicationArea = All;
                    }
                    field("BWK Etax Sales Receipt Form ID"; Rec."BWK Etax Sales Receipt Form ID")
                    {
                        ApplicationArea = All;
                    }
                    field("BWK Etax Rec Deposit Form ID"; Rec."BWK Etax Rec Deposit Form ID")
                    {
                        ApplicationArea = All;
                    }
                    field("BWK Etax Rec Tax KeyIn Form ID"; Rec."BWK Etax Rec Tax KeyIn Form ID")
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    trigger OnAfterGetRecord()
    begin
        GetKeyAutholize();
    end;

    procedure GetKeyAutholize()
    var
        GenLedgerSetup: Record "General Ledger Setup";
    begin
        GenLedgerSetup.Get();
        if GenLedgerSetup."BWK Access Key" <> '' then begin
            varAccessKey := txtHideValue;
        end;

        if GenLedgerSetup."BWK API Key" <> '' then begin
            varAPIKey := txtHideValue;
        end;
        if GenLedgerSetup."BWK Authorization" <> '' then begin
            varAuthorize := txtHideValue;
        end;
    end;

    var
        myInt: Integer;
        varAPIKey, varAuthorize, varAccessKey : Text;
        txtHideValue: Label '**********';
}