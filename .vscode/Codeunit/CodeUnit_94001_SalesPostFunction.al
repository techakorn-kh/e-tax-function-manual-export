codeunit 94001 "BWK Sales Post Function"
{
    EventSubscriberInstance = StaticAutomatic;

    //Insert 20231127 by NM >>>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeInsertPostedHeaders', '', false, false)]
    local procedure BWKOnBeforeInsertPostedHeaders(var SalesHeader: Record "Sales Header"; var TempWarehouseShipmentHeader: Record "Warehouse Shipment Header" temporary; var TempWarehouseReceiptHeader: Record "Warehouse Receipt Header" temporary);
    var
        SalesLine: Record "Sales Line";
        ErrorTxt001: Label 'BWK Etax Branch Code ต้องมีจำนวนตัวอักษรเท่ากับ 5 ตำแหน่ง';
        ErrorTxt002: Label 'DN Purpost Code must have value.';
        PRODUCT_NAME: Text;
    begin
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice then begin
            if SalesHeader."BWK Etax Taxpayer Type" = SalesHeader."BWK Etax Taxpayer Type"::TXID then begin
                SalesHeader.TestField("BWK Etax Branch Code");
                if StrLen(SalesHeader."BWK Etax Branch Code") < 5 then begin
                    Error(ErrorTxt001);
                end;
            end;

            if SalesHeader."BWK Is Debit Note" then begin
                if SalesHeader."BWK DN Purpost Code" = '' then begin
                    Error(ErrorTxt002);
                end;

                SalesHeader.TestField("Sell-to Customer Name"); //B3.BUYER_NAME (M) -> DN
                SalesHeader.TestField("VAT Registration No."); //B5.BUYER_TAX_ID (M) -> DN

                //End AGE-WE-TAX Mandatory [DN]
            end;

            //AGE-WE-TAX Mandatory [INV, DN]
            SalesHeader.TestField("BWK Etax Country ID"); //B26.BUYER_COUNTRY_ID (M) -> INV, DN

            SalesLine.Reset();
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            if SalesLine.FindSet() then begin
                repeat
                    Clear(PRODUCT_NAME);

                    PRODUCT_NAME := SalesLine.Description + SalesLine."Description 2"; //L4.PRODUCT_NAME (M) -> INV, DN

                    if PRODUCT_NAME = '' then begin
                        Error('No. ' + SalesLine."No." + ' กรุณากรอกรายละเอียดช่อง Description หรือ Description 2');
                    end;
                until SalesLine.Next() = 0;
            end;
            //End AGE-WE-TAX Mandatory [INV, DN]
        end;

    end;
    //End Insert 20231127 by NM <<<


    //Insert 20240109 by BW.Techakorn >>>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post (Yes/No)", 'OnAfterConfirmPost', '', false, false)]
    local procedure OnAfterConfirmPost(var SalesHeader: Record "Sales Header");
    var
        SalesLine: Record "Sales Line";
        PRODUCT_NAME: Text;
    begin
        //AGE-WE-TAX Mandatory [CN]
        if SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo" then begin
            SalesHeader.TestField("Sell-to Customer Name"); //B3.BUYER_NAME (M) -> CN
            SalesHeader.TestField("VAT Registration No."); //B5.BUYER_TAX_ID (M) -> CN
            SalesHeader.TestField("BWK Etax Country ID"); //B26.BUYER_COUNTRY_ID (M) -> CN

            SalesLine.Reset();
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            if SalesLine.FindSet() then begin
                repeat
                    Clear(PRODUCT_NAME);

                    PRODUCT_NAME := SalesLine.Description + SalesLine."Description 2"; //L4.PRODUCT_NAME (M) -> CN

                    if PRODUCT_NAME = '' then begin
                        Error('No. ' + SalesLine."No." + ' กรุณากรอกรายละเอียดช่อง Description หรือ Description 2');
                    end;
                until SalesLine.Next() = 0;
            end;
        end;
        //End AGE-WE-TAX Mandatory [CN]
    end;
    //End Insert 20240109 by BW.Techakorn <<<

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterCheckMandatoryFields', '', false, false)]
    local procedure OnAfterCheckMandatoryFields(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean);
    begin
        if SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo" then begin
            SalesHeader.TestField("BWK CN Purpost Code");
            SalesHeader.TestField("BWK CN Purpost Name");
        end;

        if SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice then begin
            if SalesHeader."BWK Is Debit Note" then begin
                SalesHeader.TestField("BWK DN Purpost Code");
                SalesHeader.TestField("BWK DN Purpost Name");
            end;
        end;
    end;


    var
        myInt: Integer;
}