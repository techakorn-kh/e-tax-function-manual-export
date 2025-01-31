page 94003 "BWK E-Tax Card"
{

    PageType = Document;
    SourceTable = "BWK E-Tax Header";
    Caption = 'E-Tax Card';
    RefreshOnActivate = true;
    DataCaptionExpression = StrSubstNo('[%1] E-Tax เดือน %2 ปี %3', Rec."BWK E-Tax Document Type", Rec."BWK Month Name", Rec."BWK Year No.");
    InsertAllowed = false;
    DeleteAllowed = false;
    Permissions = tabledata "VAT Entry" = RIMD;
    layout
    {
        area(content)
        {
            group("BWK General")
            {
                Caption = 'General';
                //Customize Siravich 031023 ASB2310-0032
                field("BWK E-Tax Document Type"; Rec."BWK E-Tax Document Type")
                {
                    ApplicationArea = all;
                    trigger OnValidate()
                    begin
                        if Rec."BWK E-Tax Document Type" = Rec."BWK E-Tax Document Type"::" " then
                            Error('Document type must be not is empty!');
                    end;
                }
                //Customize Siravich 031023 ASB2310-0032
                field("BWK End date of Month"; Rec."BWK End date of Month")
                {
                    ApplicationArea = All;
                }
                field("BWK Year-Month"; Rec."BWK Year-Month")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("BWK Month No."; Rec."BWK Month No.")
                {
                    ApplicationArea = All;
                }
                field("BWK Month Name"; Rec."BWK Month Name")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }
                field("BWK Year No."; Rec."BWK Year No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                }

                group("BWK Total")
                {
                    Caption = 'Total VAT Amount';

                    field("BWK Total Amount"; Rec."BWK Total Amount")
                    {
                        Editable = false;
                        ApplicationArea = all;
                    }
                    field("BWK Total VAT Amount"; Rec."BWK Total VAT Amount")
                    {
                        Editable = false;
                        ApplicationArea = all;
                    }
                    field("BWK Total Amount Incl. VAT"; Rec."BWK Total Amount Incl. VAT")
                    {
                        Editable = false;
                        ApplicationArea = all;
                    }

                }
            }
            part("BWK ETaxSubpage"; "BWK E-Tax Subpage")
            {
                SubPageView = sorting("BWK E-Tax Document Type", "BWK End date of Month", "BWK Source Table", "BWK Document No.");
                SubPageLink = "BWK E-Tax Document Type" = field("BWK E-Tax Document Type"), "BWK End date of Month" = field("BWK End date of Month");
                ApplicationArea = all;
                UpdatePropagation = Both;
                Editable = Rec."BWK Status Lock" = false;
                Caption = 'E-Tax Subpage';
            }
            group("E-Tax Total")
            {
                field("BWK Etax Total List Line"; Rec."BWK Etax Total List Line")
                {
                    ApplicationArea = all;
                }

                field("BWK Etax Total Export file"; Rec."BWK Etax Total Export file")
                {
                    ApplicationArea = all;
                }

                // field("BWK Etax Total Send file"; Rec."BWK Etax Total Send file")
                // {
                //     ApplicationArea = all;
                // }

                // field("BWK Etax Total Sign file"; Rec."BWK Etax Total Sign file")
                // {
                //     ApplicationArea = all;
                // }

            }
        }

    }
    actions
    {
        area(Reporting)
        {
            // action("BWK Sales Vat Report")
            // {
            //     Caption = 'รายงานภาษีขาย';
            //     ApplicationArea = all;
            //     Promoted = true;
            //     PromotedCategory = Report;
            //     PromotedIsBig = true;
            //     Image = PrintVAT;
            //     trigger OnAction()
            //     var
            //         TaxReportHeader: Record "BWK Tax Report Header";
            //         ReportSalesVat: Report "BWK Sales Vat";
            //     begin

            //         Clear(ReportSalesVat);
            //         TaxReportHeader.Reset();
            //         TaxReportHeader.SetRange("BWK Tax Type", Rec."BWK Tax Type");
            //         TaxReportHeader.SetRange("BWK Document No.", Rec."BWK Document No.");
            //         TaxReportHeader.FindFirst();
            //         ReportSalesVat.SetTableView(TaxReportHeader);
            //         ReportSalesVat.Run();
            //         Clear(ReportSalesVat);
            //     end;
            // }
        }
        area(Processing)
        {
            group("BWK Function")
            {
                Caption = '&Function';
                action("BWK Lock")
                {
                    Caption = 'Lock';
                    ApplicationArea = all;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Image = Lock;
                    trigger OnAction()
                    begin
                        Rec."BWK Status Lock" := true;
                    end;
                }
                action("BWK UnLock")
                {
                    Caption = 'UnLock';
                    ApplicationArea = all;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Image = UnApply;
                    trigger OnAction()
                    begin
                        Rec."BWK Status Lock" := false;
                    end;
                }
                action("BWK Genarate Line")
                {
                    Caption = 'Generate Line';
                    ApplicationArea = all;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Image = UnApply;
                    trigger OnAction()
                    var

                        lrEtaxLine: Record "BWK E-Tax Line";
                        lrEtaxLine2: Record "BWK E-Tax Line";
                        lrEtaxHead: Record "BWK E-Tax Header";
                        lrVATEntry: Record "VAT Entry";
                        lrSalesInvHeader: Record "Sales Invoice Header";
                        lrSalesCrMemoHeader: Record "Sales Cr.Memo Header";
                        lrSalesInvLine: Record "Sales Invoice Line";
                        lrSalesCrMemoLine: Record "Sales Cr.Memo Line";
                        lrPostedGenJournalLine: Record "Posted Gen. Journal Line";
                        lrPostedGenJournalLineDep: Record "Posted Gen. Journal Line";
                        NoSeries: Record "No. Series";
                        GLRegister: Record "G/L Register";
                        Cust: Record Customer;
                        LineNo: Integer;
                        Pos: Integer;
                        VtBus: Record "VAT Business Posting Group";
                        VatEntrySum: Record "VAT Entry";
                        GenLedgerSetup: Record "General Ledger Setup";
                    begin
                        GenLedgerSetup.Get();
                        lrVATEntry.Reset();
                        lrVATEntry.SetFilter("Posting Date", '%1..%2', DMY2DATE(1, Rec."BWK Month No.", Rec."BWK Year No."), Rec."BWK End date of Month");
                        if Rec."BWK E-Tax Document Type" = rec."BWK E-Tax Document Type"::INV then
                            lrVATEntry.SetFilter("Document Type", '%1', lrVATEntry."Document Type"::Invoice);
                        if Rec."BWK E-Tax Document Type" = rec."BWK E-Tax Document Type"::DN then
                            lrVATEntry.SetFilter("Document Type", '%1', lrVATEntry."Document Type"::Invoice);
                        if Rec."BWK E-Tax Document Type" = rec."BWK E-Tax Document Type"::CN then
                            lrVATEntry.SetFilter("Document Type", '%1', lrVATEntry."Document Type"::"Credit Memo");
                        if Rec."BWK E-Tax Document Type" = rec."BWK E-Tax Document Type"::RV then
                            lrVATEntry.SetFilter("Document Type", '%1|%2', lrVATEntry."Document Type"::" ", lrVATEntry."Document Type"::Payment);

                        lrVATEntry.SetFilter("BWK Generate E-TAX", '%1', false);
                        lrVATEntry.SetFilter(Type, '%1', lrVATEntry.Type::Sale);
                        lrVATEntry.SetFilter(Base, '<>%1', 0);
                        lrVATEntry.SetFilter(Amount, '<>%1', 0);
                        if lrVATEntry.FindFirst() then begin
                            repeat
                                case lrVATEntry."Document Type" of
                                    lrVATEntry."Document Type"::Invoice:
                                        begin
                                            clear(Pos);
                                            lrEtaxHead.Reset();
                                            lrEtaxHead.SetFilter("BWK E-Tax Document Type", '%1', rec."BWK E-Tax Document Type");
                                            lrEtaxHead.SetRange("BWK End date of Month", Rec."BWK End date of Month");
                                            if lrEtaxHead.FindFirst() then begin
                                                if lrEtaxHead."BWK E-Tax Document Type" = rec."BWK E-Tax Document Type"::INV then begin
                                                    Pos := StrPos(lrVATEntry."Document No.", 'DR');
                                                    if (lrVATEntry."Source Code" = 'SALES') and (Pos = 0) then begin
                                                        lrEtaxLine.Reset();
                                                        lrEtaxLine.SetRange("BWK E-Tax Document Type", lrEtaxHead."BWK E-Tax Document Type");
                                                        lrEtaxLine.SetRange("BWK End date of Month", lrEtaxHead."BWK End date of Month");
                                                        lrEtaxLine.SetRange("BWK Document No.", lrVATEntry."Document No.");
                                                        if lrEtaxLine.FindFirst() then begin
                                                            lrEtaxLine."BWK Amount" += lrVATEntry.Base * -1;
                                                            lrEtaxLine."BWK VAT Amount" += lrVATEntry.Amount * -1;
                                                            lrEtaxLine."BWK Amount Incl. VAT" := lrEtaxLine."BWK Amount" + lrEtaxLine."BWK VAT Amount";//Insert 20231124 by NM for ASB2311-0344
                                                            lrEtaxLine.Modify();

                                                            lrVATEntry."BWK Document Type" := Rec."BWK E-Tax Document Type";
                                                            lrVATEntry."BWK End date of Month" := Rec."BWK End date of Month";
                                                            lrVATEntry."BWK Generate E-TAX" := true;
                                                            lrVATEntry.Modify(true);
                                                        end else begin
                                                            lrEtaxLine2.Init();
                                                            lrEtaxLine2.Validate("BWK Source Table", lrEtaxLine2."BWK Source Table"::"Sales Invoice Header");
                                                            lrEtaxLine2.Validate("BWK E-Tax Document Type", Rec."BWK E-Tax Document Type");
                                                            lrEtaxLine2.Validate("BWK End date of Month", Rec."BWK End date of Month");
                                                            lrEtaxLine2.Validate("BWK Document No.", lrVATEntry."Document No.");
                                                            lrEtaxLine2."BWK Line No." += 1;
                                                            lrEtaxLine2."BWK Amount" := lrVATEntry.Base * -1;
                                                            lrEtaxLine2."BWK VAT Amount" := lrVATEntry.Amount * -1;
                                                            lrEtaxLine2."BWK Amount Incl. VAT" := lrEtaxLine2."BWK Amount" + lrEtaxLine2."BWK VAT Amount";//Insert 20231124 by NM for ASB2311-0344
                                                            lrEtaxLine2.Validate("BWK Posting Date", lrVATEntry."Posting Date");
                                                            lrEtaxLine2.Validate("BWK VAT Business Posting Group", lrVATEntry."VAT Bus. Posting Group");
                                                            lrEtaxLine2.Validate("BWK Customer No.", lrVATEntry."Bill-to/Pay-to No.");
                                                            if not lrSalesInvHeader.get(lrVATEntry."Document No.") then begin
                                                                lrSalesInvHeader.Init();
                                                            end;
                                                            lrEtaxLine2.Validate("BWK Customer Name", lrSalesInvHeader."Sell-to Customer Name");

                                                            //Customize BW.TK ASB2312-0151 2023-12-20
                                                            lrEtaxLine2.Validate("BWK VAT Prod. Posting Group", lrVATEntry."VAT Prod. Posting Group");
                                                            //Customize BW.TK ASB2312-0151 2023-12-20

                                                            //Customize BW.WW ASB2311-0162
                                                            VtBus.Reset();
                                                            VtBus.SetFilter(Code, '%1', lrSalesInvHeader."VAT Bus. Posting Group");
                                                            if VtBus.FindFirst() then begin
                                                                if VtBus."BWK Head Office" then begin
                                                                    lrEtaxLine2.Validate("BWK Branch Code", '');
                                                                    lrEtaxLine2.Validate("BWK Head Office", true);
                                                                end else begin
                                                                    lrEtaxLine2.Validate("BWK Branch Code", VtBus."BWK Branch Code");
                                                                    lrEtaxLine2.Validate("BWK Head Office", false);
                                                                end;
                                                            end;
                                                            //Customize BW.WW ASB2311-0162   
                                                            lrEtaxLine2."BWK VAT Registration No." := lrSalesInvHeader."VAT Registration No.";
                                                            lrEtaxLine2."BWK Customer Address" := lrSalesInvHeader."Sell-to Address";
                                                            lrEtaxLine2."BWK Customer Address" += ' ' + lrSalesInvHeader."Sell-to Address 2";
                                                            lrEtaxLine2."BWK Customer Address" += ' ' + lrSalesInvHeader."Sell-to City";
                                                            lrEtaxLine2."BWK Customer Address" += ' ' + lrSalesInvHeader."Sell-to Post Code";
                                                            lrEtaxLine2.Insert(true);

                                                            lrVATEntry."BWK Document Type" := Rec."BWK E-Tax Document Type";
                                                            lrVATEntry."BWK End date of Month" := Rec."BWK End date of Month";
                                                            lrVATEntry."BWK Generate E-TAX" := true;
                                                            lrVATEntry.Modify(true);
                                                            // end;
                                                        end;
                                                        /*
                                                        lrSalesInvHeader.Reset();
                                                        lrSalesInvHeader.SetFilter("No.", '%1', lrVATEntry."Document No.");
                                                        if lrSalesInvHeader.FindFirst() then begin
                                                            lrSalesInvLine.Reset();
                                                            lrSalesInvLine.SetFilter("Document No.", '%1', lrSalesInvHeader."No.");
                                                            if lrSalesInvLine.FindFirst() then begin
                                                                lrEtaxLine.Init();
                                                                lrEtaxLine.Validate("BWK Source Table", lrEtaxLine."BWK Source Table"::"Sales Invoice Header");
                                                                lrEtaxLine.Validate("BWK E-Tax Document Type", Rec."BWK E-Tax Document Type");
                                                                lrEtaxLine.Validate("BWK End date of Month", Rec."BWK End date of Month");
                                                                lrEtaxLine.Validate("BWK Document No.", lrVATEntry."Document No.");

                                                                lrEtaxLine2.Reset();
                                                                lrEtaxLine2.SetFilter("BWK E-Tax Document Type", '%1', lrEtaxLine."BWK E-Tax Document Type");
                                                                lrEtaxLine2.SetFilter("BWK End date of Month", '%1', lrEtaxLine."BWK End date of Month");
                                                                lrEtaxLine2.SetFilter("BWK Source Table", '%1', lrEtaxLine."BWK Source Table");
                                                                lrEtaxLine2.SetFilter("BWK Document No.", '%1', lrEtaxLine."BWK Document No.");

                                                                if lrEtaxLine2.FindLast() then
                                                                    LineNo := lrEtaxLine2."BWK Line No.";

                                                                VatEntrySum.Reset();
                                                                VatEntrySum.SetFilter("Document Type", '%1', lrVATEntry."Document Type");
                                                                VatEntrySum.SetFilter("Type", '%1', lrVATEntry."Type");
                                                                VatEntrySum.SetFilter("Document No.", '%1', lrVATEntry."Document No.");
                                                                if VatEntrySum.FindFirst() then begin
                                                                    VatEntrySum.CalcSums(Amount, Base);
                                                                    lrEtaxLine."BWK Amount" := lrVATEntry.Base * -1;
                                                                    lrEtaxLine."BWK VAT Amount" := lrVATEntry.Amount * -1;
                                                                end;
                                                                //lrSalesInvLine.CalcSums("Amount Including VAT");
                                                                //lrEtaxLine."BWK Amount Incl. VAT" := lrSalesInvLine."Amount Including VAT";
                                                                lrEtaxLine."BWK Amount Incl. VAT" := lrEtaxLine."BWK Amount" + lrEtaxLine."BWK VAT Amount";//Insert 20231124 by NM for ASB2311-0344
                                                                lrEtaxLine.Validate("BWK Posting Date", lrVATEntry."Posting Date");
                                                                lrEtaxLine.Validate("BWK VAT Business Posting Group", lrVATEntry."VAT Bus. Posting Group");
                                                                lrEtaxLine.Validate("BWK Customer No.", lrVATEntry."Bill-to/Pay-to No.");
                                                                lrEtaxLine.Validate("BWK Line No.", LineNo + 1);
                                                                lrEtaxLine.Validate("BWK Customer Name", lrSalesInvHeader."Bill-to Name");

                                                                //Customize BW.TK ASB2312-0151 2023-12-20
                                                                lrEtaxLine.Validate("BWK VAT Prod. Posting Group", lrVATEntry."VAT Prod. Posting Group");
                                                                //Customize BW.TK ASB2312-0151 2023-12-20

                                                                //Customize BW.WW ASB2311-0162
                                                                VtBus.Reset();
                                                                VtBus.SetFilter(Code, '%1', lrSalesInvHeader."VAT Bus. Posting Group");
                                                                if VtBus.FindFirst() then begin
                                                                    if VtBus."BWK Head Office" then begin
                                                                        lrEtaxLine.Validate("BWK Branch Code", '');
                                                                        lrEtaxLine.Validate("BWK Head Office", true);
                                                                    end else begin
                                                                        lrEtaxLine.Validate("BWK Branch Code", VtBus."BWK Branch Code");
                                                                        lrEtaxLine.Validate("BWK Head Office", false);
                                                                    end;
                                                                end;
                                                                //Customize BW.WW ASB2311-0162   
                                                                lrEtaxLine."BWK VAT Registration No." := lrSalesInvHeader."VAT Registration No.";
                                                                lrEtaxLine."BWK Customer Address" := lrSalesInvHeader."Sell-to Address";
                                                                lrEtaxLine."BWK Customer Address" += ' ' + lrSalesInvHeader."Sell-to Address 2";
                                                                lrEtaxLine."BWK Customer Address" += ' ' + lrSalesInvHeader."Sell-to City";
                                                                lrEtaxLine."BWK Customer Address" += ' ' + lrSalesInvHeader."Sell-to Post Code";
                                                                lrEtaxLine.Insert(true);
                                                                // end;
                                                            end;
                                                        end;
                                                        */
                                                    end;
                                                end
                                                else
                                                    if lrEtaxHead."BWK E-Tax Document Type" = rec."BWK E-Tax Document Type"::DN then begin
                                                        GenLedgerSetup.TestField("BWK DN No. Series");//20240122 by NM
                                                        //Pos := StrPos(lrVATEntry."Document No.", 'DR');
                                                        Pos := StrPos(lrVATEntry."No. Series", GenLedgerSetup."BWK DN No. Series");
                                                        if (lrVATEntry."Source Code" = 'SALES') and (Pos = 1) then begin
                                                            lrSalesInvHeader.Reset();
                                                            lrSalesInvHeader.SetFilter("No.", '%1', lrVATEntry."Document No.");
                                                            if lrSalesInvHeader.FindFirst() then begin
                                                                lrSalesInvLine.Reset();
                                                                lrSalesInvLine.SetFilter("Document No.", '%1', lrSalesInvHeader."No.");
                                                                if lrSalesInvLine.FindFirst() then begin
                                                                    lrEtaxLine.Init();
                                                                    lrEtaxLine.Validate("BWK Source Table", lrEtaxLine."BWK Source Table"::"Sales Invoice Header");
                                                                    lrEtaxLine.Validate("BWK E-Tax Document Type", Rec."BWK E-Tax Document Type");
                                                                    lrEtaxLine.Validate("BWK End date of Month", Rec."BWK End date of Month");
                                                                    lrEtaxLine.Validate("BWK Document No.", lrVATEntry."Document No.");

                                                                    lrEtaxLine2.Reset();
                                                                    lrEtaxLine2.SetFilter("BWK E-Tax Document Type", '%1', lrEtaxLine."BWK E-Tax Document Type");
                                                                    lrEtaxLine2.SetFilter("BWK End date of Month", '%1', lrEtaxLine."BWK End date of Month");
                                                                    lrEtaxLine2.SetFilter("BWK Source Table", '%1', lrEtaxLine."BWK Source Table");
                                                                    lrEtaxLine2.SetFilter("BWK Document No.", '%1', lrEtaxLine."BWK Document No.");
                                                                    if lrEtaxLine2.FindLast() then
                                                                        LineNo := lrEtaxLine2."BWK Line No.";

                                                                    VatEntrySum.Reset();
                                                                    VatEntrySum.SetFilter("Document Type", '%1', lrVATEntry."Document Type");
                                                                    VatEntrySum.SetFilter("Type", '%1', lrVATEntry."Type");
                                                                    VatEntrySum.SetFilter("Document No.", '%1', lrVATEntry."Document No.");
                                                                    if VatEntrySum.FindFirst() then begin
                                                                        VatEntrySum.CalcSums(Amount, Base);
                                                                        lrEtaxLine."BWK Amount" := lrVATEntry.Base * -1;
                                                                        lrEtaxLine."BWK VAT Amount" := lrVATEntry.Amount * -1;
                                                                    end;
                                                                    lrSalesInvLine.CalcSums("Amount Including VAT");
                                                                    lrEtaxLine."BWK Amount Incl. VAT" := lrSalesInvLine."Amount Including VAT";
                                                                    lrEtaxLine.Validate("BWK Line No.", LineNo + 1);
                                                                    //Customize BW.WW ASB2311-0162
                                                                    VtBus.Reset();
                                                                    VtBus.SetFilter(Code, '%1', lrSalesInvHeader."VAT Bus. Posting Group");
                                                                    if VtBus.FindFirst() then begin
                                                                        if VtBus."BWK Head Office" then begin
                                                                            lrEtaxLine.Validate("BWK Branch Code", '');
                                                                            lrEtaxLine.Validate("BWK Head Office", true);
                                                                        end else begin
                                                                            lrEtaxLine.Validate("BWK Branch Code", VtBus."BWK Branch Code");
                                                                            lrEtaxLine.Validate("BWK Head Office", false);
                                                                        end;
                                                                        //Lek รอสอบถามลูกค้าเกี่ยวกับ LCL ของลูกค้าว่าบันทึกสาขาแบบไหน
                                                                        // if StrLen(VtBus."AVF_Branch No.") > 5 then begin
                                                                        //     lrEtaxLine.Validate("BWK Branch Code", '');
                                                                        //     lrEtaxLine.Validate("BWK Head Office", true);
                                                                        // end else begin
                                                                        //     lrEtaxLine.Validate("BWK Branch Code", VtBus."AVF_Branch No.");
                                                                        //     lrEtaxLine.Validate("BWK Head Office", VtBus."AVF_Default Head Office");
                                                                        // end;
                                                                        //Lek รอสอบถามลูกค้าเกี่ยวกับ LCL ของลูกค้าว่าบันทึกสาขาแบบไหน
                                                                    end;

                                                                    //Customize BW.TK ASB2312-0152 2023-12-20
                                                                    lrEtaxLine.Validate("BWK VAT Prod. Posting Group", lrVATEntry."VAT Prod. Posting Group");
                                                                    //Customize BW.TK ASB2312-0152 2023-12-20

                                                                    //Customize BW.WW ASB2311-0162   
                                                                    lrEtaxLine.Validate("BWK Line No.", LineNo + 1);
                                                                    lrEtaxLine.Validate("BWK Posting Date", lrVATEntry."Posting Date");
                                                                    lrEtaxLine.Validate("BWK VAT Business Posting Group", lrVATEntry."VAT Bus. Posting Group");
                                                                    lrEtaxLine.Validate("BWK Customer No.", lrVATEntry."Bill-to/Pay-to No.");
                                                                    lrEtaxLine.Validate("BWK Customer Name", lrSalesInvHeader."Bill-to Name");
                                                                    lrEtaxLine."BWK VAT Registration No." := lrSalesInvHeader."VAT Registration No.";
                                                                    lrEtaxLine."BWK Customer Address" := lrSalesInvHeader."Sell-to Address";
                                                                    lrEtaxLine."BWK Customer Address" += ' ' + lrSalesInvHeader."Sell-to Address 2";
                                                                    lrEtaxLine."BWK Customer Address" += ' ' + lrSalesInvHeader."Sell-to City";
                                                                    lrEtaxLine."BWK Customer Address" += ' ' + lrSalesInvHeader."Sell-to Post Code";
                                                                    lrEtaxLine.Insert(true);

                                                                    lrVATEntry."BWK Document Type" := Rec."BWK E-Tax Document Type";
                                                                    lrVATEntry."BWK End date of Month" := Rec."BWK End date of Month";
                                                                    lrVATEntry."BWK Generate E-TAX" := true;
                                                                    lrVATEntry.Modify(true);
                                                                    // end;
                                                                end;
                                                            end;
                                                        end;
                                                    end;
                                            end;
                                        end;
                                    lrVATEntry."Document Type"::"Credit Memo":
                                        begin
                                            if (lrVATEntry."Source Code" = 'SALES') then begin
                                                lrSalesCrMemoHeader.Reset();
                                                lrSalesCrMemoHeader.SetFilter("No.", '%1', lrVATEntry."Document No.");
                                                if lrSalesCrMemoHeader.FindFirst() then begin
                                                    lrSalesCrMemoLine.Reset();
                                                    lrSalesCrMemoLine.SetFilter("Document No.", '%1', lrSalesCrMemoHeader."No.");
                                                    if lrSalesCrMemoLine.FindFirst() then begin
                                                        lrEtaxLine.Init();
                                                        lrEtaxLine.Validate("BWK Source Table", lrEtaxLine."BWK Source Table"::"Sales Cr.Memo Header");
                                                        lrEtaxLine.Validate("BWK E-Tax Document Type", Rec."BWK E-Tax Document Type");
                                                        lrEtaxLine.Validate("BWK End date of Month", Rec."BWK End date of Month");
                                                        lrEtaxLine.Validate("BWK Document No.", lrVATEntry."Document No.");

                                                        lrEtaxLine2.Reset();
                                                        lrEtaxLine2.SetFilter("BWK E-Tax Document Type", '%1', lrEtaxLine."BWK E-Tax Document Type");
                                                        lrEtaxLine2.SetFilter("BWK End date of Month", '%1', lrEtaxLine."BWK End date of Month");
                                                        lrEtaxLine2.SetFilter("BWK Source Table", '%1', lrEtaxLine."BWK Source Table");
                                                        lrEtaxLine2.SetFilter("BWK Document No.", '%1', lrEtaxLine."BWK Document No.");

                                                        if lrEtaxLine2.FindLast() then
                                                            LineNo := lrEtaxLine2."BWK Line No.";

                                                        VatEntrySum.Reset();
                                                        VatEntrySum.SetFilter("Document Type", '%1', lrVATEntry."Document Type");
                                                        VatEntrySum.SetFilter("Type", '%1', lrVATEntry."Type");
                                                        VatEntrySum.SetFilter("Document No.", '%1', lrVATEntry."Document No.");

                                                        if VatEntrySum.FindFirst() then begin
                                                            VatEntrySum.CalcSums(Amount, Base);
                                                            lrEtaxLine."BWK Amount" := VatEntrySum.Base * -1;
                                                            lrEtaxLine."BWK VAT Amount" := VatEntrySum.Amount * -1;
                                                        end;
                                                        //lrSalesCrMemoHeader.CalcSums("Amount Including VAT");
                                                        //lrEtaxLine."BWK Amount Incl. VAT" := lrSalesCrMemoHeader."Amount Including VAT";
                                                        lrEtaxLine."BWK Amount Incl. VAT" := lrEtaxLine."BWK Amount" + lrEtaxLine."BWK VAT Amount";//Insert 20231124 by NM
                                                        lrEtaxLine.Validate("BWK Line No.", LineNo + 1);
                                                        //Customize BW.WW ASB2311-0162
                                                        VtBus.Reset();
                                                        VtBus.SetFilter(Code, '%1', lrSalesCrMemoHeader."VAT Bus. Posting Group");

                                                        if VtBus.FindFirst() then begin
                                                            if VtBus."BWK Head Office" then begin
                                                                lrEtaxLine.Validate("BWK Branch Code", '');
                                                                lrEtaxLine.Validate("BWK Head Office", true);
                                                            end else begin
                                                                lrEtaxLine.Validate("BWK Branch Code", VtBus."BWK Branch Code");
                                                                lrEtaxLine.Validate("BWK Head Office", false);
                                                            end;
                                                            //Lek รอสอบถามลูกค้าเกี่ยวกับ LCL ของลูกค้าว่าบันทึกสาขาแบบไหน
                                                            // if StrLen(VtBus."AVF_Branch No.") > 5 then begin
                                                            //     lrEtaxLine.Validate("BWK Branch Code", '');
                                                            //     lrEtaxLine.Validate("BWK Head Office", true);
                                                            // end else begin
                                                            //     lrEtaxLine.Validate("BWK Branch Code", VtBus."AVF_Branch No.");
                                                            //     lrEtaxLine.Validate("BWK Head Office", VtBus."AVF_Default Head Office");
                                                            // end;
                                                            //Lek รอสอบถามลูกค้าเกี่ยวกับ LCL ของลูกค้าว่าบันทึกสาขาแบบไหน
                                                        end;

                                                        //Customize BW.WW ASB2311-0162   
                                                        lrEtaxLine.Validate("BWK Line No.", LineNo + 1);
                                                        lrEtaxLine.Validate("BWK Posting Date", lrVATEntry."Posting Date");
                                                        lrEtaxLine.Validate("BWK VAT Business Posting Group", lrVATEntry."VAT Bus. Posting Group");
                                                        lrEtaxLine.Validate("BWK Customer No.", lrVATEntry."Bill-to/Pay-to No.");

                                                        //Customize BW.TK ASB2312-0153 2023-12-20
                                                        lrEtaxLine.Validate("BWK VAT Prod. Posting Group", lrVATEntry."VAT Prod. Posting Group");
                                                        //Customize BW.TK ASB2312-0153 2023-12-20

                                                        lrEtaxLine."BWK VAT Registration No." := lrSalesCrMemoHeader."VAT Registration No.";
                                                        lrEtaxLine."BWK Customer Name" := lrSalesCrMemoHeader."Sell-to Customer Name";
                                                        lrEtaxLine."BWK Customer Address" := lrSalesCrMemoHeader."Sell-to Address";
                                                        lrEtaxLine."BWK Customer Address" += ' ' + lrSalesCrMemoHeader."Sell-to Address 2";
                                                        lrEtaxLine."BWK Customer Address" += ' ' + lrSalesCrMemoHeader."Sell-to City";
                                                        lrEtaxLine."BWK Customer Address" += ' ' + lrSalesCrMemoHeader."Sell-to Post Code";

                                                        lrEtaxLine.Insert(true);

                                                        lrVATEntry."BWK Document Type" := Rec."BWK E-Tax Document Type";
                                                        lrVATEntry."BWK End date of Month" := Rec."BWK End date of Month";
                                                        lrVATEntry."BWK Generate E-TAX" := true;
                                                        lrVATEntry.Modify(true);
                                                    end;
                                                end;
                                            end;
                                        end;
                                    lrVATEntry."Document Type"::" ":
                                        begin
                                            if lrVATEntry."Source Code" = 'CASHRECJNL' then begin
                                                lrPostedGenJournalLine.Reset();
                                                lrPostedGenJournalLine.SetFilter("Document No.", '%1', lrVATEntry."Document No.");
                                                if lrPostedGenJournalLine.FindFirst() then begin
                                                    Cust.Reset();
                                                    Cust.SetFilter("No.", '%1', lrVATEntry."Bill-to/Pay-to No.");
                                                    if Cust.FindFirst() then begin
                                                        lrEtaxLine2.Reset();
                                                        lrEtaxLine2.SetFilter("BWK E-Tax Document Type", '%1', lrEtaxLine."BWK E-Tax Document Type");
                                                        lrEtaxLine2.SetFilter("BWK End date of Month", '%1', lrEtaxLine."BWK End date of Month");
                                                        lrEtaxLine2.SetFilter("BWK Source Table", '%1', lrEtaxLine."BWK Source Table");
                                                        lrEtaxLine2.SetFilter("BWK Document No.", '%1', lrEtaxLine."BWK Document No.");
                                                        if lrEtaxLine2.FindLast() then begin
                                                            LineNo := lrEtaxLine2."BWK Line No.";
                                                            lrEtaxLine2."BWK Amount" += lrVATEntry.Base * -1;
                                                            lrEtaxLine2."BWK VAT Amount" += lrVATEntry.Amount * -1;
                                                            lrEtaxLine2.Validate("BWK Posting Date", lrVATEntry."Posting Date");
                                                            lrEtaxLine2.Validate("BWK VAT Business Posting Group", lrVATEntry."VAT Bus. Posting Group");
                                                            lrEtaxLine2.Validate("BWK Customer No.", lrVATEntry."Bill-to/Pay-to No.");
                                                            lrEtaxLine2.Modify(true);

                                                            lrVATEntry."BWK Document Type" := Rec."BWK E-Tax Document Type";
                                                            lrVATEntry."BWK End date of Month" := Rec."BWK End date of Month";
                                                            lrVATEntry."BWK Generate E-TAX" := true;
                                                            lrVATEntry.Modify(true);
                                                        end
                                                        else begin
                                                            lrEtaxLine.Init();
                                                            lrEtaxLine.Validate("BWK Source Table", lrEtaxLine."BWK Source Table"::"Posted Gen. Journal Line");
                                                            lrEtaxLine.Validate("BWK E-Tax Document Type", Rec."BWK E-Tax Document Type");
                                                            lrEtaxLine.Validate("BWK End date of Month", Rec."BWK End date of Month");
                                                            lrEtaxLine.Validate("BWK Document No.", lrVATEntry."Document No.");
                                                            lrEtaxLine.Validate("BWK Line No.", LineNo + 1);
                                                            lrEtaxLine.Validate("BWK Posting Date", lrVATEntry."Posting Date");
                                                            lrEtaxLine.Validate("BWK VAT Business Posting Group", lrVATEntry."VAT Bus. Posting Group");
                                                            lrEtaxLine.Validate("BWK VAT Amount", lrVATEntry.Amount * -1);
                                                            lrEtaxLine.Validate("BWK Customer No.", lrVATEntry."Bill-to/Pay-to No.");
                                                            lrEtaxLine.Validate("BWK Amount", lrVATEntry.Base * -1);
                                                            lrEtaxLine."BWK Customer Name" := Cust.Name;
                                                            lrEtaxLine."BWK VAT Registration No." := Cust."VAT Registration No.";
                                                            lrEtaxLine."BWK Customer Address" := Cust.Address;
                                                            lrEtaxLine."BWK Customer Address" += ' ' + Cust."Address 2";
                                                            lrEtaxLine."BWK Customer Address" += ' ' + Cust.City;
                                                            lrEtaxLine."BWK Customer Address" += ' ' + Cust."Post Code";
                                                            lrEtaxLine."BWK Amount Incl. VAT" := lrEtaxLine."BWK Amount" + lrEtaxLine."BWK VAT Amount";

                                                            //Customize BW.TK ASB2312-0156 2023-12-20
                                                            lrEtaxLine.Validate("BWK VAT Prod. Posting Group", lrVATEntry."VAT Prod. Posting Group");
                                                            //Customize BW.TK ASB2312-0156 2023-12-20

                                                            //Customize BW.WW ASB2311-0162
                                                            VtBus.Reset();
                                                            VtBus.SetFilter(Code, '%1', lrVATEntry."VAT Bus. Posting Group");
                                                            if VtBus.FindFirst() then begin
                                                                if VtBus."BWK Head Office" then begin
                                                                    lrEtaxLine.Validate("BWK Branch Code", '');
                                                                    lrEtaxLine.Validate("BWK Head Office", true);
                                                                end else begin
                                                                    lrEtaxLine.Validate("BWK Branch Code", VtBus."BWK Branch Code");
                                                                    lrEtaxLine.Validate("BWK Head Office", false);
                                                                end;
                                                            end;
                                                            //Customize BW.WW ASB2311-0162  

                                                            lrEtaxLine.Insert(true);
                                                            // lrEtaxLine.Modify(true);

                                                            lrVATEntry."BWK Document Type" := Rec."BWK E-Tax Document Type";
                                                            lrVATEntry."BWK End date of Month" := Rec."BWK End date of Month";
                                                            lrVATEntry."BWK Generate E-TAX" := true;
                                                            lrVATEntry.Modify(true);
                                                        end;
                                                    end else begin
                                                        lrPostedGenJournalLineDep.Reset();
                                                        lrPostedGenJournalLineDep.SetRange("Document No.", lrVATEntry."Document No.");
                                                        lrPostedGenJournalLineDep.SetRange("BWK Deposit", true);
                                                        if lrPostedGenJournalLineDep.FindFirst() then begin
                                                            Cust.Reset();
                                                            Cust.SetFilter("No.", '%1', lrPostedGenJournalLineDep."BWK Deposit Of Card");
                                                            if Cust.FindFirst() then begin
                                                                lrEtaxLine2.Reset();
                                                                lrEtaxLine2.SetFilter("BWK E-Tax Document Type", '%1', lrEtaxLine."BWK E-Tax Document Type");
                                                                lrEtaxLine2.SetFilter("BWK End date of Month", '%1', lrEtaxLine."BWK End date of Month");
                                                                lrEtaxLine2.SetFilter("BWK Source Table", '%1', lrEtaxLine."BWK Source Table");
                                                                lrEtaxLine2.SetFilter("BWK Document No.", '%1', lrEtaxLine."BWK Document No.");
                                                                if lrEtaxLine2.FindLast() then begin
                                                                    LineNo := lrEtaxLine2."BWK Line No.";
                                                                    lrEtaxLine2."BWK Amount" += lrVATEntry.Base * -1;
                                                                    lrEtaxLine2."BWK VAT Amount" += lrVATEntry.Amount * -1;
                                                                    lrEtaxLine2.Validate("BWK Posting Date", lrVATEntry."Posting Date");
                                                                    lrEtaxLine2.Validate("BWK VAT Business Posting Group", lrVATEntry."VAT Bus. Posting Group");
                                                                    lrEtaxLine2.Validate("BWK Customer No.", lrPostedGenJournalLineDep."BWK Deposit Of Card");
                                                                    lrEtaxLine2.Modify(true);

                                                                    lrVATEntry."BWK Document Type" := Rec."BWK E-Tax Document Type";
                                                                    lrVATEntry."BWK End date of Month" := Rec."BWK End date of Month";
                                                                    lrVATEntry."BWK Generate E-TAX" := true;
                                                                    lrVATEntry.Modify(true);
                                                                end
                                                                else begin
                                                                    lrEtaxLine.Init();
                                                                    lrEtaxLine.Validate("BWK Source Table", lrEtaxLine."BWK Source Table"::"Posted Gen. Journal Line");
                                                                    lrEtaxLine.Validate("BWK E-Tax Document Type", Rec."BWK E-Tax Document Type");
                                                                    lrEtaxLine.Validate("BWK End date of Month", Rec."BWK End date of Month");
                                                                    lrEtaxLine.Validate("BWK Document No.", lrVATEntry."Document No.");
                                                                    lrEtaxLine.Validate("BWK Line No.", LineNo + 1);
                                                                    lrEtaxLine.Validate("BWK Posting Date", lrVATEntry."Posting Date");
                                                                    lrEtaxLine.Validate("BWK VAT Business Posting Group", lrVATEntry."VAT Bus. Posting Group");
                                                                    lrEtaxLine.Validate("BWK VAT Amount", lrVATEntry.Amount * -1);
                                                                    lrEtaxLine.Validate("BWK Customer No.", lrPostedGenJournalLineDep."BWK Deposit Of Card");
                                                                    lrEtaxLine.Validate("BWK Amount", lrVATEntry.Base * -1);
                                                                    lrEtaxLine."BWK Customer Name" := Cust.Name;
                                                                    lrEtaxLine."BWK VAT Registration No." := Cust."VAT Registration No.";
                                                                    lrEtaxLine."BWK Customer Address" := Cust.Address;
                                                                    lrEtaxLine."BWK Customer Address" += ' ' + Cust."Address 2";
                                                                    lrEtaxLine."BWK Customer Address" += ' ' + Cust.City;
                                                                    lrEtaxLine."BWK Customer Address" += ' ' + Cust."Post Code";
                                                                    lrEtaxLine."BWK Amount Incl. VAT" := lrEtaxLine."BWK Amount" + lrEtaxLine."BWK VAT Amount";

                                                                    //Customize BW.TK ASB2312-0156 2023-12-20
                                                                    lrEtaxLine.Validate("BWK VAT Prod. Posting Group", lrVATEntry."VAT Prod. Posting Group");
                                                                    //Customize BW.TK ASB2312-0156 2023-12-20

                                                                    //Customize BW.WW ASB2311-0162
                                                                    VtBus.Reset();
                                                                    VtBus.SetFilter(Code, '%1', lrVATEntry."VAT Bus. Posting Group");
                                                                    if VtBus.FindFirst() then begin
                                                                        if VtBus."BWK Head Office" then begin
                                                                            lrEtaxLine.Validate("BWK Branch Code", '');
                                                                            lrEtaxLine.Validate("BWK Head Office", true);
                                                                        end else begin
                                                                            lrEtaxLine.Validate("BWK Branch Code", VtBus."BWK Branch Code");
                                                                            lrEtaxLine.Validate("BWK Head Office", false);
                                                                        end;
                                                                    end;
                                                                    //Customize BW.WW ASB2311-0162  

                                                                    lrEtaxLine.Insert(true);
                                                                    // lrEtaxLine.Modify(true);

                                                                    lrVATEntry."BWK Document Type" := Rec."BWK E-Tax Document Type";
                                                                    lrVATEntry."BWK End date of Month" := Rec."BWK End date of Month";
                                                                    lrVATEntry."BWK Generate E-TAX" := true;
                                                                    lrVATEntry.Modify(true);
                                                                end;
                                                            end;
                                                        end;
                                                    end;
                                                end;
                                            end;


                                            /*
                                            if lrVATEntry."Source Code" = 'CASHRECJNL' then begin
                                                GLRegister.Reset();
                                                GLRegister.SetFilter("AGE_Document No2", '%1', lrVATEntry."Document No.");
                                                if GLRegister.FindFirst() then begin
                                                    Cust.Reset();
                                                    Cust.SetFilter("No.", '%1', lrVATEntry."Bill-to/Pay-to No.");
                                                    if Cust.FindFirst() then begin
                                                        lrEtaxLine2.Reset();
                                                        lrEtaxLine2.SetFilter("BWK E-Tax Document Type", '%1', lrEtaxLine."BWK E-Tax Document Type");
                                                        lrEtaxLine2.SetFilter("BWK End date of Month", '%1', lrEtaxLine."BWK End date of Month");
                                                        lrEtaxLine2.SetFilter("BWK Source Table", '%1', lrEtaxLine."BWK Source Table");
                                                        lrEtaxLine2.SetFilter("BWK Document No.", '%1', lrEtaxLine."BWK Document No.");
                                                        if lrEtaxLine2.FindLast() then begin
                                                            LineNo := lrEtaxLine2."BWK Line No.";
                                                            lrEtaxLine2."BWK Amount" += lrVATEntry.Base * -1;
                                                            lrEtaxLine2."BWK VAT Amount" += lrVATEntry.Amount * -1;
                                                            lrEtaxLine2.Validate("BWK Posting Date", lrVATEntry."Posting Date");
                                                            lrEtaxLine2.Validate("BWK VAT Business Posting Group", lrVATEntry."VAT Bus. Posting Group");
                                                            lrEtaxLine2.Validate("BWK Customer No.", lrVATEntry."Bill-to/Pay-to No.");
                                                            lrEtaxLine2.Modify(true);
                                                        end
                                                        else begin
                                                            lrEtaxLine.Init();
                                                            lrEtaxLine.Validate("BWK Source Table", lrEtaxLine."BWK Source Table"::"G/L Register");
                                                            lrEtaxLine.Validate("BWK E-Tax Document Type", Rec."BWK E-Tax Document Type");
                                                            lrEtaxLine.Validate("BWK End date of Month", Rec."BWK End date of Month");
                                                            lrEtaxLine.Validate("BWK Document No.", lrVATEntry."Document No.");
                                                            lrEtaxLine.Validate("BWK Line No.", LineNo + 1);
                                                            lrEtaxLine.Validate("BWK Posting Date", lrVATEntry."Posting Date");
                                                            lrEtaxLine.Validate("BWK VAT Business Posting Group", lrVATEntry."VAT Bus. Posting Group");
                                                            lrEtaxLine.Validate("BWK VAT Amount", lrVATEntry.Amount * -1);
                                                            lrEtaxLine.Validate("BWK Customer No.", lrVATEntry."Bill-to/Pay-to No.");
                                                            lrEtaxLine.Validate("BWK Amount", lrVATEntry.Base * -1);
                                                            lrEtaxLine."BWK Customer Name" := Cust.Name;
                                                            lrEtaxLine."BWK VAT Registration No." := Cust."VAT Registration No.";
                                                            lrEtaxLine."BWK Customer Address" := Cust.Address;
                                                            lrEtaxLine."BWK Customer Address" += ' ' + Cust."Address 2";
                                                            lrEtaxLine."BWK Customer Address" += ' ' + Cust.City;
                                                            lrEtaxLine."BWK Customer Address" += ' ' + Cust."Post Code";
                                                            lrEtaxLine."BWK Amount Incl. VAT" := lrEtaxLine."BWK Amount" + lrEtaxLine."BWK VAT Amount";

                                                            //Customize BW.TK ASB2312-0156 2023-12-20
                                                            lrEtaxLine.Validate("BWK VAT Prod. Posting Group", lrVATEntry."VAT Prod. Posting Group");
                                                            //Customize BW.TK ASB2312-0156 2023-12-20

                                                            //Customize BW.WW ASB2311-0162
                                                            VtBus.Reset();
                                                            VtBus.SetFilter(Code, '%1', lrVATEntry."VAT Bus. Posting Group");
                                                            if VtBus.FindFirst() then begin
                                                                //Lek รอสอบถามลูกค้าเกี่ยวกับ LCL ของลูกค้าว่าบันทึกสาขาแบบไหน
                                                                if StrLen(VtBus."AVF_Branch No.") > 5 then begin
                                                                    lrEtaxLine.Validate("BWK Branch Code", '');
                                                                    lrEtaxLine.Validate("BWK Head Office", true);
                                                                end else begin
                                                                    lrEtaxLine.Validate("BWK Branch Code", VtBus."AVF_Branch No.");
                                                                    lrEtaxLine.Validate("BWK Head Office", VtBus."AVF_Default Head Office");
                                                                end;
                                                                //Lek รอสอบถามลูกค้าเกี่ยวกับ LCL ของลูกค้าว่าบันทึกสาขาแบบไหน
                                                            end;
                                                            //Customize BW.WW ASB2311-0162  

                                                            lrEtaxLine.Insert(true);
                                                            // lrEtaxLine.Modify(true);
                                                        end;
                                                    end;
                                                end;
                                            end;
                                            */
                                        end;
                                    lrVATEntry."Document Type"::Payment:
                                        begin
                                            /*
                                            if lrVATEntry."Source Code" = 'CASHRECJNL' then begin
                                                GLRegister.Reset();
                                                GLRegister.SetFilter("AGE_Document No2", '%1', lrVATEntry."Document No.");
                                                if GLRegister.FindFirst() then begin
                                                    Cust.Reset();
                                                    Cust.SetFilter("No.", '%1', lrVATEntry."Bill-to/Pay-to No.");
                                                    if Cust.FindFirst() then begin
                                                        lrEtaxLine.Init();
                                                        lrEtaxLine.Validate("BWK Source Table", lrEtaxLine."BWK Source Table"::"G/L Register");
                                                        lrEtaxLine.Validate("BWK E-Tax Document Type", Rec."BWK E-Tax Document Type");
                                                        lrEtaxLine.Validate("BWK End date of Month", Rec."BWK End date of Month");
                                                        lrEtaxLine.Validate("BWK Document No.", lrVATEntry."Document No.");

                                                        lrEtaxLine2.Reset();
                                                        lrEtaxLine2.SetFilter("BWK E-Tax Document Type", '%1', lrEtaxLine."BWK E-Tax Document Type");
                                                        lrEtaxLine2.SetFilter("BWK End date of Month", '%1', lrEtaxLine."BWK End date of Month");
                                                        lrEtaxLine2.SetFilter("BWK Source Table", '%1', lrEtaxLine."BWK Source Table");
                                                        lrEtaxLine2.SetFilter("BWK Document No.", '%1', lrEtaxLine."BWK Document No.");
                                                        if lrEtaxLine2.FindLast() then begin
                                                            LineNo := lrEtaxLine2."BWK Line No.";
                                                            lrEtaxLine2."BWK Amount" += lrVATEntry.Base * -1;
                                                            lrEtaxLine2."BWK VAT Amount" += lrVATEntry.Amount * -1;
                                                            lrEtaxLine2."BWK Amount Incl. VAT" := (lrEtaxLine."BWK Amount Incl. VAT" + (lrEtaxLine2."BWK Amount" + lrEtaxLine2."BWK VAT Amount"));
                                                            lrEtaxLine2.Validate("BWK Posting Date", lrVATEntry."Posting Date");
                                                            lrEtaxLine2.Validate("BWK VAT Business Posting Group", lrVATEntry."VAT Bus. Posting Group");
                                                            lrEtaxLine2.Validate("BWK Customer No.", lrVATEntry."Bill-to/Pay-to No.");
                                                            lrEtaxLine2.Modify(true);
                                                        end
                                                        else begin
                                                            lrEtaxLine.Validate("BWK Line No.", LineNo + 1);
                                                            lrEtaxLine.Validate("BWK Posting Date", lrVATEntry."Posting Date");
                                                            lrEtaxLine.Validate("BWK VAT Business Posting Group", lrVATEntry."VAT Bus. Posting Group");
                                                            lrEtaxLine.Validate("BWK VAT Amount", lrVATEntry.Amount * -1);
                                                            lrEtaxLine.Validate("BWK Customer No.", lrVATEntry."Bill-to/Pay-to No.");
                                                            lrEtaxLine.Validate("BWK Amount", lrVATEntry.Base * -1);
                                                            lrEtaxLine."BWK Customer Name" := Cust.Name;
                                                            lrEtaxLine."BWK VAT Registration No." := Cust."VAT Registration No.";
                                                            lrEtaxLine."BWK Customer Address" := Cust.Address;
                                                            lrEtaxLine."BWK Customer Address" += ' ' + Cust."Address 2";
                                                            lrEtaxLine."BWK Customer Address" += ' ' + Cust.City;
                                                            lrEtaxLine."BWK Customer Address" += ' ' + Cust."Post Code";
                                                            lrEtaxLine."BWK Amount Incl. VAT" := (lrEtaxLine."BWK Amount" + lrEtaxLine."BWK VAT Amount");

                                                            //Customize BW.TK ASB2312-0156 2023-12-20
                                                            lrEtaxLine.Validate("BWK VAT Prod. Posting Group", lrVATEntry."VAT Prod. Posting Group");
                                                            //Customize BW.TK ASB2312-0156 2023-12-20

                                                            //Customize BW.WW ASB2311-0162
                                                            VtBus.Reset();
                                                            VtBus.SetFilter(Code, '%1', lrVATEntry."VAT Bus. Posting Group");
                                                            if VtBus.FindFirst() then begin
                                                                //Lek รอสอบถามลูกค้าเกี่ยวกับ LCL ของลูกค้าว่าบันทึกสาขาแบบไหน
                                                                if StrLen(VtBus."AVF_Branch No.") > 5 then begin
                                                                    lrEtaxLine.Validate("BWK Branch Code", '');
                                                                    lrEtaxLine.Validate("BWK Head Office", true);
                                                                end else begin
                                                                    lrEtaxLine.Validate("BWK Branch Code", VtBus."AVF_Branch No.");
                                                                    lrEtaxLine.Validate("BWK Head Office", VtBus."AVF_Default Head Office");
                                                                end;
                                                                //Lek รอสอบถามลูกค้าเกี่ยวกับ LCL ของลูกค้าว่าบันทึกสาขาแบบไหน
                                                            end;
                                                            //Customize BW.WW ASB2311-0162  

                                                            lrEtaxLine.Insert(true);
                                                        end;
                                                    end;
                                                end;
                                            end;
                                            */
                                        end;
                                end;
                            // lrVATEntry."BWK Document Type" := Rec."BWK E-Tax Document Type";
                            // lrVATEntry."BWK End date of Month" := Rec."BWK End date of Month";
                            // lrVATEntry."BWK Generate E-TAX" := true;
                            // lrVATEntry.Modify(true);
                            until lrVATEntry.Next() = 0;
                        end else begin
                            Message('No data to Generate Line!');//Insert 20231110 by NM
                        end;
                        CurrPage.Update(true);
                    end;
                }
                // action(UpdateData)
                // {
                //     Caption = 'Update Data';
                //     Image = UpdateDescription;
                //     Promoted = true;
                //     PromotedCategory = Process;

                //     trigger OnAction()
                //     var
                //         vatEntry: Record "VAT Entry";
                //     begin
                //         vatEntry.Reset();
                //         vatEntry.SetFilter("Document No.", '%1|%2', 'DR23100001', 'DR23110001');
                //         if vatEntry.FindSet() then begin
                //             repeat
                //                 vatEntry."BWK Generate E-TAX" := false;
                //                 vatEntry."Document Type" := vatEntry."Document Type"::Invoice;
                //                 vatEntry."BWK Document Type" := vatEntry."BWK Document Type"::" ";
                //                 vatEntry."BWK End date of Month" := 0D;
                //                 vatEntry.Modify();
                //             until vatEntry.Next() = 0;
                //             Message('Success');
                //         end;
                //     end;
                // }
            }
        }
    }
}
