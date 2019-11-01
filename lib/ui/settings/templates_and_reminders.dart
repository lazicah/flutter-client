import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invoiceninja_flutter/constants.dart';
import 'package:invoiceninja_flutter/data/models/company_model.dart';
import 'package:invoiceninja_flutter/ui/app/form_card.dart';
import 'package:invoiceninja_flutter/ui/app/forms/app_dropdown_button.dart';
import 'package:invoiceninja_flutter/ui/app/forms/app_form.dart';
import 'package:invoiceninja_flutter/ui/app/forms/bool_dropdown_button.dart';
import 'package:invoiceninja_flutter/ui/app/forms/decorated_form_field.dart';
import 'package:invoiceninja_flutter/ui/settings/settings_scaffold.dart';
import 'package:invoiceninja_flutter/ui/settings/templates_and_reminders_vm.dart';
import 'package:invoiceninja_flutter/utils/completers.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TemplatesAndReminders extends StatefulWidget {
  const TemplatesAndReminders({
    Key key,
    @required this.viewModel,
  }) : super(key: key);

  final TemplatesAndRemindersVM viewModel;

  @override
  _TemplatesAndRemindersState createState() => _TemplatesAndRemindersState();
}

class _TemplatesAndRemindersState extends State<TemplatesAndReminders>
    with SingleTickerProviderStateMixin {
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _template = kEmailTemplateInvoice;
  FocusScopeNode _focusNode;
  TabController _controller;

  final _debouncer = Debouncer(milliseconds: 500);

  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();

  List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _focusNode = FocusScopeNode();
    _controller = TabController(vsync: this, length: 2);
    _controller.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.removeListener(_handleTabSelection);
    _controller.dispose();
    _controllers.forEach((dynamic controller) {
      controller.removeListener(_onChanged);
      controller.dispose();
    });
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _controllers = [
      _subjectController,
      _bodyController,
    ];

    _controllers
        .forEach((dynamic controller) => controller.removeListener(_onChanged));

    //_loadTemplate(kEmailTemplateInvoice);

    _controllers
        .forEach((dynamic controller) => controller.addListener(_onChanged));

    super.didChangeDependencies();
  }

  void _loadTemplate(String type) {
    final settings = widget.viewModel.settings;
    String body = '';
    String subject = '';

    if (type == kEmailTemplateInvoice) {
      subject = settings.emailSubjectInvoice;
      body = settings.emailBodyInvoice;
    } else if (type == kEmailTemplateQuote) {
      subject = settings.emailSubjectQuote;
      body = settings.emailBodyQuote;
    } else if (type == kEmailTemplatePayment) {
      subject = settings.emailSubjectPayment;
      body = settings.emailBodyPayment;
    } else if (type == kEmailTemplateReminder1) {
      subject = settings.emailSubjectReminder1;
      body = settings.emailBodyReminder1;
    } else if (type == kEmailTemplateReminder2) {
      subject = settings.emailSubjectReminder2;
      body = settings.emailBodyReminder2;
    } else if (type == kEmailTemplateReminder3) {
      subject = settings.emailSubjectReminder3;
      body = settings.emailBodyReminder3;
    }

    _bodyController.text = body;
    _subjectController.text = subject;
  }

  void _onChanged() {
    final String body = _bodyController.text.trim();
    final String subject = _subjectController.text.trim();
    SettingsEntity settings = widget.viewModel.settings;

    if (_template == kEmailTemplateInvoice) {
      settings = settings.rebuild((b) => b
        ..emailBodyInvoice = body
        ..emailSubjectInvoice = subject);
    } else if (_template == kEmailTemplateQuote) {
      settings = settings.rebuild((b) => b
        ..emailBodyQuote = body
        ..emailSubjectQuote = subject);
    } else if (_template == kEmailTemplatePayment) {
      settings = settings.rebuild((b) => b
        ..emailBodyPayment = body
        ..emailSubjectPayment = subject);
    } else if (_template == kEmailTemplateReminder1) {
      settings = settings.rebuild((b) => b
        ..emailBodyReminder1 = body
        ..emailSubjectReminder1 = subject);
    } else if (_template == kEmailTemplateReminder2) {
      settings = settings.rebuild((b) => b
        ..emailBodyReminder2 = body
        ..emailSubjectReminder2 = subject);
    } else if (_template == kEmailTemplateReminder3) {
      settings = settings.rebuild((b) => b
        ..emailBodyReminder3 = body
        ..emailSubjectReminder3 = subject);
    }

    if (settings != widget.viewModel.settings) {
      _debouncer.run(() {
        widget.viewModel.onSettingsChanged(settings);

        /*
      final str =
          '<b>${_subjectController.text.trim()}</b><br/><br/>${_bodyController.text.trim()}';
      final String contentBase64 =
          base64Encode(const Utf8Encoder().convert(str));
      final url = 'data:text/html;base64,$contentBase64';
      _webViewController.loadUrl(url);
       */
      });
    }
  }

  void _handleTabSelection() {
    print('### TAB CHANGED ##');
    //_webViewController.loadUrl(_getUrl(_template));
  }

  String _getUrl(String template) {
    final str =
        '<b>${_subjectController.text.trim()}</b><br/><br/>${_bodyController.text.trim()}';
    final String contentBase64 = base64Encode(const Utf8Encoder().convert(str));
    return 'data:text/html;base64,$contentBase64';
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final viewModel = widget.viewModel;
    final state = viewModel.state;
    final settings = viewModel.settings;

    return SettingsScaffold(
      title: localization.templatesAndReminders,
      onSavePressed: viewModel.onSavePressed,
      appBarBottom: TabBar(
        key: ValueKey(state.settingsUIState.updatedAt),
        controller: _controller,
        isScrollable: false,
        tabs: [
          Tab(
            text: localization.edit,
          ),
          Tab(
            text: localization.preview,
          ),
        ],
      ),
      body: AppTabForm(
        tabController: _controller,
        formKey: _formKey,
        focusNode: _focusNode,
        children: <Widget>[
          ListView(
            children: <Widget>[
              FormCard(children: <Widget>[
                AppDropdownButton(
                  labelText: localization.template,
                  value: _template,
                  showBlank: false,
                  onChanged: (value) => setState(() {
                    _template = value;
                    _loadTemplate(_template);
                  }),
                  items: kEmailTemplateTypes
                      .map((item) => DropdownMenuItem<String>(
                            child: Text(localization.lookup(item)),
                            value: item,
                          ))
                      .toList(),
                ),
                DecoratedFormField(
                  label: localization.subject,
                  controller: _subjectController,
                ),
                DecoratedFormField(
                  label: localization.body,
                  controller: _bodyController,
                  maxLines: 8,
                ),
              ]),
              if (_template == kEmailTemplateReminder1)
                ReminderSettings(
                  viewModel: viewModel,
                  enabled: settings.enableReminder1,
                  onChanged: (value) => viewModel.onSettingsChanged(
                      settings.rebuild((b) => b..enableReminder1 = value)),
                ),
              if (_template == kEmailTemplateReminder2)
                ReminderSettings(
                  viewModel: viewModel,
                  enabled: settings.enableReminder2,
                  onChanged: (value) => viewModel.onSettingsChanged(
                      settings.rebuild((b) => b..enableReminder2 = value)),
                ),
              if (_template == kEmailTemplateReminder3)
                ReminderSettings(
                  viewModel: viewModel,
                  enabled: settings.enableReminder3,
                  onChanged: (value) => viewModel.onSettingsChanged(
                      settings.rebuild((b) => b..enableReminder3 = value)),
                )
            ],
          ),
          TemplatePreview(_getUrl(_template)),
        ],
      ),
    );
  }
}

class ReminderSettings extends StatelessWidget {
  const ReminderSettings({this.viewModel, this.enabled, this.onChanged});

  final TemplatesAndRemindersVM viewModel;
  final bool enabled;
  final Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final state = viewModel.state;

    return FormCard(
      children: <Widget>[
        BoolDropdownButton(
          label: localization.sendEmail,
          showBlank: state.settingsUIState.isFiltered,
          value: enabled,
          onChanged: onChanged,
          iconData: FontAwesomeIcons.solidEnvelope,
        )
      ],
    );
  }
}

class TemplatePreview extends StatefulWidget {
  const TemplatePreview(this.html);

  final String html;

  @override
  _TemplatePreviewState createState() => _TemplatePreviewState();
}

class _TemplatePreviewState extends State<TemplatePreview>
    with AutomaticKeepAliveClientMixin<TemplatePreview> {
  WebViewController _webViewController;

  @override
  bool get wantKeepAlive => true;

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.html != oldWidget.html) {
      _webViewController.loadUrl(widget.html);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.all(15),
      child: WebView(
        debuggingEnabled: true,
        initialUrl: widget.html,
        onWebViewCreated: (WebViewController webViewController) {
          _webViewController = webViewController;
        },
        //onPageFinished: (String url) {},
        javascriptMode: JavascriptMode.disabled,
      ),
    );
  }
}
