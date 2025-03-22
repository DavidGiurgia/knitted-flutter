import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:validators/validators.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/screens/post/create_post/post_data.dart';

class PostLinkContent extends StatefulWidget {
  final VoidCallback resetPost;
  final PostData postData;
  final VoidCallback validatePost;

  const PostLinkContent({
    super.key,
    required this.resetPost,
    required this.postData,
    required this.validatePost,
  });

  @override
  State<PostLinkContent> createState() => _PostLinkContentState();
}

class _PostLinkContentState extends State<PostLinkContent> {
  bool _isValidUrl = false;
  PreviewData? _previewData;

  @override
  void initState() {
    super.initState();
    widget.postData.urlController.addListener(_validateUrl);
  }

  void _validateUrl() {
    setState(() {
      _isValidUrl = isURL(widget.postData.urlController.text);
      if (!_isValidUrl) {
        _previewData = null;
      }

      widget.validatePost();
    });
  }

  Future<void> _launchUrl() async {
    if (_isValidUrl) {
      final Uri url = Uri.parse(widget.postData.urlController.text);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch ${widget.postData.urlController.text}';
      }
    }
  }

  // Function to reset the post with confirmation
  void _resetPostWithConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Confirm"),
            content: const Text("Are you sure you want to remove this link?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(), // Cancel
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () {
                  widget.resetPost(); // Reset
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text("Remove"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: AppTheme.foregroundColor(context),
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.375,
    );
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: widget.postData.textController,
              onChanged: (value) {
                widget.validatePost(); // Adaugă această linie
              },
              decoration: const InputDecoration(
                hintText: "Add a comment...",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      widget.postData.urlController.text.isEmpty
                          ? widget.resetPost
                          : _resetPostWithConfirmation,
                  child: const Text(
                    "Remove link",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),

            TextField(
              controller: widget.postData.urlController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: Colors.red),
                ),
                errorText:
                    _isValidUrl || widget.postData.urlController.text.isEmpty
                        ? null
                        : "Invalid URL",
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                hintText: 'https://example.com',
                label: const Text("URL"),
              ),
            ),
            const SizedBox(height: 16),
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
                    text: widget.postData.urlController.text,
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
          ],
        ),
      ),
    );
  }
}
