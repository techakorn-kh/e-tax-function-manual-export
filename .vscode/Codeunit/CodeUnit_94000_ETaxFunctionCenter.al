codeunit 94000 "BWK E-Tax Function Center"
{
    procedure "BWK Get ThaiMonth"(NoOfMonth: Integer): Text[50]
    begin
        case NoOfMonth OF
            1:
                EXIT('มกราคม');
            2:
                EXIT('กุมภาพันธ์');
            3:
                EXIT('มีนาคม');
            4:
                EXIT('เมษายน');
            5:
                EXIT('พฤษภาคม');
            6:
                EXIT('มิถุนายน');
            7:
                EXIT('กรกฎาคม');
            8:
                EXIT('สิงหาคม');
            9:
                EXIT('กันยายน');
            10:
                EXIT('ตุลาคม');
            11:
                EXIT('พฤศจิกายน');
            12:
                EXIT('ธันวาคม');
        END;

    end;

    procedure GenerateJSONData(ETaxLine: Record "BWK E-Tax Line")
    var
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpHeadersContent, HttpHeadersRequestMessage : HttpHeaders;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;

        VJsonObjectHeader: JsonObject;
        VJsonObjectLines: JsonObject;
        VJsonArray: JsonArray;
        VJsonArrayLines: JsonArray;
        VJsonText: Text;
        LocalETaxLine: Record "BWK E-Tax Line";
        JsonStringResponse: Text;
        LETaxLineData: Record "BWK E-Tax Line";
        GenLedgerSetup: Record "General Ledger Setup";

        JArrays: JsonArray;
        JObject: JsonObject;

        InStr: InStream;
        tmpBlob: Codeunit "Temp Blob";
        FileName: Text;
        InStream: InStream;
    begin

    end;

    procedure "Export Text File"(Var EtaxLine: Record "BWK E-Tax Line"): Boolean
    var
        Cust: Record Customer;
        SaleINVH: Record "Sales Invoice Header";
        SaleINVL: Record "Sales Invoice Line";
        SaleCrH: Record "Sales Cr.Memo Header";
        SaleCrL: Record "Sales Cr.Memo Line";
        PoGenJnlLine: Record "Posted Gen. Journal Line";
        GenLedSet: Record "General Ledger Setup";
        CompanyInfo: Record "Company Information";
        EtaxHead: Record "BWK E-Tax Header";
        TextFile: File;
        InStream: InStream;
        Route, TempText : Text;
        DocNo: Code[20];
        CRLF: Text[2];
        TypeHelper: Codeunit "Type Helper";

        // Start Templete Field E-TAX INET
        FILE_NAME: Text;
        SELLER_TAX_ID: Text;
        SELLER_BRANCH_ID: Text;

        DOCUMENT_ID: Text;
        DOCUMENT_ISSUE_DTM: Text;
        CREATE_PURPOSE_CODE: Text;
        CREATE_PURPOSE: Text;
        ADDITIONAL_REF_ASSIGN_ID: Text;
        ADDITIONAL_REF_ISSUE_DTM: Text;
        ADDITIONAL_REF_TYPE_CODE: Text;
        ADDITIONAL_REF_DOCUMENT_NAME: Text;
        SEND_EMAIL: text;

        BUYER_ID: Text;
        BUYER_NAME: Text;
        BUYER_TAX_ID_TYPE: Text;
        BUYER_TAX_ID: Text;
        BUYER_BRANCH_ID: Text;
        BUYER_URIID: Text;
        BUYER_POST_CODE: Text;
        BUYER_BUILDING_NAME: Text;
        BUYER_BUILDING_NO: Text;
        BUYER_ADDRESS_LINE1: Text;
        BUYER_ADDRESS_LINE2: Text;
        BUYER_ADDRESS_LINE3: Text;
        BUYER_ADDRESS_LINE4: Text;
        BUYER_ADDRESS_LINE5: Text;
        BUYER_STREET_NAME: Text;
        BUYER_CITY_SUB_DIV_NAME: Text;
        BUYER_CITY_NAME: Text;
        BUYER_COUNTRY_SUB_DIV_NAME: Text;
        BUYER_COUNTRY_ID: Text;

        LINE_ID: Text;
        PRODUCT_ID: Text;
        PRODUCT_NAME: Text;
        PRODUCT_CHARGE_AMOUNT: Text;
        PRODUCT_QUANTITY: Text;
        LINE_TAX_CAL_RATE: Text;
        LINE_BASIS_AMOUNT: Text;
        LINE_TAX_CAL_AMOUNT: Text;
        LINE_ALLOWANCE_CHARGE_IND: Text;
        LINE_ALLOWANCE_REASON: Text;
        LINE_ALLOWANCE_ACTUAL_AMOUNT: Text;
        LINE_TAX_TOTAL_AMOUNT: Text;
        LINE_NET_TOTAL_AMOUNT: Text;
        LINE_NET_INCLUDE_TAX_TOTAL_AMOUNT: Text;

        LINE_TOTAL_COUNT: Text;
        TAX_CAL_RATE: Text;
        BASIS_AMOUNT: Text;
        TAX_CAL_AMOUNT: Text;
        CURRENCY_CODE: Text;
        ORIGINAL_TOTAL_AMOUNT: Text;
        LINE_TOTAL_AMOUNT: Text;
        ADJUSTED_INFORMATION_AMOUNT: Text;
        TAX_BASIS_TOTAL_AMOUNT: Text;
        TAX_TOTAL_AMOUNT: Text;
        GRAND_TOTAL_AMOUNT: Text;
    // End Templete Field E-TAX INET
    begin
        CRLF := TypeHelper.CRLFSeparator();

        Clear(DocNo);
        Clear(SELLER_TAX_ID);
        Clear(SELLER_BRANCH_ID);

        if (DocNo = '') or (DocNo <> Etaxline."BWK Document No.") then begin
            TextFile.CreateTempFile(TextEncoding::UTF8);
            TextFile.CreateInStream(InStream);
            DocNo := Etaxline."BWK Document No.";
        end;

        EtaxHead.Reset();
        EtaxHead.SetFilter("BWK E-Tax Document Type", '%1', EtaxLine."BWK E-Tax Document Type");
        if EtaxHead.FindFirst() then begin
            CompanyInfo.Reset();
            CompanyInfo.get();

            SELLER_TAX_ID := CompanyInfo."VAT Registration No.";
            SELLER_BRANCH_ID := CompanyInfo."Bank Branch No.";

            // Start AGE-WE-TAX - File Control
            TextFile.Write(
                '"C"' + ',' //C1.DATA_TYPE (M)
                + '"' + SELLER_TAX_ID + '"' + ',' //C2.SELLER_TAX_ID (M)
                + '"' + SELLER_BRANCH_ID + '"' + ',' //C3.SELLER_BRANCH_ID (M)
                + '"' + FILE_NAME + '"' //C4.FILE_NAME (O)
            );
            // End AGE-WE-TAX - File Control

            Cust.Reset();
            Cust.SetRange("No.", EtaxLine."BWK Customer No.");
            if Cust.FindFirst() then begin
                case EtaxHead."BWK E-Tax Document Type" of
                    EtaxHead."BWK E-Tax Document Type"::INV:
                        begin
                            SaleINVH.Reset();
                            SaleINVH.SetRange("No.", EtaxLine."BWK Document No.");
                            if SaleINVH.FindFirst() then begin
                                Clear(CURRENCY_CODE);
                                Clear(DOCUMENT_ID);
                                Clear(DOCUMENT_ISSUE_DTM);
                                Clear(SEND_EMAIL);

                                if SaleINVH."Currency Code" <> '' then begin
                                    CURRENCY_CODE := COPYSTR(SaleINVH."Currency Code", 1, 3);
                                end else begin
                                    CURRENCY_CODE := 'THB';
                                end;

                                DOCUMENT_ID := SaleINVH."No.";
                                DOCUMENT_ISSUE_DTM := Format(SaleINVH."Posting Date", 0, '<Year4>-<Month,2>-<Day,2>T00:00:00');

                                // if EtaxLine."BWK Etax Select Non Send Email" then
                                SEND_EMAIL := 'N';
                                // else
                                //     SEND_EMAIL := 'Y';

                                // E-TAX | Document Header
                                TextFile.Write(CRLF
                                    + '"H"' + ',' //H1.DATA_TYPE (M)
                                    + '"T02"' + ',' //H2.DOCUMENT_TYPE_CODE (M)
                                    + '"ใบแจ้งหนี้/ใบกำกับภาษี"' + ',' //H3.DOCUMENT_NAME (C)
                                    + '"' + DOCUMENT_ID + '"' + ',' //H4.DOCUMENT_ID (M)
                                    + '"' + DOCUMENT_ISSUE_DTM + '"' + ',' //H5.DOCUMENT_ISSUE_DTM (M)
                                    + '""' + ',' //H6.CREATE_PURPOSE_CODE (O)
                                    + '""' + ',' //H7.CREATE_PURPOSE (O)
                                    + '""' + ',' //H8.ADDITIONAL_REF_ASSIGN_ID (O)
                                    + '""' + ',' //H9.ADDITIONAL_REF_ISSUE_DTM (O)
                                    + '""' + ',' //H10.ADDITIONAL_REF_TYPE_CODE (O)
                                    + '""' + ',' //H11.ADDITIONAL_REF_DOCUMENT_NAME (C)
                                    + '""' + ',' //H12.DELIVERY_TYPE_CODE (O)
                                    + '""' + ',' //H13.BUYER_ORDER_ASSIGN_ID (O)
                                    + '""' + ',' //H14.BUYER_ORDER_ISSUE_DTM (O)
                                    + '""' + ',' //H15.BUYER_ORDER_REF_TYPE_CODE (O) ``
                                    + '""' + ',' //H16.DOCUMENT_REMARK (O)
                                    + '""' + ',' //H17.VOUCHER_NO (O)
                                    + '""' + ',' //H18.SELLER_CONTACT_PERSON_NAME (O)
                                    + '""' + ',' //H19.SELLER_CONTACT_DEPARTMENT_NAME (O)
                                    + '""' + ',' //H20.SELLER_CONTACT_URIID (O)
                                    + '""' + ',' //H21.SELLER_CONTACT_PHONE_NO (O)
                                    + '""' + ',' //H22.FLEX_FIELD (O)
                                    + '""' + ',' //H23.SELLER_BRANCH_ID (O)
                                    + '""' + ',' //H24.SOURCE_SYSTEM (O)
                                    + '""' + ',' //H25.ENCRYPT_PASSWORD (O)
                                    + '""' + ',' //H26.PDF_TEMPLATE_ID (O)
                                    + '"' + SEND_EMAIL + '"' //H27.SEND_EMAIL (O)
                                );
                                // End E-TAX | Document Header

                                Clear(BUYER_ID);
                                Clear(BUYER_NAME);
                                Clear(BUYER_TAX_ID_TYPE);
                                Clear(BUYER_TAX_ID);
                                Clear(BUYER_BRANCH_ID);
                                Clear(BUYER_URIID);
                                Clear(BUYER_POST_CODE);
                                Clear(BUYER_BUILDING_NAME);
                                Clear(BUYER_ADDRESS_LINE1);
                                Clear(BUYER_ADDRESS_LINE2);
                                Clear(BUYER_ADDRESS_LINE3);
                                Clear(BUYER_ADDRESS_LINE4);
                                Clear(BUYER_ADDRESS_LINE5);
                                Clear(BUYER_STREET_NAME);
                                Clear(BUYER_CITY_SUB_DIV_NAME);
                                Clear(BUYER_CITY_NAME);
                                Clear(BUYER_COUNTRY_SUB_DIV_NAME);
                                Clear(BUYER_COUNTRY_ID);

                                BUYER_ID := Cust."No.";
                                BUYER_NAME := Cust.Name;
                                BUYER_TAX_ID_TYPE := 'TXID';
                                BUYER_TAX_ID := Cust."VAT Registration No.";
                                BUYER_BRANCH_ID := Cust."BWK Etax Branch Code";

                                if SaleINVH."BWK Etax E-Mail" = '' then begin
                                    BUYER_URIID := Cust."BWK Etax E-Mail"
                                end else begin
                                    BUYER_URIID := SaleINVH."BWK Etax E-Mail";
                                end;

                                BUYER_POST_CODE := Cust."Post Code";
                                BUYER_BUILDING_NAME := Cust."BWK Etax Building Name";
                                BUYER_BUILDING_NO := Cust."BWK Etax Building No.";
                                BUYER_ADDRESS_LINE1 := Cust."BWK Etax Address1";
                                BUYER_ADDRESS_LINE2 := Cust."BWK Etax Address2";
                                BUYER_ADDRESS_LINE3 := Cust."BWK Etax Address3";
                                BUYER_ADDRESS_LINE4 := Cust."BWK Etax Address4";
                                BUYER_ADDRESS_LINE5 := Cust."BWK Etax Address5";
                                BUYER_STREET_NAME := Cust."BWK Etax Street";
                                BUYER_CITY_SUB_DIV_NAME := Cust."BWK Etax City Sub";
                                BUYER_CITY_NAME := Cust."BWK Etax City";
                                BUYER_COUNTRY_SUB_DIV_NAME := Cust."BWK Etax Sub Country";
                                BUYER_COUNTRY_ID := Cust."BWK Etax Country ID";

                                case Cust."BWK Etax Taxpayer Type" of
                                    Cust."BWK Etax Taxpayer Type"::TXID:
                                        begin
                                            BUYER_TAX_ID_TYPE := 'TXID';
                                        end;
                                    Cust."BWK Etax Taxpayer Type"::NIDN:
                                        begin
                                            BUYER_TAX_ID_TYPE := 'NIDN';
                                        end;
                                    Cust."BWK Etax Taxpayer Type"::CCPT:
                                        begin
                                            BUYER_TAX_ID_TYPE := 'CCPT';
                                        end;
                                    Cust."BWK Etax Taxpayer Type"::OTHR:
                                        begin
                                            BUYER_TAX_ID_TYPE := 'OTHR';
                                            BUYER_TAX_ID := 'N/A';
                                        end;
                                end;

                                // E-TAX | Buyer Information
                                TextFile.Write(CRLF
                                    + '"B"' + ',' //B1.DATA_TYPE (M)
                                    + '"' + BUYER_ID + '"' + ',' //B2.BUYER_ID (O)
                                    + '"' + BUYER_NAME + '"' + ',' //B3.BUYER_NAME (O)
                                    + '"' + BUYER_TAX_ID_TYPE + '"' + ',' //B4.BUYER_TAX_ID_TYPE (O)
                                    + '"' + BUYER_TAX_ID + '"' + ',' //B5.BUYER_TAX_ID (O)
                                    + '"' + BUYER_BRANCH_ID + '"' + ',' //B6.BUYER_BRANCH_ID (C)
                                    + '""' + ',' //B7.BUYER_CONTACT_PERSON_NAME (O)
                                    + '""' + ',' //B8.BUYER_CONTACT_DEPARTMENT_NAME (O)
                                    + '"' + BUYER_URIID + '"' + ',' //B9.BUYER_URIID (O)
                                    + '""' + ',' //B10.BUYER_CONTACT_PHONE_NO (C)
                                    + '"' + BUYER_POST_CODE + '"' + ',' //B11.BUYER_POST_CODE (O)
                                    + '"' + BUYER_BUILDING_NAME + '"' + ',' //B12.BUYER_BUILDING_NAME (O)
                                    + '"' + BUYER_BUILDING_NO + '"' + ',' //B13.BUYER_BUILDING_NO (O)
                                    + '"' + BUYER_ADDRESS_LINE1 + '"' + ',' //B14.BUYER_ADDRESS_LINE1 (O)
                                    + '"' + BUYER_ADDRESS_LINE2 + '"' + ',' //B15.BUYER_ADDRESS_LINE2 (O)
                                    + '"' + BUYER_ADDRESS_LINE3 + '"' + ',' //B16.BUYER_ADDRESS_LINE3 (O)
                                    + '"' + BUYER_ADDRESS_LINE4 + '"' + ',' //B17.BUYER_ADDRESS_LINE4 (O)
                                    + '"' + BUYER_ADDRESS_LINE5 + '"' + ',' //B18.BUYER_ADDRESS_LINE5 (O)
                                    + '"' + BUYER_STREET_NAME + '"' + ',' //B19.BUYER_STREET_NAME (O)
                                    + '""' + ',' //B20.BUYER_CITY_SUB_DIV_ID (C)
                                    + '"' + BUYER_CITY_SUB_DIV_NAME + '"' + ',' //B21.BUYER_CITY_SUB_DIV_NAME (O)
                                    + '""' + ',' //B22.BUYER_CITY_ID (C)
                                    + '"' + BUYER_CITY_NAME + '"' + ',' //B23.BUYER_CITY_NAME (O)
                                    + '""' + ',' //B24.BUYER_COUNTRY_SUB_DIV_ID (C)
                                    + '"' + BUYER_COUNTRY_SUB_DIV_NAME + '"' + ',' //B25.BUYER_COUNTRY_SUB_DIV_NAME (C)
                                    + '"' + BUYER_COUNTRY_ID + '"' //B26.BUYER_COUNTRY_ID (M)
                                );
                                // End E-TAX | Buyer Information

                                SaleINVL.RESET;
                                SaleINVL.SetRange("Document No.", SaleINVH."No.");
                                SaleINVL.SetFilter("No.", '<>%1', '');
                                if SaleINVL.FindFirst() THEN BEGIN
                                    Clear(TAX_CAL_RATE);

                                    if SaleINVL.FIND('-') then begin
                                        SaleINVL.CALCSUMS("Amount Including VAT", Amount);
                                        if (SaleINVL."Amount Including VAT" - SaleINVL.Amount) <> 0 then begin
                                            TAX_CAL_RATE := '7';
                                        end else begin
                                            TAX_CAL_RATE := '0';
                                        end;
                                    end;

                                    if SaleINVL.FindSet() then begin
                                        repeat
                                            Clear(LINE_ID);
                                            Clear(PRODUCT_ID);
                                            Clear(PRODUCT_NAME);
                                            Clear(PRODUCT_CHARGE_AMOUNT);
                                            Clear(PRODUCT_QUANTITY);
                                            Clear(LINE_TAX_CAL_RATE);
                                            Clear(LINE_BASIS_AMOUNT);
                                            Clear(LINE_TAX_CAL_AMOUNT);
                                            Clear(LINE_ALLOWANCE_CHARGE_IND);
                                            Clear(LINE_ALLOWANCE_ACTUAL_AMOUNT);
                                            Clear(LINE_ALLOWANCE_REASON);
                                            Clear(LINE_TAX_TOTAL_AMOUNT);
                                            Clear(LINE_NET_TOTAL_AMOUNT);
                                            Clear(LINE_NET_INCLUDE_TAX_TOTAL_AMOUNT);

                                            LINE_ID := DELCHR(Format(SaleINVL."Line No."), '=', ',');
                                            PRODUCT_ID := SaleINVL."No.";
                                            PRODUCT_NAME := SaleINVL.Description + SaleINVL."Description 2";
                                            PRODUCT_CHARGE_AMOUNT := DELCHR(Format(SaleINVL."Unit Price", 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');

                                            if TAX_CAL_RATE = '7' then begin
                                                LINE_TAX_CAL_AMOUNT := DELCHR(Format(SaleINVL."Amount Including VAT" - SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
                                            end else begin
                                                LINE_TAX_CAL_AMOUNT := '0.00';
                                            end;

                                            if SaleINVL.Quantity < 0 then begin
                                                PRODUCT_QUANTITY := DELCHR(Format(ABS(SaleINVL.Quantity), 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
                                                LINE_ALLOWANCE_CHARGE_IND := 'false';
                                                LINE_ALLOWANCE_REASON := PRODUCT_NAME;
                                                LINE_BASIS_AMOUNT := '0.00';
                                                LINE_TAX_CAL_AMOUNT := '0.00';
                                                LINE_TAX_TOTAL_AMOUNT := '0.00';
                                                LINE_NET_TOTAL_AMOUNT := '0.00';
                                                LINE_NET_INCLUDE_TAX_TOTAL_AMOUNT := '0.00';
                                                LINE_ALLOWANCE_ACTUAL_AMOUNT := DELCHR(Format(ABS(SaleINVL.Amount), 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
                                            end else begin
                                                PRODUCT_QUANTITY := DELCHR(Format(SaleINVL.Quantity, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
                                                LINE_BASIS_AMOUNT := DELCHR(Format(SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
                                                LINE_TAX_TOTAL_AMOUNT := DELCHR(Format(SaleINVL."Amount Including VAT" - SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
                                                LINE_NET_TOTAL_AMOUNT := DELCHR(Format(SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
                                                LINE_NET_INCLUDE_TAX_TOTAL_AMOUNT := DELCHR(Format(SaleINVL."Amount Including VAT" - SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
                                                LINE_ALLOWANCE_ACTUAL_AMOUNT := '0.00';
                                            end;

                                            LINE_TAX_CAL_RATE := DELCHR(Format(SaleINVL."VAT %", 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
                                            LINE_TAX_TOTAL_AMOUNT := DELCHR(Format(SaleINVL."Amount Including VAT" - SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');

                                            // E-TAX | Trade Line Item Information
                                            TextFile.Write(CRLF
                                                + '"L"' + ',' //L1.DATA_TYPE (M)
                                                + '"' + LINE_ID + '"' + ',' //L2.LINE_ID (M)
                                                + '"' + PRODUCT_ID + '"' + ',' //L3.PRODUCT_ID (O)
                                                + '"' + PRODUCT_NAME + '"' + ',' //L4.PRODUCT_NAME (M)
                                                + '""' + ',' //L5.PRODUCT_DESC (O)
                                                + '""' + ',' //L6.PRODUCT_BATCH_ID (O)
                                                + '"2019-01-01T00:00:00+07:00"' + ',' //L7.PRODUCT_EXPIRE_DTM (O)
                                                + '""' + ',' //L8.PRODUCT_CLASS_CODE (O)
                                                + '""' + ',' //L9.PRODUCT_CLASS_NAME (O)
                                                + '""' + ',' //L10.PRODUCT_ORIGIN_COUNTRY_ID (O)
                                                + '"' + PRODUCT_CHARGE_AMOUNT + '"' + ',' //L11.PRODUCT_CHARGE_AMOUNT (M)
                                                + '"' + CURRENCY_CODE + '"' + ',' //L12.PRODUCT_CHARGE_CURRENCY_CODE (M)
                                                + '""' + ',' //L13.PRODUCT_ALLOWANCE_CHARGE_IND (O)
                                                + '"0.00"' + ',' //L14.PRODUCT_ALLOWANCE_ACTUAL_AMOUNT (C)
                                                + '"' + CURRENCY_CODE + '"' + ',' //L15.PRODUCT_ALLOWANCE_ACTUAL_CURRENCY_CODE (C)
                                                + '""' + ',' //L16.PRODUCT_ALLOWANCE_REASON_CODE (O)
                                                + '""' + ',' //L17.PRODUCT_ALLOWANCE_REASON (O)
                                                + '"' + PRODUCT_QUANTITY + '"' + ',' //L18.PRODUCT_QUANTITY (O)
                                                + '""' + ',' //L19.PRODUCT_UNIT_CODE (O)
                                                + '"0.00"' + ',' //L20.PRODUCT_QUANTITY_PER_UNIT (O)
                                                + '"VAT"' + ',' //L21.LINE_TAX_TYPE_CODE (O)
                                                + '"' + LINE_TAX_CAL_RATE + '"' + ',' //L22.LINE_TAX_CAL_RATE (O)
                                                + '"' + LINE_BASIS_AMOUNT + '"' + ',' //L23.LINE_BASIS_AMOUNT (O)
                                                + '"' + CURRENCY_CODE + '"' + ',' //L24.LINE_BASIS_CURRENCY_CODE (O)
                                                + '"' + LINE_TAX_CAL_AMOUNT + '"' + ',' //L25.LINE_TAX_CAL_AMOUNT (O)
                                                + '"' + CURRENCY_CODE + '"' + ',' //L26.LINE_TAX_CAL_CURRENCY_CODE (O)
                                                + '"' + LINE_ALLOWANCE_CHARGE_IND + '"' + ',' //L27.LINE_ALLOWANCE_CHARGE_IND (O)
                                                + '"' + LINE_ALLOWANCE_ACTUAL_AMOUNT + '"' + ',' //L28.LINE_ALLOWANCE_ACTUAL_AMOUNT (C)
                                                + '"' + CURRENCY_CODE + '"' + ',' //L29.LINE_ALLOWANCE_ACTUAL_CURRENCY_CODE (C)
                                                + '""' + ',' //L30.LINE_ALLOWANCE_REASON_CODE (O)
                                                + '"' + LINE_ALLOWANCE_REASON + '"' + ',' //L31.LINE_ALLOWANCE_REASON (O)
                                                + '"' + LINE_TAX_TOTAL_AMOUNT + '"' + ',' //L32.LINE_TAX_TOTAL_AMOUNT (O)
                                                + '"' + CURRENCY_CODE + '"' + ',' //L33.LINE_TAX_TOTAL_CURRENCY_CODE (O)
                                                + '"' + LINE_NET_TOTAL_AMOUNT + '"' + ',' //L34.LINE_NET_TOTAL_AMOUNT (O)
                                                + '"' + CURRENCY_CODE + '"' + ',' //L35.LINE_NET_TOTAL_CURRENCY_CODE (O)
                                                + '"' + LINE_NET_INCLUDE_TAX_TOTAL_AMOUNT + '"' + ',' //L36.LINE_NET_INCLUDE_TAX_TOTAL_AMOUNT (O)
                                                + '"' + CURRENCY_CODE + '"' //L37.LINE_NET_INCLUDE_TAX_TOTAL_CURRENCY_CODE (O)
                                            );
                                        // End E-TAX | Trade Line Item Information
                                        until SaleINVL.Next = 0;

                                        SaleINVL.CALCSUMS(Amount, "Amount Including VAT");

                                        Clear(LINE_TOTAL_COUNT);
                                        Clear(BASIS_AMOUNT);
                                        Clear(TAX_CAL_AMOUNT);
                                        Clear(ORIGINAL_TOTAL_AMOUNT);
                                        Clear(TAX_BASIS_TOTAL_AMOUNT);
                                        Clear(TAX_TOTAL_AMOUNT);
                                        Clear(GRAND_TOTAL_AMOUNT);

                                        LINE_TOTAL_COUNT := DELCHR(Format(SaleINVL.Count), '=', ',');
                                        BASIS_AMOUNT := DELCHR(Format(SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
                                        TAX_CAL_AMOUNT := DELCHR(Format(SaleINVL."Amount Including VAT" - SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
                                        ORIGINAL_TOTAL_AMOUNT := DELCHR(Format(SaleINVL."Amount Including VAT", 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
                                        TAX_BASIS_TOTAL_AMOUNT := DELCHR(Format(SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
                                        TAX_TOTAL_AMOUNT := DELCHR(Format(SaleINVL."Amount Including VAT" - SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
                                        GRAND_TOTAL_AMOUNT := DELCHR(Format(SaleINVL."Amount Including VAT", 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');

                                        // E-TAX |Document Footer
                                        TextFile.Write(CRLF + '"F"' + ',' //F1.DATA_TYPE (M)
                                            + '"' + LINE_TOTAL_COUNT + '"' + ',' //F2.LINE_TOTAL_COUNT (M)
                                            + '"0001-01-01T00:00:00Z"' + ',' //F3.DELIVERY_OCCUR_DTM (O)
                                            + '"' + CURRENCY_CODE + '"' + ',' //F4.INVOICE_CURRENCY_CODE (O)
                                            + '"VAT"' + ',' //F5.TAX_TYPE_CODE (O)
                                            + '"' + TAX_CAL_RATE + '"' + ',' //F6.TAX_CAL_RATE (O)
                                            + '"' + BASIS_AMOUNT + '"' + ',' //F7.BASIS_AMOUNT (O)
                                            + '"' + CURRENCY_CODE + '"' + ',' //F8.BASIS_CURRENCY_CODE (O)
                                            + '"' + TAX_CAL_AMOUNT + '"' + ',' //F9.TAX_CAL_AMOUNT (O)
                                            + '"' + CURRENCY_CODE + '"' + ',' //F10.TAX_CAL_CURRENCY_CODE (O)
                                            + '""' + ',' //F29.ALLOWANCE_CHARGE_IND (O)
                                            + '"0.00"' + ',' //F30.ALLOWANCE_ACTUAL_AMOUNT (C)
                                            + '"' + CURRENCY_CODE + '"' + ',' //F31.ALLOWANCE_ACTUAL_CURRENCY_CODE (C)
                                            + '""' + ',' //F32.ALLOWANCE_REASON_CODE (O)
                                            + '""' + ',' //F33.ALLOWANCE_REASON (O)
                                            + '""' + ',' //F34.PAYMENT_TYPE_CODE (O)
                                            + '""' + ',' //F35.PAYMENT_DESCRIPTION (O)
                                            + '"0001-01-01T00:00:00Z"' + ',' //F36.PAYMENT_DUE_DTM (O)
                                            + '"' + ORIGINAL_TOTAL_AMOUNT + '"' + ',' //F37.ORIGINAL_TOTAL_AMOUNT (N)
                                            + '"' + CURRENCY_CODE + '"' + ',' //F38.ORIGINAL_TOTAL_CURRENCY_CODE (N)
                                            + '"0.00"' + ',' //F39.LINE_TOTAL_AMOUNT (O)
                                            + '"' + CURRENCY_CODE + '"' + ',' //F40.LINE_TOTAL_CURRENCY_CODE (O)
                                            + '"0.00"' + ',' //F41.ADJUSTED_INFORMATION_AMOUNT (N)
                                            + '"' + CURRENCY_CODE + '"' + ',' //F42.ADJUSTED_INFORMATION_CURRENCY_CODE (N)
                                            + '"0.00"' + ',' //F43.ALLOWANCE_TOTAL_AMOUNT (O)
                                            + '"' + CURRENCY_CODE + '"' + ',' //F44.ALLOWANCE_TOTAL_CURRENCY_CODE (O)
                                            + '"0.00"' + ',' //F45.CHARGE_TOTAL_AMOUNT (O)
                                            + '"' + CURRENCY_CODE + '"' + ',' //F46.CHARGE_TOTAL_CURRENCY_CODE (O)
                                            + '"' + TAX_BASIS_TOTAL_AMOUNT + '"' + ',' //F47.TAX_BASIS_TOTAL_AMOUNT (O)
                                            + '"' + CURRENCY_CODE + '"' + ',' //F48.TAX_BASIS_TOTAL_CURRENCY_CODE (O)
                                            + '"' + TAX_TOTAL_AMOUNT + '"' + ',' //F49.TAX_TOTAL_AMOUNT (O)
                                            + '"' + CURRENCY_CODE + '"' + ',' //F50.TAX_TOTAL_CURRENCY_CODE (O)
                                            + '"' + GRAND_TOTAL_AMOUNT + '"' + ',' //F51.GRAND_TOTAL_AMOUNT (O)
                                            + '"' + CURRENCY_CODE + '"' //F52.GRAND_TOTAL_CURRENCY_CODE (O)
                                        );
                                        // End E-TAX |Document Footer

                                        // E-TAX |File Trailer
                                        TextFile.Write(CRLF
                                            + '"T"' + ',' //T.DATA_TYPE (M)
                                            + '"1"' //T.TOTAL_DOCUMENT_COUNT (M)
                                        );
                                        // End E-TAX |File Trailer

                                    end;
                                end;
                            end;
                        end;
                    EtaxHead."BWK E-Tax Document Type"::DN:
                        begin

                        end;
                    EtaxHead."BWK E-Tax Document Type"::CN:
                        begin

                        end;
                    EtaxHead."BWK E-Tax Document Type"::RV:
                        begin

                        end;
                end;
            end;
        end;

        DownloadFromStream(InStream, 'Export', '', 'All Files (*.*)|*.*', FILE_NAME);
        exit(true);
    end;

    // procedure "Export Text File"(Var EtaxLine: Record "BWK E-Tax Line")
    // var
    //     Cust: Record Customer;
    //     SaleINVH: Record "Sales Invoice Header";
    //     SaleINVL: Record "Sales Invoice Line";
    //     SaleCrH: Record "Sales Cr.Memo Header";
    //     SaleCrL: Record "Sales Cr.Memo Line";
    //     PoGenJnlLine: Record "Posted Gen. Journal Line";
    //     GenLedSet: Record "General Ledger Setup";
    //     CompanyInfo: Record "Company Information";
    //     EtaxHead: Record "BWK E-Tax Header";
    //     FileGen: File;
    //     InStr: InStream;
    //     TxtBuilder: TextBuilder;
    //     Route, TempText : Text;
    //     DocNo: Code[20];

    //     // Start Templete Field E-TAX INET
    //     FILE_NAME: Text;
    //     SELLER_TAX_ID: Text;
    //     SELLER_BRANCH_ID: Text;

    //     DOCUMENT_ID: Text;
    //     DOCUMENT_ISSUE_DTM: Text;
    //     CREATE_PURPOSE_CODE: Text;
    //     CREATE_PURPOSE: Text;
    //     ADDITIONAL_REF_ASSIGN_ID: Text;
    //     ADDITIONAL_REF_ISSUE_DTM: Text;
    //     ADDITIONAL_REF_TYPE_CODE: Text;
    //     ADDITIONAL_REF_DOCUMENT_NAME: Text;
    //     SEND_EMAIL: text;

    //     BUYER_ID: Text;
    //     BUYER_NAME: Text;
    //     BUYER_TAX_ID_TYPE: Text;
    //     BUYER_TAX_ID: Text;
    //     BUYER_BRANCH_ID: Text;
    //     BUYER_URIID: Text;
    //     BUYER_POST_CODE: Text;
    //     BUYER_BUILDING_NAME: Text;
    //     BUYER_BUILDING_NO: Text;
    //     BUYER_ADDRESS_LINE1: Text;
    //     BUYER_ADDRESS_LINE2: Text;
    //     BUYER_ADDRESS_LINE3: Text;
    //     BUYER_ADDRESS_LINE4: Text;
    //     BUYER_ADDRESS_LINE5: Text;
    //     BUYER_STREET_NAME: Text;
    //     BUYER_CITY_SUB_DIV_NAME: Text;
    //     BUYER_CITY_NAME: Text;
    //     BUYER_COUNTRY_SUB_DIV_NAME: Text;
    //     BUYER_COUNTRY_ID: Text;

    //     LINE_ID: Text;
    //     PRODUCT_ID: Text;
    //     PRODUCT_NAME: Text;
    //     PRODUCT_CHARGE_AMOUNT: Text;
    //     PRODUCT_QUANTITY: Text;
    //     LINE_TAX_CAL_RATE: Text;
    //     LINE_BASIS_AMOUNT: Text;
    //     LINE_TAX_CAL_AMOUNT: Text;
    //     LINE_ALLOWANCE_CHARGE_IND: Text;
    //     LINE_ALLOWANCE_REASON: Text;
    //     LINE_ALLOWANCE_ACTUAL_AMOUNT: Text;
    //     LINE_TAX_TOTAL_AMOUNT: Text;
    //     LINE_NET_TOTAL_AMOUNT: Text;
    //     LINE_NET_INCLUDE_TAX_TOTAL_AMOUNT: Text;

    //     LINE_TOTAL_COUNT: Text;
    //     TAX_CAL_RATE: Text;
    //     BASIS_AMOUNT: Text;
    //     TAX_CAL_AMOUNT: Text;
    //     CURRENCY_CODE: Text;
    //     ORIGINAL_TOTAL_AMOUNT: Text;
    //     LINE_TOTAL_AMOUNT: Text;
    //     ADJUSTED_INFORMATION_AMOUNT: Text;
    //     TAX_BASIS_TOTAL_AMOUNT: Text;
    //     TAX_TOTAL_AMOUNT: Text;
    //     GRAND_TOTAL_AMOUNT: Text;
    //     // End Templete Field E-TAX INET

    //     CRLF: Text[2];
    //     TypeHelper: Codeunit "Type Helper";
    //     q: Boolean;
    // begin
    //     CRLF := TypeHelper.CRLFSeparator();

    //     Clear(SELLER_TAX_ID);
    //     Clear(SELLER_BRANCH_ID);
    //     Clear(DocNo);

    //     FILE_NAME := Format(EtaxLine."BWK E-Tax Document Type") + '_' + Format(Date2DMY(EtaxLine."BWK Posting Date", 2)) + '-' + Format(Date2DMY(EtaxLine."BWK Posting Date", 3)) + '_' + Format(EtaxLine."BWK Document No.") + '.txt';
    //     GenLedSet.Get();

    //     EtaxLine."BWK Etax Text file name" := FILE_NAME;

    //     if (DocNo = '') or (DocNo <> Etaxline."BWK Document No.") then begin
    //         FileGen.CreateTempFile(TextEncoding::UTF8);
    //         FileGen.CreateInStream(InStr);
    //         DocNo := Etaxline."BWK Document No.";
    //     end;

    //     EtaxHead.Reset();
    //     EtaxHead.SetFilter("BWK E-Tax Document Type", '%1', EtaxLine."BWK E-Tax Document Type");
    //     if EtaxHead.FindFirst() then begin
    //         if (EtaxHead."BWK E-Tax Document Type" = EtaxHead."BWK E-Tax Document Type"::INV) then begin
    //             CompanyInfo.Reset();
    //             CompanyInfo.get();

    //             SELLER_TAX_ID := CompanyInfo."VAT Registration No.";
    //             SELLER_BRANCH_ID := CompanyInfo."Bank Branch No.";

    //             // Start AGE-WE-TAX - File Control
    //             FileGen.Write('"C"' + ',' //C1.DATA_TYPE (M)
    //                 + '"' + SELLER_TAX_ID + '"' + ',' //C2.SELLER_TAX_ID (M)
    //                 + '"' + SELLER_BRANCH_ID + '"' + ',' //C3.SELLER_BRANCH_ID (M)
    //                 + '"' + FILE_NAME + '"'); //C4.FILE_NAME (O)
    //             // End AGE-WE-TAX - File Control

    //             Cust.Reset();
    //             Cust.SetRange("No.", EtaxLine."BWK Customer No.");
    //             if Cust.FindFirst() then begin
    //                 SaleINVH.Reset();
    //                 SaleINVH.SetRange("No.", EtaxLine."BWK Document No.");
    //                 if SaleINVH.FindFirst() then begin
    //                     Clear(CURRENCY_CODE);
    //                     Clear(DOCUMENT_ID);
    //                     Clear(DOCUMENT_ISSUE_DTM);
    //                     Clear(SEND_EMAIL);

    //                     if SaleINVH."Currency Code" <> '' then begin
    //                         CURRENCY_CODE := COPYSTR(SaleINVH."Currency Code", 1, 3);
    //                     end else begin
    //                         CURRENCY_CODE := 'THB';
    //                     end;

    //                     DOCUMENT_ID := SaleINVH."No.";
    //                     DOCUMENT_ISSUE_DTM := Format(SaleINVH."Posting Date", 0, '<Year4>-<Month,2>-<Day,2>T00:00:00');

    //                     // if EtaxLine."BWK Etax Select Non Send Email" then
    //                     SEND_EMAIL := 'N';
    //                     // else
    //                     //     SEND_EMAIL := 'Y';

    //                     // AGE-WE-TAX - Document Header
    //                     FileGen.Write(CRLF + '"H"' + ',' //H1.DATA_TYPE (M)
    //                         + '"T02"' + ',' //H2.DOCUMENT_TYPE_CODE (M)
    //                         + '"ใบแจ้งหนี้/ใบกำกับภาษี"' + ',' //H3.DOCUMENT_NAME (C)
    //                         + '"' + DOCUMENT_ID + '"' + ',' //H4.DOCUMENT_ID (M)
    //                         + '"' + DOCUMENT_ISSUE_DTM + '"' + ',' //H5.DOCUMENT_ISSUE_DTM (M)
    //                         + '""' + ',' //H6.CREATE_PURPOSE_CODE (O)
    //                         + '""' + ',' //H7.CREATE_PURPOSE (O)
    //                         + '""' + ',' //H8.ADDITIONAL_REF_ASSIGN_ID (O)
    //                         + '""' + ',' //H9.ADDITIONAL_REF_ISSUE_DTM (O)
    //                         + '""' + ',' //H10.ADDITIONAL_REF_TYPE_CODE (O)
    //                         + '""' + ',' //H11.ADDITIONAL_REF_DOCUMENT_NAME (C)
    //                         + '""' + ',' //H12.DELIVERY_TYPE_CODE (O)
    //                         + '""' + ',' //H13.BUYER_ORDER_ASSIGN_ID (O)
    //                         + '""' + ',' //H14.BUYER_ORDER_ISSUE_DTM (O)
    //                         + '""' + ',' //H15.BUYER_ORDER_REF_TYPE_CODE (O) ``
    //                         + '""' + ',' //H16.DOCUMENT_REMARK (O)
    //                         + '""' + ',' //H17.VOUCHER_NO (O)
    //                         + '""' + ',' //H18.SELLER_CONTACT_PERSON_NAME (O)
    //                         + '""' + ',' //H19.SELLER_CONTACT_DEPARTMENT_NAME (O)
    //                         + '""' + ',' //H20.SELLER_CONTACT_URIID (O)
    //                         + '""' + ',' //H21.SELLER_CONTACT_PHONE_NO (O)
    //                         + '""' + ',' //H22.FLEX_FIELD (O)
    //                         + '""' + ',' //H23.SELLER_BRANCH_ID (O)
    //                         + '""' + ',' //H24.SOURCE_SYSTEM (O)
    //                         + '""' + ',' //H25.ENCRYPT_PASSWORD (O)
    //                         + '""' + ',' //H26.PDF_TEMPLATE_ID (O)
    //                         + '"' + SEND_EMAIL + '"'); //H27.SEND_EMAIL (O)
    //                     // End AGE-WE-TAX - Document Header

    //                     Clear(BUYER_ID);
    //                     Clear(BUYER_NAME);
    //                     Clear(BUYER_TAX_ID_TYPE);
    //                     Clear(BUYER_TAX_ID);
    //                     Clear(BUYER_BRANCH_ID);
    //                     Clear(BUYER_URIID);
    //                     Clear(BUYER_POST_CODE);
    //                     Clear(BUYER_BUILDING_NAME);
    //                     Clear(BUYER_ADDRESS_LINE1);
    //                     Clear(BUYER_ADDRESS_LINE2);
    //                     Clear(BUYER_ADDRESS_LINE3);
    //                     Clear(BUYER_ADDRESS_LINE4);
    //                     Clear(BUYER_ADDRESS_LINE5);
    //                     Clear(BUYER_STREET_NAME);
    //                     Clear(BUYER_CITY_SUB_DIV_NAME);
    //                     Clear(BUYER_CITY_NAME);
    //                     Clear(BUYER_COUNTRY_SUB_DIV_NAME);
    //                     Clear(BUYER_COUNTRY_ID);

    //                     BUYER_ID := Cust."No.";
    //                     BUYER_NAME := Cust.Name;
    //                     BUYER_TAX_ID_TYPE := 'TXID';
    //                     BUYER_TAX_ID := Cust."VAT Registration No.";
    //                     BUYER_BRANCH_ID := Cust."BWK Etax Branch Code";

    //                     if SaleINVH."BWK Etax E-Mail" = '' then
    //                         BUYER_URIID := Cust."BWK Etax E-Mail"
    //                     else
    //                         BUYER_URIID := SaleINVH."BWK Etax E-Mail";

    //                     BUYER_POST_CODE := Cust."Post Code";
    //                     BUYER_BUILDING_NAME := Cust."BWK Etax Building Name";
    //                     BUYER_BUILDING_NO := Cust."BWK Etax Building No.";
    //                     BUYER_ADDRESS_LINE1 := Cust."BWK Etax Address1";
    //                     BUYER_ADDRESS_LINE2 := Cust."BWK Etax Address2";
    //                     BUYER_ADDRESS_LINE3 := Cust."BWK Etax Address3";
    //                     BUYER_ADDRESS_LINE4 := Cust."BWK Etax Address4";
    //                     BUYER_ADDRESS_LINE5 := Cust."BWK Etax Address5";
    //                     BUYER_STREET_NAME := Cust."BWK Etax Street";
    //                     BUYER_CITY_SUB_DIV_NAME := Cust."BWK Etax City Sub";
    //                     BUYER_CITY_NAME := Cust."BWK Etax City";
    //                     BUYER_COUNTRY_SUB_DIV_NAME := Cust."BWK Etax Sub Country";
    //                     BUYER_COUNTRY_ID := Cust."BWK Etax Country ID";

    //                     IF Cust."BWK Etax Taxpayer Type" = Cust."BWK Etax Taxpayer Type"::TXID THEN
    //                         BUYER_TAX_ID_TYPE := 'TXID'
    //                     ELSE
    //                         IF Cust."BWK Etax Taxpayer Type" = Cust."BWK Etax Taxpayer Type"::NIDN THEN
    //                             BUYER_TAX_ID_TYPE := 'NIDN'
    //                         ELSE
    //                             IF Cust."BWK Etax Taxpayer Type" = Cust."BWK Etax Taxpayer Type"::CCPT THEN
    //                                 BUYER_TAX_ID_TYPE := 'CCPT'
    //                             ELSE
    //                                 IF Cust."BWK Etax Taxpayer Type" = Cust."BWK Etax Taxpayer Type"::OTHR THEN begin
    //                                     BUYER_TAX_ID_TYPE := 'OTHR';
    //                                     BUYER_TAX_ID := 'N/A';
    //                                 end;

    //                     // AGE-WE-TAX - Buyer Information
    //                     FileGen.Write(CRLF + '"B"' + ',' //B1.DATA_TYPE (M)
    //                         + '"' + BUYER_ID + '"' + ',' //B2.BUYER_ID (O)
    //                         + '"' + BUYER_NAME + '"' + ',' //B3.BUYER_NAME (O)
    //                         + '"' + BUYER_TAX_ID_TYPE + '"' + ',' //B4.BUYER_TAX_ID_TYPE (O)
    //                         + '"' + BUYER_TAX_ID + '"' + ',' //B5.BUYER_TAX_ID (O)
    //                         + '"' + BUYER_BRANCH_ID + '"' + ',' //B6.BUYER_BRANCH_ID (C)
    //                         + '""' + ',' //B7.BUYER_CONTACT_PERSON_NAME (O)
    //                         + '""' + ',' //B8.BUYER_CONTACT_DEPARTMENT_NAME (O)
    //                         + '"' + BUYER_URIID + '"' + ',' //B9.BUYER_URIID (O)
    //                         + '""' + ',' //B10.BUYER_CONTACT_PHONE_NO (C)
    //                         + '"' + BUYER_POST_CODE + '"' + ',' //B11.BUYER_POST_CODE (O)
    //                         + '"' + BUYER_BUILDING_NAME + '"' + ',' //B12.BUYER_BUILDING_NAME (O)
    //                         + '"' + BUYER_BUILDING_NO + '"' + ',' //B13.BUYER_BUILDING_NO (O)
    //                         + '"' + BUYER_ADDRESS_LINE1 + '"' + ',' //B14.BUYER_ADDRESS_LINE1 (O)
    //                         + '"' + BUYER_ADDRESS_LINE2 + '"' + ',' //B15.BUYER_ADDRESS_LINE2 (O)
    //                         + '"' + BUYER_ADDRESS_LINE3 + '"' + ',' //B16.BUYER_ADDRESS_LINE3 (O)
    //                         + '"' + BUYER_ADDRESS_LINE4 + '"' + ',' //B17.BUYER_ADDRESS_LINE4 (O)
    //                         + '"' + BUYER_ADDRESS_LINE5 + '"' + ',' //B18.BUYER_ADDRESS_LINE5 (O)
    //                         + '"' + BUYER_STREET_NAME + '"' + ',' //B19.BUYER_STREET_NAME (O)
    //                         + '""' + ',' //B20.BUYER_CITY_SUB_DIV_ID (C)
    //                         + '"' + BUYER_CITY_SUB_DIV_NAME + '"' + ',' //B21.BUYER_CITY_SUB_DIV_NAME (O)
    //                         + '""' + ',' //B22.BUYER_CITY_ID (C)
    //                         + '"' + BUYER_CITY_NAME + '"' + ',' //B23.BUYER_CITY_NAME (O)
    //                         + '""' + ',' //B24.BUYER_COUNTRY_SUB_DIV_ID (C)
    //                         + '"' + BUYER_COUNTRY_SUB_DIV_NAME + '"' + ',' //B25.BUYER_COUNTRY_SUB_DIV_NAME (C)
    //                         + '"' + BUYER_COUNTRY_ID + '"'); //B26.BUYER_COUNTRY_ID (M)
    //                     // End AGE-WE-TAX - Buyer Information

    //                     SaleINVL.RESET;
    //                     SaleINVL.SetRange("Document No.", SaleINVH."No.");
    //                     SaleINVL.SetFilter("No.", '<>%1', '');
    //                     if SaleINVL.FindFirst() THEN BEGIN
    //                         Clear(TAX_CAL_RATE);

    //                         IF SaleINVL.FIND('-') THEN BEGIN
    //                             SaleINVL.CALCSUMS("Amount Including VAT", Amount);
    //                             IF (SaleINVL."Amount Including VAT" - SaleINVL.Amount) <> 0 THEN BEGIN
    //                                 TAX_CAL_RATE := '7';
    //                             END ELSE BEGIN
    //                                 TAX_CAL_RATE := '0';
    //                             END;
    //                         END;

    //                         if SaleINVL.FindSet() then begin
    //                             repeat
    //                                 Clear(LINE_ID);
    //                                 Clear(PRODUCT_ID);
    //                                 Clear(PRODUCT_NAME);
    //                                 Clear(PRODUCT_CHARGE_AMOUNT);
    //                                 Clear(PRODUCT_QUANTITY);
    //                                 Clear(LINE_TAX_CAL_RATE);
    //                                 Clear(LINE_BASIS_AMOUNT);
    //                                 Clear(LINE_TAX_CAL_AMOUNT);
    //                                 Clear(LINE_ALLOWANCE_CHARGE_IND);
    //                                 Clear(LINE_ALLOWANCE_ACTUAL_AMOUNT);
    //                                 Clear(LINE_ALLOWANCE_REASON);
    //                                 Clear(LINE_TAX_TOTAL_AMOUNT);
    //                                 Clear(LINE_NET_TOTAL_AMOUNT);
    //                                 Clear(LINE_NET_INCLUDE_TAX_TOTAL_AMOUNT);

    //                                 LINE_ID := DELCHR(Format(SaleINVL."Line No."), '=', ',');
    //                                 PRODUCT_ID := SaleINVL."No.";
    //                                 PRODUCT_NAME := SaleINVL.Description + SaleINVL."Description 2";
    //                                 PRODUCT_CHARGE_AMOUNT := DELCHR(Format(SaleINVL."Unit Price", 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');

    //                                 IF TAX_CAL_RATE = '7' THEN BEGIN
    //                                     LINE_TAX_CAL_AMOUNT := DELCHR(Format(SaleINVL."Amount Including VAT" - SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                 END ELSE BEGIN
    //                                     LINE_TAX_CAL_AMOUNT := '0.00';
    //                                 END;

    //                                 IF SaleINVL.Quantity < 0 THEN BEGIN
    //                                     PRODUCT_QUANTITY := DELCHR(Format(ABS(SaleINVL.Quantity), 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                     LINE_ALLOWANCE_CHARGE_IND := 'false';
    //                                     LINE_ALLOWANCE_REASON := PRODUCT_NAME;
    //                                     LINE_BASIS_AMOUNT := '0.00';
    //                                     LINE_TAX_CAL_AMOUNT := '0.00';
    //                                     LINE_TAX_TOTAL_AMOUNT := '0.00';
    //                                     LINE_NET_TOTAL_AMOUNT := '0.00';
    //                                     LINE_NET_INCLUDE_TAX_TOTAL_AMOUNT := '0.00';
    //                                     LINE_ALLOWANCE_ACTUAL_AMOUNT := DELCHR(Format(ABS(SaleINVL.Amount), 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                 END ELSE BEGIN
    //                                     PRODUCT_QUANTITY := DELCHR(Format(SaleINVL.Quantity, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                     LINE_BASIS_AMOUNT := DELCHR(Format(SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                     LINE_TAX_TOTAL_AMOUNT := DELCHR(Format(SaleINVL."Amount Including VAT" - SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                     LINE_NET_TOTAL_AMOUNT := DELCHR(Format(SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                     LINE_NET_INCLUDE_TAX_TOTAL_AMOUNT := DELCHR(Format(SaleINVL."Amount Including VAT" - SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                     LINE_ALLOWANCE_ACTUAL_AMOUNT := '0.00';
    //                                 END;

    //                                 LINE_TAX_CAL_RATE := DELCHR(Format(SaleINVL."VAT %", 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                 LINE_TAX_TOTAL_AMOUNT := DELCHR(Format(SaleINVL."Amount Including VAT" - SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');

    //                                 // AGE-WE-TAX - Trade Line Item Information
    //                                 FileGen.Write(CRLF + '"L"' + ',' //L1.DATA_TYPE (M)
    //                                     + '"' + LINE_ID + '"' + ',' //L2.LINE_ID (M)
    //                                     + '"' + PRODUCT_ID + '"' + ',' //L3.PRODUCT_ID (O)
    //                                     + '"' + PRODUCT_NAME + '"' + ',' //L4.PRODUCT_NAME (M)
    //                                     + '""' + ',' //L5.PRODUCT_DESC (O)
    //                                     + '""' + ',' //L6.PRODUCT_BATCH_ID (O)
    //                                     + '"2019-01-01T00:00:00+07:00"' + ',' //L7.PRODUCT_EXPIRE_DTM (O)
    //                                     + '""' + ',' //L8.PRODUCT_CLASS_CODE (O)
    //                                     + '""' + ',' //L9.PRODUCT_CLASS_NAME (O)
    //                                     + '""' + ',' //L10.PRODUCT_ORIGIN_COUNTRY_ID (O)
    //                                     + '"' + PRODUCT_CHARGE_AMOUNT + '"' + ',' //L11.PRODUCT_CHARGE_AMOUNT (M)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //L12.PRODUCT_CHARGE_CURRENCY_CODE (M)
    //                                     + '""' + ',' //L13.PRODUCT_ALLOWANCE_CHARGE_IND (O)
    //                                     + '"0.00"' + ',' //L14.PRODUCT_ALLOWANCE_ACTUAL_AMOUNT (C)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //L15.PRODUCT_ALLOWANCE_ACTUAL_CURRENCY_CODE (C)
    //                                     + '""' + ',' //L16.PRODUCT_ALLOWANCE_REASON_CODE (O)
    //                                     + '""' + ',' //L17.PRODUCT_ALLOWANCE_REASON (O)
    //                                     + '"' + PRODUCT_QUANTITY + '"' + ',' //L18.PRODUCT_QUANTITY (O)
    //                                     + '""' + ',' //L19.PRODUCT_UNIT_CODE (O)
    //                                     + '"0.00"' + ',' //L20.PRODUCT_QUANTITY_PER_UNIT (O)
    //                                     + '"VAT"' + ',' //L21.LINE_TAX_TYPE_CODE (O)
    //                                     + '"' + LINE_TAX_CAL_RATE + '"' + ',' //L22.LINE_TAX_CAL_RATE (O)
    //                                     + '"' + LINE_BASIS_AMOUNT + '"' + ',' //L23.LINE_BASIS_AMOUNT (O)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //L24.LINE_BASIS_CURRENCY_CODE (O)
    //                                     + '"' + LINE_TAX_CAL_AMOUNT + '"' + ',' //L25.LINE_TAX_CAL_AMOUNT (O)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //L26.LINE_TAX_CAL_CURRENCY_CODE (O)
    //                                     + '"' + LINE_ALLOWANCE_CHARGE_IND + '"' + ',' //L27.LINE_ALLOWANCE_CHARGE_IND (O)
    //                                     + '"' + LINE_ALLOWANCE_ACTUAL_AMOUNT + '"' + ',' //L28.LINE_ALLOWANCE_ACTUAL_AMOUNT (C)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //L29.LINE_ALLOWANCE_ACTUAL_CURRENCY_CODE (C)
    //                                     + '""' + ',' //L30.LINE_ALLOWANCE_REASON_CODE (O)
    //                                     + '"' + LINE_ALLOWANCE_REASON + '"' + ',' //L31.LINE_ALLOWANCE_REASON (O)
    //                                     + '"' + LINE_TAX_TOTAL_AMOUNT + '"' + ',' //L32.LINE_TAX_TOTAL_AMOUNT (O)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //L33.LINE_TAX_TOTAL_CURRENCY_CODE (O)
    //                                     + '"' + LINE_NET_TOTAL_AMOUNT + '"' + ',' //L34.LINE_NET_TOTAL_AMOUNT (O)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //L35.LINE_NET_TOTAL_CURRENCY_CODE (O)
    //                                     + '"' + LINE_NET_INCLUDE_TAX_TOTAL_AMOUNT + '"' + ',' //L36.LINE_NET_INCLUDE_TAX_TOTAL_AMOUNT (O)
    //                                     + '"' + CURRENCY_CODE + '"'); //L37.LINE_NET_INCLUDE_TAX_TOTAL_CURRENCY_CODE (O)

    //                             // End AGE-WE-TAX - Trade Line Item Information

    //                             until SaleINVL.Next = 0;

    //                             SaleINVL.CALCSUMS(Amount, "Amount Including VAT");

    //                             Clear(LINE_TOTAL_COUNT);
    //                             Clear(BASIS_AMOUNT);
    //                             Clear(TAX_CAL_AMOUNT);
    //                             Clear(ORIGINAL_TOTAL_AMOUNT);
    //                             Clear(TAX_BASIS_TOTAL_AMOUNT);
    //                             Clear(TAX_TOTAL_AMOUNT);
    //                             Clear(GRAND_TOTAL_AMOUNT);

    //                             LINE_TOTAL_COUNT := DELCHR(Format(SaleINVL.Count), '=', ',');
    //                             BASIS_AMOUNT := DELCHR(Format(SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                             TAX_CAL_AMOUNT := DELCHR(Format(SaleINVL."Amount Including VAT" - SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                             ORIGINAL_TOTAL_AMOUNT := DELCHR(Format(SaleINVL."Amount Including VAT", 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                             TAX_BASIS_TOTAL_AMOUNT := DELCHR(Format(SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                             TAX_TOTAL_AMOUNT := DELCHR(Format(SaleINVL."Amount Including VAT" - SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                             GRAND_TOTAL_AMOUNT := DELCHR(Format(SaleINVL."Amount Including VAT", 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');

    //                             // AGE-WE-TAX - Document Footer
    //                             FileGen.Write(CRLF + '"F"' + ',' //F1.DATA_TYPE (M)
    //                                 + '"' + LINE_TOTAL_COUNT + '"' + ',' //F2.LINE_TOTAL_COUNT (M)
    //                                 + '"0001-01-01T00:00:00Z"' + ',' //F3.DELIVERY_OCCUR_DTM (O)
    //                                 + '"' + CURRENCY_CODE + '"' + ',' //F4.INVOICE_CURRENCY_CODE (O)
    //                                 + '"VAT"' + ',' //F5.TAX_TYPE_CODE (O)
    //                                 + '"' + TAX_CAL_RATE + '"' + ',' //F6.TAX_CAL_RATE (O)
    //                                 + '"' + BASIS_AMOUNT + '"' + ',' //F7.BASIS_AMOUNT (O)
    //                                 + '"' + CURRENCY_CODE + '"' + ',' //F8.BASIS_CURRENCY_CODE (O)
    //                                 + '"' + TAX_CAL_AMOUNT + '"' + ',' //F9.TAX_CAL_AMOUNT (O)
    //                                 + '"' + CURRENCY_CODE + '"' + ',' //F10.TAX_CAL_CURRENCY_CODE (O)
    //                                 + '""' + ',' //F29.ALLOWANCE_CHARGE_IND (O)
    //                                 + '"0.00"' + ',' //F30.ALLOWANCE_ACTUAL_AMOUNT (C)
    //                                 + '"' + CURRENCY_CODE + '"' + ',' //F31.ALLOWANCE_ACTUAL_CURRENCY_CODE (C)
    //                                 + '""' + ',' //F32.ALLOWANCE_REASON_CODE (O)
    //                                 + '""' + ',' //F33.ALLOWANCE_REASON (O)
    //                                 + '""' + ',' //F34.PAYMENT_TYPE_CODE (O)
    //                                 + '""' + ',' //F35.PAYMENT_DESCRIPTION (O)
    //                                 + '"0001-01-01T00:00:00Z"' + ',' //F36.PAYMENT_DUE_DTM (O)
    //                                 + '"' + ORIGINAL_TOTAL_AMOUNT + '"' + ',' //F37.ORIGINAL_TOTAL_AMOUNT (N)
    //                                 + '"' + CURRENCY_CODE + '"' + ',' //F38.ORIGINAL_TOTAL_CURRENCY_CODE (N)
    //                                 + '"0.00"' + ',' //F39.LINE_TOTAL_AMOUNT (O)
    //                                 + '"' + CURRENCY_CODE + '"' + ',' //F40.LINE_TOTAL_CURRENCY_CODE (O)
    //                                 + '"0.00"' + ',' //F41.ADJUSTED_INFORMATION_AMOUNT (N)
    //                                 + '"' + CURRENCY_CODE + '"' + ',' //F42.ADJUSTED_INFORMATION_CURRENCY_CODE (N)
    //                                 + '"0.00"' + ',' //F43.ALLOWANCE_TOTAL_AMOUNT (O)
    //                                 + '"' + CURRENCY_CODE + '"' + ',' //F44.ALLOWANCE_TOTAL_CURRENCY_CODE (O)
    //                                 + '"0.00"' + ',' //F45.CHARGE_TOTAL_AMOUNT (O)
    //                                 + '"' + CURRENCY_CODE + '"' + ',' //F46.CHARGE_TOTAL_CURRENCY_CODE (O)
    //                                 + '"' + TAX_BASIS_TOTAL_AMOUNT + '"' + ',' //F47.TAX_BASIS_TOTAL_AMOUNT (O)
    //                                 + '"' + CURRENCY_CODE + '"' + ',' //F48.TAX_BASIS_TOTAL_CURRENCY_CODE (O)
    //                                 + '"' + TAX_TOTAL_AMOUNT + '"' + ',' //F49.TAX_TOTAL_AMOUNT (O)
    //                                 + '"' + CURRENCY_CODE + '"' + ',' //F50.TAX_TOTAL_CURRENCY_CODE (O)
    //                                 + '"' + GRAND_TOTAL_AMOUNT + '"' + ',' //F51.GRAND_TOTAL_AMOUNT (O)
    //                                 + '"' + CURRENCY_CODE + '"'); //F52.GRAND_TOTAL_CURRENCY_CODE (O)

    //                             // End AGE-WE-TAX - Document Footer

    //                             // AGE-WE-TAX - File Trailer
    //                             FileGen.Write(CRLF + '"T"' + ',' //T.DATA_TYPE (M)
    //                                 + '"1"'); //T.TOTAL_DOCUMENT_COUNT (M)
    //                             // End AGE-WE-TAX - File Trailer
    //                         end;
    //                     end;
    //                 end;
    //             end;
    //         end else
    //             if (EtaxHead."BWK E-Tax Document Type" = EtaxHead."BWK E-Tax Document Type"::DN) then begin
    //                 CompanyInfo.Reset();
    //                 CompanyInfo.get();

    //                 SELLER_TAX_ID := CompanyInfo."VAT Registration No.";
    //                 SELLER_BRANCH_ID := CompanyInfo."Bank Branch No.";

    //                 // Start AGE-WE-TAX - File Control
    //                 FileGen.Write('"C"' + ',' //C1.DATA_TYPE (M)
    //                     + '"' + SELLER_TAX_ID + '"' + ',' //C2.SELLER_TAX_ID (M)
    //                     + '"' + SELLER_BRANCH_ID + '"' + ',' //C3.SELLER_BRANCH_ID (M)
    //                     + '"' + FILE_NAME + '"' + ','); //C4.FILE_NAME (O
    //                 // End AGE-WE-TAX - File Control

    //                 Cust.Reset();
    //                 Cust.SetRange("No.", EtaxLine."BWK Customer No.");
    //                 if Cust.FindFirst() then begin
    //                     SaleINVH.Reset();
    //                     SaleINVH.SetRange("No.", EtaxLine."BWK Document No.");
    //                     if SaleINVH.FindFirst() then begin
    //                         Clear(CURRENCY_CODE);
    //                         Clear(DOCUMENT_ID);
    //                         Clear(DOCUMENT_ISSUE_DTM);
    //                         Clear(CREATE_PURPOSE_CODE);
    //                         Clear(CREATE_PURPOSE);
    //                         Clear(ADDITIONAL_REF_ASSIGN_ID);
    //                         Clear(ADDITIONAL_REF_ISSUE_DTM);
    //                         Clear(ADDITIONAL_REF_TYPE_CODE);
    //                         Clear(ADDITIONAL_REF_DOCUMENT_NAME);
    //                         Clear(SEND_EMAIL);

    //                         if SaleINVH."Currency Code" <> '' then begin
    //                             CURRENCY_CODE := COPYSTR(SaleINVH."Currency Code", 1, 3);
    //                         end else begin
    //                             CURRENCY_CODE := 'THB';
    //                         end;

    //                         DOCUMENT_ID := SaleINVH."No.";

    //                         if SaleINVH."Posting Date" = 0D then
    //                             ADDITIONAL_REF_ISSUE_DTM := Format(SaleINVH."Posting Date", 0, '<Year4>-<Month,2>-<Day,2>T00:00:00');

    //                         DOCUMENT_ISSUE_DTM := Format(CURRENTDATETIME, 0, '<Year4>-<Month,2>-<Day,2>T00:00:00');

    //                         //IF SaleINVH."BWK DN Purpost Code" = SaleINVH."BWK DN Purpost Code"::" " THEN
    //                         IF SaleINVH."BWK DN Purpost Code" = '' THEN
    //                             CREATE_PURPOSE_CODE := 'DBNG01'
    //                         ELSE
    //                             CREATE_PURPOSE_CODE := Format(SaleINVH."BWK DN Purpost Code");

    //                         CREATE_PURPOSE := SaleINVH."BWK DN Purpost Name";

    //                         // AGECN_DN.Reset();
    //                         // AGECN_DN.SetRange("Apply From Doc. No.", SaleINVH."No.");
    //                         // AGECN_DN.SetRange("Apply From Doc. Type", AGECN_DN."Apply From Doc. Type"::Invoice);

    //                         // if AGECN_DN.FindFirst() then begin
    //                         //     ADDITIONAL_REF_ASSIGN_ID := AGECN_DN."Document No.";
    //                         //     ADDITIONAL_REF_ISSUE_DTM := Format(CURRENTDATETIME, 0, '<Year4>-<Month,2>-<Day,2>T00:00:00');
    //                         //     ADDITIONAL_REF_TYPE_CODE := 'T02';
    //                         //     ADDITIONAL_REF_DOCUMENT_NAME := 'ใบแจ้งหนี้/ใบกำกับภาษี';
    //                         // end;

    //                         if SaleINVH."BWK Applies-to ID" <> '' then begin
    //                             ADDITIONAL_REF_ASSIGN_ID := SaleINVH."BWK Applies-to ID";
    //                         end;

    //                         if SaleINVH."Applies-to Doc. No." <> '' then begin
    //                             ADDITIONAL_REF_ASSIGN_ID := SaleINVH."Applies-to Doc. No.";
    //                         end;

    //                         ADDITIONAL_REF_ISSUE_DTM := Format(CURRENTDATETIME, 0, '<Year4>-<Month,2>-<Day,2>T00:00:00');
    //                         ADDITIONAL_REF_TYPE_CODE := 'T02';
    //                         ADDITIONAL_REF_DOCUMENT_NAME := 'ใบแจ้งหนี้/ใบกำกับภาษี';

    //                         // if EtaxLine."BWK Etax Select Non Send Email" then
    //                         SEND_EMAIL := 'N';
    //                         // else
    //                         //     SEND_EMAIL := 'Y';

    //                         // AGE-WE-TAX - Document Header
    //                         FileGen.Write(CRLF + '"H"' + ',' //H1.DATA_TYPE (M)
    //                             + '"80"' + ',' //H2.DOCUMENT_TYPE_CODE (M)
    //                             + '"ใบเพิ่มหนี้"' + ',' //H3.DOCUMENT_NAME (C)
    //                             + '"' + DOCUMENT_ID + '"' + ',' //H4.DOCUMENT_ID (M)
    //                             + '"' + DOCUMENT_ISSUE_DTM + '"' + ',' //H5.DOCUMENT_ISSUE_DTM (M)
    //                             + '"' + CREATE_PURPOSE_CODE + '"' + ',' //H6.CREATE_PURPOSE_CODE (M)
    //                             + '"' + CREATE_PURPOSE + '"' + ',' //H7.CREATE_PURPOSE 
    //                             + '"' + ADDITIONAL_REF_ASSIGN_ID + '"' + ',' //H8.ADDITIONAL_REF_ASSIGN_ID (M)
    //                             + '"' + ADDITIONAL_REF_ISSUE_DTM + '"' + ',' //H9.ADDITIONAL_REF_ISSUE_DTM (M)
    //                             + '"' + ADDITIONAL_REF_TYPE_CODE + '"' + ',' //H10.ADDITIONAL_REF_TYPE_CODE (M)
    //                             + '"' + ADDITIONAL_REF_DOCUMENT_NAME + '"' + ',' //H11.ADDITIONAL_REF_DOCUMENT_NAME (C)
    //                             + '""' + ',' //H12.DELIVERY_TYPE_CODE (O)
    //                             + '""' + ',' //H13.BUYER_ORDER_ASSIGN_ID (O)
    //                             + '""' + ',' //H14.BUYER_ORDER_ISSUE_DTM (O)
    //                             + '""' + ',' //H15.BUYER_ORDER_REF_TYPE_CODE (O)
    //                             + '""' + ',' //H16.DOCUMENT_REMARK (O)
    //                             + '""' + ',' //H17.VOUCHER_NO (O)
    //                             + '""' + ',' //H18.SELLER_CONTACT_PERSON_NAME (O)
    //                             + '""' + ',' //H19.SELLER_CONTACT_DEPARTMENT_NAME (O)
    //                             + '""' + ',' //H20.SELLER_CONTACT_URIID (O)
    //                             + '""' + ',' //H21.SELLER_CONTACT_PHONE_NO (O)
    //                             + '""' + ',' //H22.FLEX_FIELD (O)
    //                             + '""' + ',' //H23.SELLER_BRANCH_ID (O)
    //                             + '""' + ',' //H24.SOURCE_SYSTEM (O)
    //                             + '""' + ',' //H25.ENCRYPT_PASSWORD (O)
    //                             + '""' + ',' //H26.PDF_TEMPLATE_ID (O)
    //                             + '"' + SEND_EMAIL + '"'); //H27.SEND_EMAIL (O)

    //                         // End AGE-WE-TAX - Document Header

    //                         Clear(BUYER_ID);
    //                         Clear(BUYER_NAME);
    //                         Clear(BUYER_TAX_ID_TYPE);
    //                         Clear(BUYER_TAX_ID);
    //                         Clear(BUYER_BRANCH_ID);
    //                         Clear(BUYER_URIID);
    //                         Clear(BUYER_POST_CODE);
    //                         Clear(BUYER_BUILDING_NAME);
    //                         Clear(BUYER_ADDRESS_LINE1);
    //                         Clear(BUYER_ADDRESS_LINE2);
    //                         Clear(BUYER_ADDRESS_LINE3);
    //                         Clear(BUYER_ADDRESS_LINE4);
    //                         Clear(BUYER_ADDRESS_LINE5);
    //                         Clear(BUYER_STREET_NAME);
    //                         Clear(BUYER_CITY_SUB_DIV_NAME);
    //                         Clear(BUYER_CITY_NAME);
    //                         Clear(BUYER_COUNTRY_SUB_DIV_NAME);
    //                         Clear(BUYER_COUNTRY_ID);

    //                         BUYER_ID := Cust."No.";
    //                         BUYER_NAME := SaleINVH."Sell-to Customer Name";
    //                         BUYER_TAX_ID_TYPE := 'TXID';
    //                         BUYER_TAX_ID := Cust."VAT Registration No.";

    //                         IF Cust."BWK Etax Taxpayer Type" = Cust."BWK Etax Taxpayer Type"::TXID THEN
    //                             BUYER_TAX_ID_TYPE := 'TXID'
    //                         ELSE
    //                             IF Cust."BWK Etax Taxpayer Type" = Cust."BWK Etax Taxpayer Type"::NIDN THEN
    //                                 BUYER_TAX_ID_TYPE := 'NIDN'
    //                             ELSE
    //                                 IF Cust."BWK Etax Taxpayer Type" = Cust."BWK Etax Taxpayer Type"::CCPT THEN
    //                                     BUYER_TAX_ID_TYPE := 'CCPT'
    //                                 ELSE
    //                                     IF Cust."BWK Etax Taxpayer Type" = Cust."BWK Etax Taxpayer Type"::OTHR THEN begin
    //                                         BUYER_TAX_ID_TYPE := 'OTHR';
    //                                         BUYER_TAX_ID := 'N/A';
    //                                     end;

    //                         BUYER_BRANCH_ID := Cust."BWK Etax Branch Code";

    //                         if SaleINVH."BWK Etax E-Mail" <> '' then begin
    //                             BUYER_URIID := SaleINVH."BWK Etax E-Mail";
    //                         end else begin
    //                             BUYER_URIID := Cust."BWK Etax E-Mail";
    //                         end;

    //                         BUYER_POST_CODE := Cust."Post Code";
    //                         BUYER_BUILDING_NAME := Cust."BWK Etax Building Name";
    //                         BUYER_BUILDING_NO := Cust."BWK Etax Building No.";
    //                         BUYER_ADDRESS_LINE1 := Cust."BWK Etax Address1";
    //                         BUYER_ADDRESS_LINE2 := Cust."BWK Etax Address2";
    //                         BUYER_ADDRESS_LINE3 := Cust."BWK Etax Address3";
    //                         BUYER_ADDRESS_LINE4 := Cust."BWK Etax Address4";
    //                         BUYER_ADDRESS_LINE5 := Cust."BWK Etax Address5";
    //                         BUYER_STREET_NAME := Cust."BWK Etax Street";
    //                         BUYER_CITY_SUB_DIV_NAME := Cust."BWK Etax City Sub";
    //                         BUYER_CITY_NAME := Cust."BWK Etax City";
    //                         BUYER_COUNTRY_SUB_DIV_NAME := Cust."BWK Etax Sub Country";
    //                         BUYER_COUNTRY_ID := Cust."BWK Etax Country ID";

    //                         // AGE-WE-TAX - Buyer Information
    //                         FileGen.Write(CRLF + '"B"' + ',' //B1.DATA_TYPE (M)
    //                             + '"' + BUYER_ID + '"' + ',' //B2.BUYER_ID (O)
    //                             + '"' + BUYER_NAME + '"' + ',' //B3.BUYER_NAME (M)
    //                             + '"' + BUYER_TAX_ID_TYPE + '"' + ',' //B4.BUYER_TAX_ID_TYPE (M)
    //                             + '"' + BUYER_TAX_ID + '"' + ',' //B5.BUYER_TAX_ID (M)
    //                             + '"' + BUYER_BRANCH_ID + '"' + ',' //B6.BUYER_BRANCH_ID (C)
    //                             + '""' + ',' //B7.BUYER_CONTACT_PERSON_NAME (O)
    //                             + '""' + ',' //B8.BUYER_CONTACT_DEPARTMENT_NAME (O)
    //                             + '"' + BUYER_URIID + '"' + ',' //B9.BUYER_URIID (O)
    //                             + '""' + ',' //B10.BUYER_CONTACT_PHONE_NO (O)
    //                             + '"' + BUYER_POST_CODE + '"' + ',' //B11.BUYER_POST_CODE (O)
    //                             + '"' + BUYER_BUILDING_NAME + '"' + ',' //B12.BUYER_BUILDING_NAME (O)
    //                             + '"' + BUYER_BUILDING_NO + '"' + ',' //B13.BUYER_BUILDING_NO (O)
    //                             + '"' + BUYER_ADDRESS_LINE1 + '"' + ',' //B14.BUYER_ADDRESS_LINE1 (O)
    //                             + '"' + BUYER_ADDRESS_LINE2 + '"' + ',' //B15.BUYER_ADDRESS_LINE2 (O)
    //                             + '"' + BUYER_ADDRESS_LINE3 + '"' + ',' //B16.BUYER_ADDRESS_LINE3 (O)
    //                             + '"' + BUYER_ADDRESS_LINE4 + '"' + ',' //B17.BUYER_ADDRESS_LINE4 (O)
    //                             + '"' + BUYER_ADDRESS_LINE5 + '"' + ',' //B18.BUYER_ADDRESS_LINE5 (O)
    //                             + '"' + BUYER_STREET_NAME + '"' + ',' //B19.BUYER_STREET_NAME (O)
    //                             + '""' + ',' //B20.BUYER_CITY_SUB_DIV_ID (O)
    //                             + '"' + BUYER_CITY_SUB_DIV_NAME + '"' + ',' //B21.BUYER_CITY_SUB_DIV_NAME (C)
    //                             + '""' + ',' //B22.BUYER_CITY_ID (O)
    //                             + '"' + BUYER_CITY_NAME + '"' + ',' //B23.BUYER_CITY_NAME (C)
    //                             + '""' + ',' //B24.BUYER_COUNTRY_SUB_DIV_ID (O)
    //                             + '"' + BUYER_COUNTRY_SUB_DIV_NAME + '"' + ',' //B25.BUYER_COUNTRY_SUB_DIV_NAME (C)
    //                             + '"' + BUYER_COUNTRY_ID + '"'); //B26.BUYER_COUNTRY_ID (M)

    //                         // End AGE-WE-TAX - Buyer Information


    //                         SaleINVL.RESET;
    //                         SaleINVL.SetRange("Document No.", SaleINVH."No.");
    //                         if SaleINVL.FindFirst() THEN BEGIN
    //                             Clear(TAX_CAL_RATE);

    //                             IF SaleINVL.FIND('-') THEN BEGIN
    //                                 SaleINVL.CALCSUMS("Amount Including VAT", Amount);
    //                                 IF (SaleINVL."Amount Including VAT" - SaleINVL.Amount) <> 0 THEN BEGIN
    //                                     TAX_CAL_RATE := '7';
    //                                 END ELSE BEGIN
    //                                     TAX_CAL_RATE := '0';
    //                                 END;
    //                             END;

    //                             if SaleINVL.FindSet() then begin
    //                                 repeat
    //                                     Clear(LINE_ID);
    //                                     Clear(PRODUCT_ID);
    //                                     Clear(PRODUCT_NAME);
    //                                     Clear(PRODUCT_CHARGE_AMOUNT);
    //                                     Clear(PRODUCT_QUANTITY);
    //                                     Clear(LINE_TAX_CAL_RATE);
    //                                     Clear(LINE_BASIS_AMOUNT);
    //                                     Clear(LINE_TAX_CAL_AMOUNT);
    //                                     Clear(LINE_ALLOWANCE_CHARGE_IND);
    //                                     Clear(LINE_ALLOWANCE_ACTUAL_AMOUNT);
    //                                     Clear(LINE_ALLOWANCE_REASON);
    //                                     Clear(LINE_TAX_TOTAL_AMOUNT);
    //                                     Clear(LINE_NET_TOTAL_AMOUNT);
    //                                     Clear(LINE_NET_INCLUDE_TAX_TOTAL_AMOUNT);

    //                                     LINE_ID := DELCHR(Format(SaleINVL."Line No."), '=', ',');
    //                                     PRODUCT_ID := SaleINVL."No.";
    //                                     PRODUCT_NAME := SaleINVL.Description + SaleINVL."Description 2";
    //                                     PRODUCT_CHARGE_AMOUNT := DELCHR(Format(SaleINVL."Unit Price", 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');

    //                                     IF TAX_CAL_RATE = '7' THEN BEGIN
    //                                         LINE_TAX_CAL_AMOUNT := DELCHR(Format(SaleINVL."Amount Including VAT" - SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                     END ELSE BEGIN
    //                                         LINE_TAX_CAL_AMOUNT := '0.00';
    //                                     END;

    //                                     PRODUCT_QUANTITY := DELCHR(Format(SaleINVL.Quantity, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                     LINE_BASIS_AMOUNT := DELCHR(Format(SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                     LINE_TAX_TOTAL_AMOUNT := DELCHR(Format(SaleINVL."Amount Including VAT" - SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                     LINE_NET_TOTAL_AMOUNT := DELCHR(Format(SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                     LINE_NET_INCLUDE_TAX_TOTAL_AMOUNT := DELCHR(Format(SaleINVL."Amount Including VAT" - SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                     LINE_TAX_CAL_RATE := DELCHR(Format(SaleINVL."VAT %", 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                     LINE_TAX_TOTAL_AMOUNT := DELCHR(Format(SaleINVL."Amount Including VAT" - SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');

    //                                     // AGE-WE-TAX - Trade Line Item Information
    //                                     FileGen.Write(CRLF + '"L"' + ',' //L1.DATA_TYPE (M)
    //                                         + '"' + LINE_ID + '"' + ',' //L2.LINE_ID (M)
    //                                         + '"' + PRODUCT_ID + '"' + ',' //L3.PRODUCT_ID (O)
    //                                         + '"' + PRODUCT_NAME + '"' + ',' //L4.PRODUCT_NAME (M)
    //                                         + '""' + ',' //L5.PRODUCT_DESC (O)
    //                                         + '""' + ',' //L6.PRODUCT_BATCH_ID (O)
    //                                         + '"2019-01-01T00:00:00+07:00"' + ',' //L7.PRODUCT_EXPIRE_DTM (O)
    //                                         + '""' + ',' //L8.PRODUCT_CLASS_CODE (O)
    //                                         + '""' + ',' //L9.PRODUCT_CLASS_NAME (O)
    //                                         + '""' + ',' //L10.PRODUCT_ORIGIN_COUNTRY_ID (O)
    //                                         + '"' + PRODUCT_CHARGE_AMOUNT + '"' + ',' //L11.PRODUCT_CHARGE_AMOUNT (M)
    //                                         + '"' + CURRENCY_CODE + '"' + ',' //L12.PRODUCT_CHARGE_CURRENCY_CODE (M)
    //                                         + '""' + ',' //L13.PRODUCT_ALLOWANCE_CHARGE_IND (O)
    //                                         + '"0.00"' + ',' //L14.PRODUCT_ALLOWANCE_ACTUAL_AMOUNT (C)
    //                                         + '"' + CURRENCY_CODE + '"' + ',' //L15.PRODUCT_ALLOWANCE_ACTUAL_CURRENCY_CODE (C)
    //                                         + '""' + ',' //L16.PRODUCT_ALLOWANCE_REASON_CODE (O)
    //                                         + '""' + ',' //L17.PRODUCT_ALLOWANCE_REASON (O)
    //                                         + '"' + PRODUCT_QUANTITY + '"' + ',' //L18.PRODUCT_QUANTITY (O)
    //                                         + '""' + ',' //L19.PRODUCT_UNIT_CODE (O)
    //                                         + '"0.00"' + ',' //L20.PRODUCT_QUANTITY_PER_UNIT (O)
    //                                         + '"VAT"' + ',' //L21.LINE_TAX_TYPE_CODE (M)
    //                                         + '"' + LINE_TAX_CAL_RATE + '"' + ',' //L22.LINE_TAX_CAL_RATE (M)
    //                                         + '"' + LINE_BASIS_AMOUNT + '"' + ',' //L23.LINE_BASIS_AMOUNT (M)
    //                                         + '"' + CURRENCY_CODE + '"' + ',' //L24.LINE_BASIS_CURRENCY_CODE (M)
    //                                         + '"' + LINE_TAX_CAL_AMOUNT + '"' + ',' //L25.LINE_TAX_CAL_AMOUNT (M)
    //                                         + '"' + CURRENCY_CODE + '"' + ',' //L26.LINE_TAX_CAL_CURRENCY_CODE (M)
    //                                         + '""' + ',' //L27.LINE_ALLOWANCE_CHARGE_IND (O)
    //                                         + '"0.00"' + ',' //L28.LINE_ALLOWANCE_ACTUAL_AMOUNT (O)
    //                                         + '"' + CURRENCY_CODE + '"' + ',' //L29.LINE_ALLOWANCE_ACTUAL_CURRENCY_CODE (O)
    //                                         + '""' + ',' //L30.LINE_ALLOWANCE_REASON_CODE (O)
    //                                         + '""' + ',' //L31.LINE_ALLOWANCE_REASON (O)
    //                                         + '"' + LINE_TAX_TOTAL_AMOUNT + '"' + ',' //L32.LINE_TAX_TOTAL_AMOUNT (O)
    //                                         + '"' + CURRENCY_CODE + '"' + ',' //L33.LINE_TAX_TOTAL_CURRENCY_CODE (O)
    //                                         + '"' + LINE_NET_TOTAL_AMOUNT + '"' + ',' //L34.LINE_NET_TOTAL_AMOUNT (M)
    //                                         + '"' + CURRENCY_CODE + '"' + ',' //L35.LINE_NET_TOTAL_CURRENCY_CODE (M)
    //                                         + '"' + LINE_NET_INCLUDE_TAX_TOTAL_AMOUNT + '"' + ',' //L36.LINE_NET_INCLUDE_TAX_TOTAL_AMOUNT (M)
    //                                         + '"' + CURRENCY_CODE + '"'); //L37.LINE_NET_INCLUDE_TAX_TOTAL_CURRENCY_CODE (M)

    //                                 // End AGE-WE-TAX - Trade Line Item Information

    //                                 until SaleINVL.Next = 0;

    //                                 SaleINVL.CALCSUMS(Amount, "Amount Including VAT");

    //                                 Clear(LINE_TOTAL_COUNT);
    //                                 Clear(BASIS_AMOUNT);
    //                                 Clear(TAX_CAL_AMOUNT);
    //                                 Clear(ORIGINAL_TOTAL_AMOUNT);
    //                                 Clear(TAX_BASIS_TOTAL_AMOUNT);
    //                                 Clear(TAX_TOTAL_AMOUNT);
    //                                 Clear(GRAND_TOTAL_AMOUNT);

    //                                 LINE_TOTAL_COUNT := DELCHR(Format(SaleINVL.Count), '=', ',');
    //                                 BASIS_AMOUNT := DELCHR(Format(SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                 TAX_CAL_AMOUNT := DELCHR(Format(SaleINVL."Amount Including VAT" - SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                 ORIGINAL_TOTAL_AMOUNT := DELCHR(Format(SaleINVL."Amount Including VAT", 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                 TAX_BASIS_TOTAL_AMOUNT := DELCHR(Format(SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                 TAX_TOTAL_AMOUNT := DELCHR(Format(SaleINVL."Amount Including VAT" - SaleINVL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                 GRAND_TOTAL_AMOUNT := DELCHR(Format(SaleINVL."Amount Including VAT", 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');

    //                                 // AGE-WE-TAX - Document Footer
    //                                 FileGen.Write(CRLF + '"F"' + ',' //F1.DATA_TYPE (M)
    //                                     + '"' + LINE_TOTAL_COUNT + '"' + ',' //F2.LINE_TOTAL_COUNT (M)
    //                                     + '"0001-01-01T00:00:00Z"' + ',' //F3.DELIVERY_OCCUR_DTM (O)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F4.INVOICE_CURRENCY_CODE (O)
    //                                     + '"VAT"' + ',' //F5.TAX_TYPE_CODE (M)
    //                                     + '"' + TAX_CAL_RATE + '"' + ',' //F6.TAX_CAL_RATE (M)
    //                                     + '"' + BASIS_AMOUNT + '"' + ',' //F7.BASIS_AMOUNT (M)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F8.BASIS_CURRENCY_CODE (M)
    //                                     + '"' + TAX_CAL_AMOUNT + '"' + ',' //F9.TAX_CAL_AMOUNT (M) 
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F10.TAX_CAL_CURRENCY_CODE (M)
    //                                     + '""' + ',' //F29.ALLOWANCE_CHARGE_IND (O)
    //                                     + '"0.00"' + ',' //F30.ALLOWANCE_ACTUAL_AMOUNT (C)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F31.ALLOWANCE_ACTUAL_CURRENCY_CODE (C)
    //                                     + '""' + ',' //F32.ALLOWANCE_REASON_CODE (C)
    //                                     + '""' + ',' //F33.ALLOWANCE_REASON (O)
    //                                     + '""' + ',' //F34.PAYMENT_TYPE_CODE (O)
    //                                     + '""' + ',' //F35.PAYMENT_DESCRIPTION (O)
    //                                     + '"0001-01-01T00:00:00Z"' + ',' //F36.PAYMENT_DUE_DTM (O)
    //                                     + '"' + ORIGINAL_TOTAL_AMOUNT + '"' + ',' //F37.ORIGINAL_TOTAL_AMOUNT (M)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F38.ORIGINAL_TOTAL_CURRENCY_CODE (M)
    //                                     + '"0.00"' + ',' //F39.LINE_TOTAL_AMOUNT (M)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F40.LINE_TOTAL_CURRENCY_CODE (M)
    //                                     + '"0.00"' + ',' //F41.ADJUSTED_INFORMATION_AMOUNT (M)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F42.ADJUSTED_INFORMATION_CURRENCY_CODE (M)
    //                                     + '"0.00"' + ',' //F43.ALLOWANCE_TOTAL_AMOUNT (O)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F44.ALLOWANCE_TOTAL_CURRENCY_CODE (O)
    //                                     + '"0.00"' + ',' //F45.CHARGE_TOTAL_AMOUNT (O)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F46.CHARGE_TOTAL_CURRENCY_CODE (O)
    //                                     + '"' + TAX_BASIS_TOTAL_AMOUNT + '"' + ',' //F47.TAX_BASIS_TOTAL_AMOUNT (M)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F48.TAX_BASIS_TOTAL_CURRENCY_CODE (M)
    //                                     + '"' + TAX_TOTAL_AMOUNT + '"' + ',' //F49.TAX_TOTAL_AMOUNT (M)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F50.TAX_TOTAL_CURRENCY_CODE (M)
    //                                     + '"' + GRAND_TOTAL_AMOUNT + '"' + ',' //F51.GRAND_TOTAL_AMOUNT (M) 
    //                                     + '"' + CURRENCY_CODE + '"'); //F52.GRAND_TOTAL_CURRENCY_CODE (M)

    //                                 // End AGE-WE-TAX - Document Footer

    //                                 // AGE-WE-TAX - File Trailer
    //                                 FileGen.Write(CRLF + '"T"' + ',' //T.DATA_TYPE (M)
    //                                     + '"1"'); //T.TOTAL_DOCUMENT_COUNT (M)

    //                                 // End AGE-WE-TAX - File Trailer
    //                             end;
    //                         end;
    //                     end;
    //                 end;
    //             end else
    //                 if EtaxHead."BWK E-Tax Document Type" = EtaxHead."BWK E-Tax Document Type"::CN then begin
    //                     CompanyInfo.Reset();
    //                     CompanyInfo.get();

    //                     SELLER_TAX_ID := CompanyInfo."VAT Registration No.";
    //                     SELLER_BRANCH_ID := CompanyInfo."Bank Branch No.";

    //                     // Start AGE-WE-TAX - File Control
    //                     FileGen.Write(CRLF + '"C"' + ',' //C1.DATA_TYPE (M)
    //                         + '"' + SELLER_TAX_ID + '"' + ',' //C2.SELLER_TAX_ID (M)
    //                         + '"' + SELLER_BRANCH_ID + '"' + ',' //C3.SELLER_BRANCH_ID (M)
    //                         + '"' + FILE_NAME + '"' + ','); //C4.FILE_NAME (O)
    //                     // End AGE-WE-TAX - File Control

    //                     Cust.Reset();
    //                     Cust.SetRange("No.", EtaxLine."BWK Customer No.");
    //                     if Cust.FindFirst() then begin
    //                         Clear(CURRENCY_CODE);
    //                         Clear(DOCUMENT_ID);
    //                         Clear(DOCUMENT_ISSUE_DTM);
    //                         Clear(CREATE_PURPOSE_CODE);
    //                         Clear(CREATE_PURPOSE);
    //                         Clear(ADDITIONAL_REF_ASSIGN_ID);
    //                         Clear(ADDITIONAL_REF_ISSUE_DTM);
    //                         Clear(ADDITIONAL_REF_TYPE_CODE);
    //                         Clear(SEND_EMAIL);

    //                         SaleCrH.Reset();
    //                         SaleCrH.SetRange("No.", EtaxLine."BWK Document No.");
    //                         if SaleCrH.FindFirst() then begin
    //                             if SaleCrH."Currency Code" <> '' then begin
    //                                 CURRENCY_CODE := COPYSTR(SaleCrH."Currency Code", 1, 3);
    //                             end else begin
    //                                 CURRENCY_CODE := 'THB';
    //                             end;

    //                             DOCUMENT_ID := SaleCrH."No.";
    //                             DOCUMENT_ISSUE_DTM := Format(SaleCrH."Posting Date", 0, '<Year4>-<Month,2>-<Day,2>T00:00:00');

    //                             //IF SaleCrH."BWK CN Purpost Code" = SaleCrH."BWK CN Purpost Code"::" " THEN
    //                             IF SaleCrH."BWK CN Purpost Code" = '' THEN
    //                                 CREATE_PURPOSE_CODE := 'CDNG01'
    //                             ELSE
    //                                 CREATE_PURPOSE_CODE := Format(SaleCrH."BWK CN Purpost Code");

    //                             CREATE_PURPOSE := SaleCrH."BWK CN Purpost Name";

    //                             if SaleCrH."Applies-to Doc. No." <> '' then begin
    //                                 ADDITIONAL_REF_ASSIGN_ID := SaleCrH."Applies-to Doc. No.";
    //                                 ADDITIONAL_REF_ISSUE_DTM := Format(CURRENTDATETIME, 0, '<Year4>-<Month,2>-<Day,2>T00:00:00');
    //                                 ADDITIONAL_REF_TYPE_CODE := '388';
    //                             end;

    //                             if SaleCrH."BWK Applies-to ID" <> '' then begin
    //                                 ADDITIONAL_REF_ASSIGN_ID := SaleCrH."BWK Applies-to ID";
    //                                 ADDITIONAL_REF_ISSUE_DTM := Format(CURRENTDATETIME, 0, '<Year4>-<Month,2>-<Day,2>T00:00:00');
    //                                 ADDITIONAL_REF_TYPE_CODE := '388';
    //                             end;
    //                             //end;

    //                             // if EtaxLine."BWK Etax Select Non Send Email" then
    //                             SEND_EMAIL := 'N';
    //                             // else
    //                             //     SEND_EMAIL := 'Y';

    //                             // AGE-WE-TAX - Document Header
    //                             FileGen.Write(CRLF + '"H"' + ',' //H1.DATA_TYPE (M)
    //                                 + '"81"' + ',' //H2.DOCUMENT_TYPE_CODE (M)
    //                                 + '"ใบลดหนี้อิเล็กทรอนิกส์"' + ',' //H3.DOCUMENT_NAME (C)
    //                                 + '"' + DOCUMENT_ID + '"' + ',' //H4.DOCUMENT_ID (M)
    //                                 + '"' + DOCUMENT_ISSUE_DTM + '"' + ',' //H5.DOCUMENT_ISSUE_DTM (M)
    //                                 + '"' + CREATE_PURPOSE_CODE + '"' + ',' //H6.CREATE_PURPOSE_CODE (M)
    //                                 + '"' + CREATE_PURPOSE + '"' + ',' //H7.CREATE_PURPOSE (O)
    //                                 + '"' + ADDITIONAL_REF_ASSIGN_ID + '"' + ',' //H8.ADDITIONAL_REF_ASSIGN_ID (M)
    //                                 + '"' + ADDITIONAL_REF_ISSUE_DTM + '"' + ',' //H9.ADDITIONAL_REF_ISSUE_DTM (M)
    //                                 + '"' + ADDITIONAL_REF_TYPE_CODE + '"' + ',' //H10.ADDITIONAL_REF_TYPE_CODE (M)
    //                                 + '""' + ',' //H11.ADDITIONAL_REF_DOCUMENT_NAME (C)
    //                                 + '""' + ',' //H12.DELIVERY_TYPE_CODE (O)
    //                                 + '""' + ',' //H13.BUYER_ORDER_ASSIGN_ID (O)
    //                                 + '""' + ',' //H14.BUYER_ORDER_ISSUE_DTM (O)
    //                                 + '""' + ',' //H15.BUYER_ORDER_REF_TYPE_CODE (O)
    //                                 + '""' + ',' //H16.DOCUMENT_REMARK (O)
    //                                 + '""' + ',' //H17.VOUCHER_NO (O)
    //                                 + '""' + ',' //H18.SELLER_CONTACT_PERSON_NAME (O)
    //                                 + '""' + ',' //H19.SELLER_CONTACT_DEPARTMENT_NAME (O)
    //                                 + '""' + ',' //H20.SELLER_CONTACT_URIID (O)
    //                                 + '""' + ',' //H21.SELLER_CONTACT_PHONE_NO (O)
    //                                 + '""' + ',' //H22.FLEX_FIELD (O)
    //                                 + '""' + ',' //H23.SELLER_BRANCH_ID (O)
    //                                 + '""' + ',' //H24.SOURCE_SYSTEM (O)
    //                                 + '""' + ',' //H25.ENCRYPT_PASSWORD (O)
    //                                 + '""' + ',' //H26.PDF_TEMPLATE_ID (O)
    //                                 + '"' + SEND_EMAIL + '"'); //H27.SEND_EMAIL (O)

    //                             // End AGE-WE-TAX - Document Header

    //                             Clear(BUYER_ID);
    //                             Clear(BUYER_NAME);
    //                             Clear(BUYER_TAX_ID_TYPE);
    //                             Clear(BUYER_TAX_ID);
    //                             Clear(BUYER_BRANCH_ID);
    //                             Clear(BUYER_URIID);
    //                             Clear(BUYER_POST_CODE);
    //                             Clear(BUYER_BUILDING_NAME);
    //                             Clear(BUYER_BUILDING_NO);
    //                             Clear(BUYER_ADDRESS_LINE1);
    //                             Clear(BUYER_ADDRESS_LINE2);
    //                             Clear(BUYER_ADDRESS_LINE3);
    //                             Clear(BUYER_ADDRESS_LINE4);
    //                             Clear(BUYER_ADDRESS_LINE5);
    //                             Clear(BUYER_STREET_NAME);
    //                             Clear(BUYER_CITY_SUB_DIV_NAME);
    //                             Clear(BUYER_CITY_NAME);
    //                             Clear(BUYER_COUNTRY_SUB_DIV_NAME);
    //                             Clear(BUYER_COUNTRY_ID);

    //                             BUYER_ID := Cust."No.";
    //                             BUYER_NAME := Cust.Name;
    //                             BUYER_TAX_ID_TYPE := 'TXID';

    //                             IF Cust."BWK Etax Taxpayer Type" = Cust."BWK Etax Taxpayer Type"::TXID THEN
    //                                 BUYER_TAX_ID_TYPE := 'TXID'
    //                             ELSE
    //                                 IF Cust."BWK Etax Taxpayer Type" = Cust."BWK Etax Taxpayer Type"::NIDN THEN
    //                                     BUYER_TAX_ID_TYPE := 'NIDN'
    //                                 ELSE
    //                                     IF Cust."BWK Etax Taxpayer Type" = Cust."BWK Etax Taxpayer Type"::CCPT THEN
    //                                         BUYER_TAX_ID_TYPE := 'CCPT'
    //                                     ELSE
    //                                         IF Cust."BWK Etax Taxpayer Type" = Cust."BWK Etax Taxpayer Type"::OTHR THEN
    //                                             BUYER_TAX_ID_TYPE := 'OTHR';

    //                             BUYER_TAX_ID := Cust."VAT Registration No.";
    //                             BUYER_BRANCH_ID := Cust."BWK Etax Branch Code";

    //                             if SaleCrH."BWK Etax E-Mail" = '' then
    //                                 BUYER_URIID := Cust."BWK Etax E-Mail"
    //                             else
    //                                 BUYER_URIID := SaleCrH."BWK Etax E-Mail";

    //                             //BUYER_URIID := Cust."BWK Etax E-Mail";
    //                             BUYER_POST_CODE := Cust."Post Code";
    //                             BUYER_BUILDING_NAME := Cust."BWK Etax Building Name";
    //                             BUYER_BUILDING_NO := Cust."BWK Etax Building No.";
    //                             BUYER_ADDRESS_LINE1 := Cust."BWK Etax Address1";
    //                             BUYER_ADDRESS_LINE2 := Cust."BWK Etax Address2";
    //                             BUYER_ADDRESS_LINE3 := Cust."BWK Etax Address3";
    //                             BUYER_ADDRESS_LINE4 := Cust."BWK Etax Address4";
    //                             BUYER_ADDRESS_LINE5 := Cust."BWK Etax Address5";
    //                             BUYER_STREET_NAME := Cust."BWK Etax Street";
    //                             BUYER_CITY_SUB_DIV_NAME := Cust."BWK Etax City Sub";
    //                             BUYER_CITY_NAME := Cust."BWK Etax City";
    //                             BUYER_COUNTRY_SUB_DIV_NAME := Cust."BWK Etax Sub Country";
    //                             BUYER_COUNTRY_ID := Cust."BWK Etax Country ID";

    //                             // AGE-WE-TAX - Buyer Information
    //                             FileGen.Write(CRLF + '"B"' + ',' //B1.DATA_TYPE (M)
    //                                 + '"' + BUYER_ID + '"' + ',' //B2.BUYER_ID (O)
    //                                 + '"' + BUYER_NAME + '"' + ',' //B3.BUYER_NAME (M)
    //                                 + '"' + BUYER_TAX_ID_TYPE + '"' + ',' //B4.BUYER_TAX_ID_TYPE (M)
    //                                 + '"' + BUYER_TAX_ID + '"' + ',' //B5.BUYER_TAX_ID (M)
    //                                 + '"' + BUYER_BRANCH_ID + '"' + ',' //B6.BUYER_BRANCH_ID (C)
    //                                 + '""' + ',' //B7.BUYER_CONTACT_PERSON_NAME (O)
    //                                 + '""' + ',' //B8.BUYER_CONTACT_DEPARTMENT_NAME (O)
    //                                 + '"' + BUYER_URIID + '"' + ',' //B9.BUYER_URIID (O)
    //                                 + '""' + ',' //B10.BUYER_CONTACT_PHONE_NO (O)
    //                                 + '"' + BUYER_POST_CODE + '"' + ',' //B11.BUYER_POST_CODE (O)
    //                                 + '"' + BUYER_BUILDING_NAME + '"' + ',' //B12.BUYER_BUILDING_NAME (O)
    //                                 + '"' + BUYER_BUILDING_NO + '"' + ',' //B13.BUYER_BUILDING_NO (O)
    //                                 + '"' + BUYER_ADDRESS_LINE1 + '"' + ',' //B14.BUYER_ADDRESS_LINE1 (O)
    //                                 + '"' + BUYER_ADDRESS_LINE2 + '"' + ',' //B15.BUYER_ADDRESS_LINE2 (O)
    //                                 + '"' + BUYER_ADDRESS_LINE3 + '"' + ',' //B16.BUYER_ADDRESS_LINE3 (O)
    //                                 + '"' + BUYER_ADDRESS_LINE4 + '"' + ',' //B17.BUYER_ADDRESS_LINE4 (O)
    //                                 + '"' + BUYER_ADDRESS_LINE5 + '"' + ',' //B18.BUYER_ADDRESS_LINE5 (O)
    //                                 + '"' + BUYER_STREET_NAME + '"' + ',' //B19.BUYER_STREET_NAME (O)
    //                                 + '""' + ',' //B20.BUYER_CITY_SUB_DIV_ID (O)
    //                                 + '"' + BUYER_CITY_SUB_DIV_NAME + '"' + ',' //B21.BUYER_CITY_SUB_DIV_NAME (C)
    //                                 + '""' + ',' //B22.BUYER_CITY_ID (O)
    //                                 + '"' + BUYER_CITY_NAME + '"' + ',' //B23.BUYER_CITY_NAME (C)
    //                                 + '""' + ',' //B24.BUYER_COUNTRY_SUB_DIV_ID (O)
    //                                 + '"' + BUYER_COUNTRY_SUB_DIV_NAME + '"' + ',' //B25.BUYER_COUNTRY_SUB_DIV_NAME (C)
    //                                 + '"' + BUYER_COUNTRY_ID + '"'); //B26.BUYER_COUNTRY_ID (M)

    //                             // End AGE-WE-TAX - Buyer Information

    //                             SaleCrL.Reset();
    //                             SaleCrL.SetRange("Document No.", SaleCrH."No.");
    //                             SaleCrL.SetFilter(Type, '<>%1', SaleCrL.Type::" ");

    //                             if SaleCrL.FindFirst() then begin
    //                                 if SaleCrL.FindSet() then begin
    //                                     repeat
    //                                         Clear(LINE_ID);
    //                                         Clear(PRODUCT_ID);
    //                                         Clear(PRODUCT_NAME);
    //                                         Clear(PRODUCT_CHARGE_AMOUNT);
    //                                         Clear(PRODUCT_QUANTITY);
    //                                         Clear(LINE_TAX_CAL_RATE);
    //                                         Clear(LINE_BASIS_AMOUNT);
    //                                         Clear(LINE_TAX_CAL_AMOUNT);
    //                                         Clear(LINE_ALLOWANCE_ACTUAL_AMOUNT);
    //                                         Clear(LINE_TAX_TOTAL_AMOUNT);
    //                                         Clear(LINE_NET_TOTAL_AMOUNT);
    //                                         Clear(LINE_NET_INCLUDE_TAX_TOTAL_AMOUNT);

    //                                         LINE_ID := DELCHR(Format(SaleCrL."Line No."), '=', ',');
    //                                         PRODUCT_ID := SaleCrL."No.";
    //                                         PRODUCT_NAME := SaleCrL.Description + SaleCrL."Description 2";
    //                                         PRODUCT_CHARGE_AMOUNT := DELCHR(Format(SaleCrL."Unit Price", 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                         PRODUCT_QUANTITY := DELCHR(Format(SaleCrL.Quantity, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                         LINE_TAX_CAL_RATE := DELCHR(Format(SaleCrL."VAT %", 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');

    //                                         IF SaleCrL.Amount < 0 THEN BEGIN
    //                                             LINE_BASIS_AMOUNT := '0.00';
    //                                             LINE_ALLOWANCE_ACTUAL_AMOUNT := DELCHR(Format(SaleCrL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                         END ELSE BEGIN
    //                                             LINE_BASIS_AMOUNT := DELCHR(Format(SaleCrL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                             LINE_ALLOWANCE_ACTUAL_AMOUNT := '0.00';
    //                                         END;

    //                                         LINE_TAX_CAL_AMOUNT := DELCHR(Format(SaleCrL."Amount Including VAT" - SaleCrL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                         LINE_TAX_TOTAL_AMOUNT := DELCHR(Format(SaleCrL."Amount Including VAT" - SaleCrL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                         LINE_NET_TOTAL_AMOUNT := DELCHR(Format(SaleCrL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                         LINE_NET_INCLUDE_TAX_TOTAL_AMOUNT := DELCHR(Format(SaleCrL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');

    //                                         // AGE-WE-TAX - Trade Line Item Information
    //                                         FileGen.Write(CRLF + '"L"' + ',' //L1.DATA_TYPE (M)
    //                                             + '"' + LINE_ID + '"' + ',' //L2.LINE_ID (M)
    //                                             + '"' + PRODUCT_ID + '"' + ',' //L3.PRODUCT_ID (O)
    //                                             + '"' + PRODUCT_NAME + '"' + ',' //L4.PRODUCT_NAME (M)
    //                                             + '""' + ',' //L5.PRODUCT_DESC (O)
    //                                             + '""' + ',' //L6.PRODUCT_BATCH_ID (O)
    //                                             + '"0001-01-01T00:00:00Z"' + ',' //L7.PRODUCT_EXPIRE_DTM (O)
    //                                             + '""' + ',' //L8.PRODUCT_CLASS_CODE (O)
    //                                             + '""' + ',' //L9.PRODUCT_CLASS_NAME (O)
    //                                             + '""' + ',' //L10.PRODUCT_ORIGIN_COUNTRY_ID (O)
    //                                             + '"' + PRODUCT_CHARGE_AMOUNT + '"' + ',' //L11.PRODUCT_CHARGE_AMOUNT (M)
    //                                             + '"' + CURRENCY_CODE + '"' + ',' //L12.PRODUCT_CHARGE_CURRENCY_CODE (M)
    //                                             + '""' + ',' //L13.PRODUCT_ALLOWANCE_CHARGE_IND (O)
    //                                             + '"0.00"' + ',' //L14.PRODUCT_ALLOWANCE_ACTUAL_AMOUNT (C)
    //                                             + '"' + CURRENCY_CODE + '"' + ',' //L15.PRODUCT_ALLOWANCE_ACTUAL_CURRENCY_CODE (C)
    //                                             + '""' + ',' //L16.PRODUCT_ALLOWANCE_REASON_CODE (O)
    //                                             + '""' + ',' //L17.PRODUCT_ALLOWANCE_REASON (O)
    //                                             + '"' + PRODUCT_QUANTITY + '"' + ',' //L18.PRODUCT_QUANTITY (O)
    //                                             + '""' + ',' //L19.PRODUCT_UNIT_CODE (O)
    //                                             + '"0.00"' + ',' //L20.PRODUCT_QUANTITY_PER_UNIT (O)
    //                                             + '"VAT"' + ',' //L21.LINE_TAX_TYPE_CODE (M)
    //                                             + '"' + LINE_TAX_CAL_RATE + '"' + ',' //L22.LINE_TAX_CAL_RATE (M)
    //                                             + '"' + LINE_BASIS_AMOUNT + '"' + ',' //L23.LINE_BASIS_AMOUNT (M)
    //                                             + '"' + CURRENCY_CODE + '"' + ',' //L24.LINE_BASIS_CURRENCY_CODE (M)
    //                                             + '"' + LINE_TAX_CAL_AMOUNT + '"' + ',' //L25.LINE_TAX_CAL_AMOUNT (M)
    //                                             + '"' + CURRENCY_CODE + '"' + ',' //L26.LINE_TAX_CAL_CURRENCY_CODE (M)
    //                                             + '""' + ',' //L27.LINE_ALLOWANCE_CHARGE_IND (O)
    //                                             + '"' + LINE_ALLOWANCE_ACTUAL_AMOUNT + '"' + ',' //L28.LINE_ALLOWANCE_ACTUAL_AMOUNT (C)
    //                                             + '"' + CURRENCY_CODE + '"' + ',' //L29.LINE_ALLOWANCE_ACTUAL_CURRENCY_CODE (C)
    //                                             + '""' + ',' //L30.LINE_ALLOWANCE_REASON_CODE (O)
    //                                             + '""' + ',' //L31.LINE_ALLOWANCE_REASON (O)
    //                                             + '"' + LINE_TAX_TOTAL_AMOUNT + '"' + ',' //L32.LINE_TAX_TOTAL_AMOUNT (O)
    //                                             + '"' + CURRENCY_CODE + '"' + ',' //L33.LINE_TAX_TOTAL_CURRENCY_CODE (O)
    //                                             + '"' + LINE_NET_TOTAL_AMOUNT + '"' + ',' //L34.LINE_NET_TOTAL_AMOUNT (M)
    //                                             + '"' + CURRENCY_CODE + '"' + ',' //L35.LINE_NET_TOTAL_CURRENCY_CODE (M)
    //                                             + '"' + LINE_NET_INCLUDE_TAX_TOTAL_AMOUNT + '"' + ',' //L36.LINE_NET_INCLUDE_TAX_TOTAL_AMOUNT (M)
    //                                             + '"' + CURRENCY_CODE + '"'); //L37.LINE_NET_INCLUDE_TAX_TOTAL_CURRENCY_CODE (M)

    //                                     // End AGE-WE-TAX - Trade Line Item Information

    //                                     until SaleCrL.Next = 0;
    //                                 end;

    //                                 Clear(LINE_TOTAL_COUNT);
    //                                 Clear(TAX_CAL_RATE);
    //                                 Clear(BASIS_AMOUNT);
    //                                 Clear(ORIGINAL_TOTAL_AMOUNT);
    //                                 Clear(ADJUSTED_INFORMATION_AMOUNT);
    //                                 Clear(LINE_TOTAL_AMOUNT);
    //                                 Clear(TAX_BASIS_TOTAL_AMOUNT);
    //                                 Clear(TAX_TOTAL_AMOUNT);
    //                                 Clear(GRAND_TOTAL_AMOUNT);

    //                                 IF SaleCrL.FIND('-') THEN BEGIN
    //                                     SaleCrL.CALCSUMS("Amount Including VAT", Amount);
    //                                     IF (SaleCrL."Amount Including VAT" - SaleCrL.Amount) <> 0 THEN BEGIN
    //                                         TAX_CAL_RATE := '7';
    //                                     END ELSE BEGIN
    //                                         TAX_CAL_RATE := '0';
    //                                     END;
    //                                 END;

    //                                 IF SaleCrL.FINDSET THEN
    //                                     SaleCrL.CALCSUMS(Amount, "Amount Including VAT", "VAT Base Amount");

    //                                 LINE_TOTAL_COUNT := DELCHR(Format(SaleCrL.Count), '=', ',');
    //                                 BASIS_AMOUNT := DELCHR(Format(SaleCrL."VAT Base Amount"), '=', ',');

    //                                 SaleCrL.RESET;
    //                                 SaleCrL.SetRange("Document No.", SaleCrH."No.");

    //                                 IF SaleCrL.FINDSET THEN BEGIN
    //                                     SaleCrL.CALCSUMS(Amount, "Amount Including VAT");
    //                                     ORIGINAL_TOTAL_AMOUNT := DELCHR(Format(SaleCrL.Amount, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                 END;

    //                                 ADJUSTED_INFORMATION_AMOUNT := DELCHR(Format(SaleCrL.Amount - (SaleCrL.Amount - SaleCrL."VAT Base Amount"), 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                 LINE_TOTAL_AMOUNT := DELCHR(Format(Abs(SaleCrL.Amount - SaleCrL."VAT Base Amount"), 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                 TAX_BASIS_TOTAL_AMOUNT := DELCHR(Format(SaleCrL."VAT Base Amount", 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                 TAX_TOTAL_AMOUNT := DELCHR(Format(SaleCrL."Amount Including VAT" - SaleCrL."VAT Base Amount", 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                 GRAND_TOTAL_AMOUNT := DELCHR(Format(SaleCrL."Amount Including VAT", 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');

    //                                 // AGE-WE-TAX - Document Footer
    //                                 FileGen.Write(CRLF + '"F"' + ',' //F1.DATA_TYPE (M)
    //                                     + '"' + LINE_TOTAL_COUNT + '"' + ',' //F2.LINE_TOTAL_COUNT (M)
    //                                     + '"0001-01-01T00:00:00Z"' + ',' //F3.DELIVERY_OCCUR_DTM (O)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F4.INVOICE_CURRENCY_CODE (O)
    //                                     + '"VAT"' + ',' //F5.TAX_TYPE_CODE (M)
    //                                     + '"' + TAX_CAL_RATE + '"' + ',' //F6.TAX_CAL_RATE (M)
    //                                     + '"' + BASIS_AMOUNT + '"' + ',' //F7.BASIS_AMOUNT (M)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F8.BASIS_CURRENCY_CODE (M)
    //                                     + '"0.00"' + ',' //F9.TAX_CAL_AMOUNT (M)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F10.TAX_CAL_CURRENCY_CODE (M)
    //                                     + '""' + ',' //F29.ALLOWANCE_CHARGE_IND (O)
    //                                     + '"0.00"' + ',' //F30.ALLOWANCE_ACTUAL_AMOUNT (C)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F31.ALLOWANCE_ACTUAL_CURRENCY_CODE (C)
    //                                     + '""' + ',' //F32.ALLOWANCE_REASON_CODE (O)
    //                                     + '""' + ',' //F33.ALLOWANCE_REASON (O)
    //                                     + '""' + ',' //F34.PAYMENT_TYPE_CODE (O)
    //                                     + '""' + ',' //F35.PAYMENT_DESCRIPTION (O)
    //                                     + '"0001-01-01T00:00:00Z"' + ',' //F36.PAYMENT_DUE_DTM (O)
    //                                     + '"' + ORIGINAL_TOTAL_AMOUNT + '"' + ',' //F37.ORIGINAL_TOTAL_AMOUNT (M)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F38.ORIGINAL_TOTAL_CURRENCY_CODE (M)
    //                                     + '"' + LINE_TOTAL_AMOUNT + '"' + ',' //F39.LINE_TOTAL_AMOUNT (M)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F40.LINE_TOTAL_CURRENCY_CODE (M)
    //                                     + '"' + ADJUSTED_INFORMATION_AMOUNT + '"' + ',' //F41.ADJUSTED_INFORMATION_AMOUNT (M)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F42.ADJUSTED_INFORMATION_CURRENCY_CODE (M)
    //                                     + '"0.00"' + ',' //F43.ALLOWANCE_TOTAL_AMOUNT (O)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F44.ALLOWANCE_TOTAL_CURRENCY_CODE (O)
    //                                     + '"0.00"' + ',' //F45.CHARGE_TOTAL_AMOUNT (O)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F46.CHARGE_TOTAL_CURRENCY_CODE (O)
    //                                     + '"' + TAX_BASIS_TOTAL_AMOUNT + '"' + ',' //F47.TAX_BASIS_TOTAL_AMOUNT (M)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F48.TAX_BASIS_TOTAL_CURRENCY_CODE (M)
    //                                     + '"' + TAX_TOTAL_AMOUNT + '"' + ',' //F49.TAX_TOTAL_AMOUNT (M)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F50.TAX_TOTAL_CURRENCY_CODE (M)
    //                                     + '"' + GRAND_TOTAL_AMOUNT + '"' + ',' //F51.GRAND_TOTAL_AMOUNT (M)
    //                                     + '"' + CURRENCY_CODE + '"'); //F52.GRAND_TOTAL_CURRENCY_CODE (M)

    //                                 // End AGE-WE-TAX - Document Footer

    //                                 // AGE-WE-TAX - File Trailer
    //                                 FileGen.Write(CRLF + '"T"' + ',' //T.DATA_TYPE (M)
    //                                     + '"1"'); //T.TOTAL_DOCUMENT_COUNT (M)

    //                                 // End AGE-WE-TAX - File Trailer
    //                             end;
    //                         end;
    //                     end;
    //                 end else
    //                     if EtaxHead."BWK E-Tax Document Type" = EtaxHead."BWK E-Tax Document Type"::RV then begin
    //                         CompanyInfo.Reset();
    //                         CompanyInfo.get();

    //                         SELLER_TAX_ID := CompanyInfo."VAT Registration No.";
    //                         SELLER_BRANCH_ID := CompanyInfo."Bank Branch No.";

    //                         // Start AGE-WE-TAX - File Control
    //                         FileGen.Write('"C"' + ',' //C1.DATA_TYPE (M)
    //                             + '"' + SELLER_TAX_ID + '"' + ',' //C2.SELLER_TAX_ID (M)
    //                             + '"' + SELLER_BRANCH_ID + '"' + ',' //C3.SELLER_BRANCH_ID (M)
    //                             + '"' + FILE_NAME + '"'); //C4.FILE_NAME (O)

    //                         // End AGE-WE-TAX - File Control

    //                         Cust.Reset();
    //                         Cust.SetFilter("No.", '%1', EtaxLine."BWK Customer No.");
    //                         if Cust.FindFirst() then begin
    //                             Clear(CURRENCY_CODE);
    //                             Clear(DOCUMENT_ID);
    //                             Clear(DOCUMENT_ISSUE_DTM);
    //                             Clear(SEND_EMAIL);

    //                             PoGenJnlLine.Reset();
    //                             PoGenJnlLine.SetRange("Document No.", EtaxLine."BWK Document No.");
    //                             if PoGenJnlLine.FindFirst() then begin
    //                                 if PoGenJnlLine."Currency Code" <> '' then begin
    //                                     CURRENCY_CODE := COPYSTR(PoGenJnlLine."Currency Code", 1, 3);
    //                                 end else begin
    //                                     CURRENCY_CODE := 'THB';
    //                                 end;

    //                                 DOCUMENT_ID := PoGenJnlLine."Document No.";
    //                                 DOCUMENT_ISSUE_DTM := Format(PoGenJnlLine."Posting Date", 0, '<Year4>-<Month,2>-<Day,2>T00:00:00');

    //                                 // if EtaxLine."BWK Etax Select Non Send Email" then
    //                                 SEND_EMAIL := 'N';
    //                                 // else
    //                                 //     SEND_EMAIL := 'Y';

    //                                 // AGE-WE-TAX - Document Header
    //                                 FileGen.Write(CRLF + '"H"' + ',' //H1.DATA_TYPE (M)
    //                                     + '"T01"' + ',' //H2.DOCUMENT_TYPE_CODE (M)
    //                                     + '"ใบเสร็จรับเงิน"' + ',' //H3.DOCUMENT_NAME (C)
    //                                     + '"' + DOCUMENT_ID + '"' + ',' //H4.DOCUMENT_ID (M)
    //                                     + '"' + DOCUMENT_ISSUE_DTM + '"' + ',' //H5.DOCUMENT_ISSUE_DTM (M)
    //                                     + '""' + ',' //H6.CREATE_PURPOSE_CODE (O)
    //                                     + '""' + ',' //H7.CREATE_PURPOSE (O)
    //                                     + '""' + ',' //H8.ADDITIONAL_REF_ASSIGN_ID (O)
    //                                     + '""' + ',' //H9.ADDITIONAL_REF_ISSUE_DTM (O)
    //                                     + '""' + ',' //H10.ADDITIONAL_REF_TYPE_CODE (O)
    //                                     + '""' + ',' //H11.ADDITIONAL_REF_DOCUMENT_NAME (C)
    //                                     + '""' + ',' //H12.DELIVERY_TYPE_CODE (O)
    //                                     + '""' + ',' //H13.BUYER_ORDER_ASSIGN_ID (O)
    //                                     + '""' + ',' //H14.BUYER_ORDER_ISSUE_DTM (O)
    //                                     + '""' + ',' //H15.BUYER_ORDER_REF_TYPE_CODE (O)
    //                                     + '""' + ',' //H16.DOCUMENT_REMARK (O)
    //                                     + '""' + ',' //H17.VOUCHER_NO (O)
    //                                     + '""' + ',' //H18.SELLER_CONTACT_PERSON_NAME (O)
    //                                     + '""' + ',' //H19.SELLER_CONTACT_DEPARTMENT_NAME (O)
    //                                     + '""' + ',' //H20.SELLER_CONTACT_URIID (O)
    //                                     + '""' + ',' //H21.SELLER_CONTACT_PHONE_NO (O)
    //                                     + '""' + ',' //H22.FLEX_FIELD (O)
    //                                     + '""' + ',' //H23.SELLER_BRANCH_ID (O)
    //                                     + '""' + ',' //H24.SOURCE_SYSTEM (O)
    //                                     + '""' + ',' //H25.ENCRYPT_PASSWORD (O)
    //                                     + '""' + ',' //H26.PDF_TEMPLATE_ID (O)
    //                                     + '"' + SEND_EMAIL + '"'); //H27.SEND_EMAIL (O)

    //                                 // End AGE-WE-TAX - Document Header

    //                                 Clear(BUYER_ID);
    //                                 Clear(BUYER_NAME);
    //                                 Clear(BUYER_TAX_ID_TYPE);
    //                                 Clear(BUYER_TAX_ID);
    //                                 Clear(BUYER_BRANCH_ID);
    //                                 Clear(BUYER_URIID);
    //                                 Clear(BUYER_POST_CODE);
    //                                 Clear(BUYER_BUILDING_NAME);
    //                                 Clear(BUYER_BUILDING_NO);
    //                                 Clear(BUYER_ADDRESS_LINE1);
    //                                 Clear(BUYER_ADDRESS_LINE2);
    //                                 Clear(BUYER_ADDRESS_LINE3);
    //                                 Clear(BUYER_ADDRESS_LINE4);
    //                                 Clear(BUYER_ADDRESS_LINE5);
    //                                 Clear(BUYER_STREET_NAME);
    //                                 Clear(BUYER_CITY_SUB_DIV_NAME);
    //                                 Clear(BUYER_CITY_NAME);
    //                                 Clear(BUYER_COUNTRY_SUB_DIV_NAME);
    //                                 Clear(BUYER_COUNTRY_ID);

    //                                 BUYER_ID := PoGenJnlLine."Account No.";
    //                                 BUYER_NAME := Cust.Name;
    //                                 BUYER_TAX_ID := Cust."VAT Registration No.";

    //                                 IF Cust."BWK Etax Taxpayer Type" = Cust."BWK Etax Taxpayer Type"::TXID THEN BEGIN
    //                                     BUYER_TAX_ID_TYPE := 'TXID';
    //                                     BUYER_BRANCH_ID := Cust."BWK Etax Branch Code";
    //                                 END ELSE
    //                                     IF Cust."BWK Etax Taxpayer Type" = Cust."BWK Etax Taxpayer Type"::NIDN THEN
    //                                         BUYER_TAX_ID_TYPE := 'NIDN'
    //                                     ELSE
    //                                         IF Cust."BWK Etax Taxpayer Type" = Cust."BWK Etax Taxpayer Type"::CCPT THEN
    //                                             BUYER_TAX_ID_TYPE := 'CCPT'
    //                                         ELSE
    //                                             IF Cust."BWK Etax Taxpayer Type" = Cust."BWK Etax Taxpayer Type"::OTHR THEN BEGIN
    //                                                 BUYER_TAX_ID_TYPE := 'OTHR';
    //                                                 BUYER_TAX_ID := 'N/A';
    //                                             END;

    //                                 BUYER_URIID := Cust."E-Mail";
    //                                 BUYER_POST_CODE := Cust."Post Code";
    //                                 BUYER_BUILDING_NAME := Cust."BWK Etax Building Name";
    //                                 BUYER_BUILDING_NO := Cust."BWK Etax Building No.";
    //                                 BUYER_ADDRESS_LINE1 := Cust."BWK Etax Address1";
    //                                 BUYER_ADDRESS_LINE2 := Cust."BWK Etax Address2";
    //                                 BUYER_ADDRESS_LINE3 := Cust."BWK Etax Address3";
    //                                 BUYER_ADDRESS_LINE4 := Cust."BWK Etax Address4";
    //                                 BUYER_ADDRESS_LINE5 := Cust."BWK Etax Address5";
    //                                 BUYER_STREET_NAME := Cust."BWK Etax Street";
    //                                 BUYER_CITY_SUB_DIV_NAME := Cust."BWK Etax City Sub";
    //                                 BUYER_CITY_NAME := Cust."BWK Etax City";
    //                                 BUYER_COUNTRY_SUB_DIV_NAME := Cust."BWK Etax Sub Country";
    //                                 BUYER_COUNTRY_ID := Cust."BWK Etax Country ID";

    //                                 // AGE-WE-TAX - Buyer Information
    //                                 FileGen.Write(CRLF + '"B"' + ',' //B1.DATA_TYPE (M)
    //                                     + '"' + BUYER_ID + '"' + ',' //B2.BUYER_ID (O)
    //                                     + '"' + BUYER_NAME + '"' + ',' //B3.BUYER_NAME (M)
    //                                     + '"' + BUYER_TAX_ID_TYPE + '"' + ',' //B4.BUYER_TAX_ID_TYPE (M)
    //                                     + '"' + BUYER_TAX_ID + '"' + ',' //B5.BUYER_TAX_ID (M)
    //                                     + '"' + BUYER_BRANCH_ID + '"' + ',' //B6.BUYER_BRANCH_ID (C)
    //                                     + '""' + ',' //B7.BUYER_CONTACT_PERSON_NAME (O)
    //                                     + '""' + ',' //B8.BUYER_CONTACT_DEPARTMENT_NAME (O)
    //                                     + '"' + BUYER_URIID + '"' + ',' //B9.BUYER_URIID (O)
    //                                     + '""' + ',' //B10.BUYER_CONTACT_PHONE_NO (O)
    //                                     + '"' + BUYER_POST_CODE + '"' + ',' //B11.BUYER_POST_CODE (O)
    //                                     + '"' + BUYER_BUILDING_NAME + '"' + ',' //B12.BUYER_BUILDING_NAME (O)
    //                                     + '"' + BUYER_BUILDING_NO + '"' + ',' //B13.BUYER_BUILDING_NO (O)
    //                                     + '"' + BUYER_ADDRESS_LINE1 + '"' + ',' //B14.BUYER_ADDRESS_LINE1 (O)
    //                                     + '"' + BUYER_ADDRESS_LINE2 + '"' + ',' //B15.BUYER_ADDRESS_LINE2 (O)
    //                                     + '"' + BUYER_ADDRESS_LINE3 + '"' + ',' //B16.BUYER_ADDRESS_LINE3 (O)
    //                                     + '"' + BUYER_ADDRESS_LINE4 + '"' + ',' //B17.BUYER_ADDRESS_LINE4 (O)
    //                                     + '"' + BUYER_ADDRESS_LINE5 + '"' + ',' //B18.BUYER_ADDRESS_LINE5 (O)
    //                                     + '"' + BUYER_STREET_NAME + '"' + ',' //B19.BUYER_STREET_NAME (O)
    //                                     + '""' + ',' //B20.BUYER_CITY_SUB_DIV_ID (O)
    //                                     + '"' + BUYER_CITY_SUB_DIV_NAME + '"' + ',' //B21.BUYER_CITY_SUB_DIV_NAME (C)
    //                                     + '""' + ',' //B22.BUYER_CITY_ID (O)
    //                                     + '"' + BUYER_CITY_NAME + '"' + ',' //B23.BUYER_CITY_NAME (C)
    //                                     + '""' + ',' //B24.BUYER_COUNTRY_SUB_DIV_ID (O)
    //                                     + '"' + BUYER_COUNTRY_SUB_DIV_NAME + '"' + ',' //B25.BUYER_COUNTRY_SUB_DIV_NAME (C)
    //                                     + '"' + BUYER_COUNTRY_ID + '"'); //B26.BUYER_COUNTRY_ID (M)


    //                                 if PoGenJnlLine.FindSet() then begin
    //                                     repeat
    //                                         Clear(LINE_ID);
    //                                         Clear(PRODUCT_NAME);
    //                                         Clear(PRODUCT_QUANTITY);
    //                                         Clear(LINE_TAX_CAL_RATE);
    //                                         Clear(LINE_BASIS_AMOUNT);
    //                                         Clear(LINE_TAX_CAL_AMOUNT);
    //                                         Clear(LINE_TAX_TOTAL_AMOUNT);

    //                                         LINE_ID := DELCHR(Format(PoGenJnlLine."Line No."), '=', ',');
    //                                         PRODUCT_NAME := PoGenJnlLine.Description;
    //                                         PRODUCT_QUANTITY := DELCHR(Format(PoGenJnlLine.Quantity, 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                         LINE_TAX_CAL_RATE := DELCHR(Format(PoGenJnlLine."VAT %", 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                         LINE_BASIS_AMOUNT := DELCHR(Format(ABS(PoGenJnlLine.Amount), 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                         LINE_TAX_CAL_AMOUNT := DELCHR(Format(ABS(PoGenJnlLine."VAT Base Amount"), 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                         LINE_TAX_TOTAL_AMOUNT := DELCHR(Format(ABS(PoGenJnlLine."VAT Base Amount"), 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');

    //                                         // AGE-WE-TAX - Trade Line Item Information
    //                                         FileGen.Write(CRLF + '"L"' + ',' //L1.DATA_TYPE (M)
    //                                             + '"' + LINE_ID + '"' + ',' //L2.LINE_ID (M)
    //                                             + '""' + ',' //L3.PRODUCT_ID (O)
    //                                             + '"' + PRODUCT_NAME + '"' + ',' //L4.PRODUCT_NAME (M)
    //                                             + '""' + ',' //L5.PRODUCT_DESC (O)
    //                                             + '""' + ',' //L6.PRODUCT_BATCH_ID (O)
    //                                             + '"0001-01-01T00:00:00Z"' + ',' //L7.PRODUCT_EXPIRE_DTM (O)
    //                                             + '""' + ',' //L8.PRODUCT_CLASS_CODE (O)
    //                                             + '""' + ',' //L9.PRODUCT_CLASS_NAME (O)
    //                                             + '""' + ',' //L10.PRODUCT_ORIGIN_COUNTRY_ID (O)
    //                                             + '"0.00"' + ',' //L11.PRODUCT_CHARGE_AMOUNT (M)
    //                                             + '"' + CURRENCY_CODE + '"' + ',' //L12.PRODUCT_CHARGE_CURRENCY_CODE (M)
    //                                             + '""' + ',' //L13.PRODUCT_ALLOWANCE_CHARGE_IND (O)
    //                                             + '"0.00"' + ',' //L14.PRODUCT_ALLOWANCE_ACTUAL_AMOUNT (C)
    //                                             + '"' + CURRENCY_CODE + '"' + ',' //L15.PRODUCT_ALLOWANCE_ACTUAL_CURRENCY_CODE (C)
    //                                             + '""' + ',' //L16.PRODUCT_ALLOWANCE_REASON_CODE (O)
    //                                             + '""' + ',' //L17.PRODUCT_ALLOWANCE_REASON (O)
    //                                             + '"' + PRODUCT_QUANTITY + '"' + ',' //L18.PRODUCT_QUANTITY (O)
    //                                             + '""' + ',' //L19.PRODUCT_UNIT_CODE (O)
    //                                             + '"0.00"' + ',' //L20.PRODUCT_QUANTITY_PER_UNIT (O)
    //                                             + '"VAT"' + ',' //L21.LINE_TAX_TYPE_CODE (O)
    //                                             + '"' + LINE_TAX_CAL_RATE + '"' + ',' //L22.LINE_TAX_CAL_RATE (O)
    //                                             + '"' + LINE_BASIS_AMOUNT + '"' + ',' //L23.LINE_BASIS_AMOUNT (O)
    //                                             + '"' + CURRENCY_CODE + '"' + ',' //L24.LINE_BASIS_CURRENCY_CODE (O)
    //                                             + '"' + LINE_TAX_CAL_AMOUNT + '"' + ',' //L25.LINE_TAX_CAL_AMOUNT (O)
    //                                             + '"' + CURRENCY_CODE + '"' + ',' //L26.LINE_TAX_CAL_CURRENCY_CODE (O)
    //                                             + '""' + ',' //L27.LINE_ALLOWANCE_CHARGE_IND (O)
    //                                             + '"0.00"' + ',' //L28.LINE_ALLOWANCE_ACTUAL_AMOUNT (C)
    //                                             + '"' + CURRENCY_CODE + '"' + ',' //L29.LINE_ALLOWANCE_ACTUAL_CURRENCY_CODE (C)
    //                                             + '""' + ',' //L30.LINE_ALLOWANCE_REASON_CODE (O)
    //                                             + '""' + ',' //L31.LINE_ALLOWANCE_REASON (O)
    //                                             + '"' + LINE_TAX_TOTAL_AMOUNT + '"' + ',' //L32.LINE_TAX_TOTAL_AMOUNT (O)
    //                                             + '"' + CURRENCY_CODE + '"' + ',' //L33.LINE_TAX_TOTAL_CURRENCY_CODE (O)
    //                                             + '"0.00"' + ',' //L34.LINE_NET_TOTAL_AMOUNT (O)
    //                                             + '"' + CURRENCY_CODE + '"' + ',' //L35.LINE_NET_TOTAL_CURRENCY_CODE (O)
    //                                             + '"' + LINE_NET_INCLUDE_TAX_TOTAL_AMOUNT + '"' + ',' //L36.LINE_NET_INCLUDE_TAX_TOTAL_AMOUNT (O)
    //                                             + '"' + CURRENCY_CODE + '"'); //L37.LINE_NET_INCLUDE_TAX_TOTAL_CURRENCY_CODE (O)

    //                                     until PoGenJnlLine.Next = 0;
    //                                 end;

    //                                 Clear(LINE_TOTAL_COUNT);
    //                                 Clear(TAX_CAL_RATE);
    //                                 Clear(BASIS_AMOUNT);
    //                                 Clear(TAX_CAL_AMOUNT);
    //                                 Clear(LINE_TOTAL_AMOUNT);
    //                                 Clear(TAX_BASIS_TOTAL_AMOUNT);
    //                                 Clear(TAX_TOTAL_AMOUNT);

    //                                 LINE_TOTAL_COUNT := DELCHR(Format(PoGenJnlLine.Count), '=', ',');
    //                                 TAX_CAL_RATE := DELCHR(Format(PoGenJnlLine."VAT %", 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                 BASIS_AMOUNT := DELCHR(Format(ABS(PoGenJnlLine.Amount), 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                 TAX_CAL_AMOUNT := DELCHR(Format(ABS(PoGenJnlLine."VAT Base Amount"), 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                 LINE_TOTAL_AMOUNT := DELCHR(Format(PoGenJnlLine."VAT Amount" + ABS(PoGenJnlLine."VAT Base Amount"), 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                 TAX_BASIS_TOTAL_AMOUNT := DELCHR(Format(PoGenJnlLine."VAT Amount", 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                 TAX_TOTAL_AMOUNT := DELCHR(Format(ABS(PoGenJnlLine."VAT Base Amount"), 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');
    //                                 GRAND_TOTAL_AMOUNT := DELCHR(Format(PoGenJnlLine."VAT Amount" + ABS(PoGenJnlLine."VAT Base Amount"), 0, '<Precision,2><sign><Integer Thousand><Decimals,3>'), '=', ',');

    //                                 // AGE-WE-TAX - Document Footer
    //                                 FileGen.Write(CRLF + '"F"' + ',' //F1.DATA_TYPE (M)
    //                                     + '"' + LINE_TOTAL_COUNT + '"' + ',' //F2.LINE_TOTAL_COUNT (M)
    //                                     + '"0001-01-01T00:00:00Z"' + ',' //F3.DELIVERY_OCCUR_DTM (O)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F4.INVOICE_CURRENCY_CODE (O)
    //                                     + '"VAT"' + ',' //F5.TAX_TYPE_CODE (O)
    //                                     + '"' + TAX_CAL_RATE + '"' + ',' //F6.TAX_CAL_RATE (O)
    //                                     + '"' + BASIS_AMOUNT + '"' + ',' //F7.BASIS_AMOUNT (O)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F8.BASIS_CURRENCY_CODE (O)
    //                                     + '"' + TAX_CAL_AMOUNT + '"' + ',' //F9.TAX_CAL_AMOUNT (O)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F10.TAX_CAL_CURRENCY_CODE (O)
    //                                     + '""' + ',' //F29.ALLOWANCE_CHARGE_IND (O)
    //                                     + '"0.00"' + ',' //F30.ALLOWANCE_ACTUAL_AMOUNT (O)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F31.ALLOWANCE_ACTUAL_CURRENCY_CODE (O)
    //                                     + '""' + ',' //F32.ALLOWANCE_REASON_CODE (O)
    //                                     + '""' + ',' //F33.ALLOWANCE_REASON (O)
    //                                     + '""' + ',' //F34.PAYMENT_TYPE_CODE (O)
    //                                     + '""' + ',' //F35.PAYMENT_DESCRIPTION (O)
    //                                     + '"0001-01-01T00:00:00Z"' + ',' //F36.PAYMENT_DUE_DTM (O)
    //                                     + '"0.00"' + ',' //F37.ORIGINAL_TOTAL_AMOUNT (N)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F38.ORIGINAL_TOTAL_CURRENCY_CODE (N)
    //                                     + '"' + LINE_TOTAL_AMOUNT + '"' + ',' //F39.LINE_TOTAL_AMOUNT (O)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F40.LINE_TOTAL_CURRENCY_CODE (O)
    //                                     + '"0.00"' + ',' //F41.ADJUSTED_INFORMATION_AMOUNT (N)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F42.ADJUSTED_INFORMATION_CURRENCY_CODE (N)
    //                                     + '"0.00"' + ',' //F43.ALLOWANCE_TOTAL_AMOUNT (O)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F44.ALLOWANCE_TOTAL_CURRENCY_CODE (O)
    //                                     + '"0.00"' + ',' //F45.CHARGE_TOTAL_AMOUNT (O)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F46.CHARGE_TOTAL_CURRENCY_CODE (O)
    //                                     + '"' + TAX_BASIS_TOTAL_AMOUNT + '"' + ',' //F47.TAX_BASIS_TOTAL_AMOUNT (O)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F48.TAX_BASIS_TOTAL_CURRENCY_CODE (O)
    //                                     + '"' + TAX_TOTAL_AMOUNT + '"' + ',' //F49.TAX_TOTAL_AMOUNT (O)
    //                                     + '"' + CURRENCY_CODE + '"' + ',' //F50.TAX_TOTAL_CURRENCY_CODE (O)
    //                                     + '"' + GRAND_TOTAL_AMOUNT + '"' + ',' //F51.GRAND_TOTAL_AMOUNT (M)
    //                                     + '"' + CURRENCY_CODE + '"'); //F52.GRAND_TOTAL_CURRENCY_CODE (M)

    //                                 // End AGE-WE-TAX - Document Footer

    //                                 // AGE-WE-TAX - File Trailer
    //                                 FileGen.Write(CRLF + '"T"' + ',' //T.DATA_TYPE
    //                                     + '"1"'); //T.TOTAL_DOCUMENT_COUNT
    //                                 // End AGE-WE-TAX - File Trailer
    //                             end;
    //                         end;
    //                     end;
    //     end;

    //     DownloadFromStream(InStr, 'Export', '', 'All Files (*.*)|*.*', FILE_NAME);
    // end;

    procedure "Export PDF File"(Var EtaxLine: Record "BWK E-Tax Line")
    var
        FileName, Route : Text;
        ReturnValue: Boolean;
        GenLedSet, GenLedSet2 : Record "General Ledger Setup";
        DocNo: Code[20];
        LETaxLine: Record "BWK E-Tax Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCRMemoHeader: Record "Sales Cr.Memo Header";
        Customer: Record Customer;
        CountFormID: Integer;
        CompanyInfo: Record "Company Information";
        lrGLRegister: Record "G/L Register";
        lGLEntry: Record "G/L Entry";

        ReportID: Integer;
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        InStream: InStream;
    begin
        Clear(OutStream);
        Clear(InStream);
        Clear(TempBlob);
        FileName := Format(EtaxLine."BWK E-Tax Document Type") + '_' + Format(Date2DMY(EtaxLine."BWK Posting Date", 2)) + '-' + Format(Date2DMY(EtaxLine."BWK Posting Date", 3)) + '_' + Format(EtaxLine."BWK Document No.") + '.pdf';
        GenLedSet.Get();
        CompanyInfo.Get;

        EtaxLine."BWK Etax PDF file name" := FileName;
        if (DocNo = '') or (DocNo <> Etaxline."BWK Document No.") then begin
            LETaxLine.Reset();
            LETaxLine.SetRange("BWK E-Tax Document Type", EtaxLine."BWK E-Tax Document Type");
            LETaxLine.SetRange("BWK Etax Select Export File", EtaxLine."BWK Etax Select Export File");
            LETaxLine.SetRange("BWK End date of Month", EtaxLine."BWK End date of Month");
            if LETaxLine.FindSet() then begin
                repeat
                    Clear(FileName);

                    if LETaxLine."BWK Source Table" = LETaxLine."BWK Source Table"::"Sales Invoice Header" then begin
                        if LETaxLine."BWK E-Tax Document Type" = LETaxLine."BWK E-Tax Document Type"::INV then begin
                            SalesInvoiceHeader.Reset();
                            SalesInvoiceHeader.SetRange("No.", LETaxLine."BWK Document No.");
                            if SalesInvoiceHeader.FindFirst() then begin
                                GenLedSet2.Reset();
                                GenLedSet2.SetFilter("BWK Sales Invoice Form ID GP", '<>%1', 0);
                                if GenLedSet2.FindFirst() then begin
                                    CountFormID += 1;
                                end;

                                GenLedSet2.Reset();
                                GenLedSet2.SetFilter("BWK Etax Sales Invoice Form ID", '<>%1', 0);
                                if GenLedSet2.FindFirst() then begin
                                    CountFormID += 1;
                                end;

                                FileName := Format(EtaxLine."BWK E-Tax Document Type")
                                + '_' + Format(Date2DMY(EtaxLine."BWK Posting Date", 2))
                                + '-' + Format(Date2DMY(EtaxLine."BWK Posting Date", 3))
                                + '_' + Format(EtaxLine."BWK Document No.") + '.pdf';

                                if CountFormID = 0 then begin
                                    Error('Please input Form Setup ID on General Ledger Setup.');
                                end else begin
                                    GenLedSet2.TestField("BWK Etax Sales Invoice Form ID");

                                    // Define the report you want to download
                                    ReportID := GenLedSet2."BWK Etax Sales Invoice Form ID"; // Replace with your report

                                    // Create a temporary blob to store the PDF
                                    TempBlob.CreateOutStream(OutStream);

                                    // Save the report as PDF into the OutStream
                                    Report.SaveAs(ReportID, '', ReportFormat::Pdf, OutStream);

                                    // Convert OutStream to InStream
                                    TempBlob.CreateInStream(InStream);

                                    // Download the PDF file
                                    DownloadFromStream(InStream, '', '', '', FileName);
                                    Commit();
                                end;
                            end;
                        end;

                        if LETaxLine."BWK E-Tax Document Type" = LETaxLine."BWK E-Tax Document Type"::DN then begin
                            SalesInvoiceHeader.Reset();
                            SalesInvoiceHeader.SetRange("No.", LETaxLine."BWK Document No.");
                            if SalesInvoiceHeader.FindFirst() then begin
                                GenLedSet2.Reset();
                                GenLedSet2.SetFilter("BWK Etax Sales DN Form ID", '<>%1', 0);
                                if GenLedSet2.FindFirst() then begin
                                    CountFormID += 1;
                                end;

                                FileName := Format(EtaxLine."BWK E-Tax Document Type") + '_' + Format(Date2DMY(EtaxLine."BWK Posting Date", 2)) + '-' + Format(Date2DMY(EtaxLine."BWK Posting Date", 3)) + '_' + Format(EtaxLine."BWK Document No.") + '.pdf';
                                Route := GenLedSet."BWK Etax Export PDF File" + FileName;


                                if CountFormID = 0 then begin
                                    Error('Please input Form Setup ID on General Ledger Setup.');
                                end else begin
                                    Report.SaveAsPdf(GenLedSet2."BWK Etax Sales DN Form ID", Route, SalesInvoiceHeader);
                                    // EtaxLine."BWK Etax PDF file storage" := Route;
                                end;
                            end;
                        end;
                    end;

                    if LETaxLine."BWK Source Table" = LETaxLine."BWK Source Table"::"Sales Cr.Memo Header" then begin
                        SalesCRMemoHeader.Reset();
                        SalesCRMemoHeader.SetRange("No.", LETaxLine."BWK Document No.");
                        if SalesCRMemoHeader.FindFirst() then begin
                            GenLedSet2.Reset();
                            GenLedSet2.SetFilter("BWK Etax Sales Cr Memo Form ID", '<>%1', 0);
                            if GenLedSet2.FindFirst() then begin
                                CountFormID += 1;
                            end;

                            FileName := Format(EtaxLine."BWK E-Tax Document Type") + '_' + Format(Date2DMY(EtaxLine."BWK Posting Date", 2)) + '-' + Format(Date2DMY(EtaxLine."BWK Posting Date", 3)) + '_' + Format(EtaxLine."BWK Document No.") + '.pdf';
                            Route := GenLedSet."BWK Etax Export PDF File" + FileName;


                            if CountFormID = 0 then begin
                                Error('Please input Form Setup ID on General Ledger Setup.');
                            end else begin
                                Customer.Reset();
                                Customer.SetFilter("No.", '%1', SalesCRMemoHeader."Sell-to Customer No.");
                                //Customer.SetFilter("AGE_Billing Method Code", '%1', '*GR*');
                                if Customer.FindFirst() then begin
                                    GenLedSet2.TestField("BWK Etax Sales Cr Memo Form ID");

                                    Report.SaveAsPdf(GenLedSet2."BWK Etax Sales Cr Memo Form ID", Route, SalesCRMemoHeader);
                                    // EtaxLine."BWK Etax PDF file storage" := Route;
                                end;
                            end;
                        end;

                    end;

                    if LETaxLine."BWK Source Table" = LETaxLine."BWK Source Table"::"Posted Gen. Journal Line" then begin
                        GenLedSet.TestField("BWK Etax Sales Receipt Form ID");
                        FileName := Format(EtaxLine."BWK E-Tax Document Type") + '_' + Format(Date2DMY(EtaxLine."BWK Posting Date", 2)) + '-' + Format(Date2DMY(EtaxLine."BWK Posting Date", 3)) + '_' + Format(EtaxLine."BWK Document No.") + '.pdf';
                        Route := GenLedSet."BWK Etax Export PDF File" + FileName;

                        DetailCustLedger.Reset();
                        DetailCustLedger.SetRange("Document No.", LETaxLine."BWK Document No.");
                        DetailCustLedger.SetRange("Initial Document Type", DetailCustLedger."Initial Document Type"::Invoice);
                        if DetailCustLedger.FindFirst() then begin
                            CustLedger.Reset();
                            CustLedger.SetRange("Entry No.", DetailCustLedger."Cust. Ledger Entry No.");
                            Report.SaveAsPdf(GenLedSet."BWK Etax Sales Receipt Form ID", Route, CustLedger);
                            // EtaxLine."BWK Etax PDF file storage" := Route;
                        end else begin
                            PostedGenJnlLine.Reset();
                            PostedGenJnlLine.SetRange("Document No.", LETaxLine."BWK Document No.");
                            PostedGenJnlLine.SetRange("BWK Deposit", true);
                            if PostedGenJnlLine.Find('-') then begin
                                GenLedSet.TestField("BWK Etax Rec Deposit Form ID");

                                Report.SaveAsPdf(GenLedSet."BWK Etax Rec Deposit Form ID", Route, PostedGenJnlLine);
                                // EtaxLine."BWK Etax PDF file storage" := Route;
                            end;
                        end;
                    end;

                until LETaxLine.Next() = 0;
            end;
        end;
    end;

    var
        myInt: Integer;
        WebUrl, InetUrl, sellertaxid, sellerbranchid, apikey, usercode, accesskey, servicecode, authorization :
                text;
        StatusResponse, errorCodeResponse, errorMessageResponse, TransactionCodeResponse, documentNoResponse, pdfUrlResponse, xmlUrlResponse :
                Text;
        GETaxLine: Record "BWK E-Tax Line";
        GLogResponse: Record "BWK E-Tax Log Response";
        CustLedger: Record "Cust. Ledger Entry";
        DetailCustLedger: Record "Detailed Cust. Ledg. Entry";
        PostedGenJnlLine: Record "Posted Gen. Journal Line";
}