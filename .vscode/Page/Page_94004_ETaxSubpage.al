page 94004 "BWK E-Tax Subpage"
{

    PageType = ListPart;
    SourceTable = "BWK E-Tax Line";
    Caption = 'E-Tax Subpage';
    InsertAllowed = false;
    Permissions = tabledata "VAT Entry" = RIMD, tabledata "Sales Invoice Header" = RM;
    RefreshOnActivate = true;
    layout
    {
        area(content)
        {
            repeater("BWK General")
            {
                Caption = 'General';

                field("BWK Etax Select"; Rec."BWK Etax Select")
                {
                    ApplicationArea = All;
                }

                field("BWK Etax Select Non Send Email"; Rec."BWK Etax Select Non Send Email")
                {
                    ApplicationArea = All;
                }
                field("BWK Etax Text File"; Rec."BWK Etax Text File")
                {
                    ApplicationArea = all;
                }
                field("BWK Etax PDF File"; Rec."BWK Etax PDF File")
                {
                    ApplicationArea = all;
                }

                field("BWK Etax PDF Sign File"; Rec."BWK Etax PDF Sign File")
                {
                    ApplicationArea = all;
                }

                field("BWK Etax XML File"; Rec."BWK Etax XML File")
                {
                    ApplicationArea = all;
                }
                field("BWK Document No."; Rec."BWK Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("BWK Tax Invoice No."; Rec."BWK Tax Invoice No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }

                field("BWK Posting Date"; Rec."BWK Posting Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("BWK Customer No."; Rec."BWK Customer No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("BWK Customer Name"; Rec."BWK Customer Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("BWK Customer Address"; Rec."BWK Customer Address")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("BWK Head Office"; Rec."BWK Head Office")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("BWK Branch Code"; Rec."BWK Branch Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("BWK VAT Registration No."; Rec."BWK VAT Registration No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("BWK Amount"; Rec."BWK Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("BWK VAT Amount"; Rec."BWK VAT Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("BWK Amount Incl. VAT"; Rec."BWK Amount Incl. VAT")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("BWK VAT Business Posting Group"; Rec."BWK VAT Business Posting Group")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("BWK VATBWK VAT Prod. Posting Group"; Rec."BWK VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("BWK Source Table"; Rec."BWK Source Table")
                {
                    ApplicationArea = all;
                }

                field("BWK Etax Text file name"; Rec."BWK Etax Text file name")
                {
                    ApplicationArea = all;
                }

                field("BWK Etax PDF file name"; Rec."BWK Etax PDF file name")
                {
                    ApplicationArea = all;
                }

                field("BWK Etax PDF Sign file name"; Rec."BWK Etax PDF Sign file name")
                {
                    ApplicationArea = all;
                }

                field("BWK Etax XML file name"; Rec."BWK Etax XML file name")
                {
                    ApplicationArea = all;
                }

                field("BWK Etax User Export file"; Rec."BWK Etax User Export file")
                {
                    ApplicationArea = all;
                }

                field("BWK Etax DateTime Export file"; Rec."BWK Etax DateTime Export file")
                {
                    ApplicationArea = all;
                }
            }

        }
    }
    actions
    {
        area(Processing)
        {
            group("BWK Function")
            {
                Caption = 'Function';

                action("BWK Export File")
                {
                    Caption = 'Export Text File';
                    ApplicationArea = All;
                    Image = Export;
                    trigger OnAction()
                    var
                        ETaxFunctionCenter: Codeunit "BWK E-Tax Function Center";
                        EtaxLine: Record "BWK E-Tax Line";
                        EtaxLine2: Record "BWK E-Tax Line";
                        GenLedSet: Record "General Ledger Setup";
                        varCount, varExportCount : Integer;
                    begin
                        EtaxLine.Reset();
                        EtaxLine.SetFilter("BWK E-Tax Document Type", '%1', rec."BWK E-Tax Document Type");
                        EtaxLine.SetFilter("BWK End date of Month", '%1', rec."BWK End date of Month");
                        EtaxLine.SetFilter("BWK Source Table", '%1', rec."BWK Source Table");
                        EtaxLine.SetFilter("BWK Etax Select", '%1', true);

                        if EtaxLine.FindFirst() then begin
                            if (EtaxLine."BWK Etax Text File" = true) and (EtaxLine."BWK Etax Select" = true) then begin
                                if Not Confirm('พบเอกสารที่มีการ Export file ไปก่อนหน้า ต้องการ Export file ซ้ำใช่หรือไม่?', false) then begin
                                    exit;
                                end;
                            end;

                            // EtaxLine2.Reset();
                            // EtaxLine2.SetFilter("BWK E-Tax Document Type", '%1', rec."BWK E-Tax Document Type");
                            // EtaxLine2.SetFilter("BWK End date of Month", '%1', rec."BWK End date of Month");
                            // EtaxLine2.SetFilter("BWK Source Table", '%1', rec."BWK Source Table");
                            // EtaxLine2.SetFilter("BWK Etax Text File", '%1', rec."BWK Etax Text File");
                            // EtaxLine2.SetFilter("BWK Etax Select", '%1', rec."BWK Etax Select");
                            // if EtaxLine2.FindFirst() then begin
                            //     varCount := EtaxLine2.count;
                            // end;

                            repeat
                                // if ETaxFunctionCenter."Export Text File"(EtaxLine) then begin
                                EtaxLine."BWK Etax Text File" := true;
                                EtaxLine."BWK Etax PDF File" := true;

                                //     if ETaxFunctionCenter."Export PDF File"(EtaxLine) then begin
                                //         EtaxLine."BWK Etax User Export file" := UserId;
                                //         EtaxLine."BWK Etax DateTime Export file" := CurrentDateTime;
                                //     end;
                                // end;

                                EtaxLine."BWK Etax User Export file" := UserId;
                                EtaxLine."BWK Etax DateTime Export file" := CurrentDateTime;
                                varExportCount := varExportCount + 1;

                                EtaxLine.Modify(true);
                            until EtaxLine.Next = 0;

                            CurrPage.Update(true);

                            Message('ดำเนินการ Export file เรียบร้อยแล้ว จำนวน %1 รายการ', Format(varExportCount));
                        end else begin
                            Message('โปรดเลือกเอกสารอย่างน้อย 1 รายการ');
                        end;
                    end;
                }

                action("BWK Select All")
                {
                    Image = Approve;
                    Caption = 'Select All';
                    ApplicationArea = all;

                    trigger OnAction()
                    var
                        EtaxLine: record "BWK E-Tax Line";
                    begin
                        EtaxLine.Reset();
                        EtaxLine.SetFilter("BWK E-Tax Document Type", '%1', rec."BWK E-Tax Document Type");
                        EtaxLine.SetFilter("BWK Source Table", '%1', rec."BWK Source Table");
                        EtaxLine.SetFilter("BWK Etax Select", '%1', false);

                        if EtaxLine.FindSet() then begin
                            repeat
                                EtaxLine."BWK Etax Select" := true;
                                EtaxLine.Modify(true);
                            until EtaxLine.Next() = 0;
                        end;
                    end;
                }

                action("BWK Clear Select All")
                {
                    Image = Cancel;
                    Caption = 'Clear Select All';
                    ApplicationArea = all;

                    trigger OnAction()
                    var
                        EtaxLine: record "BWK E-Tax Line";
                    begin
                        EtaxLine.Reset();
                        EtaxLine.SetFilter("BWK E-Tax Document Type", '%1', rec."BWK E-Tax Document Type");
                        EtaxLine.SetFilter("BWK Source Table", '%1', rec."BWK Source Table");
                        EtaxLine.SetFilter("BWK Etax Select", '%1', true);

                        if EtaxLine.FindSet() then begin
                            repeat
                                EtaxLine."BWK Etax Select" := false;
                                EtaxLine.Modify(true);
                            until EtaxLine.Next() = 0;
                        end;
                    end;
                }

                action("BWK Open Document")
                {
                    Caption = 'Card';
                    Image = List;
                    ApplicationArea = all;

                    trigger OnAction()
                    var
                        lpagePoSaINV: Page "Posted Sales Invoice";
                        lreSaINVHead: Record "Sales Invoice Header";
                        lpagePoSaCredit: Page "Posted Sales Credit Memo";
                        lrecSaCrHead: Record "Sales Cr.Memo Header";
                        lpagePoGenJour: Page "Posted General Journal";
                        lrecPoGenJourL: Record "Posted Gen. Journal Line";
                        lrecGLRegis: Record "G/L Register";
                    begin
                        if Rec."BWK E-Tax Document Type" = rec."BWK E-Tax Document Type"::INV then begin
                            lreSaINVHead.Reset();
                            lreSaINVHead.SetFilter("No.", '%1', rec."BWK Document No.");
                            if lreSaINVHead.FindFirst() then begin
                                Clear(lpagePoSaINV);
                                lpagePoSaINV.SetTableView(lreSaINVHead);
                                lpagePoSaINV.Run();
                            end;
                        end else
                            if Rec."BWK E-Tax Document Type" = rec."BWK E-Tax Document Type"::DN then begin
                                lreSaINVHead.Reset();
                                lreSaINVHead.SetFilter("No.", '%1', rec."BWK Document No.");
                                if lreSaINVHead.FindFirst() then begin
                                    Clear(lpagePoSaINV);
                                    lpagePoSaINV.SetTableView(lreSaINVHead);
                                    lpagePoSaINV.Run();
                                end;
                            end else
                                if Rec."BWK E-Tax Document Type" = rec."BWK E-Tax Document Type"::CN then begin
                                    lrecSaCrHead.Reset();
                                    lrecSaCrHead.SetFilter("No.", '%1', rec."BWK Document No.");
                                    if lrecSaCrHead.FindFirst() then begin
                                        Clear(lpagePoSaCredit);
                                        lpagePoSaCredit.SetTableView(lrecSaCrHead);
                                        lpagePoSaCredit.Run();
                                    end;
                                end else
                                    if Rec."BWK E-Tax Document Type" = rec."BWK E-Tax Document Type"::RV then begin

                                    end;
                    end;
                }
            }

            group("BWK Print")
            {
                Caption = 'Print';
                action("BWK Preprint Form")
                {
                    Caption = 'Print Form';
                    Image = PrintReport;
                    ApplicationArea = all;
                    trigger OnAction()
                    var
                        lrSalesINVHeader: Record "Sales Invoice Header";
                        lrSalesCrMemoHeader: Record "Sales Cr.Memo Header";
                        lrGLRegister: Record "G/L Register";
                        GenLedSetup: Record "General Ledger Setup";
                        lGLEntry: Record "G/L Entry";
                        ErrorTxt001: Label 'Report ID % 1 not found in table Report Option Setup';
                        ETaxFunctionCenter: Codeunit "BWK E-Tax Function Center";
                    begin
                        // GenLedSetup.Get();

                        // if Rec."BWK E-Tax Document Type" = rec."BWK E-Tax Document Type"::INV then begin
                        //     lrSalesINVHeader.Reset();
                        //     lrSalesINVHeader.SetFilter("No.", '%1', rec."BWK Document No.");
                        //     if lrSalesINVHeader.FindFirst() then begin
                        //         GenLedSetup.TestField("BWK Etax Sales Invoice Form ID");
                        //         Report.RunModal(GenLedSetup."BWK Etax Sales Invoice Form ID", true, true, lrSalesINVHeader);
                        //     end;
                        // end else
                        //     if Rec."BWK E-Tax Document Type" = rec."BWK E-Tax Document Type"::DN then begin
                        //         lrSalesINVHeader.Reset();
                        //         lrSalesINVHeader.SetFilter("No.", '%1', rec."BWK Document No.");
                        //         if lrSalesINVHeader.FindFirst() then begin
                        //             GenLedSetup.TestField("BWK Etax Sales DN Form ID");
                        //             Report.RunModal(GenLedSetup."BWK Etax Sales DN Form ID", true, true, lrSalesINVHeader);
                        //         end;
                        //     end else
                        //         if Rec."BWK E-Tax Document Type" = rec."BWK E-Tax Document Type"::CN then begin
                        //             lrSalesCrMemoHeader.Reset();
                        //             lrSalesCrMemoHeader.SetFilter("No.", '%1', rec."BWK Document No.");
                        //             if lrSalesCrMemoHeader.FindFirst() then begin
                        //                 GenLedSetup.TestField("BWK Etax Sales Cr Memo Form ID");
                        //                 Report.RunModal(GenLedSetup."BWK Etax Sales Cr Memo Form ID", true, true, lrSalesCrMemoHeader);
                        //             end;
                        //         end else
                        //             if Rec."BWK E-Tax Document Type" = rec."BWK E-Tax Document Type"::RV then begin
                        //                 //20240122 >>>
                        //                 DetailCustLedger.Reset();
                        //                 DetailCustLedger.SetRange("Document No.", rec."BWK Document No.");
                        //                 DetailCustLedger.SetRange("Initial Document Type", DetailCustLedger."Initial Document Type"::Invoice);
                        //                 if DetailCustLedger.FindFirst() then begin
                        //                     GenLedSetup.TestField("BWK Etax Sales Receipt Form ID");
                        //                     CustLedger.Reset();
                        //                     CustLedger.SetRange("Entry No.", DetailCustLedger."Cust. Ledger Entry No.");

                        //                     Report.RunModal(GenLedSetup."BWK Etax Sales Receipt Form ID", true, true, CustLedger);
                        //                 end else begin
                        //                     PostedGenJnlLine.Reset();
                        //                     PostedGenJnlLine.SetRange("Document No.", Rec."BWK Document No.");
                        //                     PostedGenJnlLine.SetRange("BWK Deposit", true);
                        //                     if PostedGenJnlLine.Find('-') then begin
                        //                         GenLedSetup.TestField("BWK Etax Rcp Deposit Form ID");
                        //                         Report.RunModal(GenLedSetup."BWK Etax Rcp Deposit Form ID", true, true, PostedGenJnlLine);
                        //                     end;
                        //                 end;
                        //             end;
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        lrecEline: Record "BWK E-Tax Line";
    begin
        lrecEline.Reset();
        lrecEline.SetFilter("BWK Etax Select", '%1', true);
        if lrecEline.FindFirst() then begin
            repeat
                Clear(lrecEline."BWK Etax Select");
                lrecEline.Modify(true);
            until lrecEline.Next() = 0;
        end;

    end;

    // local procedure GetFileStream(FileName: Text; var FileStream: InStream): Boolean
    // var
    //     TempBlob: Codeunit "Temp Blob";
    //     OutStream: OutStream;
    // begin
    //     // Simulate file content (Replace this with real file retrieval)
    //     TempBlob.CreateOutStream(OutStream);
    //     OutStream.WriteText('Dummy content for ' + FileName);
    //     TempBlob.CreateInStream(FileStream);
    //     exit(true);
    // end;

    var
        statuslock: Boolean;
        CustLedger: Record "Cust. Ledger Entry";
        DetailCustLedger: Record "Detailed Cust. Ledg. Entry";
        PostedGenJnlLine: Record "Posted Gen. Journal Line";
}