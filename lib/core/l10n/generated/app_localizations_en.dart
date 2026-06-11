// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Gilanli Village Tavern';

  @override
  String greeting(String name) {
    return 'Hello Mr. $name';
  }

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get saveConfirmTitle => 'Are you sure you want to save?';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get login => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get loginError =>
      'Login failed. Please check your email and password.';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmTitle => 'Are you sure you want to logout?';

  @override
  String get staff => 'Staff';

  @override
  String get staffList => 'Staff List';

  @override
  String get addStaff => 'Add Staff';

  @override
  String get editStaff => 'Edit Staff';

  @override
  String get staffName => 'Full Name';

  @override
  String get staffNameRequired => 'Full name is required';

  @override
  String get staffRole => 'Role';

  @override
  String get dailyWage => 'Daily Wage (₺)';

  @override
  String get dailyWageRequired => 'Daily wage is required';

  @override
  String get dailyWageInvalid => 'Please enter a valid wage';

  @override
  String get isActive => 'Active';

  @override
  String get deactivate => 'Deactivate';

  @override
  String get deactivateConfirmTitle =>
      'Are you sure you want to deactivate this staff member?';

  @override
  String get deactivateConfirmBody =>
      'Inactive staff won\'t appear in new records. Past records are unaffected.';

  @override
  String get deleteStaff => 'Delete Staff';

  @override
  String get deleteStaffConfirmTitle =>
      'Are you sure you want to delete this staff member?';

  @override
  String get deleteStaffConfirmBody => 'This action cannot be undone.';

  @override
  String get wageHistory => 'Wage History';

  @override
  String get noStaff => 'No staff members added yet.';

  @override
  String wageUpdated(String date) {
    return 'Wage updated — effective from $date.';
  }

  @override
  String get roleGarson => 'Waiter';

  @override
  String get roleAsci => 'Chef';

  @override
  String get roleBarmen => 'Bartender';

  @override
  String get roleKasiyer => 'Cashier';

  @override
  String get roleDiger => 'Other';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get dailyRecord => 'Daily Record';

  @override
  String get recordDate => 'Work Day Date';

  @override
  String get revenue => 'Total Revenue';

  @override
  String get creditCardTotal => 'Credit Card Total';

  @override
  String get totalTips => 'Total Tips';

  @override
  String get ownerExpense => 'Expense (Owner Pays)';

  @override
  String get cashExpense => 'Expense (From Cash)';

  @override
  String get creditSale => 'Credit Sale';

  @override
  String get creditCustomer => 'Customer Name';

  @override
  String get previousDayCash => 'Previous Day Cash';

  @override
  String get workingStaff => 'Working Staff';

  @override
  String get notes => 'Notes';

  @override
  String get liveTotals => 'Live Totals';

  @override
  String get totalExpense => 'Total Expense';

  @override
  String get dailyCash => 'Daily Cash';

  @override
  String get totalCash => 'Total Cash';

  @override
  String get noActiveStaff => 'No active staff.';

  @override
  String get creditCustomerRequired =>
      'Customer name is required for a credit sale';

  @override
  String get dailyRecordSaved => 'Daily record saved.';

  @override
  String get openStaff => 'Staff';

  @override
  String get openDailyRecord => 'Daily Record';

  @override
  String get creditBook => 'Credit Book';

  @override
  String get addCreditSale => 'Add Credit Sale';

  @override
  String get editCreditSale => 'Edit Credit Sale';

  @override
  String get creditTotalAmount => 'Total Amount (₺)';

  @override
  String get creditTotalAmountRequired => 'Total amount is required';

  @override
  String get creditTotalAmountInvalid => 'Enter a valid amount';

  @override
  String get creditRemainingAmount => 'Remaining';

  @override
  String get creditStatusPending => 'Pending';

  @override
  String get creditStatusPartial => 'Partially Paid';

  @override
  String get creditStatusPaid => 'Paid';

  @override
  String get addPayment => 'Add Payment';

  @override
  String get paymentAmount => 'Payment Amount (₺)';

  @override
  String get paymentAmountRequired => 'Payment amount is required';

  @override
  String get paymentAmountInvalid => 'Enter a valid amount';

  @override
  String get paymentAmountExceedsRemaining =>
      'Payment cannot exceed remaining balance';

  @override
  String get markAsPaid => 'Mark as Paid';

  @override
  String get undoPaid => 'Undo';

  @override
  String get undoPaidConfirmTitle =>
      'Are you sure you want to undo this payment?';

  @override
  String get markAsPaidConfirmTitle => 'Mark full balance as paid?';

  @override
  String get creditSaleAdded => 'Credit sale saved.';

  @override
  String get creditSaleUpdated => 'Credit sale updated.';

  @override
  String get paymentAdded => 'Payment recorded.';

  @override
  String get noCreditSales => 'No credit sales yet.';

  @override
  String get openCreditBook => 'Credit Book';

  @override
  String get payments => 'Payments';

  @override
  String get openPayments => 'Payments';

  @override
  String get staffPaymentsTab => 'Staff';

  @override
  String get expensesTab => 'Expenses';

  @override
  String get workedDays => 'Days Worked';

  @override
  String get accruedWage => 'Accrued';

  @override
  String get totalPaid => 'Paid';

  @override
  String get remainingBalance => 'Remaining';

  @override
  String get addPaymentToStaff => 'Record Payment';

  @override
  String get paymentToStaffConfirmTitle =>
      'Are you sure you want to record this payment?';

  @override
  String get staffPaymentAdded => 'Payment recorded.';

  @override
  String get noStaffForPayments => 'No active staff found.';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get editExpense => 'Edit Expense';

  @override
  String get expenseDescription => 'Description';

  @override
  String get expenseDescriptionRequired => 'Description is required';

  @override
  String get expenseTotalAmount => 'Total Amount (₺)';

  @override
  String get expenseTotalAmountRequired => 'Total amount is required';

  @override
  String get expenseTotalAmountInvalid => 'Enter a valid amount';

  @override
  String get expenseAdded => 'Expense saved.';

  @override
  String get expenseUpdated => 'Expense updated.';

  @override
  String get expensePaymentAdded => 'Payment recorded.';

  @override
  String get expenseMarkAsPaid => 'Mark as Paid';

  @override
  String get expenseMarkAsPaidConfirmTitle => 'Mark this expense as paid?';

  @override
  String get expenseUndoPaid => 'Undo';

  @override
  String get expenseUndoPaidConfirmTitle =>
      'Are you sure you want to undo this payment?';

  @override
  String get noExpenses => 'No expense records yet.';

  @override
  String get expenseStatusPending => 'Pending';

  @override
  String get expenseStatusPartial => 'Partially Paid';

  @override
  String get expenseStatusPaid => 'Paid';

  @override
  String get todaySummary => 'Today\'s Summary';

  @override
  String get noRecordToday => 'No record entered for today.';

  @override
  String get workingStaffCountLabel => 'Working Staff';

  @override
  String get openWeeklySummary => 'Weekly Summary';

  @override
  String get openMonthlySummary => 'Monthly Summary';

  @override
  String get prevWeek => 'Previous Week';

  @override
  String get nextWeek => 'Next Week';

  @override
  String get weeklyRevenue => 'Weekly Revenue';

  @override
  String get weeklyTips => 'Weekly Tips';

  @override
  String get openTips => 'Undistributed Tips';

  @override
  String get distributeTips => 'Distribute & Close';

  @override
  String get distributeTipsConfirmTitle => 'Confirm tip distribution?';

  @override
  String distributeTipsConfirmBody(String amount) {
    return '$amount in undistributed tips will be deducted from cash.';
  }

  @override
  String get tipsDistributed => 'Tip distribution recorded.';

  @override
  String get noRecordsThisWeek => 'No records this week.';

  @override
  String get staffDaysTitle => 'Staff Days';

  @override
  String get noOpenTips => 'No tips to distribute.';

  @override
  String get prevMonth => 'Previous Month';

  @override
  String get nextMonth => 'Next Month';

  @override
  String get monthlyRevenue => 'Monthly Revenue';

  @override
  String get monthlyCreditCard => 'Credit Card';

  @override
  String get monthlyCashExpenses => 'Cash Expenses';

  @override
  String get monthlyOwnerExpenses => 'Owner Expenses';

  @override
  String get monthlyStaffWages => 'Staff Wages';

  @override
  String get monthlyOutstandingCredit => 'Outstanding Credit';

  @override
  String get monthlyUncollectible => 'Uncollectible';

  @override
  String get monthlyProfitLabel => 'Profit / Loss';

  @override
  String get noRecordsThisMonth => 'No records this month.';

  @override
  String get monthlyCreditSalesTable => 'Monthly Credit Sales';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsEnabled => 'Daily Reminder';

  @override
  String get notificationTime => 'Reminder Time';

  @override
  String get notificationBody => 'Don\'t forget to enter today\'s cash record.';

  @override
  String get languageSection => 'Language';

  @override
  String get turkish => 'Turkish';

  @override
  String get english => 'English';

  @override
  String get openSettings => 'Settings';

  @override
  String get genericError => 'An error occurred';

  @override
  String get requiredField => 'This field cannot be empty';

  @override
  String get date => 'Date';

  @override
  String get deleteCreditSale => 'Delete Credit Sale';

  @override
  String get deleteCreditConfirmTitle =>
      'Are you sure you want to delete this credit record?';

  @override
  String get deleteExpense => 'Delete Expense';

  @override
  String get deleteExpenseConfirmTitle =>
      'Are you sure you want to delete this expense record?';

  @override
  String get dayUnit => 'days';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';
}
