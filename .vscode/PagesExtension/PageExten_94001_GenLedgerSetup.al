pageextension 94001 "BWK General Ledger Setup" extends "General Ledger Setup"
{
    layout
    {
        addlast(content)
        {
            group("E-TAX")
            {
                Visible = vGroupEtax;

                group(PathSetup)
                {
                    Caption = 'Path Setup';

                    field("BWK URL text file"; Rec."BWK URL text file")
                    {
                        ApplicationArea = All;
                        Visible = vURL;
                    }

                    field("BWK URL pdf file"; Rec."BWK URL pdf file")
                    {
                        ApplicationArea = All;
                        Visible = vURL;
                    }

                    field("BWK URL pdf sign file"; Rec."BWK URL pdf sign file")
                    {
                        ApplicationArea = All;
                        Visible = vURL;
                    }

                    field("BWK URL xml file"; Rec."BWK URL xml file")
                    {
                        ApplicationArea = All;
                        Visible = vURL;
                    }

                    field("BWK Export text file"; Rec."BWK Export text file")
                    {
                        ApplicationArea = All;
                        Visible = vPathFile;
                    }

                    field("BWK Export pdf file"; Rec."BWK Export pdf file")
                    {
                        ApplicationArea = All;
                        Visible = vPathFile;
                    }

                    field("BWK Download pdf sign file"; Rec."BWK Download pdf sign file")
                    {
                        ApplicationArea = All;
                        Visible = vPathFile;
                    }

                    field("BWK Download xml file"; Rec."BWK Download xml file")
                    {
                        ApplicationArea = All;
                        Visible = vPathFile;
                    }
                }

                group(APISetup)
                {
                    Caption = 'API Setup';
                    Visible = vGroupAPISetup;

                    field("BWK WE-TAX Service URL"; Rec."BWK WE-TAX Service URL")
                    {
                        ApplicationArea = All;
                    }

                    field(varAccessToken; varAccessToken)
                    {
                        Caption = 'BWK WE-TAX Access Token';
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            if varAccessToken <> txtHideValue then begin
                                Rec."BWK WE-TAX Access Token" := varAccessToken;
                                Rec.Modify();

                                varAccessToken := txtHideValue;
                            end;
                        end;
                    }

                    field("BWK POC Service URL"; Rec."BWK POC Service URL")
                    {
                        ApplicationArea = All;
                    }

                    field(varAuthorize; varAuthorize)
                    {
                        Caption = 'BWK POC Authorization';
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            if varAccessKey <> txtHideValue then begin
                                Rec."BWK POC Authorization" := varAccessKey;
                                Rec.Modify();

                                varAccessKey := txtHideValue;
                            end;
                        end;
                    }

                    field("BWK POC Seller Tax ID"; Rec."BWK POC Seller Tax ID")
                    {
                        ApplicationArea = All;
                    }

                    field("BWK POC Seller Branch ID"; Rec."BWK POC Seller Branch ID")
                    {
                        ApplicationArea = All;
                    }

                    field(varAPIKey; varAPIKey)
                    {
                        Caption = 'BWK POC API Key';
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            if varAPIKey <> txtHideValue then begin
                                Rec."BWK POC API Key" := varAPIKey;
                                Rec.Modify();

                                varAPIKey := txtHideValue;
                            end;
                        end;
                    }

                    field(varUserCode; varUserCode)
                    {
                        Caption = 'BWK POC User Code';
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            if varUserCode <> txtHideValue then begin
                                Rec."BWK POC User Code" := varUserCode;
                                Rec.Modify();

                                varUserCode := txtHideValue;
                            end;
                        end;
                    }

                    field(varAccessKey; varAccessKey)
                    {
                        Caption = 'BWK POC Access Key';
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            if varAccessKey <> txtHideValue then begin
                                Rec."BWK POC Access Key" := varAccessKey;
                                Rec.Modify();

                                varAccessKey := txtHideValue;
                            end;
                        end;
                    }

                    field("BWK POC Service Code"; Rec."BWK POC Service Code")
                    {
                        ApplicationArea = All;
                    }
                }

                group(NoSeriesSetup)
                {
                    Caption = 'No. Series Setup';

                    field("BWK DN No. Series"; Rec."BWK DN No. Series")
                    {
                        ApplicationArea = All;
                    }
                }

                group(FormIDSetup)
                {
                    Caption = 'Form ID Setup';

                    field("BWK Etax Sales Invoice Form ID"; Rec."BWK Etax Sales Invoice Form ID")
                    {
                        ApplicationArea = All;
                    }

                    field("BWK Etax Sales DN Form ID"; Rec."BWK Etax Sales DN Form ID")
                    {
                        ApplicationArea = All;
                    }

                    field("BWK Etax Sales Cr Memo Form ID"; Rec."BWK Etax Sales Cr Memo Form ID")
                    {
                        ApplicationArea = All;
                    }

                    field("BWK Etax Sales Receipt Form ID"; Rec."BWK Etax Sales Receipt Form ID")
                    {
                        ApplicationArea = All;
                    }

                    field("BWK Etax Rcp Deposit Form ID"; Rec."BWK Etax Rcp Deposit Form ID")
                    {
                        ApplicationArea = All;
                    }

                    field("BWK Etax Rcp Tax KeyIn Form ID"; Rec."BWK Etax Rcp Tax KeyIn Form ID")
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        lrAccessControl: Record "Access Control";
    begin
        lrAccessControl.Reset();
        lrAccessControl.SetFilter("User Name", '%1', UserId);
        lrAccessControl.SetFilter("Role ID", 'BWK-E-TAX-CLOUD-GD|BWK-E-TAX-CLOUD-OB|BWK-E-TAX-CLOUD-OD|BWK-E-TAX-LOCAL|BWK-E-TAX-MANUAL');
        if lrAccessControl.FindFirst() then begin
            vGroupEtax := true;

            case lrAccessControl."Role ID" of
                'BWK-E-TAX-CLOUD-GD', 'BWK-E-TAX-CLOUD-OB', 'BWK-E-TAX-CLOUD-OD':
                    begin
                        vGroupAPISetup := true; //เปิดแถบ API Setup
                        vURL := true; //เปิดฟิลด์
                        vPathFile := false; //ปิดฟิลด์
                    end;
                'BWK-E-TAX-LOCAL':
                    begin
                        vGroupAPISetup := true; //เปิดแถบ API Setup
                        vURL := false; //ปิดฟิลด์
                        vPathFile := true; //เปิดฟิลด์
                    end;
                'BWK-E-TAX-MANUAL':
                    begin
                        vGroupAPISetup := false; //ปิดแถบ API Setup
                        vURL := false; //ปิดฟิลด์
                        vPathFile := true; //เปิดฟิลด์
                    end;
                else begin
                    vGroupAPISetup := false;
                end;
            end;
        end else begin
            vGroupEtax := false;
        end;
    end;

    trigger OnAfterGetRecord()
    var
        lrGenLedgerSetup: Record "General Ledger Setup";
    begin
        lrGenLedgerSetup.Get();

        if lrGenLedgerSetup."BWK POC Access Key" <> '' then begin
            varAccessKey := txtHideValue;
        end;

        if lrGenLedgerSetup."BWK POC API Key" <> '' then begin
            varAPIKey := txtHideValue;
        end;

        if lrGenLedgerSetup."BWK POC Authorization" <> '' then begin
            varAuthorize := txtHideValue;
        end;

        if lrGenLedgerSetup."BWK POC User Code" <> '' then begin
            varUserCode := txtHideValue;
        end;
    end;

    var
        myInt: Integer;
        setRoleID: Code[20];
        vGroupEtax, vGroupAPISetup : Boolean;
        vURL, vPathFile : Boolean;
        varAccessToken, varAPIKey, varAuthorize, varUserCode, varAccessKey : Text;
        txtHideValue: Label '**********';
}