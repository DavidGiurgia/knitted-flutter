import 'package:flutter/material.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/link.dart';
import 'package:zic_flutter/core/models/post.dart';

class PostLinkPreview extends StatefulWidget {
  final Post post;

  const PostLinkPreview({super.key, required this.post});

  @override
  State<PostLinkPreview> createState() => _PostLinkPreviewState();
}

class _PostLinkPreviewState extends State<PostLinkPreview> {
  PreviewData? _previewData;

  @override
  Widget build(BuildContext context) {
    if (widget.post is! LinkPost) {
      debugPrint("Post claims to be LinkPost but isn't");
      return const SizedBox.shrink();
    }

    final linkPost = widget.post as LinkPost;
    final style = TextStyle(
      color: AppTheme.foregroundColor(context),
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.375,
    );

    return InkWell(
      onTap: () => _launchURL(context, linkPost.url),
      borderRadius: BorderRadius.circular(14.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.0),
          color: AppTheme.isDark(context) ? AppTheme.grey900 : AppTheme.grey100,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.0),
          child: LinkPreview(
            enableAnimation: true,
            text: linkPost.url,
            width: MediaQuery.of(context).size.width,
            onLinkPressed: (url) => _launchURL(context, url),
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
            previewData: _previewData,
            onPreviewDataFetched: (data) {
              setState(() {
                _previewData = data;
              });
            },
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid URL')),
    );
    return;
  }
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch URL')));
    }
  } catch (e) {
    debugPrint("Error launching URL: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')));
  }
}
}