import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:validators/validators.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/screens/post/create_post/post_create_state.dart';
import 'package:zic_flutter/screens/shared/custom_toast.dart';

class PostLinkContent extends ConsumerStatefulWidget {
  const PostLinkContent({super.key});

  @override
  ConsumerState<PostLinkContent> createState() => _PostLinkContentState();
}

class _PostLinkContentState extends ConsumerState<PostLinkContent> {
  bool _isValidUrl = false;
  PreviewData? _previewData;

  @override
  void initState() {
    super.initState();
    ref
        .read(postCreationNotifierProvider)
        .urlController
        .addListener(_validateUrl);
    _validateUrl();
  }

  @override
  void dispose() {
    // Remove listener to prevent memory leaks
    ref
        .read(postCreationNotifierProvider)
        .urlController
        .removeListener(_validateUrl);
    super.dispose();
  }

  void _validateUrl() {
    final notifier = ref.read(postCreationNotifierProvider.notifier);
    final currentUrlText =
        ref.read(postCreationNotifierProvider).urlController.text;
    setState(() {
      _isValidUrl = isURL(currentUrlText);
      if (!_isValidUrl) {
        _previewData = null;
      }
      notifier.validatePost(); // Declanșează validarea globală
    });
  }

  Future<void> _launchUrl() async {
    final currentUrlText =
        ref.read(postCreationNotifierProvider).urlController.text;
    if (_isValidUrl) {
      final Uri url = Uri.parse(currentUrlText);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (context.mounted) {
          CustomToast.show(context, 'Could not launch $currentUrlText');
        }
      }
    }
  }

  // Function to reset the link-related data in the notifier
  void _resetLink() {
    final notifier = ref.read(postCreationNotifierProvider.notifier);
    // Resetează câmpurile relevante prin notifier
    notifier.updateField('url', '');
    notifier.updateField('selectedPostType', 'text');

    setState(() {
      _previewData = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Observă starea notifier-ului pentru a reacționa la schimbări
    final postCreationState = ref.watch(postCreationNotifierProvider);
    final currentUrlText = postCreationState.urlController.text;

    final style = TextStyle(
      color: AppTheme.foregroundColor(context),
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.375,
    );
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isValidUrl)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.0),
                color:
                    AppTheme.isDark(context)
                        ? AppTheme.grey900
                        : AppTheme.grey100,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: LinkPreview(
                  enableAnimation: true,
                  text: currentUrlText,
                  width: MediaQuery.of(context).size.width,
                  previewData: _previewData,
                  onPreviewDataFetched: (data) {
                    setState(() {
                      _previewData = data;
                    });
                  },
                  onLinkPressed: (url) => _launchUrl(),
                  openOnPreviewTitleTap: true,
                  openOnPreviewImageTap: true,
                  linkStyle: style,
                  metadataTextStyle: style.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  metadataTitleStyle: style.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  textStyle: style,
                ),
              ),
            ),
          const SizedBox(height: 16),

          TextField(
            controller: postCreationState.urlController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.red),
              ),
              errorText:
                  (postCreationState.validationMessage != null &&
                          postCreationState.validationMessage!.contains(
                            "URL",
                          ) &&
                          !postCreationState.isValid)
                      ? postCreationState.validationMessage
                      : (_isValidUrl || currentUrlText.isEmpty
                          ? null
                          : "Invalid URL"),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              hintText: 'https://example.com',
              label: const Text("URL"),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _resetLink,
                child: const Text(
                  "Remove link",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
