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
  final updateHelper = UpdateHelper.instance;

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
          // width: 100,
          child: Text(
            widget.config.laterButtonText,
            style: TextStyle(
              color: Theme.of(context).disabledColor,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        )
    ];

    return AlertDialog.adaptive(
      title: Text(widget.config.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (widget.config.forceUpdate
                    ? widget.config.forceUpdateContent
                    : widget.config.content)
                .replaceAll('%currentVersion', widget.config.currentVersion)
                .replaceAll('%latestVersion',
                    widget.config.updatePlatformConfig.latestVersion!),
            style: const TextStyle(fontSize: 15),
            textAlign: TextAlign.left,
          ),
          if (widget.config.changelogs.isNotEmpty) ...[
            const Divider(),
            Text(
              '${widget.config.changelogsText}:',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final text in widget.config.changelogs) ...[
                  Text(
                    '- $text',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                ]
              ],
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
      actions: actions,
    );
  }
}
