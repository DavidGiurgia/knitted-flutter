import 'package:flutter/material.dart';
import 'package:zic_flutter/core/app_theme.dart';
import 'package:zic_flutter/core/models/poll.dart';
import 'package:zic_flutter/core/models/post.dart';

class PostPoll extends StatefulWidget {
  final Post post;
  final bool showResults;
  final int? userVotedOptionIndex;

  const PostPoll({
    super.key,
    required this.post,
    this.showResults = true,
    this.userVotedOptionIndex,
  });

  @override
  State<PostPoll> createState() => _PostPollState();
}

class _PostPollState extends State<PostPoll> {
  int? _localUserVotedOptionIndex;
  late List<PollOption> _pollOptions;
  late int _totalVotes;

  @override
  void initState() {
    super.initState();
    _localUserVotedOptionIndex = widget.userVotedOptionIndex;
    if (widget.post is PollPost) {
      _pollOptions = (widget.post as PollPost).options;
      _totalVotes = _calculateTotalVotes(_pollOptions);
    }
  }

  int _calculateTotalVotes(List<PollOption> options) {
    return options.fold(0, (sum, option) => sum + option.votes);
  }

  // String _getTimeLeft(DateTime endTime) {
  //   final now = DateTime.now();
  //   final difference = endTime.difference(now);

  //   if (difference.inDays > 0) {
  //     return '${difference.inDays}d left';
  //   } else if (difference.inHours > 0) {
  //     return '${difference.inHours}h left';
  //   } else if (difference.inMinutes > 0) {
  //     return '${difference.inMinutes}m left';
  //   } else {
  //     return 'Poll ended';
  //   }
  // }

  void _handleVote(int index) {
    setState(() {
      if (_localUserVotedOptionIndex == null) {
        _pollOptions[index].votes++;
        _totalVotes++;
        _localUserVotedOptionIndex = index;
        // Implement the actual vote submission to your backend here.
        // You'll likely need to call an API to update the vote count.
        // and add the user's vote to the list of voters for the option.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.post is! PollPost) {
      debugPrint("Post claims to be PollPost but isn't");
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 2),
        ..._pollOptions.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: PollOptionItem(
              option: entry.value,
              totalVotes: _totalVotes,
              showResults: widget.showResults,
              isSelected: entry.key == _localUserVotedOptionIndex,
              onTap: () => _handleVote(entry.key),
            ),
          ),
        ),
        if (_totalVotes > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              "$_totalVotes votes ", //• ${_getTimeLeft(widget.post.expiresAt ?? DateTime.now())}",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ),
      ],
    );
  }
}

class PollOptionItem extends StatelessWidget {
  final PollOption option;
  final int totalVotes;
  final bool showResults;
  final bool isSelected;
  final VoidCallback onTap;

  const PollOptionItem({
    super.key,
    required this.option,
    required this.totalVotes,
    required this.showResults,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = totalVotes > 0 ? (option.votes / totalVotes) : 0.0;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : AppTheme.isDark(context)
                  ? AppTheme.grey800
                  : AppTheme.grey100,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    option.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : null,
                        ),
                  ),
                ),
                if (showResults && totalVotes > 0)
                  Text(
                    '${(percentage * 100).round()}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                  ),
              ],
            ),
            if (showResults && totalVotes > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: percentage,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${option.votes} votes',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}