table 94000 "BWK E-Tax Header"
{
    Caption = 'BWK E-Tax Header';
    fields
    {
        field(1; "BWK E-Tax Document Type"; Enum "BWK E-Tax Document Type")
        {
            DataClassification = SystemMetadata;
            Caption = 'Document Type';
            Editable = false;
        }

        field(2; "BWK End date of Month"; Date)
        {
            Caption = 'End date of Month';
            DataClassification = CustomerContent;
            Editable = false;

            trigger OnValidate()
            var
                FunctionCenter: Codeunit "BWK E-Tax Function Center";
            begin
                "BWK Month No." := DATE2DMY("BWK End date of Month", 2);
                "BWK Month Name" := FunctionCenter."BWK Get ThaiMonth"("BWK Month No.");
                "BWK Year No." := DATE2DMY("BWK End date of Month", 3);
                "BWK Year-Month" := format("BWK End date of Month", 0, '<Year4>-<Month,2>');

            end;
        }

        field(3; "BWK Year-Month"; Code[7])
        {
            Caption = 'Year-Month';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(4; "BWK Month No."; Integer)
        {
            Caption = 'Month No';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(5; "BWK Month Name"; Text[30])
        {
            Caption = 'Month Name';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(6; "BWK Year No."; Integer)
        {
            Caption = 'Year No';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(7; "BWK Status Lock"; Boolean)
        {
            Caption = 'Status Lock';
            DataClassification = SystemMetadata;
        }

        field(8; "BWK Total Amount"; Decimal)
        {
            CalcFormula = Sum("BWK E-Tax Line"."BWK Amount" WHERE("BWK E-Tax Document Type" = FIELD("BWK E-Tax Document Type"),
                                                                "BWK End date of Month" = FIELD("BWK End date of Month")));
            Editable = false;
            FieldClass = FlowField;
            Caption = 'Total Base Amount';
        }

        field(9; "BWK Total VAT Amount"; Decimal)
        {
            CalcFormula = Sum("BWK E-Tax Line"."BWK VAT Amount" WHERE("BWK E-Tax Document Type" = FIELD("BWK E-Tax Document Type"),
                                                                    "BWK End date of Month" = FIELD("BWK End date of Month")));
            Editable = false;
            FieldClass = FlowField;
            Caption = 'Total VAT Amount';
        }

        field(10; "BWK Total Amount Incl. VAT"; Decimal)
        {
            CalcFormula = Sum("BWK E-Tax Line"."BWK Amount Incl. VAT" WHERE("BWK E-Tax Document Type" = FIELD("BWK E-Tax Document Type"),
                                                                    "BWK End date of Month" = FIELD("BWK End date of Month")));
            Editable = false;
            FieldClass = FlowField;
            Caption = 'Total Amount Incl. VAT';
        }

        field(11; "BWK Create By"; Code[50])
        {
            Editable = false;
            Caption = 'Create By';
            DataClassification = SystemMetadata;
        }

        field(12; "BWK Create DateTime"; DateTime)
        {
            Editable = false;
            Caption = 'Create DateTime';
            DataClassification = SystemMetadata;
        }

        field(13; "BWK Etax Total List Line"; Integer)
        {
            Caption = 'Total List Line';
            Editable = false;
            CalcFormula = count("BWK E-Tax Line" where("BWK E-Tax Document Type" = field("BWK E-Tax Document Type"),
                                                        "BWK End date of Month" = FIELD("BWK End date of Month")));
            FieldClass = FlowField;

        }

        field(14; "BWK Etax Total Export file"; Integer)
        {
            Caption = 'Total Export file';
            // Editable = false;
            CalcFormula = count("BWK E-Tax Line" where("BWK Etax Text File" = const(true),
                                                    "BWK Etax PDF File" = const(true),
                                                    "BWK E-Tax Document Type" = field("BWK E-Tax Document Type"),
                                                    "BWK End date of Month" = FIELD("BWK End date of Month")));
            FieldClass = FlowField;


        }

        // field(15; "BWK Etax Total Send file"; Integer)
        // {
        //     Caption = 'Total Send file';
        //     Editable = false;
        //     CalcFormula = count("BWK E-Tax Line" where("BWK Etax Send File" = const(true),
        //                                                 "BWK E-Tax Document Type" = field("BWK E-Tax Document Type"),
        //                                                 "BWK End date of Month" = FIELD("BWK End date of Month")));
        //     FieldClass = FlowField;

        // }

        // field(16; "BWK Etax Total Sign file"; Integer)
        // {
        //     Caption = 'Total Sign file';
        //     Editable = false;
        //     CalcFormula = count("BWK E-Tax Line" where("BWK Etax Sign File" = const(true),
        //                                                 "BWK E-Tax Document Type" = field("BWK E-Tax Document Type"),
        //                                                 "BWK End date of Month" = FIELD("BWK End date of Month")));
        //     FieldClass = FlowField;

        // }
    }

    keys
    {
        key(Key1; "BWK E-Tax Document Type", "BWK End date of Month")
        {
            Clustered = true;
        }




    }

    trigger OnDelete()
    var
    begin

        GRecETaxLine.RESET;
        GRecETaxLine.SetFilter("BWK E-Tax Document Type", '%1', "BWK E-Tax Document Type");
        GRecETaxLine.SetFilter("BWK End date of Month", '%1', "BWK End date of Month");
        IF GRecETaxLine.Find('-') THEN begin
            GRecETaxLine.DELETEALL(TRUE);
        end;


    end;

    trigger OnRename()
    begin
        ERROR('Can not change!');
    end;

    trigger OnInsert()
    begin
        "BWK Create By" := UserId;
        "BWK Create DateTime" := CurrentDateTime;

    end;

    var
        GRecETaxLine: Record "BWK E-Tax Line";


}

