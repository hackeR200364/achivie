import 'package:achivie/styles.dart';
import 'package:flutter/material.dart';

class HashtagAutocompleteOptions extends StatefulWidget {
  const HashtagAutocompleteOptions({
    Key? key,
    required this.query,
    required this.onHashtagTap,
    required this.token,
    required this.hashtags,
  }) : super(key: key);

  final String query, token;
  final ValueSetter<String> onHashtagTap;
  final List<String> hashtags;

  @override
  State<HashtagAutocompleteOptions> createState() =>
      _HashtagAutocompleteOptionsState();
}

class _HashtagAutocompleteOptionsState
    extends State<HashtagAutocompleteOptions> {
  // List<String> hashtags = [];
  int pageCount = 1, limitCount = 15;

  @override
  void initState() {
    // getUsrDetails();
    super.initState();
  }

  // void getUsrDetails() async {
  //   var uri = Uri.parse(
  //       "${Keys.apiReportsBaseUrl}/hashtags/autocomplete?q=${Uri.encodeComponent(widget.query)}&page=$pageCount&limit=$limitCount");
  //
  //   http.Response response = await http.get(
  //     uri,
  //     headers: {
  //       'content-Type': 'application/json',
  //       'authorization': 'Bearer ${widget.token}',
  //     },
  //   );
  //
  //   if (response.statusCode == 200) {
  //     log(response.body.toString());
  //     if (jsonDecode(response.body)["success"]) {
  //       Hashtags hashtagsLocal = hashtagsFromJson(response.body);
  //
  //       log(hashtagsLocal.message);
  //       hashtags = hashtagsLocal.hashtags;
  //     }
  //   }
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    // final hashtags = ;

    if (widget.hashtags.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: AppColors.white,
            child: ListTile(
              dense: true,
              horizontalTitleGap: 0,
              title: Text("Hashtags matching '${widget.query}'"),
            ),
          ),
          const Divider(height: 0),
          LimitedBox(
            maxHeight: MediaQuery.of(context).size.height * 0.3,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: widget.hashtags.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (context, i) {
                final hashtag = widget.hashtags.elementAt(i);
                return ListTile(
                  dense: true,
                  // leading: CircleAvatar(
                  //   backgroundColor: const Color(0xFFF7F7F8),
                  //   backgroundImage: NetworkImage(
                  //     hashtag.image,
                  //     scale: 0.5,
                  //   ),
                  // ),
                  title: Text('#$hashtag'),
                  // subtitle: Text(
                  //   hashtag.description,
                  //   maxLines: 1,
                  //   overflow: TextOverflow.ellipsis,
                  // ),
                  onTap: () => widget.onHashtagTap(hashtag),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
