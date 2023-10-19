part of '../update_helper.dart';

class _StatefulAlert extends StatefulWidget {
  const _StatefulAlert({
    required this.forceUpdate,
    required this.title,
    required this.content,
    required this.forceUpdateContent,
    required this.changelogs,
    required this.changelogsText,
    required this.okButtonText,
    required this.laterButtonText,
    required this.updatePlatformConfig,
    required this.currentVersion,
    required this.packageInfo,
    required this.failToOpenStoreError,
  });

  final bool forceUpdate;
  final String title;
  final String content;
  final String forceUpdateContent;
  final List<String> changelogs;
  final String changelogsText;
  final String okButtonText;
  final String laterButtonText;
  final UpdatePlatformConfig updatePlatformConfig;
  final String currentVersion;
  final PackageInfo packageInfo;
  final String failToOpenStoreError;

  @override
  State<_StatefulAlert> createState() => _StatefulAlertState();
}

class _StatefulAlertState extends State<_StatefulAlert> {
  String errorText = '';
  final updateHelper = UpdateHelper.instance;

  @override
  Widget build(BuildContext context) {
    return BoxWDialog(
      title: widget.title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            (widget.forceUpdate ? widget.forceUpdateContent : widget.content)
                .replaceAll('%currentVersion', widget.currentVersion)
                .replaceAll('%latestVersion',
                    widget.updatePlatformConfig.latestVersion!),
            style: const TextStyle(fontSize: 15),
          ),
          if (widget.changelogs.isNotEmpty) ...[
            const Divider(),
            Text(
              '${widget.changelogsText}:',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 4),
          ],
          if (widget.changelogs.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final text in widget.changelogs) ...[
                  Text(
                    '- $text',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                ]
              ],
            ),
          const SizedBox(height: 20),
          if (errorText.isNotEmpty)
            Text(
              widget.failToOpenStoreError.replaceAll('%error', errorText),
              style: const TextStyle(fontSize: 13, color: Colors.red),
            ),
          if (widget.changelogs.isNotEmpty) ...[
            const Divider(),
            Text(
              '${widget.changelogsText}:',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 4),
          ],
          if (widget.changelogs.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final text in widget.changelogs) ...[
                  Text(
                    '- $text',
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                ]
              ],
            ),
          // const SizedBox(height: 20),
          if (errorText.isNotEmpty)
            Text(
              widget.failToOpenStoreError.replaceAll('%error', errorText),
              style: const TextStyle(fontSize: 13, color: Colors.red),
            ),
        ],
      ),
      buttons: [
        Buttons(
          axis: Axis.horizontal,
          buttons: [
            BoxWButton(
              width: 100,
              child: Text(widget.okButtonText),
              onPressed: () async {
                String packageName = widget.packageInfo.packageName;

                // For testing
                if (updateHelper._isDebug && updateHelper.packageName != '') {
                  packageName = updateHelper.packageName;
                }

                try {
                  await openStoreImpl(
                    packageName,
                    widget.updatePlatformConfig.storeUrl,
                    (debugLog) {
                      updateHelper._print(debugLog);
                    },
                  );
                } catch (e) {
                  setState(() {
                    errorText = e.toString();
                  });
                }
              },
            ),
            if (!widget.forceUpdate)
              BoxWOutlinedButton(
                width: 100,
                child: Text(widget.laterButtonText),
                onPressed: () => Navigator.pop(context),
              )
          ],
        ),
      ],
    );
  }
}
