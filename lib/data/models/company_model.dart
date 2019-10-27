import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:flutter/foundation.dart';
import 'package:invoiceninja_flutter/constants.dart';
import 'package:invoiceninja_flutter/data/models/company_gateway_model.dart';
import 'package:invoiceninja_flutter/data/models/entities.dart';
import 'package:invoiceninja_flutter/data/models/group_model.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/data/models/task_model.dart';
import 'package:invoiceninja_flutter/utils/formatting.dart';

part 'company_model.g.dart';

abstract class CompanyEntity extends Object
    with BaseEntity
    implements Built<CompanyEntity, CompanyEntityBuilder> {
  factory CompanyEntity() {
    return _$CompanyEntity._(
      id: '',
      updatedAt: 0,
      companyKey: '',
      plan: '',
      settings: SettingsEntity(),
      appUrl: '',
      enabledModules: 0,
      financialYearStart: 1,
      startOfWeek: 1,
      groups: BuiltList<GroupEntity>(),
      taxRates: BuiltList<TaxRateEntity>(),
      taskStatuses: BuiltList<TaskStatusEntity>(),
      taskStatusMap: BuiltMap<String, TaskStatusEntity>(),
      companyGateways: BuiltList<CompanyGatewayEntity>(),
      expenseCategories: BuiltList<ExpenseCategoryEntity>(),
      expenseCategoryMap: BuiltMap<String, ExpenseCategoryEntity>(),
      users: BuiltList<UserEntity>(),
      userMap: BuiltMap<String, UserEntity>(),
      customFields: BuiltMap<String, String>(),
    );
  }

  CompanyEntity._();

  @nullable
  @BuiltValueField(wireName: 'custom_invoice_taxes1')
  bool get enableCustomSurchargeTaxes1;

  @nullable
  @BuiltValueField(wireName: 'custom_invoice_taxes2')
  bool get enableCustomSurchargeTaxes2;

  @nullable
  @BuiltValueField(wireName: 'custom_invoice_taxes3')
  bool get enableCustomSurchargeTaxes3;

  @nullable
  @BuiltValueField(wireName: 'custom_invoice_taxes4')
  bool get enableCustomSurchargeTaxes4;

  @nullable
  @BuiltValueField(wireName: 'size_id')
  String get sizeId;

  @nullable
  @BuiltValueField(wireName: 'industry_id')
  String get industryId;

  @nullable
  @BuiltValueField(wireName: 'portal_mode')
  String get portalMode;

  // TODO remove this
  @nullable
  String get plan;

  @BuiltValueField(wireName: 'company_key')
  String get companyKey;

  // TODO remove this
  @nullable
  @BuiltValueField(wireName: 'default_url')
  String get appUrl;

  // TODO remove this
  @nullable
  @BuiltValueField(wireName: 'start_of_week')
  int get startOfWeek;

  // TODO remove this
  @nullable
  @BuiltValueField(wireName: 'financial_year_start')
  int get financialYearStart;

  BuiltList<GroupEntity> get groups;

  // TODO remove this
  @nullable
  @BuiltValueField(wireName: 'tax_rates')
  BuiltList<TaxRateEntity> get taxRates;

  @nullable
  @BuiltValueField(wireName: 'task_statuses')
  BuiltList<TaskStatusEntity> get taskStatuses;

  BuiltMap<String, TaskStatusEntity> get taskStatusMap;

  // TODO remove this
  @nullable
  @BuiltValueField(wireName: 'company_gateways')
  BuiltList<CompanyGatewayEntity> get companyGateways;

  // TODO remove this
  @nullable
  @BuiltValueField(wireName: 'expense_categories')
  BuiltList<ExpenseCategoryEntity> get expenseCategories;

  // TODO remove this
  @nullable
  BuiltMap<String, ExpenseCategoryEntity> get expenseCategoryMap;

  // TODO remove this
  @nullable
  @BuiltValueField(wireName: 'users')
  BuiltList<UserEntity> get users;

  // TODO remove this
  @nullable
  BuiltMap<String, UserEntity> get userMap;

  // TODO remove this
  @BuiltValueField(wireName: 'custom_fields')
  BuiltMap<String, String> get customFields;

  SettingsEntity get settings;

  // TODO remove this
  @nullable
  @BuiltValueField(wireName: 'enabled_modules')
  int get enabledModules;

  //@BuiltValueField(wireName: 'custom_messages')

  String get displayName => settings.name ?? '';

  @override
  bool matchesFilter(String filter) => false;

  @override
  String matchesFilterValue(String filter) => null;

  @override
  double get listDisplayAmount => null;

  @override
  FormatNumberType get listDisplayAmountType => null;

  @override
  String get listDisplayName => null;

  String getCustomFieldLabel(String field) {
    // TODO remove this
    if (customFields == null) {
      return '';
    }

    if (customFields.containsKey(field)) {
      return customFields[field].split('|').first;
    } else {
      return '';
    }
  }

  List<String> getCustomFieldValues(String field, {bool excludeBlank = false}) {
    // TODO remove this
    if (customFields == null) {
      return [];
    }

    final values = customFields[field];

    if (values == null || !values.contains('|')) {
      return [];
    } else {
      final data = values.split('|').last.split(',');

      if (excludeBlank) {
        return data.where((data) => data.isNotEmpty).toList();
      } else {
        return data;
      }
    }
  }

  bool get isSelfHost {
    if (!kReleaseMode) {
      return true;
    }

    return appUrl != null && appUrl.isNotEmpty && appUrl != kAppUrl;
  }

  bool get isHosted => !isSelfHost;

  bool get isProPlan => isSelfHost || plan == kPlanPro;

  bool get isEnterprisePlan => isSelfHost || plan == kPlanEnterprise;

  bool isModuleEnabled(EntityType entityType) {
    // TODO remove this
    if ([
      EntityType.recurringInvoice,
      EntityType.credit,
      EntityType.project,
      EntityType.task,
      EntityType.expense,
      EntityType.vendor,
    ].contains(entityType)) {
      return false;
    }

    /*
    if (entityType == EntityType.recurringInvoice &&
        enabledModules & kModuleRecurringInvoice == 0) {
      return false;
    } else if (entityType == EntityType.credit &&
        enabledModules & kModuleCredit == 0) {
      return false;
    } else if (entityType == EntityType.quote &&
        enabledModules & kModuleQuote == 0) {
      return false;
    } else if ([EntityType.task, EntityType.project].contains(entityType) &&
        enabledModules & kModuleTask == 0) {
      return false;
    } else if ([EntityType.expense, EntityType.vendor].contains(entityType) &&
        enabledModules & kModuleExpense == 0) {
      return false;
    }
    */

    return true;
  }

  String get currencyId => settings.currencyId ?? kDefaultCurrencyId;

  // TODO remove
  // Handle bug in earlier version of API
  int get firstMonthOfYear =>
      financialYearStart == 2000 ? 1 : (financialYearStart ?? 1);

  static Serializer<CompanyEntity> get serializer => _$companyEntitySerializer;
}

abstract class PaymentTermEntity extends Object
    with SelectableEntity
    implements Built<PaymentTermEntity, PaymentTermEntityBuilder> {
  factory PaymentTermEntity() {
    return _$PaymentTermEntity._(
      id: BaseEntity.nextId,
      numDays: 0,
    );
  }

  PaymentTermEntity._();

  static Serializer<PaymentTermEntity> get serializer =>
      _$paymentTermEntitySerializer;

  String getPaymentTerm(String netLabel) {
    if (numDays == 0) {
      return '';
    } else if (numDays == -1) {
      return '$netLabel 0';
    } else {
      return '$netLabel $numDays';
    }
  }

  @nullable
  @BuiltValueField(wireName: 'num_days')
  int get numDays;

  @nullable
  @BuiltValueField(wireName: 'archived_at')
  int get archivedAt;
}

abstract class GatewayEntity extends Object
    with SelectableEntity
    implements Built<GatewayEntity, GatewayEntityBuilder> {
  factory GatewayEntity() {
    return _$GatewayEntity._(
      id: BaseEntity.nextId,
      name: '',
      sortOrder: 0,
      fields: '',
    );
  }

  GatewayEntity._();

  static Serializer<GatewayEntity> get serializer => _$gatewayEntitySerializer;

  @override
  @nullable
  @BuiltValueField(wireName: 'key')
  String get id;

  String get name;

  @BuiltValueField(wireName: 'sort_order')
  int get sortOrder;

  //bool get recommended;
  //bool get visible;

  String get fields;

  Map<String, dynamic> get parsedFields =>
      fields.isEmpty ? <String, dynamic>{} : jsonDecode(fields);

  int compareTo(GatewayEntity gateway, String sortField, bool sortAscending) {
    int response = 0;
    final GatewayEntity gatewayA = sortAscending ? this : gateway;
    final GatewayEntity gatewayB = sortAscending ? gateway : this;

    switch (sortField) {
      case CreditFields.amount:
        response = gatewayA.name.compareTo(gatewayB.name);
    }

    return response;
  }

  @override
  bool matchesFilter(String filter) {
    if (filter == null || filter.isEmpty) {
      return true;
    }

    return name.toLowerCase().contains(filter);
  }

  @override
  String matchesFilterValue(String filter) {
    if (filter == null || filter.isEmpty) {
      return null;
    }

    return null;
  }

  @override
  String get listDisplayName => name;

  @override
  double get listDisplayAmount => null;

  @override
  FormatNumberType get listDisplayAmountType => null;
}

abstract class UserEntity implements Built<UserEntity, UserEntityBuilder> {
  factory UserEntity() {
    return _$UserEntity._(
      firstName: '',
      lastName: '',
      email: '',
      phone: '',
      id: '',
    );
  }

  UserEntity._();

  String get id;

  @BuiltValueField(wireName: 'first_name')
  String get firstName;

  @BuiltValueField(wireName: 'last_name')
  String get lastName;

  String get email;

  String get phone;

  String get fullName => (firstName + ' ' + lastName).trim();

  static Serializer<UserEntity> get serializer => _$userEntitySerializer;
}

abstract class UserCompanyEntity
    implements Built<UserCompanyEntity, UserCompanyEntityBuilder> {
  factory UserCompanyEntity() {
    return _$UserCompanyEntity._(
      isOwner: false,
      isAdmin: false,
      permissionsMap: BuiltMap<String, bool>(),
      company: CompanyEntity(),
      user: UserEntity(),
      token: TokenEntity(),
    );
  }

  UserCompanyEntity._();

  @BuiltValueField(wireName: 'is_owner')
  bool get isOwner;

  @BuiltValueField(wireName: 'is_admin')
  bool get isAdmin;

  CompanyEntity get company;

  UserEntity get user;

  TokenEntity get token;

  // TODO fix this
  @BuiltValueField(wireName: 'permissions_HIDDEN')
  BuiltMap<String, bool> get permissionsMap;

  bool can(UserPermission permission, EntityType entityType) =>
      (isAdmin ?? false) ||
      permissionsMap.containsKey('${permission}_$entityType');

  bool canView(EntityType entityType) => can(UserPermission.view, entityType);

  bool canEdit(EntityType entityType) => can(UserPermission.edit, entityType);

  bool canCreate(EntityType entityType) =>
      can(UserPermission.create, entityType);

  bool canViewOrCreate(EntityType entityType) =>
      canView(entityType) || canCreate(entityType);

  bool canEditEntity(BaseEntity entity) {
    if (entity == null) {
      return false;
    }

    if (entity.isNew) {
      return canCreate(entity.entityType);
    } else {
      return canEdit(entity.entityType) || (entity.isOwner ?? false);
    }
  }

  static Serializer<UserCompanyEntity> get serializer =>
      _$userCompanyEntitySerializer;
}

abstract class TokenEntity implements Built<TokenEntity, TokenEntityBuilder> {
  factory TokenEntity() {
    return _$TokenEntity._(
      token: '',
      name: '',
    );
  }

  TokenEntity._();

  String get token;

  String get name;

  static Serializer<TokenEntity> get serializer => _$tokenEntitySerializer;
}

abstract class SettingsEntity
    implements Built<SettingsEntity, SettingsEntityBuilder> {
  factory SettingsEntity() {
    return _$SettingsEntity._(
      name: '',
      address1: '',
      address2: '',
      city: '',
      state: '',
      postalCode: '',
      countryId: null,
      companyLogo: '',
      vatNumber: '',
      idNumber: '',
      website: '',
      email: '',
      phone: '',
      // TODO set to default EST timezone
      timezoneId: '',
      convertProductExchangeRate: null,
      dateFormatId: null,
      defaultInvoiceDesignId: null,
      defaultInvoiceFooter: '',
      defaultInvoiceTerms: '',
      defaultPaymentTerms: 0,
      defaultPaymentTypeId: null,
      defaultQuoteDesignId: null,
      defaultQuoteTerms: '',
      defaultTaskRate: 0,
      defaultTaxName1: '',
      defaultTaxRate1: 0,
      defaultTaxName2: '',
      defaultTaxRate2: 0,
      sendReminders: null,
      showTasksInPortal: null,
      enableInclusiveTaxes: null,
      enableInvoiceItemTaxes: null,
      enableInvoiceTaxes: null,
      enableMilitaryTime: null,
      enableSecondTaxRate: null,
      languageId: null,
      showCurrencyCode: null,
      showInvoiceItemTaxes: null,
      customPaymentTerms: BuiltList<PaymentTermEntity>(),
      invoiceFields: '',
      emailFooter: '',
      emailSubjectInvoice: '',
      emailSubjectQuote: '',
      emailSubjectPayment: '',
      emailBodyInvoice: '',
      emailBodyQuote: '',
      emailBodyPayment: '',
      emailSubjectReminder1: '',
      emailSubjectReminder2: '',
      emailSubjectReminder3: '',
      emailBodyReminder1: '',
      emailBodyReminder2: '',
      emailBodyReminder3: '',
      fillProducts: null,
      enablePortalPassword: null,
      hasCustomDesign1: null,
      hasCustomDesign2: null,
      hasCustomDesign3: null,
    );
  }

  SettingsEntity._();

  @nullable
  @BuiltValueField(wireName: 'timezone_id')
  String get timezoneId;

  @nullable
  @BuiltValueField(wireName: 'date_format_id')
  String get dateFormatId;

  @nullable
  @BuiltValueField(wireName: 'military_time')
  bool get enableMilitaryTime;

  @nullable
  @BuiltValueField(wireName: 'language_id')
  String get languageId;

  @nullable
  @BuiltValueField(wireName: 'show_currency_code')
  bool get showCurrencyCode;

  @nullable
  @BuiltValueField(wireName: 'currency_id')
  String get currencyId;

  @nullable
  @BuiltValueField(wireName: 'custom_value1')
  String get customValue1;

  @nullable
  @BuiltValueField(wireName: 'custom_value2')
  String get customValue2;

  @nullable
  @BuiltValueField(wireName: 'custom_value3')
  String get customValue3;

  @nullable
  @BuiltValueField(wireName: 'custom_value4')
  String get customValue4;

  @nullable
  @BuiltValueField(wireName: 'payment_terms')
  int get defaultPaymentTerms;

  @nullable
  @BuiltValueField(wireName: 'company_gateway_ids')
  String get companyGatewayIds;

  @nullable
  @BuiltValueField(wireName: 'default_task_rate')
  double get defaultTaskRate;

  @nullable
  @BuiltValueField(wireName: 'send_reminders')
  bool get sendReminders;

  @nullable
  @BuiltValueField(wireName: 'show_tasks_in_portal')
  bool get showTasksInPortal;

  @nullable
  @BuiltValueField(wireName: 'email_style')
  String get emailStyle;

  @nullable
  @BuiltValueField(wireName: 'reply_to_email')
  String get replyToEmail;

  @nullable
  @BuiltValueField(wireName: 'bcc_email')
  String get bccEmail;

  @nullable
  @BuiltValueField(wireName: 'pdf_email_attachment')
  bool get pdfEmailAttachment;

  @nullable
  @BuiltValueField(wireName: 'ubl_email_attachment')
  bool get ublEmailAttachment;

  @nullable
  @BuiltValueField(wireName: 'document_email_attachment')
  bool get documentEmailAttachment;

  @nullable
  @BuiltValueField(wireName: 'email_style_custom')
  String get emailStyleCustom;

  @nullable
  @BuiltValueField(wireName: 'custom_message_dashboard')
  String get customMessageDashboard;

  @nullable
  @BuiltValueField(wireName: 'custom_message_unpaid_invoice')
  String get customMessageUnpaidInvoice;

  @nullable
  @BuiltValueField(wireName: 'custom_message_paid_invoice')
  String get customMessagePaidInvoice;

  @nullable
  @BuiltValueField(wireName: 'custom_message_unapproved_quote')
  String get customMessageUnapprovedQuote;

  @nullable
  @BuiltValueField(wireName: 'lock_sent_invoices')
  bool get lockSentInvoices;

  @nullable
  @BuiltValueField(wireName: 'auto_archive_invoice')
  bool get autoArchiveInvoice;

  @nullable
  @BuiltValueField(wireName: 'inclusive_taxes')
  bool get enableInclusiveTaxes;

  @nullable
  BuiltMap<String, String> get translations;

  @nullable
  @BuiltValueField(wireName: 'task_number_pattern')
  String get taskNumberPattern;

  @nullable
  @BuiltValueField(wireName: 'task_number_counter')
  int get taskNumberCounter;

  @nullable
  @BuiltValueField(wireName: 'expense_number_pattern')
  String get expenseNumberPattern;

  @nullable
  @BuiltValueField(wireName: 'expense_number_counter')
  int get expenseNumberCounter;

  @nullable
  @BuiltValueField(wireName: 'vendor_number_pattern')
  String get vendorNumberPattern;

  @nullable
  @BuiltValueField(wireName: 'vendor_number_counter')
  int get vendorNumberCounter;

  @nullable
  @BuiltValueField(wireName: 'ticket_number_pattern')
  String get ticketNumberPattern;

  @nullable
  @BuiltValueField(wireName: 'ticket_number_counter')
  int get ticketNumberCounter;

  @nullable
  @BuiltValueField(wireName: 'payment_number_pattern')
  String get paymentNumberPattern;

  @nullable
  @BuiltValueField(wireName: 'payment_number_counter')
  int get paymentNumberCounter;

  @nullable
  @BuiltValueField(wireName: 'invoice_number_pattern')
  String get invoiceNumberPattern;

  @nullable
  @BuiltValueField(wireName: 'invoice_number_counter')
  int get invoiceNumberCounter;

  @nullable
  @BuiltValueField(wireName: 'quote_number_pattern')
  String get quoteNumberPattern;

  @nullable
  @BuiltValueField(wireName: 'quote_number_counter')
  int get quoteNumberCounter;

  @nullable
  @BuiltValueField(wireName: 'client_number_pattern')
  String get clientNumberPattern;

  @nullable
  @BuiltValueField(wireName: 'client_number_counter')
  int get clientNumberCounter;

  @nullable
  @BuiltValueField(wireName: 'credit_number_pattern')
  String get creditNumberPattern;

  @nullable
  @BuiltValueField(wireName: 'credit_number_counter')
  int get creditNumberCounter;

  @nullable
  @BuiltValueField(wireName: 'recurring_invoice_number_prefix')
  String get recurringInvoiceNumberPrefix;

  @nullable
  @BuiltValueField(wireName: 'reset_counter_frequency_id')
  String get resetCounterFrequencyId;

  @nullable
  @BuiltValueField(wireName: 'reset_counter_date')
  String get resetCounterDate;

  @nullable
  @BuiltValueField(wireName: 'counter_padding')
  int get counterPadding;

  @nullable
  @BuiltValueField(wireName: 'shared_invoice_quote_counter')
  bool get sharedInvoiceQuoteCounter;

  @nullable
  @BuiltValueField(wireName: 'update_products')
  bool get updateProducts;

  @nullable
  @BuiltValueField(wireName: 'convert_products')
  bool get convertProductExchangeRate;

  @nullable
  @BuiltValueField(wireName: 'fill_products')
  bool get fillProducts;

  @nullable
  @BuiltValueField(wireName: 'invoice_terms')
  String get defaultInvoiceTerms;

  @nullable
  @BuiltValueField(wireName: 'quote_terms')
  String get defaultQuoteTerms;

  @nullable
  @BuiltValueField(wireName: 'invoice_taxes')
  bool get enableInvoiceTaxes;

  @nullable
  @BuiltValueField(wireName: 'invoice_item_taxes')
  bool get enableInvoiceItemTaxes;

  @nullable
  @BuiltValueField(wireName: 'invoice_design_id')
  String get defaultInvoiceDesignId;

  @nullable
  @BuiltValueField(wireName: 'quote_design_id')
  String get defaultQuoteDesignId;

  @nullable
  @BuiltValueField(wireName: 'invoice_footer')
  String get defaultInvoiceFooter;

  @nullable
  @BuiltValueField(wireName: 'invoice_labels')
  String get invoiceLabels;

  @nullable
  @BuiltValueField(wireName: 'show_item_taxes')
  bool get showInvoiceItemTaxes;

  @nullable
  @BuiltValueField(wireName: 'tax_name1')
  String get defaultTaxName1;

  @nullable
  @BuiltValueField(wireName: 'tax_rate1')
  double get defaultTaxRate1;

  @nullable
  @BuiltValueField(wireName: 'tax_name2')
  String get defaultTaxName2;

  @nullable
  @BuiltValueField(wireName: 'tax_rate2')
  double get defaultTaxRate2;

  @nullable
  @BuiltValueField(wireName: 'tax_name3')
  String get defaultTaxName3;

  @nullable
  @BuiltValueField(wireName: 'tax_rate3')
  double get defaultTaxRate3;

  @nullable
  @BuiltValueField(wireName: 'payment_type_id')
  String get defaultPaymentTypeId;

  @nullable
  @BuiltValueField(wireName: 'enable_second_tax_rate')
  bool get enableSecondTaxRate;


  @nullable
  @BuiltValueField(wireName: 'invoice_fields')
  String get invoiceFields;

  @nullable
  @BuiltValueField(wireName: 'email_footer')
  String get emailFooter;

  @nullable
  @BuiltValueField(wireName: 'email_subject_invoice')
  String get emailSubjectInvoice;

  @nullable
  @BuiltValueField(wireName: 'email_subject_quote')
  String get emailSubjectQuote;

  @nullable
  @BuiltValueField(wireName: 'email_subject_payment')
  String get emailSubjectPayment;

  @nullable
  @BuiltValueField(wireName: 'email_template_invoice')
  String get emailBodyInvoice;

  @nullable
  @BuiltValueField(wireName: 'email_template_quote')
  String get emailBodyQuote;

  @nullable
  @BuiltValueField(wireName: 'email_template_payment')
  String get emailBodyPayment;

  @nullable
  @BuiltValueField(wireName: 'email_subject_reminder1')
  String get emailSubjectReminder1;

  @nullable
  @BuiltValueField(wireName: 'email_subject_reminder2')
  String get emailSubjectReminder2;

  @nullable
  @BuiltValueField(wireName: 'email_subject_reminder3')
  String get emailSubjectReminder3;

  @nullable
  @BuiltValueField(wireName: 'email_template_reminder1')
  String get emailBodyReminder1;

  @nullable
  @BuiltValueField(wireName: 'email_template_reminder2')
  String get emailBodyReminder2;

  @nullable
  @BuiltValueField(wireName: 'email_template_reminder3')
  String get emailBodyReminder3;

  @nullable
  @BuiltValueField(wireName: 'enable_portal_password')
  bool get enablePortalPassword;

  @nullable
  @BuiltValueField(wireName: 'send_portal_password')
  bool get sendPortalPassword;

  @nullable
  @BuiltValueField(wireName: 'signature_on_pdf')
  bool get signatureOnPdf;

  @nullable
  @BuiltValueField(wireName: 'enable_email_markup')
  bool get enableEmailMarkup;

  @nullable
  @BuiltValueField(wireName: 'show_accept_invoice_terms')
  bool get showAcceptInvoiceTerms;

  @nullable
  @BuiltValueField(wireName: 'show_accept_quote_terms')
  bool get showAcceptQuoteTerms;

  @nullable
  @BuiltValueField(wireName: 'require_invoice_signature')
  bool get requireInvoiceSignature;

  @nullable
  @BuiltValueField(wireName: 'require_quote_signature')
  bool get requireQuoteSignature;

  @nullable
  String get name;

  @nullable
  @BuiltValueField(wireName: 'company_logo')
  String get companyLogo;

  @nullable
  @BuiltValueField(wireName: 'website')
  String get website;

  @nullable
  String get address1;

  @nullable
  String get address2;

  @nullable
  String get city;

  @nullable
  String get state;

  @nullable
  @BuiltValueField(wireName: 'postal_code')
  String get postalCode;

  @nullable
  String get phone;

  @nullable
  String get email;

  @nullable
  @BuiltValueField(wireName: 'country_id')
  String get countryId;

  @nullable
  @BuiltValueField(wireName: 'vat_number')
  String get vatNumber;

  @nullable
  @BuiltValueField(wireName: 'id_number')
  String get idNumber;

  // TODO remove this field
  @nullable
  @BuiltValueField(wireName: 'custom_payment_terms')
  BuiltList<PaymentTermEntity> get customPaymentTerms;

  // TODO remove this field
  @nullable
  @BuiltValueField(wireName: 'has_custom_design1_HIDDEN')
  bool get hasCustomDesign1;

  // TODO remove this field
  @nullable
  @BuiltValueField(wireName: 'has_custom_design2_HIDDEN')
  bool get hasCustomDesign2;

  // TODO remove this field
  @nullable
  @BuiltValueField(wireName: 'has_custom_design3_HIDDEN')
  bool get hasCustomDesign3;

  bool get hasAddress => address1 != null && address1.isNotEmpty;

  bool get hasLogo => companyLogo != null && companyLogo.isNotEmpty;

  bool get hasTimezone => timezoneId != null && timezoneId.isNotEmpty;

  bool get hasDateFormat => dateFormatId != null && dateFormatId.isNotEmpty;

  bool get hasLanguage => languageId != null && languageId.isNotEmpty;

  bool get hasCurrency => currencyId != null && currencyId.isNotEmpty;

  bool get hasDefaultPaymentTypeId =>
      defaultPaymentTypeId != null && defaultPaymentTypeId.isNotEmpty;

  bool hasInvoiceField(String field,
      [EntityType entityType = EntityType.product]) {
    if (invoiceFields != null && invoiceFields.isNotEmpty) {
      return invoiceFields.contains('$entityType.$field');
    } else if (field == 'discount') {
      return false;
    } else {
      return true;
    }
  }

  static Serializer<SettingsEntity> get serializer =>
      _$settingsEntitySerializer;
}

abstract class UserItemResponse
    implements Built<UserItemResponse, UserItemResponseBuilder> {
  factory UserItemResponse([void updates(UserItemResponseBuilder b)]) =
      _$UserItemResponse;

  UserItemResponse._();

  UserEntity get data;

  static Serializer<UserItemResponse> get serializer =>
      _$userItemResponseSerializer;
}

abstract class CompanyItemResponse
    implements Built<CompanyItemResponse, CompanyItemResponseBuilder> {
  factory CompanyItemResponse([void updates(CompanyItemResponseBuilder b)]) =
      _$CompanyItemResponse;

  CompanyItemResponse._();

  CompanyEntity get data;

  static Serializer<CompanyItemResponse> get serializer =>
      _$companyItemResponseSerializer;
}
