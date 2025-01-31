page 94000 "BWK E-Tax Role Center"
{
    PageType = RoleCenter;

    layout
    {
        area(RoleCenter)
        {
            part(Control76; "Headline RC Accountant")
            {
                ApplicationArea = Basic, Suite;
            }

            part(ApprovalsActivities; "Approvals Activities")
            {
                ApplicationArea = Suite;
            }
            part(Control1902304208; "BWK E-Tax Activities")
            {
                ApplicationArea = Basic, Suite;
            }
            part(Control1907692008; "My Accounts")
            {
                ApplicationArea = Basic, Suite;
            }
            part(Control103; "Trailing Sales Orders Chart")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
            part(Control106; "My Job Queue")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
            part(Control9; "Help And Chart Wrapper")
            {
                ApplicationArea = Basic, Suite;
            }
            part(Control10; "Product Video Topics")
            {
                ApplicationArea = All;
            }
            part(Control100; "Cash Flow Forecast Chart")
            {
                ApplicationArea = Basic, Suite;
            }
            part(Control108; "Report Inbox Part")
            {
                AccessByPermission = TableData "Report Inbox" = IMD;
                ApplicationArea = Basic, Suite;
            }
            part(Control122; "Power BI Report Spinner Part")
            {
                ApplicationArea = Basic, Suite;
            }
            part(Control123; "Team Member Activities")
            {
                ApplicationArea = Suite;
            }
            systempart(Control1901377608; MyNotes)
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }

    actions
    {
        area(Sections)
        {

            group("E-Tax Process")
            {
                action(INV)
                {
                    ApplicationArea = All;
                    Caption = '[INV] ใบกำกับภาษี';
                    Image = List;
                    RunObject = page "BWK E-Tax Lists";
                    RunPageLink = "BWK E-Tax Document Type" = filter(INV);
                }
                action(DN)
                {
                    ApplicationArea = All;
                    Caption = '[DN] ใบเพิ่มหนี้/ใบกำกับภาษี';
                    Image = List;
                    RunObject = page "BWK E-Tax Lists";
                    RunPageLink = "BWK E-Tax Document Type" = filter(DN);
                }
                action(CN)
                {
                    ApplicationArea = All;
                    Caption = '[CN] ใบลดหนี้/ใบกำกับภาษี';
                    Image = List;
                    RunObject = page "BWK E-Tax Lists";
                    RunPageLink = "BWK E-Tax Document Type" = filter(CN);
                }
                // action(SR)
                // {
                //     ApplicationArea = All;
                //     Caption = '[SR] ใบเสร็จรับเงิน/ใบกำกับภาษี';
                //     Image = List;
                //     RunObject = page "BWK E-Tax Lists";
                //     RunPageLink = "BWK E-Tax Document Type" = filter(SR);
                // }
                action(RV)
                {
                    ApplicationArea = All;
                    Caption = '[RV] ใบเสร็จ/ใบกำกับภาษี';
                    Image = List;
                    RunObject = page "BWK E-Tax Lists";
                    RunPageLink = "BWK E-Tax Document Type" = filter(RV);
                }
            }

            group("E-Tax Setup")
            {
                action(GeneralLedgerSetup)
                {
                    ApplicationArea = All;
                    Caption = 'General Ledger Setup';
                    Image = Setup;
                    RunObject = page "General Ledger Setup";
                }

                action(CustomerList)
                {
                    ApplicationArea = All;
                    Caption = 'Customer';
                    Image = Customer;
                    RunObject = page "Customer List";
                }

                action(CNPurpose)
                {
                    ApplicationArea = All;
                    Caption = 'CN Purpose Code';
                    Image = Setup;
                    RunObject = page "BWK ETax Purpose Code List";
                    RunPageLink = "BWK Purpose Type" = filter('CN');
                }

                action(DNPurpose)
                {
                    ApplicationArea = All;
                    Caption = 'DN Purpose Code';
                    Image = Setup;
                    RunObject = page "BWK ETax Purpose Code List";
                    RunPageLink = "BWK Purpose Type" = filter('DN');
                }
            }
        }
    }
}