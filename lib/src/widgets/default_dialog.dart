part of '../update_helper.dart';

class DefaultUpdateHelperDialog extends StatefulWidget {
  const DefaultUpdateHelperDialog({super.key, required this.config});

  final DialogConfig config;

  @override
  State<DefaultUpdateHelperDialog> createState() =>
      _DefaultUpdateHelperDialogState();
}

class _DefaultUpdateHelperDialogState extends State<DefaultUpdateHelperDialog> {
  String errorText = '';

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = [
      TextButton(
        child: Text(widget.config.okButtonText),
        onPressed: () async {
          final errorText = await widget.config.onOkPressed();
          if (errorText != null) {
            setState(() {
              this.errorText = errorText;
            });
          }
        },
      ),
      if (!widget.config.forceUpdate)
        TextButton(
          onPressed: widget.config.onLaterPressed,
          child: Text(
            widget.config.laterButtonText,
            style: TextStyle(
              color: Theme.of(context).disabledColor,
            ),
          ),
        )
    ];

    final title = Text(widget.config.title);
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          (widget.config.forceUpdate
                  ? widget.config.forceUpdateContent
                  : widget.config.content)
              .replaceAll('%currentVersion', widget.config.currentVersion)
              .replaceAll('%latestVersion',
                  widget.config.updatePlatformConfig.latestVersion!),
          textAlign: TextAlign.center,
        ),
        if (widget.config.changelogs.isNotEmpty) ...[
          const Divider(),
          Text(
            widget.config.changelogsText,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (final text in widget.config.changelogs) ...[
                  Text(text, textAlign: TextAlign.center),
                  if (text != widget.config.changelogs.last)
                    const SizedBox(height: 4),
                ]
              ],
            ),
          ),
        ],
        if (errorText.isNotEmpty)
          Text(
            widget.config.failToOpenStoreError.replaceAll('%error', errorText),
            style: TextStyle(color: ColorScheme.of(context).error),
          )
      ],
    );

    return AlertDialog.adaptive(
      title: title,
      content: content,
      actions: actions,
    );
  }
}
